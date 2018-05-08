function Get-AuditPolResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable]$auditPolRules
    );

    $results = @{};
    $r = Get-AuditPol;
    foreach ($key in $auditPolRules.keys) {
        $group = $auditPolRules.$key[0];
        $category = $auditPolRules.$key[1];
        $expected = $auditPolRules.$key[2];
        $actual = $r.$group.$category;
        if ($actual -match "\b$($expected)\b") {
            $results.$key = @($CKL_STATUS_PASS, "Correct AuditPol setting [$actual]");
        } else {
            $results.$key = @($CKL_STATUS_OPEN, "Incorrect AuditPol setting value: [$actual], expected: [$expected]");
        }
        ++$global:ruleCount;
    }
    return $results;
}