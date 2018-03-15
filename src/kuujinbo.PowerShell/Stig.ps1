function Get-AuditPol {
    $result = @{};

    $audit = AuditPol /get /category:*;
    $lines = $audit.Split(
        [string[]] "`n",
        [System.StringSplitOptions]::RemoveEmptyEntries
    );
    # remove headers
    $lines =  $lines[2..($lines.length-1)];
    $group = '';

    foreach ($line in $lines) {
        $parts = [regex]::Split($line.Trim(), '\s{2,}');

        if ($parts.length -eq 1) {
            $group = $parts[0];
            $result.$group = @{};
        } else {
            $result.$group[$parts[0]] = $parts[1];
        }
    }

    return $result;
}