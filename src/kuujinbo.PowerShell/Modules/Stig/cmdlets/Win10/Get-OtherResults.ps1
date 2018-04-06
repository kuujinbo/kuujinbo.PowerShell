function Get-OtherResults {
    $results = @{};

    $results = Get-EqualOrNoName;
    $results += Get-RegistryResults (Get-RegistryRulesRange) -invoke;
    $results += Get-V-63319;
    $results += Get-V-63323;
    $results += Get-V-77083;

    return $results;
}

function Get-V-77083 {
    try {
        if (Confirm-SecureBootUEFI -ErrorAction Stop) {
            return @{'V-77083' = @($CKL_STATUS_PASS, "Configured to run in UEFI mode."); };
        }
    } catch {
        # TODO: research why this is a WTF 
        # Write-Output "$h => $($_.Exception.Message)";
        # Write-Output "$($_.Exception.Message)";
    }
    return @{'V-77083' = @($CKL_STATUS_OPEN, "Not in UEFI mode."); }
}

function Get-V-63323 {
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

function Get-V-63319 {
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



        # If the system is configured to send audit records directly to an audit server, this is NA. This must be documented with the ISSO.
        'V-63519' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application\', 'MaxSize', '0x00008000 (32768) (or greater)');
        'V-63523' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security\', 'MaxSize', '0x00030000 (196608) (or greater)');
        'V-63527' = @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System\', 'MaxSize', '0x00008000 (32768) (or greater)');




        'V-63661' = @('HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters\', 'MaximumPasswordAge', '30 (or less, excluding 0)');
        'V-74413' = @('HKLM:\SOFTWARE\Policies\Microsoft\ Cryptography\Configuration\SSL\00010002\', 'EccCurves', 'NistP384 NistP256');
    };
}