<#
.SYNOPSIS
    Get registry rules for equality test **OR** 'Value Name does not exist'.
#>
function Get-RegistryRulesEqualOrNoName{
    @{
        'V-63329' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer\', 'SafeForScripting', '0');
        'V-63581' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy\', 'fMinimizeConnections', '1');
        # 'V-63607' = @('HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch\', 'DriverLoadPolicy', '1, 3, 8');
        'V-63627' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\', 'DevicePKInitEnabled', '1');
        'V-63689' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\', 'NoDataExecutionPrevention', '0');
        'V-63691' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\', 'NoHeapTerminationOnCorruption', '0');
        'V-63695' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\', 'PreXPSP2ShellProtocolBehavior', '0');
        'V-63747' = @('HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds\', 'AllowBasicAuthInClear', '0');
        'V-63841' = @('HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments\', 'SaveZoneInformation', '2');
    };
}