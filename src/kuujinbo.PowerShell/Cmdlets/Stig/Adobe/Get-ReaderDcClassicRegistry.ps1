<#
.SYNOPSIS
    Get registry rules => Version: 1, Release: 4, 27 Jul 2018
#>
function Get-ReaderDcClassicRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [int]$version
    )

    @{
        'V-65729' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bEnhancedSecurityStandalone', '1');
        'V-65735' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bEnhancedSecurityInBrowser', '1');
        'V-65737' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bProtectedMode', '1');
        'V-65739' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'iProtectedView', '2');
        'V-65767' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cDefaultLaunchURLPerms", 'iURLPerms', '1');
        'V-65769' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cDefaultLaunchURLPerms", 'iUnknownURLPerms', '3');
        'V-65771' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'iFileAttachmentPerms', '1');
        'V-65775' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bEnableFlash', '0');
        'V-65777' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bDisablePDFHandlerSwitching', '1');
        'V-65779' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cCloud", 'bAdobeSendPluginToggle', '1');
        'V-65781' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cServices", 'bToggleAdobeDocumentServices', '1');
        'V-65783' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cServices", 'bTogglePrefsSync', '1');
        # 32 bit
        # 'V-65785' = @("HKLM:\Software\Adobe\Acrobat Reader\$version\Installer", 'DisableMaintenance', '1');
        'V-65785' = @("HKLM:\SOFTWARE\Wow6432Node\Adobe\Acrobat Reader\$version\Installer", 'DisableMaintenance', '1');
        'V-65787' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cServices", 'bToggleWebConnectors', '1');
        'V-65789' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cServices", 'bToggleAdobeSign', '1');
        'V-65791' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cWebmailProfiles", 'bDisableWebmail', '1');
        'V-65793' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cSharePoint", 'bDisableSharePointFeatures', '1');
        'V-65795' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cWelcomeScreen", 'bShowWelcomeScreen', '0');
        'V-65797' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown\cServices", 'bUpdater', '0');
        'V-65799' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bDisableOSTrustedSites', '1');
        'V-65801' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bDisableTrustedFolders', '1');
        'V-65803' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bDisableTrustedSites', '1');
        'V-65805' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bEnableCertificateBasedTrust', '0');
# HKCU 
        'V-65807' = @("HKCU:\Software\Adobe\Acrobat Reader\$version\Security\cDigSig\cEUTLDownload", 'bLoadSettingsFromURL', '0');
        'V-65809' = @("HKCU:\Software\Adobe\Acrobat Reader\$version\Security\cDigSig\cAdobeDownload", 'bLoadSettingsFromURL', '0');
        'V-65813' = @("HKCU:\Software\Adobe\Acrobat Reader\$version\AVGeneral", 'bFIPSMode', '1');
# /HKCU
        'V-65815' = @("HKLM:\Software\Policies\Adobe\Acrobat Reader\$version\FeatureLockDown", 'bAcroSuppressUpsell', '1');
    };
}