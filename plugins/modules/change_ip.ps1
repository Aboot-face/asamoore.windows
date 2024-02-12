#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        interface_alias = @{ type = "str"; required = $true }
        ip_address = @{ type = "str"; required = $true }
        subnet_prefix_length = @{ type = "int"; required = $true }
        gateway = @{ type = "str"; required = $false }
        dns_servers = @{ type = "list"; elements = "str"; required = $false }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

function Set-NetworkConfiguration {
    param(
        [Ansible.Basic.AnsibleModule]$Module,
        [string]$InterfaceAlias,
        [string]$IPAddress,
        [int]$SubnetPrefixLength,
        [string]$Gateway,
        [string[]]$DnsServers
    )

    # Check if the desired IP configuration already exists
    $existingIP = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -eq $IPAddress -and $_.PrefixLength -eq $SubnetPrefixLength
    }

    if ($existingIP) {
        # The exact desired configuration already exists, no changes needed
        $Module.Result['changed'] = $false
        $Module.ExitJson()
        return
    }

    # Remove conflicting IP configurations if necessary
    $conflictingIPs = Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -ne $IPAddress
    }
    
    foreach ($ip in $conflictingIPs) {
        try {
            Remove-NetIPAddress -IPAddress $ip.IPAddress -PrefixLength $ip.PrefixLength -InterfaceAlias $InterfaceAlias -Confirm:$false -ErrorAction Stop
        }
        catch {
            $module.FailJson("Failed to remove existing IP address $($ip.IPAddress): $_")
        }
    }


    # Now, safe to apply the new IP configuration
    New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $SubnetPrefixLength -ErrorAction Stop

    if ($Gateway) {
        $existingRoute = Get-NetRoute -InterfaceAlias $InterfaceAlias -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
        if ($existingRoute) {
            # Remove existing default gateway if different
            if ($existingRoute.NextHop -ne $Gateway) {
                Remove-NetRoute -InterfaceAlias $InterfaceAlias -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction Stop
                New-NetRoute -InterfaceAlias $InterfaceAlias -DestinationPrefix "0.0.0.0/0" -NextHop $Gateway -ErrorAction Stop
            }
        }
        else {
            New-NetRoute -InterfaceAlias $InterfaceAlias -DestinationPrefix "0.0.0.0/0" -NextHop $Gateway -ErrorAction Stop
        }
    }

    if ($DnsServers) {
        try {
            Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServers -ErrorAction Stop
        }
        catch {
            $Module.FailJson($_.Exception.Message)
        }

    # Example of setting changed status and exiting
    $module.Result['changed'] = $true
    $module.ExitJson()
    
    # Example of handling an exception and failing the module
    catch {
        $errorMessage = $_.Exception.Message
        $module.FailJson($errorMessage)
    }

}

Set-NetworkConfiguration -Module $module `
                         -InterfaceAlias $module.Params.interface_alias `
                         -IPAddress $module.Params.ip_address `
                         -SubnetPrefixLength $module.Params.subnet_prefix_length `
                         -Gateway $module.Params.gateway `
                         -DnsServers $module.Params.dns_servers

