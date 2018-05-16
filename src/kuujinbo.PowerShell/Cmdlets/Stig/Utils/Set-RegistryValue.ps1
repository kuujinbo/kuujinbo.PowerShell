<#
.SYNOPSIS
    Set registry key value
.DESCRIPTION
    The Set-RegistryValue cmdlet adds or updates a registry key value from
    the supplied parameters.
.EXAMPLE
    $registryPath = 'HKCU:\Software\Testing\TestPath';
    $registryName = 'Version';
    $registryType = 'DWORD';
    $registryValue = 25;
    Set-RegistryValue $registryPath $Name $registryType $registryValue;
#>
function Set-RegistryValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$path
        , [Parameter(Mandatory)] [string]$valueName
        , [Parameter(Mandatory)] [string]$valueType
        , [Parameter(Mandatory)] $value
    );

    if (!(Test-Path -LiteralPath $path)) {
        New-Item -Path $path -Force | Out-Null;
    } 
    New-ItemProperty -Path $path -Name $valueName `
        -PropertyType $valueType -Value $value `
        -Force | Out-Null;
}