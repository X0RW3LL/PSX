function Get-InterfaceAddress {

<#

.SYNOPSIS
    Return IPv4 address of a given network interface

.Description
    This function uses iproute2 to translate interface
    names to IPv4 addresses

.Parameter Interface
    Interface name
    Alias: i

.INPUTS
    String interface name

.Outputs
    String IPv4 address

#>
    param (

      [Parameter(Mandatory = $true)]
      [ValidateSet("eth0", "wlan0", "tun0", "lo")
      [Alias("i")]
      [String]$Interface = "tun0"

    )

    return /usr/sbin/ip -o a show $Interface | /usr/bin/awk -F ' *|/' '{print $4}' | /usr/bin/grep -v ':'

}

Export-ModuleMember -Function Get-InterfaceAddress

