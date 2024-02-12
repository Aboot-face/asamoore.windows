#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

$params = @{
    src = @{ type = "str"; required = $true }
    dest = @{ type = "str"; required = $true }
    recursive = @{ type = "bool"; required = $false; default = $false }
    force = @{ type = "bool"; required = $false; default = $false }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

$src = $module.Params.src
$dest = $module.Params.dest
$recursive = $module.Params.recursive
$force = $module.Params.force

function Test-CopyNeeded {
    param (
        [String]$SourcePath,
        [String]$DestinationPath,
        [Boolean]$Recursive
    )

    if (-Not (Test-Path -Path $DestinationPath)) {
        return $true
    }

    if ($Recursive) {
        $sourceItems = Get-ChildItem -Path $SourcePath -Recurse
        $destItems = Get-ChildItem -Path $DestinationPath -Recurse

        if ($sourceItems.Count -ne $destItems.Count) {
            return $true
        }

        foreach ($item in $sourceItems) {
            $destItemPath = $item.FullName.Replace($SourcePath, $DestinationPath)
            if (-Not (Test-Path -Path $destItemPath)) {
                return $true
            }
            if ((Get-FileHash $item.FullName).Hash -ne (Get-FileHash $destItemPath).Hash) {
                return $true
            }
        }
    } else {
        $sourceHash = (Get-FileHash -Path $SourcePath).Hash
        $destHash = (Get-FileHash -Path $DestinationPath).Hash
        if ($sourceHash -ne $destHash) {
            return $true
        }
    }

    return $false
}

$copyNeeded = Test-CopyNeeded -SourcePath $src -DestinationPath $dest -Recursive $recursive

if ($copyNeeded -or $force) {
    $copyParams = @{
        Path = $src
        Destination = $dest
        ErrorAction = "Stop"
    }

    if ($recursive) {
        $copyParams.Recurse = $true
    }

    try {
        Copy-Item @copyParams
        $module.ExitJson(@{ changed = $true; msg = "Copy operation performed." })
    } catch {
        $module.FailJson($_.Exception.Message)
    }
} else {
    $module.ExitJson(@{ changed = $false; msg = "Copy operation not needed." })
}

