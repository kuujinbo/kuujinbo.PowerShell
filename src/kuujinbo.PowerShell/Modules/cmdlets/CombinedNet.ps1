function Get-FQDN {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$hostname
    );

    [System.Net.Dns]::GetHostEntry($hostname).HostName;
}

function Get-IpAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$hostname
    );

    [System.Net.Dns]::GetHostEntry($hostname).AddressList[0].IpAddressToString;
}

function Get-MacAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$hostname
    );

    (Get-WmiObject -ClassName Win32_NetworkAdapterConfiguration `
        -Filter "IPEnabled='True'" -ComputerName $args[0] `
        | select -Property MACAddress).MACAddress;
}