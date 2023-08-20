# Initial configuration

$rootWarn=@"

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@           HERE COMES THE BIG BRIGHT RED WARNING           @
@           -------------------------------------           @
@                                                           @
@ [!] WARNING: ROOT SHELL DETECTED!                         @
@ --------------------------------------------------------- @
@ [!] ENFORCED ACTION: FAILURE; EXIT(1)                     @
@ --------------------------------------------------------- @
@ [!] RECOMMENDED ACTION: DROP TO A STANDARD USER SHELL     @
@ --------------------------------------------------------- @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

"@

# Seriously. Stop.
if ( $env:USER -eq "root" ) {
Write-Host $rootWarn -ForegroundColor Red
exit(1)
}


# Read config template
$conf_template = Get-Content $env:HOME/.local/share/powershell/Modules/PSX/.config/config_template.json -raw | ConvertFrom-JSON
$conf = Get-Content $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json -raw -ErrorAction SilentlyContinue | ConvertFrom-JSON

if ( $conf ) {
    $conf_template = $conf
}

# First run boilerplate
# Checks for xdotool, installs the package if not found
# and updates configs
if ( $conf_template.initRun -and $env:XDG_SESSION_TYPE -eq "x11" ) {

    $confirm = Read-Host -Prompt @"

[!] First run detected. PSX is all about automation.
    This prompt will only show up this one time, but
    preferences can either be manually tweaked by editing
    $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
    or by issuing Set-PSXAutomation -On|-Off

    Would you like to continue? (Y/n)
"@
    if ( !$confirm -or $confirm.ToLower() -eq "y" ) {
        $depends = $conf_template.Preferences.Automation.Depends
        if ( /usr/bin/which $depends ) {
            $conf_template.Preferences.Automation.Enabled = $true
            $conf_template.Dependencies.System | Where-Object Package -eq "xdotool" | ? { $_.Status = "OK" }
            $conf_template | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
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
            if ( !$confirmInstall -or $confirmInstall.ToLower() -eq "y" ) {
                $InformationPreference = "Continue"
                $install = /usr/bin/sudo /usr/bin/apt-get install -y xdotool
                $conf_template.Preferences.Automation.Enabled = $true
                $conf_template.Dependencies.System | Where-Object Package -eq "xdotool" | ? { $_.Status = "OK" }
                $conf_template | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
                Write-Host -m @"

[+] xdotool installed successfully. Automation is now enabled

"@ -ForegroundColor Green
            }
            else {
                $conf = $conf_template
                $conf.initRun = $false
                $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
                Write-Host -m @"

[-] Aborting. Automation will remain disabled

"@ -ForegroundColor Red
            }
        }
    }
    else {
        $conf = $conf_template
        $conf.initRun = $false
        $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
        Write-Host -m @"

[-] Aborting. Automation will remain disabled

"@ -ForegroundColor Red
    }

    $conf = Get-Content $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json -raw | ConvertFrom-JSON
    $conf.initRun = $false
    $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
}
else {
    $conf = $conf_template
    $conf.initRun = $false
    $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json
}

