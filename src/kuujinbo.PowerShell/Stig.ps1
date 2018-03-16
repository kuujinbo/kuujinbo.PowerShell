
function Parse-CheckContent {
    param(
        [Parameter(Mandatory=$true)] [string]$text
        , [Parameter(Mandatory=$true)] [string]$rule
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
    return $result;
}

function Get-Rules {
    param(
        [Parameter(Mandatory=$true)] [string]$filePath
    )

    [xml]$xmlRules = Get-Content -Path $filePath -ErrorAction Stop;
    $result = @{};
    if($xmlRules) {
        $CATs = @{
            low = 'CAT I';
            medium = 'CAT II';
            high = 'CAT III';
        };

        foreach ($group in $xmlRules.Benchmark.Group) {
            foreach ($rule in $group.Rule) {
                $result[$group.id] = New-Object -TypeName PSObject -Property (@{
                    title = $rule.title;
                    severity = $CATs[$rule.severity];
                    registry = Parse-CheckContent $rule.check.'check-content' $group.id;
                });
            }
        }
        return $result;
    }
}


function Get-AuditPol {
    # suppress STDERR if run with insufficient privileges
    $audit = ((AuditPol /get /category:* 2>$null) | Out-String) -join '';
    if (!$audit) { return $null; }

    $lines = Get-Lines $audit;
    # remove headers
    $lines =  $lines[2..($lines.length-1)];

    $result = @{};
    $group = '';
    foreach ($line in $lines) {
        $subCategory, $setting = [Regex]::Split($line.Trim(), '\s{2,}', 2);

        if ($setting -eq $null) {
            $group = $subCategory;
            $result.$group = @{};
        } else {
            $result.$group.$subCategory = $setting;
        }
    }
    return $result;
}


function Get-Lines {
    param(
        [Parameter(Mandatory=$true)] [string]$text
    )

    return $text.Split(
        [string[]] (, "`r`n", "`n", "`r"), 
        [StringSplitOptions]::RemoveEmptyEntries
    );
}