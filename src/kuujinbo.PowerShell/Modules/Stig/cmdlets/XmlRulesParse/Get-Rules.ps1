<#
.SYNOPSIS
    Get STIG rules XML file in a PowerShell data structure.
.EXAMPLE
    $rules = Get-Rules $xmlRulesPath -functionToCall ${function:Get-OfficeRegistryInfo};
#>
function Get-Rules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$xmlRulesPath
        ,[string]$regWorkingOutPath
        ,[scriptblock]$functionToCall
    )

    [xml]$xml = Get-Content -Path $xmlRulesPath -ErrorAction Stop;
    $result = @{};
    $working = New-Object System.Text.StringBuilder;
    foreach ($group in $xml.Benchmark.Group) {
        foreach ($rule in $group.Rule) {
            $result[$group.id] = @{
                title = $rule.title;
                severity = $CATs[$rule.severity];
                ruleId = $rule.id;
            };

            if ($functionToCall) {
                $result[$group.id].'registry' = $functionToCall.Invoke(
                    $rule.check.'check-content', $rule.id
                );
            }

            if ($regWorkingOutPath) { 
                $a = Get-RegistryInfoFromCheckContent $rule.check.'check-content';
                if ($a.length -gt 0) { 
                    $hive = $REGISTRY_HIVE[$a[0]] + ':' + $a[1];
                    $working.AppendLine(
                        "'$($group.id)' = @('$hive', '$($a[2])', '$($a[4])');"
                    ) | Out-Null;
                }
            }
        }
    }

    if ($regWorkingOutPath) { $working.ToString() | Out-File -FilePath $regWorkingOutPath; }

    return $result;
}

<#
.SYNOPSIS
    Get STIG registry information by rule. 
..NOTES 
    STIG XML schema is a joke, and authors **RIDICULOUSLY** inconsistent, 
    but should be in groups of 5:
    Registry Hive, Registry Path, Value Name, [Value] Type, Value
#>
function Get-OfficeRegistryInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$text
        ,[Parameter(Mandatory)] [string]$ruleId
    )

    # 'Check Content' is a joke with random crap, so need to verify number of matches
    $matchCount = (Select-String '(?:hklm|hkcu)(?:\\[\w\d\.]+)+' -input $text -AllMatches).Matches.Count;
    if ($matchCount -ne 1) { Write-Warning "Another crap rule [$ruleId]: registry key matches => [$matchCount]";}


    $registryMatch = '^(?:hklm|hkcu)(?:\\[A-Za-z]+)+';
    # another example of how inconsistent STIG writers are....
    $criteriaMatch = '^(?:Criteria:)*\s*If the value ([\w\d]+) is.*=\s*(\d*)';
    $lines = Get-TrimmedLines $text;

    for ($i = 0; $i -lt $lines.Length; ++$i) {
        if ($lines[$i] -match $registryMatch) {
            [regex]$regPathMatch ='^([A-Za-z]+)(\\)';
            # replace 'HKLM\Software' with HKLM:\Software to get registry value
            $regPath = $regPathMatch.Replace($lines[$i], '$1:$2', 1);

            $regKeyName = '';
            $regKeyValue = '';
            if ($lines[$i + 1] -match $criteriaMatch) {
                $regKeyName = $matches[1];
                $regKeyValue = $matches[2];

                return @($regPath, $regKeyName, $regKeyValue);
            } else 
              { return @($regPath, '',  ''); }
        }
    }

    return @(); 
}


<#
.SYNOPSIS
    Get STIG registry information by rule. 
..NOTES 
    STIG XML schema is a joke, and authors **RIDICULOUSLY** inconsistent, 
    but should be in groups of 5:
    Registry Hive, Registry Path, Value Name, [Value] Type, Value
#>
function Get-RegistryInfoFromCheckContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$text
    )

    $result = @();
    $wanted = "^(?:registry|value|type)[^:]*:(?'value'.*)";
    $lines = Get-TrimmedLines $text;
    foreach ($line in $lines) {
        if ($line -match $wanted) {
            $result += $matches['value'].Trim();
        }
    }

    if (($result.length -gt 0) -and ($result.length % 5 -eq 0)) { 
        return $result; 
    } else  { 
        return @(); 
    }
}