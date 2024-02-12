#!/usr/bin/powershell
# Copyright (2022, Your Name)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        ip = @{
            required = $true
            type = 'str'
        }
        port = @{
            required = $true
            type = 'int'
        }
        sign_windows = @{
            type = 'bool'
            default = $false
        }
        sign_office = @{
            type = 'bool'
            default = $false
        }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

function Set-SlmService {
    param(
        [String]$ip,
        [Int]$port
    )
    cscript.exe %windir%\System32\slmgr.vbs -skms $ip,$port
}

function Activate-Windows {
    cscript.exe %windir%\System32\slmgr.vbs -ato
}

function Activate-Office {
    param(
        [String]$ip,
        [Int]$port
    )
    cscript.exe "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs" /sethst:$ip
    cscript.exe "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs" /setprt:$port
    cscript.exe "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs" /act
}

try {
    $slmgrPath = "%windir%\System32\slmgr.vbs" 
    if (-Not (Test-Path -Path $slmgrPath -PathType Leaf)) {
        throw "SLMGR Script file not found at path: $slmgrPath"
    }

    Set-SlmService -ip $module.Params.ip -port $module.Params.port

    if ($module.Params.sign_windows) {
        Activate-Windows
    }

    if ($module.Params.sign_office) {
    	$osppPath = "%ProgramFiles%\Microsoft Office\Office16\ospp.vbs"  
        if (-Not (Test-Path -Path $osppPath -PathType Leaf)) {
            throw "OSPP Script file not found at path: $osppPath"
        }
        Activate-Office -ip $module.Params.ip -port $module.Params.port
    }

    $module.ExitJson(@{ changed = $true; message = "SLM service assigned and activation attempted as specified." })
} catch {
    $module.FailJson("Failed to execute module: $($_.Exception.Message)")
}

