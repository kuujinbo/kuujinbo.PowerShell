function Get-AuditPol {
    $result = @{};

    $auditString = AuditPol /get /category:*;
    $partsines = $auditString.split(
        [string[]] "`n",
        [System.StringSplitOptions]::RemoveEmptyEntries
    );
    # remove headers
    $partsines =  $partsines[2..($partsines.length-1)];
    $group = '';

    foreach ($partsine in $partsines) {
        $parts = [regex]::split($partsine.trim(), '\s{2,}');

        if ($parts.length -eq 1) {
            $group = $parts[0];
            $result.$group = @{};
        } else {
            $result.$group[$parts[0]] = $parts[1];
        }
    }

    return $result;
}