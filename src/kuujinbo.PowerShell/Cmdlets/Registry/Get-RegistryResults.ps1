<#
.SYNOPSIS
    Get STIG registry results.
.PARAMETER $rules
    [1] MUST be in this format:
        
    @{ 'VULNERABILITY-OR-RULE_ID' = @(HKLM:\PATH', 'NAME', 'EXPECTED_VALUE'); };

    'EXPECTED_VALUE' => [string] or [regex]; PowerShell does the right thing,
    including numeric comparisions.

    [2] For HKU / HKCU, the registry path MUST be in the following format:
        Registry::HKEY_USERS\REST-OF-PATH

        A user SID or SamAccountName will dynamically be appended to each 
        'HKEY_USERS\' path part to query the correct registry setting.
.PARAMETER $getHku
   Get HKU / HKCU registry results.
#>
function Get-RegistryResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable]$rules
        ,[switch] $getHku
        ,[switch] $invoke
    );

    $HKUKeyName = $null;
    $HKUUsername = $null;
    $HKUPathPart = $null; # SID **OR** SamAccountName
    $regLoad = $null;     # text [string] output from `REG LOAD` DOS command
    if ($getHku.IsPresent) {
        # ignore **script** user registry hive => HKEY_USERS GPO settings may
        # **NOT** be applied for remote sessions
        $scriptUsername, $scriptUserSid = (whoami.exe /user)[-1] -split '\s+';
        $loggedIn = gci Registry::HKEY_USERS | 
            where { $_.Name -ne "HKEY_USERS\$scriptUserSid" -and $_.Name -match '^HKEY_USERS\\S-1-5-21-[-\d]+$'; } |
            select $_ -ExpandProperty Name -First 1;
        if ($loggedIn -ne $null) { # HKEY_USERS logged-in user found
            $HKUPathPart = $loggedIn -replace '.*\\', '';
            $HKUUsername =  ' ({0})' -f (Convert-LoggedInSidToUsername $HKUPathPart);
        } else { # get most recently modified user hive from all user profiles on machine
            $baseUsername = $scriptUsername -replace '.*\\', '';
            $hive = gci c:/users -File -Filter 'ntuser.dat' -Recurse -Depth 1 -Hidden -ErrorAction SilentlyContinue | 
                        where { $_.Directory.Name -ne $baseUsername; } |
                        sort LastWriteTime -Descending |
                        select -First 1;
            $HKUPathPart = $hive.Directory.Name;
            $HKUUsername = ' ({0})' -f $HKUPathPart; 
            $HKUKeyName = "HKU\$HKUPathPart";

            $regLoad = REG LOAD $HKUKeyName $hive.FullName 2> $null;
        }
    }

    $results = @{};
    foreach ($key in $rules.Keys) {
        $params = $rules.$key;
        $keyPath = $params[0];
        <#
        $regPath = if ([string]::IsNullOrWhiteSpace($HKUPathPart)) { $params[0]; } 
                   else { $params[0] -replace 'HKEY_USERS\\', "HKEY_USERS\$HKUPathPart\"; }
                   #>
        $regPath, $findingPath = if ($keyPath.StartsWith('HKLM:')) { 
            @(
                $keyPath
                $keyPath.Replace('HKLM:', '')
            ); 
        } else { 
            @(
                $keyPath.Replace('HKEY_USERS\', "HKEY_USERS\$HKUPathPart\")
                $keyPath.Replace('Registry::HKEY_USERS', '')
            );
        }
        $regName = $params[1];
        $expected = $params[2];
        $actual = Get-RegistryValue $regPath $regName; 
        $findingText = @"
$findingPath ($regName).$($HKUUsername)

{0}
"@;

        if ($actual -ne $null) { # registry setting set => check against expected value
            if ($expected -is [regex]) { $pass = $expected.IsMatch($actual); } 
            else {
                $pass = if (-not $invoke.IsPresent) { $actual -eq $expected; } 
                        else { [bool](Invoke-Expression "$actual $expected"); };
            }
            $results.$key = if ($pass) { # individual .ckl rule field data
                @($CKL_STATUS_PASS, 
                    $null, 
                    ($findingText -f "Not a finding: registry value setting: [$actual]")
                );
            } else {
                @($CKL_STATUS_OPEN, 
                    ($findingText -f "Incorrect registry setting. ACTUAL: [$actual] :: REQUIRED: [$expected]")
                );
            }
        } else {  # registry setting *NOT** set => OPEN rule
            $results.$key = @($CKL_STATUS_OPEN, 
                ($findingText -f "Registry value not set")
            );
        }
    }

    # clean-up if manually loaded HKEY_USERS hive from the filesystem
    if (![string]::IsNullOrWhiteSpace($regLoad) -and `
        ![string]::IsNullOrWhiteSpace($HKUKeyName)) 
    {
        [GC]::Collect();
        $null = REG UNLOAD $HKUKeyName 2> $null;
    }

    return $results;
}