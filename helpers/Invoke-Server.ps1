function Invoke-Server
{
<#
.SYNOPSIS
    Quick Python HTTP server

.DESCRIPTION
    Invoke-Server is a helper function that allows for spinning up
    a Python HTTP server given the provided arguments

.PARAMETER Directory
    Directory to serve
    Alias: d

.PARAMETER Port
    Server port
    Alias: p

.PARAMETER Bind
    Bind address
    Alias: b

.PARAMETER PCB
    Suppresses netcat reminder if selected payload
    is a powercat bind shell

.PARAMETER Shell
    Shell type (powercat|conpty)
    Used to issue the correct command for each
    shell type

.EXAMPLE
    Invoke-Server -d $env:HOME/share -b 172.16.20.10 -p 80
#>
  param (

    [Parameter(Mandatory = $false)]
    [Alias("d")]
    [String]$Directory = '.',

    [Parameter(Mandatory = $false)]
    [Alias("p")]
    [String]$Port = '80',

    [Parameter(Mandatory = $false)]
    [Alias("b")]
    [String]$Bind = '0.0.0.0',

    [Parameter(Mandatory = $false)]
    [Switch]$PCB = $false,

    [Parameter(Mandatory = $false)]
    [String]$Shell = 'powercat'

    )
    $automation = $conf.Preferences.Automation.Enabled
    Write-Output ""
    Write-Host "[!] Starting HTTP server on $Interface port $Srvport" -ForegroundColor Green
    Write-Host "[!] Currently serving: $Directory"
    Write-Host "[!] Ctrl+C terminates the server" -ForegroundColor Magenta
    Write-Output ""
    if ( !$PCB ) {
      if ( !$automation ) {
        Write-Warning "Do not forget to start a netcat listener on port $LPORT"
      }
    }
    if ( $Shell -eq "conpty" ) {
      if ( !$automation ) {
        Write-Prompts -m "`$ stty raw -echo; nc -lnvp $LPORT`; stty raw echo" -t w
      }
      # Automation sauce for Invoke-ConPtyShell
      if ( ($env:XDG_SESSION_TYPE -eq 'x11') -and $automation ) {
        $depends = ($conf.Dependencies.System | Where-Object Package -eq "xdotool").Package
        if ( /usr/bin/which $depends ) {
          /usr/bin/xdotool key "ctrl+shift+t"; /usr/bin/xdotool type "clear"; /usr/bin/xdotool key Return; /usr/bin/xdotool type "stty raw -echo; nc -lnvp $LPORT`; stty raw echo"; /usr/bin/xdotool key Return
        }
        else {
          Set-PSXAutomation -On
        }
      }
    }
    else {
      if ( !$PCB ) {
        if ( !$automation ) {
            Write-Prompts -m "`$ nc -lnvp $LPORT" -t w
          }
        else {
          if ( ($env:XDG_SESSION_TYPE -eq 'x11') ) {
            $depends = ($conf.Dependencies.System | Where-Object Package -eq "xdotool").Package
            if ( /usr/bin/which $depends ) {
              /usr/bin/xdotool key "ctrl+shift+t"; /usr/bin/xdotool type "clear"; /usr/bin/xdotool key Return; /usr/bin/xdotool type "nc -lnvp $LPORT"; /usr/bin/xdotool key Return
            }
            else {
              Set-PSXAutomation -On
            }
          }
        }
      }
    }
    /usr/bin/env python3 -m http.server -b $Bind -d $Directory $Port
}

Export-ModuleMember -Function Invoke-Server

