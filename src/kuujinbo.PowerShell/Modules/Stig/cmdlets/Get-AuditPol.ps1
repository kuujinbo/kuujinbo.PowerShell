<#
.SYNOPSIS
    Get AuditPol STDOUT in a PowerShell data structure.
.DESCRIPTION
    The Get-AuditPol cmdlet parses AuditPol.exe STDOUT and converts result
    into a PowerShell data structure.
#>
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