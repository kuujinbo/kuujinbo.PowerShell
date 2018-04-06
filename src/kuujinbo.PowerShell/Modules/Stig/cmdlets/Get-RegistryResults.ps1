<#
.SYNOPSIS
    Get W10 STIG registry results where **ONLY** equality test is done.
#>
function Get-RegistryResults {
    param(
        [Parameter(Mandatory)] [hashtable]$rules
        ,[switch] $invoke
    );

    $results = @{};
    foreach ($key in $rules.Keys) {
        $params = $rules.$key;
        $actual = Get-RegistryValue $params[0] $params[1]; 
        $expected = $params[2];

        if ($actual -ne $null) {
            $pass = if (-not $invoke.IsPresent) { $actual -eq $expected; } 
                    else { [bool](Invoke-Expression "$actual $expected"); };

            $results.$key = if ($pass) {
                @($CKL_STATUS_PASS, "Correct registry setting: [$actual]");
            } else {
                @($CKL_STATUS_OPEN, "Incorrect registry setting value: [$actual], expected: [$expected]");
            }

        } else {
            $results.$key = @($CKL_STATUS_OPEN, 'Registry value not set.');
        }
    }

    return $results;
}