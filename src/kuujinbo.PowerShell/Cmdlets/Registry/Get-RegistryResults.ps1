<#
.SYNOPSIS
    Get STIG registry results.
.PARAMETER $rules
    Must be in this format:
        
    @{ 'VULNERABILITY-OR-RULE_ID' = @(HKLM:\PATH', 'NAME', 'EXPECTED_VALUE'); };

    'EXPECTED_VALUE' => [string] or [regex]; PowerShell does the right thing,
    including numeric comparisions.
.PARAMETER $getHku
   Get STIG registry results for HKU / HKEY_USERS.
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
    if ($getHku.IsPresent) {
        # ignore **script** user registry hive => HKEY_USERS GPO settings may
        # **NOT** be applied for remote sessions
        $scriptUsername, $scriptUserSid = (whoami.exe /user)[-1] -split '\s+';
        $scriptUsername = $scriptUsername -replace '.*\\', '';
        $loggedIn = gci Registry::HKEY_USERS | 
            where { $_.Name -ne "HKEY_USERS\$scriptUserSid" -and $_.Name -match '^HKEY_USERS\\S-1-5-21-[-\d]+$'; } |
            select $_ -ExpandProperty Name -First 1;
        if ($loggedIn -ne $null) { # HKEY_USERS logged-in user found
            $HKUPathPart = $loggedIn -replace '.*\\', '';
            $HKUUsername =  ' [{0}[' -f (Convert-LoggedInSidToUsername $HKUPathPart);
        } else { # get most recently modified user hive from all user profiles on machine
            $hive = gci c:/users -File -Filter 'ntuser.dat' -Recurse -Depth 1 -Hidden -ErrorAction SilentlyContinue | 
                        where { $_.Directory.Name -ne $scriptUsername; } |
                        sort LastWriteTime -Descending |
                        select -First 1;
            $HKUPathPart = $hive.Directory.Name;
            $HKUUsername = ' [{0}[' -f $HKUPathPart; 
            $HKUKeyName = "HKU\$HKUPathPart";

            $null = REG LOAD $HKUKeyName $hive.FullName;
        }
    }

    $results = @{};
    foreach ($key in $rules.Keys) {
        $params = $rules.$key;
        $regPath = if ([string]::IsNullOrWhiteSpace($HKUPathPart)) { $params[0]; } 
                   else { $params[0] -replace 'HKEY_USERS\\', "HKEY_USERS\$HKUPathPart\"; }
        $expected = $params[2];
        $actual = Get-RegistryValue $regPath $params[1]; 

        if ($actual -ne $null) { # registry setting set => check against expected value
            if ($expected -is [regex]) { $pass = $expected.IsMatch($actual); } 
            else {
                $pass = if (-not $invoke.IsPresent) { $actual -eq $expected; } 
                        else { [bool](Invoke-Expression "$actual $expected"); };
            }
            $results.$key = if ($pass) { # individual .ckl rule field data
                @($CKL_STATUS_PASS, $null, "Not a finding: correct registry setting [$actual].$($HKUUsername)");
            } else {
                @($CKL_STATUS_OPEN, "Incorrect registry setting. ACTUAL: [$actual] :: REQUIRED: [$expected].$($HKUUsername)");
            }
        } else {  # registry setting *NOT** set => OPEN rule
            $results.$key = @($CKL_STATUS_OPEN, "Registry value not set.$($HKUUsername)");
        }
    }

    # clean-up if manually loaded HKEY_USERS hive from the filesystem
    if (![string]::IsNullOrWhiteSpace($HKUKeyName)) {
        [GC]::Collect();
        $null = REG UNLOAD $HKUKeyName;
    }

    return $results;
}