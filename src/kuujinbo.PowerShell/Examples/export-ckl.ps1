Import-Module (Join-Path $PSScriptRoot '../Modules/Stig/Stig.psm1') -DisableNameChecking -Force; # -Verbose;

$testData = @{
    'V-63319' = @{ "$CKL_STATUS" = 'Not_Reviewed'; "$CKL_COMMENTS" = 'Not_Reviewed'; };
    'V-63321' = @{ "$CKL_STATUS" = 'Open'; "$CKL_COMMENTS" = 'Open'; };
    'V-63323' = @{ "$CKL_STATUS" = 'NotAFinding'; "$CKL_COMMENTS" = 'NotAFinding'; };
    'V-63325' = @{ "$CKL_STATUS" = 'Not_Applicable'; "$CKL_COMMENTS" = 'Not_Applicable'; };
};

$in = Join-Path $PSScriptRoot 'CKL-TEMPLATE.ckl';
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

============================================================================
STATUS values
============================================================================
Not_Reviewed
Open
NotAFinding
Not_Applicable
#>