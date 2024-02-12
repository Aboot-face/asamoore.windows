#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

$params = @{
    path = @{ type = "str"; required = $true }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

try {
    $scriptPath = $module.Params.path
    if (-Not (Test-Path -Path $scriptPath -PathType Leaf)) {
        throw "Script file not found at path: $scriptPath"
    }

    $scriptContent = Get-Content -Path $scriptPath -Raw
    Invoke-Expression -Command $scriptContent

    $module.ExitJson(@{ msg = "Script executed successfully."; changed = $true })
} catch {
    $module.FailJson($_.Exception.Message)
}

