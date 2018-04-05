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
        $returnValue = (Get-Item -LiteralPath $path).GetValue($valueName, $null);
        if (($returnValue -ne $null) -and ($returnValue -is [string])) {
            # [1] REG_SZ / REG_EXPAND_SZ / REG_MULTI_SZ `null` terminated => **NOT** valid XML
            # [2] `Escape()` => sanity-check 
            $returnValue = [System.Security.SecurityElement]::Escape(($returnValue -replace "`0", '')); 
        }

        # return needed, or wrong type returned
        return $returnValue;
    }
    return $null; # explicitly return default value
}