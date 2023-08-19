function Write-Prompts
{
    param (
        
        [Parameter(Mandatory = $false)]
        [Alias("t")]
        [String]$Type,

        [Parameter(Mandatory = $false)]
        [Alias("p")]
        [String]$Payload = 'powershell -nop -ep unrestricted -w hidden -e',
        
        [Parameter(Mandatory = $false)]
        [Alias("s")]
        [String]$Str = '',

        [Parameter(Mandatory = $false)]
        [Alias("m")]
        [String]$Message = ''
        
        )

    switch ( $Type ) {
        'po' {
            $enc = Invoke-B64 $Str -Internal
            Set-Clipboard -Value ($Payload + ' ' + $enc)
            Write-Output ""
            Write-Host "[!] Plaintext payload:" -ForegroundColor DarkCyan
            Write-Host "----------------------" -ForegroundColor DarkCyan
            Write-Host $Payload `"$Str`" -ForegroundColor DarkCyan
            Write-Output ""
            
            Write-Host "[+] Encoded payload (copied to clipboard):" -ForegroundColor Green
            Write-Host "------------------------------------------" -ForegroundColor Green
            Write-Host $Payload $enc -ForegroundColor Green
            Write-Output ""
        }
        's' {
            Write-Output ""
            Write-Host $Message -ForegroundColor Green
            Write-Output ""
        }
        'e' {
            Write-Output ""
            Write-Host $Message -ForegroundColor Red
            Write-Output ""
        }
        'w' {
            Write-Output ""
            Write-Host $Message -ForegroundColor Yellow
            Write-Output ""
        }
        default {
            Write-Output ""
            Write-Host $Message
            Write-Output ""
        }
    }
}

Export-ModuleMember -Function Write-Prompts
