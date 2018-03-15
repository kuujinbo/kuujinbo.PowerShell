function Get-AuditPol {
    # suppress STDERR if run with insufficient privileges
    $audit = AuditPol /get /category:* 2>$null;
    if (!$audit) { return $null; }

    $lines = $audit.Split(
        [string[]] "`n",
        [System.StringSplitOptions]::RemoveEmptyEntries
    );
    # remove headers
    $lines =  $lines[2..($lines.length-1)];

    $result = @{};
    $group = '';
    foreach ($line in $lines) {
        $parts = [Regex]::Split($line.Trim(), '\s{2,}', 2);

        if ($parts.length -eq 1) {
            $group = $parts[0];
            $result.$group = @{};
        } else {
            $result.$group[$parts[0]] = $parts[1];
        }
    }

    return $result;
}