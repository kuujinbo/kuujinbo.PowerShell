function Get-WantedRules {
    [CmdletBinding()]
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
        # else XmlDocument.Save(string filename) is utf-8 BOM encoded
        $utf = New-Object System.Text.UTF8Encoding($false);
        $writer = New-Object System.Xml.XmlTextWriter($xmlRulesOutPath, $utf);
        $cklTemplate.Save($writer);
        $writer.Dispose();

        # $cklTemplate.Save($xmlRulesOutPath);
    }
}