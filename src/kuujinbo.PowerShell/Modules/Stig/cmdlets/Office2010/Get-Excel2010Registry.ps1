<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
function Get-Excel2010Registry {
    [CmdletBinding()]
    param()

    @{
        'SV-33445r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security', 'VBAWarnings', '2')
        'SV-34230r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'DBaseFiles', '2')
        'SV-33442r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security', 'NoTBPromptUnsignedAddin', '1')
        'SV-34625r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options', 'ExtractDataDisableUI', '1')
        'SV-34255r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL3Macros', '2')
        'SV-33864r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\protectedview', 'DisableUnsafeLocationsInPV', '0')
        'SV-33439r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options', 'DisableAutoRepublishWarning', '0')
        'SV-33448r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'Excel12BetaFilesFromConverters', '1')
        'SV-34238r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'DifandSylkFiles', '2')
        'SV-33447r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\trusted locations', 'AllLocationsDisabled', '1')
        'SV-34239r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL2Macros', '2')
        'SV-33436r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options', 'AutoHyperlink', '0')
        'SV-33435r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\internet', 'DoNotLoadPictures', '1')
        'SV-34277r2_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL95Workbooks', '5')
        'SV-33874r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\filevalidation', 'EnableOnLoad', '1')
        'SV-33870r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\protectedview', 'DisableAttachmentsInPV', '0')
        'SV-34275r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL4Worksheets', '2')
        'SV-33867r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\filevalidation', 'OpenInProtectedView', '1')
        'SV-33446r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\trusted locations', 'AllowNetworkLocations', '0')
        'SV-33440r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security', 'ExtensionHardening', '1')
        'SV-34269r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL4Macros', '2')
        'SV-33434r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options\binaryoptions', 'fUpdateExt_78_1', '0')
        'SV-33443r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options\binaryoptions', 'fGlobalSheet_37_1', '1')
        'SV-33437r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options', 'DefaultFormat', '0')
        'SV-33872r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'OpenInProtectedView', '0')
        'SV-33855r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security', 'EnableDEP', '1')
        'SV-33861r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\protectedview', 'DisableInternetFilesInPV', '0')
        'SV-34272r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL4Workbooks', '2')
        'SV-34259r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\fileblock', 'XL3Worksheets', '2')
        'SV-33441r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security', 'ExcelBypassEncryptedMacroScan', '0')
        'SV-33438r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\options', 'DisableAutoRepublish', '1')
        'SV-33444r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security', 'AccessVBOM', '0')
        'SV-34279r2_rule' = @('HKCU:\Software\Policies\Microsoft\office\14.0\excel\security\fileblock', 'XL9597WorkbooksandTemplates', '5')
    };
}