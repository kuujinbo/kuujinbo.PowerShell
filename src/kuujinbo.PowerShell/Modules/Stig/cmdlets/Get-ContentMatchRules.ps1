function Get-ContentMatchRules {
    param(
        [Parameter(Mandatory)] [string]$xmlRulesInPath
        ,[Parameter(Mandatory)] [string]$xmlRulesOutPath
        ,[Parameter(Mandatory)] [string]$match

    )

    [xml]$cklTemplate = Get-Content -Path $xmlRulesInPath -ErrorAction Stop;
    if ($cklTemplate) {
        foreach ($group in $cklTemplate.Benchmark.Group) {
            foreach ($content in $group.Rule.check.'check-content') {
                if (!$content -match $match) {
                    $group.ParentNode.RemoveChild($group) | out-null;
                }
            }
        }
        $cklTemplate.Save($xmlRulesOutPath);
    }
}