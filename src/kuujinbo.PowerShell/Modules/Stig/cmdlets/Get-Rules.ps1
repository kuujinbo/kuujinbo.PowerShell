#region rule file parser
<#
.SYNOPSIS
    Get STIG rules XML file in a PowerShell data structure.
.DESCRIPTION
    The Get-Rules cmdlet parses A STIG rule XML file and converts into a
    PowerShell data structure.
#>
function Get-Rules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$xmlRulesPath
        , [string]$regWorkingOutPath
    )

    [xml]$cklTemplate = Get-Content -Path $xmlRulesPath -ErrorAction Stop;
    if ($cklTemplate) {
        $result = @{};
        $working = New-Object System.Text.StringBuilder;
        foreach ($group in $cklTemplate.Benchmark.Group) {
            foreach ($rule in $group.Rule) {
                $result[$group.id] = New-Object -TypeName PSObject -Property (@{
                    title = $rule.title;
                    severity = $CATs[$rule.severity];
                });
                if ($regWorkingOutPath) { 
                    $a = Get-RegistryInfoFromCheckContent $rule.check.'check-content' $group.id;
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
}

function Get-RegistryInfoFromCheckContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$text
        , [Parameter(Mandatory)] [string]$rule
    )
    <#
        STIG authors **RIDICULOUSLY** inconsistent, but should be in groups of 5:
        Registry Hive, Registry Path, Value Name, [Value] Type, Value
    #>
    $result = @();
    $wanted = "^(?:registry|value|type)[^:]*:(?'value'.*)";
    $lines = Get-Lines $text;
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