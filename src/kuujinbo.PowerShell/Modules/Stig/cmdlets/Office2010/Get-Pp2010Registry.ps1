<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
function Get-Pp2010Registry {
    [CmdletBinding()]
    param()

    @{
        'SV-33602r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'PowerPointBypassEncryptedMacroScan', '0')
        'SV-33449r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\fileblock', 'PowerPoint12BetaFilesFromConverters', '1')
        'SV-33607r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\trusted locations', 'AllowNetworkLocations', '0')
        'SV-33866r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\protectedview', 'DisableUnsafeLocationsInPV', '0')
        'SV-33858r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'EnableDEP', '1')

        'SV-33608r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\trusted locations', 'AllLocationsDisabled', '1')
        'SV-33599r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\options', 'DefaultFormat', '1')
        'SV-33600r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\options', 'MarkupOpenSave', '1')
        'SV-33601r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'RunPrograms', '0')
        'SV-33933r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\fileblock', 'OpenInProtectedView', '0')
        'SV-33604r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'NoTBPromptUnsignedAddin', '1')
        'SV-34090r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\slide libraries', 'DisableSlideUpdate', '1')
        'SV-33876r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\protectedview', 'DisableAttachmentsInPV', '0')
        'SV-33605r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'AccessVBOM', '0')
        'SV-33603r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'DownloadImages', '0')
        'SV-33606r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security', 'VBAWarnings', '2')
        'SV-33935r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\filevalidation', 'EnableOnLoad', '1')
        'SV-33862r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\protectedview', 'DisableInternetFilesInPV', '0')
    };
}