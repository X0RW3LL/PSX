function Sync-PSX
{
<#
.SYNOPSIS
    Auto-update PSX from GitHub

.DESCRIPTION
    Sync-PSX handles synchronizing PSX with the remote repo
    anywhere in the filesystem straight from PowerShell, bypassing
    the need for navigating to the PSModulePath/PSX
#>

    Write-Prompts -m "[!] Checking for PSX updates"
    $remotes = /usr/bin/git -C "$env:HOME/.local/share/powershell/Modules/PSX" pull --dry-run
    if ( $remotes ) {
        Write-Prompts -m "[!] Found new updates. Pulling from remote repository..."
        $output = /usr/bin/git -C "$env:HOME/.local/share/powershell/Modules/PSX" pull
        if ( $? ) {
            Write-Prompts -m "[+] PSX updated successfully. Restart the current PowerShell session for changes to take effect." -t s
        }
        else {
            Write-Prompts -m "[-] PSX update failed" -t e
        }
    }
    elseif ( !$? ) {
        Write-Prompts -m "[-] PSX update failed. Check your local repository for unstaged commits" -t e
    }
    else {
        Write-Prompts -m "[+] PSX is already up to date" -t s
    }
}

Export-ModuleMember -Function Sync-PSX

