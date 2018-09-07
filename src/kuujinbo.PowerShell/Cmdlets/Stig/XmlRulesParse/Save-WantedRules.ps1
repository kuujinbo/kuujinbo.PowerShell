<#
.SYNOPSIS
    Save a filtered set of STIG rules    
.PARAMETER $wantedRules
    A collection of vulnerability IDs, (default) **OR** Rule IDs    
.PARAMETER $getRuleIds
    Filter on Rule IDs instead of the default.
#>
function Save-WantedRules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$xmlRulesInPath
        ,[Parameter(Mandatory)] [hashtable]$wantedRules
        ,[switch]$getRuleIds
    )

    $fsi = gci $xmlRulesInPath;
    $xmlRulesOutPath = Join-Path $fsi.Directory.FullName '__wanted.xml';
    [xml]$cklTemplate = Get-Content -Path $xmlRulesInPath -ErrorAction Stop;
    foreach ($group in $cklTemplate.Benchmark.Group) {
        if ($getRuleIds.IsPresent) {
            if (!$wantedRules.ContainsKey($group.Rule.id)) {
                $null = $group.ParentNode.RemoveChild($group);
            }
        } else {
            if (!$wantedRules.ContainsKey($group.id)) {
                $null = $group.ParentNode.RemoveChild($group);
            }
        }
    }

    # else XmlDocument.Save(string filename) is utf-8 BOM encoded
    $utf = New-Object System.Text.UTF8Encoding($false);
    $writer = New-Object System.Xml.XmlTextWriter($xmlRulesOutPath, $utf);
    $cklTemplate.Save($writer);
    $writer.Dispose();
}