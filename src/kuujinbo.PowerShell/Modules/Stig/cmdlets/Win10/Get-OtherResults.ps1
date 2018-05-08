function Get-OtherResults {
    [CmdletBinding()]
    param()

    $results = @{};

    $winVersion = Get-Win10Version;
    if ($winVersion -ne $null) { $winVersion = [int]$winVersion; } 
    else { $winVersion = 0; } 

    $installedPrograms = Get-ItemProperty hklm:\software\microsoft\windows\currentversion\uninstall\*;


    $results = Get-EqualOrNoName;
    $results += Get-RegistryResults (Get-RegistryRulesRange) -invoke;
    $results += Get-V-63319;
    $results += Get-V-63323;
    $results += Get-V-77083-77085;
    $results += V-63349 $winVersion;
    $results += V-63519-63523-63527 $installedPrograms;
    $results += Get-V-63337;
    $results += Get-V-63353 $installedPrograms;

    return $results;
}

<#
.SYNOPSIS
   Verify local volumes must be formatted using NTFS 
#>
function Get-V-63353 {
    [CmdletBinding()]
    param()

    $drives = Get-Volume | where { $_.DriveType -eq 'Fixed' -and $_.DriveLetter; };
    #         ^^^^^^^^^^ **ONLY** Win10 and above
    $pass = $true;
    $fail = @();
    foreach ($d in $drives) {
        if ($d.FileSystem -ne 'NTFS') {
            $fail += $d.DriveLetter;
            $pass = $false;
        }
    }

    if ($pass) {
        return @{ 'V-63353' = @($CKL_STATUS_PASS, 'All drive(s) formatted using the NTFS file system.'); };

    } else {
        return @{ 'V-63353' = @($CKL_STATUS_OPEN, "Drive(s) not formatted using the NTFS file system: $($a -join ',')"); };
    }
}

<#
.SYNOPSIS
   Verify anti-virus status. 
.TODO
    Verify valid text match for installed anti-visrus program. (McAfee VirusScan Enterprise)
#>
function Get-V-63351 {
    [CmdletBinding()]
    param($installedPrograms);
    
    $hasNA = $installedPrograms | where {$_.displayname -match 'McAfee Agent'};
    if ($hasNA -ne $null) {
        return @{ 'V-63351' = @($CKL_STATUS_PASS, 'Anti-virus solution is installed on the system'); };

    } else {
        return @{ 'V-63351' = @($CKL_STATUS_OPEN, 'Anti-virus solution is not installed on the system'); };
    }
}

<#
.SYNOPSIS
   Verify BitLocker is enabled.
#>
function Get-V-63337 {
    [CmdletBinding()]
    param()

    $bl = (Get-BitlockerVolume -MountPoint "C:");
    #     ^^^^^^^^^^^^^^^^^^^  **ONLY** Win10 and above
    if ($bl -ne $null -and $bl.ProtectionStatus -eq 'On') {
        return @{'V-63337' = @($CKL_STATUS_PASS, "BitLocker is enabled."); }
    } else {
        return @{'V-63337' = @($CKL_STATUS_OPEN, "BitLocker is not enabled."); }
    }
}

<#
.SYNOPSIS
   Get V-63519, V-63523, and V-63527 results. 
.NOTES
    If the system is configured to send audit records directly to an audit
    server, this is NA. This must be documented with the ISSO.    
#>
function V-63519-63523-63527 {
    [CmdletBinding()]
    param($installedPrograms);
    
    $hasNA = $installedPrograms | where {$_.displayname -eq 'UniversalForwarder'};
    if ($hasNA -ne $null) {
        $passDetails = 'System configured to send audit records directly to an audit server using UniversalForwarder.'; 
        return @{
            'V-63519' = @($CKL_STATUS_NA, $passDetails); 
            'V-63523' = @($CKL_STATUS_NA, $passDetails); 
            'V-63527' = @($CKL_STATUS_NA, $passDetails); 
        };

    } else {
        $rules = @{
            'V-63519' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application\', 'MaxSize', '-ge 32768');
            'V-63523' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security\', 'MaxSize', '-ge 196608');
            'V-63527' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System\', 'MaxSize', '-ge 32768');
        };
        return Get-RegistryResults $rules -invoke;
    }
}

<#
.SYNOPSIS
   Verify Win10 version is at a supported servicing level 
#>
function V-63349 {
    [CmdletBinding()]
    param([int]$actual = 0);

    if ($actual -ge 1511) {
        return @{'V-63349' = @($CKL_STATUS_PASS, "[$actual] Is a supported servicing level."); }
    }
    else {
        return @{'V-63349' = @($CKL_STATUS_OPEN, "[$actual] Is not a supported servicing level."); }
    }
}

<#
.SYNOPSIS
   Get V-77083 and V-77085 results. 
.NOTES
    `Confirm-SecureBootUEFI` cmdlet covers V-77083 and V-77085:
    
    https://docs.microsoft.com/en-us/powershell/module/secureboot/confirm-securebootuefi?view=win10-ps
    -- If the computer supports Secure Boot and Secure Boot is enabled, 
       this cmdlet returns $True.

    -- If the computer supports Secure Boot and Secure Boot is disabled, 
       this cmdlet returns $False.

    -- If the computer does not support Secure Boot or is a BIOS (non-UEFI) computer, 
       this cmdlet displays the following:
#>
function Get-V-77083-77085 {
    [CmdletBinding()]
    param()

    try {
        if (Confirm-SecureBootUEFI -ErrorAction Stop) {
            return @{
                'V-77083' = @($CKL_STATUS_PASS, "Configured to run in UEFI mode."); 
                'V-77085' = @($CKL_STATUS_PASS, "Secure Boot enabled."); 
            };
        }
    } catch {
        # TODO: research why this is a WTF 
        # Write-Output "$h => $($_.Exception.Message)";
        # Write-Output "$($_.Exception.Message)";
    }
    return @{
        'V-77083' = @($CKL_STATUS_OPEN, "Not in UEFI mode."); 
        'V-77085' = @($CKL_STATUS_OPEN, "Secure Boot is not enabled."); 
    }
}


<#
.SYNOPSIS
   Verify TPM enabled and ready for use.
#>
function Get-V-63323 {
    [CmdletBinding()]
    param()

    # not sure if native powershell cmdlet Get-Tpm has a way to get versions...
    $namespace = 'root\cimv2\security\microsofttpm';
    try {
        $tpm = Get-WmiObject -Namespace $namespace -Query 'Select * from Win32_tpm';
        if ($tpm) {
            $versions = [Regex]::Split($tpm.SpecVersion, '\s*,\s*');

            $pass = $tpm.IsActivated().IsActivated -and `
                $tpm.IsEnabled().IsEnabled -and `
                # manually checked result => '2.0' not there. (i.e. whole number if no minor versions)
                (($versions -contains '2') -or $versions -contains '1.2');

            if ($pass) { return @{'V-63323' = @($CKL_STATUS_PASS, "TPM enabled and ready for use."); } }
        }
    } catch {
        Write-Output 'ERROR: Get-WmiObject call failed.';
    }

    return @{'V-63323' = @($CKL_STATUS_OPEN, "TPM not enabled."); }
}

<#
.SYNOPSIS
   Verify Windows 10 Enterprise Edition 64-bit version.
#>
function Get-V-63319 {
    [CmdletBinding()]
    param()

    $os = Get-WmiObject Win32_OperatingSystem;
    $arch = $os.OSArchitecture;
    $version = $os.Caption;
    # pass
    if ($arch -eq '64-bit' -and $version -eq 'Microsoft Windows 10 Enterprise') {
        return @{'V-63319' = @($CKL_STATUS_PASS, "Correct Windows Version: [$version $arch]"); };
    }
    # fail
    return @{'V-63319' = @($CKL_STATUS_OPEN, "Incorrect Windows Version: [$version $arch]"); };
}


<#
.SYNOPSIS
    Get W10 STIG registry results where equality test **OR** 'Value Name
    does not exist'.
#>
function Get-EqualOrNoName {
    [CmdletBinding()]
    param()

    $results = @{};
    $rules = Get-RegistryRulesEqualOrNoName;

    foreach ($key in $rules.Keys) {
        $params = $rules.$key;
        $actual = Get-RegistryValue $params[0] $params[1]; 
        $expected = $params[2];
        if ($actual -eq $null) {
            $results.$key = @($CKL_STATUS_PASS, "The Value Name does not exist");
        } elseif ($actual -eq $expected) {
            $results.$key = @($CKL_STATUS_PASS, "Correct registry setting: [$actual]");
        } else {
            @($CKL_STATUS_OPEN, "Incorrect registry setting value: [$actual], expected: [$expected]");
        }
    }
    return $results;
}


function Get-RegistryRulesTEST {
    [CmdletBinding()]
    param()
    @{
        # WTF - check content/fix too complicated for automated check
        'V-63599' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\', 'LsaCfgFlags', '0x00000001 (1) (Enabled with UEFI lock)');
        'V-63603' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\', 'HypervisorEnforcedCodeIntegrity', '0x00000001 (1) (Enabled with UEFI lock), or 0x00000002 (2) (Enabled without lock)');
        'V-63681' = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\', 'LegalNoticeCaption', '"DoD Notice and Consent Banner", "US Department of Defense Warning Statement"');
        'V-63697' = @('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\', 'SCRemoveOption', '1 (Lock Workstation) or 2 (Force Logoff)');
        # If SEHOP is configured through the Enhanced Mitigation Experience Toolkit (EMET), this registry setting is NA
        'V-68849' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel\', 'DisableExceptionChainValidation', '0x00000000 (0)');
        'V-71769' = @('HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\', 'RestrictRemoteSAM', 'O:BAG:BAD:(A;;RC;;;BA)');
        'V-72329' = @('HKLM:\SOFTWARE\Classes\batfile\shell\runasuser\', 'SuppressionPolicy', '4096');
        <#
\SOFTWARE\Classes\batfile\shell\runasuser\
\SOFTWARE\Classes\cmdfile\shell\runasuser\
\SOFTWARE\Classes\exefile\shell\runasuser\
\SOFTWARE\Classes\mscfile\shell\runasuser\
        #>

        # v1607
        'V-63685' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\', 'EnableSmartScreen', '1');
        # v1703 also needs this
        # 'V-63685' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\', 'ShellSmartScreenLevel', 'Block');
        # v1703
        'V-74415' = @('HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\ Privacy\', 'ClearBrowsingHistoryOnExit', '0');
        # v1703 NA for prior versions
        'V-74417' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR\', 'AllowGameDVR', '0');
        # v1703 NA for prior versions
        'V-74699' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\', 'AllowProtectedCreds', '1');
        # if V-70639 is configured NA.
        'V-74723' = @('HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\', 'SMB1', '0');
        # if V-70639 is configured NA.
        'V-74725' = @('HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10\', 'Start', '4');
        # NA prior to v1709 
        'V-77025' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection\', 'DisallowExploitProtectionOverride', '1');

        'V-63661' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'MaximumPasswordAge', '30 (or less, excluding 0)');
        'V-74413' = @('HKLM:\SOFTWARE\Policies\Microsoft\ Cryptography\Configuration\SSL\00010002\', 'EccCurves', 'NistP384 NistP256');
    };
}