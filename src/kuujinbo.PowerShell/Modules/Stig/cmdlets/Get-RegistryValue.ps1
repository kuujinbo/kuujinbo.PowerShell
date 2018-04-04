<#
.SYNOPSIS
    Get registry value
.DESCRIPTION
    The Get-RegistryValue cmdlet gets a registry value from the supplied path
    and value name.
.NOTES
    Caller **MUST** check return value if testing for the existence of the
    value name; if does not exist will be $null.
#>
function Get-RegistryValue {
    param(
        [Parameter(Mandatory)] [string]$path
        , [Parameter(Mandatory)] [string]$valueName
    );
    if (Test-Path -LiteralPath $path) {
        # return needed, or wrong type returned
        return (Get-Item -LiteralPath $path).GetValue($valueName, $null);
    }
    return $null; # explicitly return default value
}