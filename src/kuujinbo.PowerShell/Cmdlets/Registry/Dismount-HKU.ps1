<#
.SYNOPSIS
    Clean-up manually loaded filesystem HKEY_USERS hive. 
#>
function Dismount-HKU {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$HKUKeyName
    );

    [GC]::Collect();
    # return value !$null => success
    REG UNLOAD $HKUKeyName 2> $null;
}