#
# Module manifest for module 'PSX'
#
# Generated by: X0RW3LL
#
# Generated on: 8/6/2023
#

@{
RootModule = 'PSX.psm1'
ModuleVersion = '1.0'
GUID = '62be925a-e6c0-42be-9ed6-80a352c5860d'
Author = 'X0RW3LL'
Copyright = '(c) X0RW3LL. All rights reserved.'
Description = 'PSX provides a collection of the most common operations that rely on PowerShell like encoding, hosting and converting powershell payloads'
NestedModules = @(
                    "$env:HOME/.local/share/powershell/Modules/PSX/helpers/Invoke-Server.ps1",
                    "$env:HOME/.local/share/powershell/Modules/PSX/helpers/Invoke-B64.ps1"
                    "$env:HOME/.local/share/powershell/Modules/PSX/helpers/Write-Prompts.ps1"
                    "$env:HOME/.local/share/powershell/Modules/PSX/helpers/Get-InterfaceAddress.ps1"
                    )
FunctionsToExport = @('Convert-Shell','Invoke-B64','Invoke-Server','Get-InterfaceAddress')
AliasesToExport = @('cvsh','ib64')
# HelpInfoURI = ''
}

