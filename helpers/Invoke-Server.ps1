function Invoke-Server
{
<#
.SYNOPSIS
    Quick Python HTTP server

.DESCRIPTION
    Invoke-Server is a helper function that allows for spinning up
    a Python HTTP server given the provided arguments

.PARAMETER directory
    Directory to serve
    Alias: d

.PARAMETER port
    Server port
    Alias: p

.PARAMETER bind
    Bind address
    Alias: b

.PARAMETER pcb
    Suppresses netcat reminder if selected payload
    is a powercat bind shell

.EXAMPLE
    Invoke-Server -d $env:HOME/share -b 172.16.20.10 -p 80
#>
  param (

    [Parameter(Mandatory = $false)]
    [Alias("d")]
    [String]$directory = '.',

    [Parameter(Mandatory = $false)]
    [Alias("p")]
    [String]$port = '80',

    [Parameter(Mandatory = $false)]
    [Alias("b")]
    [String]$bind = '0.0.0.0',

    [Parameter(Mandatory = $false)]
    [Switch]$pcb = $false

    )

    Write-Output ""
    Write-Host "[!] Starting HTTP server on $interface port $srvport" -ForegroundColor Green
    Write-Host "[!] Currently serving: $directory"
    Write-Host "[!] Ctrl+C terminates the server" -ForegroundColor Magenta
    Write-Output ""
    if ( !$pcb ) {
      Write-Warning "Do not forget to start a netcat listener on port $lport"
    }
    if ( $directory -like "*/PSX/extensions" ) {
      # Automation sauce for Invoke-ConPtyShell
      Write-Prompts -m "`$ nc -lnvp $lport -c 'stty raw -echo; fg; reset'" -t w
    }
    else {
      if ( !$pcb ) {
        Write-Prompts -m "`$ nc -lnvp $lport" -t w
      }
    }
    python3 -m http.server -b $bind -d $directory $port
}

Export-ModuleMember -Function Invoke-Server

