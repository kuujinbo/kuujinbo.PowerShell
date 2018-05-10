<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
function Get-Word2010Registry {
    [CmdletBinding()]
    param()

    @{
        'SV-33611r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\options\vpref', 'fWarnRevisions_1125_1', '1')
        'SV-33613r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security', 'WordBypassEncryptedMacroScan', '0')
        'SV-33450r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\fileblock', 'Word12BetaFilesFromConverters', '1')
        'SV-33609r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\options', 'DontUpdateLinks', '1')
        'SV-33621r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\trusted locations', 'AllowNetworkLocations', '0')
        'SV-34098r2_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\fileblock', 'Word95Files', '5')
        'SV-33865r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\protectedview', 'DisableUnsafeLocationsInPV', '0')
        'SV-34094r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\common\research\translation', 'UseOnline', '1')
        'SV-33859r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security', 'EnableDEP', '1')
        'SV-33868r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\filevalidation', 'OpenInProtectedView', '1')
        'SV-34096r2_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\fileblock', 'Word2000Files', '5')
        'SV-33624r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\trusted locations', 'AllLocationsDisabled', '1')
        'SV-33610r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\options', 'DefaultFormat', '')
        'SV-33871r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\protectedview', 'DisableAttachmentsInPV', '0')
        'SV-34097r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\fileblock', 'Word60Files', '2')
        'SV-33873r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\fileblock', 'OpenInProtectedView', '0')
        'SV-33853r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security', 'RequireAddinSig', '1')
        'SV-33612r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security', 'NoTBPromptUnsignedAddin', '1')
        'SV-34095r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\fileblock', 'Word2Files', '2')
        'SV-33615r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security', 'AccessVBOM', '0')
        'SV-33619r2_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security', 'VBAWarnings', '2')
        'SV-33875r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\filevalidation', 'EnableOnLoad', '1')
        'SV-33863r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\protectedview', 'DisableInternetFilesInPV', '0')
    };
}

<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
#function Get-RegistryRules {
#    [CmdletBinding()]
#    param()

#}