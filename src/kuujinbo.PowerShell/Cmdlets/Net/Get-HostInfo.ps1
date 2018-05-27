<#
.SYNOPSIS
    Get host info.
#>
function Get-HostInfo {
    $hostname = $env:COMPUTERNAME;
    $adapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration `
        -Filter "IPEnabled='True'" `
        -ComputerName $hostname `
    | where { $_.DefaultIPGateway -ne $null; };

    return @{
        'hostname' = $hostname;
        'fqdn' = [System.Net.Dns]::GetHostEntry($hostname).HostName;
        'ipaddress' = $adapters.IPAddress[0];
        'macaddress' = $adapters.MACAddress;
    }
}