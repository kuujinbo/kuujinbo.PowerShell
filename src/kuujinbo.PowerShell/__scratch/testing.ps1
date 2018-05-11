Import-Module (Join-Path $PSScriptRoot 'Modules/Stig/Win10.psm1') -DisableNameChecking -Force;

#region functions
# ----------------------------------------------------------------------------
function Parse-Win10Rules {
    $regWorking = Join-Path $thisScriptDir 'reg-working.txt';
    $r = Get-Rules 'c:/dev/U_Windows_10_STIG_V1R12_Manual-xccdf.xml' $regWorking;
}
# ----------------------------------------------------------------------------
#endregion

# $results = @{};
$results = Get-RegistryResults  (Get-RegistryRulesRange) -invoke;
write-output $results;
exit;



$rulesFile = 'c:/dev/U_Windows_10_STIG_V1R12_Manual-xccdf.xml';

$v = get-win10version;
($v -eq $null);
Dump-AuditPolResults;

$auditPolRules = Get-AuditPolRules;
$regRules = Get-RegistryRules;

$allRules = Get-Rules $rulesFile;

$missingRules = @{};
foreach ($rule in $allRules.keys) {
    if (!$auditPolRules.containskey($rule) -and !$regRules.containskey($rule)) {
        $missingRules.$rule = $null;
    }
}


$allRules.Keys.Count;
$missingRules.Keys.Count;

Get-WantedRules $rulesFile 'c:/dev/koko.xml' $missingRules;