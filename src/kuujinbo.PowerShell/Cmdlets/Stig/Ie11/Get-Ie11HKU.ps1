<#
.SYNOPSIS
    Get HKU registry rules
#>
function Get-Ie11HKU {
    [CmdletBinding()]
    param( )

    @{
        'SV-59341r4_rule' = @("Registry::HKEY_USERS\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing Criteria", 'State', '0x23C00');
    };
}