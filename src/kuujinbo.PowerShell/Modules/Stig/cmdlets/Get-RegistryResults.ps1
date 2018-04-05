function Get-RegistryResults {
    param(
        [Parameter(Mandatory)] [hashtable]$rules
    );

    $results = @{};
    foreach ($key in $rules.Keys) {
        $params = $rules.$key;
        $actual = Get-RegistryValue $params[0] $params[1]; 
        $expected = $params[2];
        if ($actual -eq $expected) {
            $results.$key = @($CKL_STATUS_PASS, "Correct registry setting: [$actual]");
        } else {
            $results.$key = if ($actual -ne $null) {
                @($CKL_STATUS_OPEN, "Incorrect registry setting value: [$actual], expected: [$expected]");
            } else {
                @($CKL_STATUS_OPEN, 'Registry value not set.');
            }
        }
    }
    return $results;
}