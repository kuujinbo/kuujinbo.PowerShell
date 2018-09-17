<#
.SYNOPSIS
    Clean-up manually loaded filesystem HKEY_USERS hive. 
#>
function Dismount-HKU {
    [CmdletBinding()]
    param( );

    if ($script:_HKU_MOUNTED -and $script:_HKU_USER_ID) {
        $keyName = "$($REGISTRY_HIVE.HKEY_USERS)\$($script:_HKU_USER_ID)"
        [GC]::Collect();
        REG UNLOAD $HKUKeyName 2> $null;
    }
}