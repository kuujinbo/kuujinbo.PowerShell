Import-Module (Join-Path $PSScriptRoot '../Modules/Stig/Stig.psm1') -DisableNameChecking -Force; # -Verbose;

$testData = @{
    'V-63319' = @('Not_Reviewed', 'Not_Reviewed');
    'V-63321' = @('Open', 'Open');
    'V-63323' = @('NotAFinding', 'NotAFinding');
    'V-63325' = @('Not_Applicable', 'Not_Applicable');
};

$testData;

$in = Join-Path $PSScriptRoot 'WIN10-TEMPLATE.ckl';
$out = Join-Path (Get-DesktopPath) 'test-host.ckl';

Export-Ckl $in $out $testData;

<#
============================================================================
STIG Viewer 2.6.1
============================================================================

[1] Root path => CHECKLIST.STIGS.iSTIG.VULN

[2] Child path, note comments

<VULN>
    <!-- multiple 'STIG_DATA' nodes: rule is **FIRST** node -->
    <STIG_DATA>
        <VULN_ATTRIBUTE>Vuln_Num</VULN_ATTRIBUTE>
        <ATTRIBUTE_DATA>V-63321</ATTRIBUTE_DATA>
    </STIG_DATA>

    <!-- single nodes -->
    <STATUS></STATUS>
    <FINDING_DETAILS>FAIL</FINDING_DETAILS>
    <COMMENTS></COMMENTS>
    <SEVERITY_OVERRIDE></SEVERITY_OVERRIDE>
    <SEVERITY_JUSTIFICATION></SEVERITY_JUSTIFICATION>
</VULN>
#>