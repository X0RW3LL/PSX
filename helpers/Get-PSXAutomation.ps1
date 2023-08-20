function Get-PSXAutomation
{
<#
.SYNOPSIS
    Gets PSX automation status

.DESCRIPTION
    This function queries PSX's automation feature
    (automatically starting netcat listeners) status
#>
    if ( $env:XDG_SESSION_TYPE -eq 'x11' ) {
        $conf.Preferences.Automation
    }
    else {
        Write-Prompts -m "[-] Automation feature is not supported on non-X11 environments" -t e
    }
}

Export-ModuleMember -Function Get-PSXAutomation

