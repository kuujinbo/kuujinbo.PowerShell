<#
.SYNOPSIS
    Get registry rules => Version: 1, Release: 4, 27 Jul 2018
.NOTES
    For each registry key path, a user SID or SamAccountName will be appended
    to 'HKEY_USERS\' in /Cmdlets/Registry/Get-RegistryResults.ps1
.EXAMPLE
    Get-RegistryResults -getHku -rules (Get-ReaderDcClassicHKU -version 2017);
#>
function Get-ReaderDcClassicHKU {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [int]$version
    )

    @{
        'V-65807' = @("Registry::HKEY_USERS\Software\Adobe\Acrobat Reader\$version\Security\cDigSig\cEUTLDownload", 'bLoadSettingsFromURL', '0');
        'V-65809' = @("Registry::HKEY_USERS\Software\Adobe\Acrobat Reader\$version\Security\cDigSig\cAdobeDownload", 'bLoadSettingsFromURL', '0');
        'V-65813' = @("Registry::HKEY_USERS\Software\Adobe\Acrobat Reader\$version\AVGeneral", 'bFIPSMode', '1');
    };
}