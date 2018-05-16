<#
.SYNOPSIS
    Get STIG registry results where **MULTIPLE** registry key/value pairs
    must be checked for a **single** rule.
.PARAMETER $rules
    Must be in this format:

    @{
        'VULNERABILITY-OR-RULE_ID' = @(
            # commas **required** to force array context
            ,@('HKLM:\PATH', 'NAME', 'EXPECTED_VALUE')
            ,@('HKLM:\ANOTHER_PATH', 'NAME', 'EXPECTED_VALUE')
            #, ...
        );  
    };
#>
function Get-RegistryResultsMultiple {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable]$rules
        ,[switch] $invoke
    );

    $results = @{};
    $comments = New-Object System.Text.StringBuilder;
    foreach ($key in $rules.Keys) {
        $paths = $rules.$key;
        $pass = $true;

        foreach ($path in $paths) {
            $regPath = $path[0];
            $regName = $path[1];
            $actual = Get-RegistryValue $regPath $regName; 
            $expected = $path[2];
            $comments.AppendLine("$regPath => $regName") | Out-Null; 

            if ($actual -ne $null) {
                $thisPass = if (-not $invoke.IsPresent) { $actual -eq $expected; } 
                        else { [bool](Invoke-Expression "$actual $expected"); };
                $pass = $pass -and $thisPass;

                $comments.AppendLine("ACTUAL: $actual :: REQUIRED: $expected") | Out-Null; 
            } else {
                $comments.AppendLine('Registry value not set.') | Out-Null; 
            }
            $comments.AppendLine() | Out-Null;
        }

        $results.$key = if ($pass) {
            @($CKL_STATUS_PASS, $comments.ToString());
        } else {
            @($CKL_STATUS_OPEN, $comments.ToString());
        }

        $comments.Clear() | Out-Null;
    }

    return $results;    
}