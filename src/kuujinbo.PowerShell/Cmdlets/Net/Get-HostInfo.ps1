<#
.SYNOPSIS
    Get STIG host info.
#>
function Get-HostInfo {
    $hostname = $env:COMPUTERNAME;

    return @{
        'hostname' = $hostname;
        'fqdn' = [System.Net.Dns]::GetHostEntry($hostname).HostName;
        'ipaddress' = [System.Net.Dns]::GetHostEntry($hostname).AddressList[0].IpAddressToString;
        'macaddress' = (Get-WmiObject -ClassName Win32_NetworkAdapterConfiguration `
                        -Filter "IPEnabled='True'" -ComputerName $env:COMPUTERNAME `
                        | select -Property MACAddress
        ).MACAddress;
    }
}