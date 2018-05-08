<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
function Get-RegistryRules {
    [CmdletBinding()]
    param()

    @{
        # GOOD
        'V-63321' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer\', 'EnableUserControl', '0');
        'V-63325' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer\', 'AlwaysInstallElevated', '0');
        'V-63333' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'DisableAutomaticRestartSignOn', '1');
        'V-63335' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\', 'AllowBasic', '0');
        'V-63339' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\', 'AllowUnencryptedTraffic', '0');
        'V-63341' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\', 'AllowDigest', '0');
        'V-63347' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\', 'AllowBasic', '0');
        'V-63369' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\', 'AllowUnencryptedTraffic', '0');
        'V-63375' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\', 'DisableRunAs', '1');
        'V-63545' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization\', 'NoLockScreenCamera', '1');
        'V-63549' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization\', 'NoLockScreenSlideshow', '1');
        'V-63555' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\', 'DisableIpSourceRouting', '2');
        'V-63559' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\', 'DisableIPSourceRouting', '2');
        'V-63563' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\', 'EnableICMPRedirect', '0');
        'V-63567' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netbt\Parameters\', 'NoNameReleaseOnDemand', '1');
        'V-63569' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation\', 'AllowInsecureGuestAuth', '0');
        'V-63585' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy\', 'fBlockNonDomain', '1');
        'V-63591' = @('HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\', 'AutoConnectAllowedOEM', '0');
        'V-63597' = @('HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'LocalAccountTokenFilterPolicy', '0');
        'V-63609' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}', 'NoGPOListChanges', '0');
        'V-63615' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\', 'DisableWebPnPDownload', '1');
        'V-63617' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'LimitBlankPasswordUse', '1');
        'V-63621' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\', 'NoWebServices', '1');
        'V-63623' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\', 'DisableHTTPPrinting', '1');
        'V-63629' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\', 'DontDisplayNetworkSelectionUI', '1');
        'V-63633' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\', 'EnumerateLocalUsers', '0');
        'V-63635' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'SCENoApplyLegacyAuditPolicy', '1');
        'V-63637' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\', 'AllowDomainPINLogon', '0');
        'V-63639' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'RequireSignOrSeal', '1');
        'V-63643' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'SealSecureChannel', '1');
        'V-63645' = @('HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51\', 'DCSettingIndex', '1');
        'V-63647' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'SignSecureChannel', '1');
        'V-63649' = @('HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51\', 'ACSettingIndex', '1');
        'V-63651' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\', 'fAllowToGetHelp', '0');
        'V-63653' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'DisablePasswordChange', '0');
        'V-63657' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc\', 'RestrictRemoteClients', '1');
        'V-63659' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'MSAOptional', '1');
        'V-63663' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat\', 'DisableInventory', '1');
        'V-63665' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'RequireStrongKey', '1');
        'V-63667' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\', 'NoAutoplayfornonVolume', '1');
        'V-63669' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'InactivityTimeoutSecs', '900');
        'V-63671' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\', 'NoAutorun', '1');
        'V-63673' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer\', 'NoDriveTypeAutoRun', '255');
        'V-63675' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'LegalNoticeText', @'
You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.
'@
        );
        'V-63677' = @('HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures\', 'EnhancedAntiSpoofing', '1');
        'V-63679' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI\', 'EnumerateAdministrators', '0');
        'V-63683' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\', 'AllowTelemetry', '0');
        'V-63699' = @('HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter\', 'PreventOverride', '1');
        'V-63701' = @('HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter\', 'PreventOverrideAppRepUnknown', '1');
        'V-63703' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\', 'RequireSecuritySignature', '1');
        'V-63705' = @('HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\', 'AllowInPrivate', '0');
        'V-63707' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\', 'EnableSecuritySignature', '1');
        'V-63709' = @('HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\', 'FormSuggest Passwords', 'no');
        'V-63711' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters\', 'EnablePlainTextPassword', '0');
        'V-63713' = @('HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter\', 'EnabledV9', '1');
        'V-63717' = @('HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork\', 'RequireSecurityDevice', '1');
        'V-63719' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\', 'RequireSecuritySignature', '1');
        'V-63723' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\', 'EnableSecuritySignature', '1');
        'V-63725' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive\', 'DisableFileSyncNGSC', '1');
        'V-63729' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\', 'DisablePasswordSaving', '1');
        'V-63731' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\', 'fDisableCdm', '1');
        'V-63733' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\', 'fPromptForPassword', '1');
        'V-63737' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\', 'fEncryptRPCTraffic', '1');
        'V-63741' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\', 'MinEncryptionLevel', '3');
        'V-63743' = @('HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds\', 'DisableEnclosureDownload', '1');
        'V-63745' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'RestrictAnonymousSAM', '1');
        'V-63749' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'RestrictAnonymous', '1');
        'V-63751' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\', 'AllowIndexingEncryptedStoresOrItems', '0');
        'V-63753' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'DisableDomainCreds', '1');
        'V-63755' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'EveryoneIncludesAnonymous', '0');
        'V-63759' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\', 'RestrictNullSessAccess', '1');
        'V-63763' = @('HKLM:\SYSTEM\CurrentControlSet\Control\LSA\', 'UseMachineId', '1');
        'V-63765' = @('HKLM:\SYSTEM\CurrentControlSet\Control\LSA\MSV1_0\', 'allownullsessionfallback', '0');
        'V-63767' = @('HKLM:\SYSTEM\CurrentControlSet\Control\LSA\pku2u\', 'AllowOnlineID', '0');
        'V-63795' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\', 'SupportedEncryptionTypes', '2147483640');
        'V-63797' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'NoLMHash', '1');
        'V-63801' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'LmCompatibilityLevel', '5');
        'V-63803' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LDAP\', 'LDAPClientIntegrity', '1');
        'V-63805' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0\', 'NTLMMinClientSec', '537395200');
        'V-63807' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0\', 'NTLMMinServerSec', '537395200');
        'V-63811' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\', 'Enabled', '1');
        'V-63813' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel\', 'ObCaseInsensitive', '1');
        'V-63815' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\', 'ProtectionMode', '1');
        'V-63817' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'FilterAdministratorToken', '1');
        'V-63819' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'ConsentPromptBehaviorAdmin', '2');
        'V-63821' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'ConsentPromptBehaviorUser', '0');
        'V-63825' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'EnableInstallerDetection', '1');
        'V-63827' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'EnableSecureUIAPaths', '1');
        'V-63829' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'EnableLUA', '1');
        'V-63831' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'EnableVirtualization', '1');
        'V-63835' = @('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop\', 'ScreenSaveActive', '1');
        'V-63837' = @('HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop\', 'ScreenSaverIsSecure', '1');
        'V-63839' = @('HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications\', 'NoToastApplicationNotificationOnLockScreen', '1');
        'V-65681' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\', 'DODownloadMode', '0,1,2,99,100');
        'V-68817' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit\', 'ProcessCreationIncludeCmdLine_Enabled', '1');
        'V-68819' = @('HKLM:\SOFTWARE\ Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\', 'EnableScriptBlockLogging', '1');
        'V-71763' = @('HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\Wdigest\', 'UseLogonCredential', '0');
        'V-71765' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections\', 'NC_ShowSharedAccessUI', '0');
        'V-71771' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\', 'DisableWindowsConsumerFeatures', '1');
        'V-74413' = @('HKLM:\SOFTWARE\Policies\Microsoft\ Cryptography\Configuration\SSL\00010002\', 'EccCurves', 'NistP384 NistP256');
    };
}