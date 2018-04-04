function Get-WantedRules {
    param(
        [Parameter(Mandatory)] [string]$xmlRulesInPath
        ,[Parameter(Mandatory)] [string]$xmlRulesOutPath
        ,[Parameter(Mandatory)] [hashtable]$wantedRules

    )

    [xml]$cklTemplate = Get-Content -Path $xmlRulesInPath -ErrorAction Stop;
    if ($cklTemplate) {
        foreach ($group in $cklTemplate.Benchmark.Group) {
            foreach ($rule in $group.Rule) {
                if (!$wantedRules.ContainsKey($group.id)) {
                    $group.ParentNode.RemoveChild($group) | out-null;
                }
            }
        }
        $cklTemplate.Save($xmlRulesOutPath);
    }
}