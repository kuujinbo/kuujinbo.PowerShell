<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
function Get-Access2010Registry {
    [CmdletBinding()]
    param()

    @{
        'SV-33848r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\security', 'RequireAddinSig', '1')
        'SV-33428r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\internet', 'DoNotUnderlineHyperlinks', '0')
        'SV-33433r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\security', 'ModalTrustDecisionOnly', '0')
        'SV-33854r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\security', 'EnableDEP', '1')
        'SV-33424r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\security', 'VBAWarnings', '2')
        'SV-33422r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\security', 'NoTBPromptUnsignedAddin', '1')
        'SV-33430r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\settings', 'Default File Format', '12')
        'SV-33673r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\access\settings', 'NoConvertDialog', '0')
    };
}