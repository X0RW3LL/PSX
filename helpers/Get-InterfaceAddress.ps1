function Get-InterfaceAddress {

<#

.SYNOPSIS
    Return IPv4 address of a given network interface

.Description
    This function uses iproute2 to translate interface
    names to IPv4 addresses

.Parameter interface
    Interface name
    Alias: i

.INPUTS
    String interface name

.Outputs
    String IPv4 address

#>
    param (

      [Parameter(Mandatory = $true)]
      [Alias("i")]
      [String]$interface = "tun0"

    )

    return ip -o a show $interface | awk -F ' *|/' '{print $4}' | grep -v ':'

}

Export-ModuleMember -Function Get-InterfaceAddress

