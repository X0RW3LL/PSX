function Write-Prompts
{
    param (
        
        [Parameter(Mandatory = $false)]
        [Alias("t")]
        [String]$type,

        [Parameter(Mandatory = $false)]
        [Alias("p")]
        [String]$payload = 'powershell -nop -ep unrestricted -w hidden -e',
        
        [Parameter(Mandatory = $false)]
        [Alias("s")]
        [String]$str = '',

        [Parameter(Mandatory = $false)]
        [Alias("m")]
        [String]$message = ''
        
        )

    switch ( $type ) {
        'po' {
            $enc = Invoke-B64 $str -internal
            Set-Clipboard -Value ($payload + ' ' + $enc)
            Write-Output ""
            Write-Host "[!] Plaintext payload:" -ForegroundColor DarkCyan
            Write-Host "----------------------" -ForegroundColor DarkCyan
            Write-Host $payload `"$str`" -ForegroundColor DarkCyan
            Write-Output ""
            
            Write-Host "[+] Encoded payload (copied to clipboard):" -ForegroundColor Green
            Write-Host "------------------------------------------" -ForegroundColor Green
            Write-Host $payload $enc -ForegroundColor Green
            Write-Output ""
        }
        's' {
            Write-Output ""
            Write-Host $message -ForegroundColor Green
            Write-Output ""
        }
        'e' {
            Write-Output ""
            Write-Host $message -ForegroundColor Red
            Write-Output ""
        }
        'w' {
            Write-Output ""
            Write-Host $message -ForegroundColor Yellow
            Write-Output ""
        }
        default {
            Write-Output ""
            Write-Host $message
            Write-Output ""
        }
    }
}

Export-ModuleMember -Function Write-Prompts
