<#
.SYNOPSIS
    Get STIG registry results.
.PARAMETER $rules
    [1] MUST be in this format:
        
    @{ 'VULNERABILITY-OR-RULE_ID' = @(HKLM:\PATH', 'NAME', 'EXPECTED_VALUE'); };

    'EXPECTED_VALUE' => [string] or [regex]; PowerShell does the right thing,
    including numeric comparisions.

    [2] For HKU / HKCU, the registry path MUST be in the following format:
        Registry::HKEY_USERS\REST-OF-PATH

        A user SID or SamAccountName will dynamically be appended to each 
        'HKEY_USERS\' path part to query the correct registry setting.
.PARAMETER $getHku
    Get HKU / HKCU registry results.
#>
function Get-RegistryResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable]$rules
        ,[switch] $getHku
        ,[switch] $invoke
    );

    if ($getHku.IsPresent) { Mount-HKU; }

    $results = @{};
    foreach ($key in $rules.Keys) {
        $params = $rules.$key;
        $keyPath = $params[0];
        # **ONLY** HKLM and HKU are supported 
        $regPath, $findingPath = switch -Regex ($keyPath) {
            '^HKLM:' { @($keyPath, $keyPath.Replace('HKLM:', '')); }
            '^Registry::HKEY_USERS' {
                @(
                    # $keyPath.Replace('HKEY_USERS\', "HKEY_USERS\$HKUPathPart\")
                    $keyPath.Replace('HKEY_USERS\', "HKEY_USERS\$($script:_HKU_USER_ID)\")
                    $keyPath.Replace('Registry::HKEY_USERS', '')
                );
            }
            default { throw "Invalid registry search path $keyPath"; }
        }

        $regName = $params[1];
        $expected = $params[2];
        $userComment = if ($script:_HKU_USER_ID) { " ($($script:_HKU_USER_ID))";  } 
                       else { ''; }
        $actual = Get-RegistryValue $regPath $regName;
        $findingText = @"
$findingPath ($regName).$($userComment)

{0}
"@;
        # registry value set => check against expected value
        if ($actual -ne $null) {
            if ($expected -is [regex]) { $pass = $expected.IsMatch($actual); } 
            else {
                $pass = if (-not $invoke.IsPresent) { $actual -eq $expected; } 
                        else { [bool](Invoke-Expression "$actual $expected"); };
            }
            $results.$key = if ($pass) {
                @($CKL_STATUS_PASS, 
                    ($findingText -f "Not a finding: registry value setting: [$actual]")
                );
            } else {
                @($CKL_STATUS_OPEN, 
                    ($findingText -f "Open: incorrect registry setting. ACTUAL: [$actual] :: REQUIRED: [$expected]")
                );
            }
        # bad path OR registry value *NOT** set
        } else {
            $results.$key = @($CKL_STATUS_OPEN, 
                ($findingText -f "Open: Registry value not set")
            );
        }
    }

    return $results;
}