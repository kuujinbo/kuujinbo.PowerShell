# load dot source script file
$thisScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
. (Join-Path $thisScriptDir 'Stig/File.ps1');
. (Join-Path $thisScriptDir 'Stig/Stig.ps1');
. (Join-Path $thisScriptDir 'Stig/Win10.ps1');

#region functions
# ----------------------------------------------------------------------------
function Dump-AuditPolResults {
    $r = Get-AuditPol;
    $auditPolRules = Get-AuditPolRules;
    foreach ($key in $auditPolRules.keys) {
        $group = $auditPolRules.$key[0];
        $category = $auditPolRules.$key[1];
        $expected = $auditPolRules.$key[2];
        $result = $r.$group.$category;
        $pass = if ($result -match "\b$($expected)\b" ) { 'PASS'; } else { 'FAIL' }

        Write-Host "$key [$pass] = $group => $category => REQUIRED: [$expected] => ACTUAL: [$result]";
    }
}

function Parse-Win10Rules {
    $regWorking = Join-Path $thisScriptDir 'reg-working.txt';
    $r = Get-Rules 'c:/dev/U_Windows_10_STIG_V1R12_Manual-xccdf.xml' $regWorking;
}
# ----------------------------------------------------------------------------
#endregion

$auditPolRules = Get-AuditPolRules;
$regRules = Get-RegistryRules;

$allRules = Get-Rules 'c:/dev/U_Windows_10_STIG_V1R12_Manual-xccdf.xml';

$missingRules = @{};
foreach ($rule in $allRules.keys) {
    if (!$auditPolRules.containskey($rule) -and !$regRules.containskey($rule)) {
        $missingRules.$rule = $null;
    }
}


$missingRules.Keys.Count;
$missingRules | Out-GridView;