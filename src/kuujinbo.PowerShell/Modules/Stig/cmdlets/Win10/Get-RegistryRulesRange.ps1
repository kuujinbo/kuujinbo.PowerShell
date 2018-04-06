<#
.SYNOPSIS
    Get registry rules where value is within a range.
#>
function Get-RegistryRulesRange {
    @{
        'V-63687' = @('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\', 'CachedLogonsCount', '-le 10');
        'V-63715' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\', 'autodisconnect', '-le 15');
        'V-63721' = @('HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork\PINComplexity\', 'MinimumPINLength', '-ge 6');
    };
}