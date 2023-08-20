function Set-PSXAutomation
{
<#
.SYNOPSIS
    Sets PSX automation on/off

.DESCRIPTION
    This function handles toggling PSX's automation
    feature (automatically starting netcat listeners)
    on/off

.PARAMETER On
    Enables automation
    This is the default switch

.PARAMETER Off
    Disables automation

.INPUTS
    Switch

.EXAMPLE
    Set-PSXAutomation

.EXAMPLE
    Set-PSXAutomation -Off
#>
    param (
        [Switch]$On,
        [Switch]$Off = $false
        )
    if ( $env:XDG_SESSION_TYPE -eq 'x11' ) {
        if ( !$Off ) {
            $depends = $conf.Preferences.Automation.Depends
            if ( /usr/bin/which $depends ) {
                $conf.Preferences.Automation.Enabled = $true
                $conf.Dependencies.System | Where-Object Package -Like 'xdotool' | ? { $_.Status = "OK" }
                $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
            }
            else {
                $confirmInstall = Read-Host -Prompt @"

[-] Automation depends on xdotool, which is not installed.
    If you confirm the installation, PowerShell will run
    /usr/bin/sudo apt-get install -y xdotool and the output
    will not be sent to STDOUT. Download is only 55.6kB, so
    it should not take long.
    
    Would you like to install xdotool now? (Y/n)
"@
                if ( !$confirmInstall -or $confirmInstall.ToLower() -eq 'y' ) {
                    $InformationPreference = "Continue"
                    $install = /usr/bin/sudo /usr/bin/apt-get install -y xdotool
                    $conf.Preferences.Automation.Enabled = $true
                    $conf.Dependencies.System | Where-Object Package -eq 'xdotool' | ? { $_.Status = "OK" }
                    $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
                    Write-Host -m @"

[+] xdotool installed successfully. Automation is now enabled

"@ -ForegroundColor Green
            }
                else {
                    $conf.Preferences.Automation.Enabled = $false
                    $conf.Dependencies.System | Where-Object Package -eq 'xdotool' | ? { $_.Status = "" }
                    $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
                    Write-Host -m @"

[-] Aborting. Automation will remain disabled

"@ -ForegroundColor Red
                }
            }
        }
        else {
            $conf.Preferences.Automation.Enabled = $false
            $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
        }
    }
    else {
        Write-Prompts -m "[-] Automation feature is not supported on non-X11 environments" -t e
    }
}

Export-ModuleMember -Function Set-PSXAutomation

