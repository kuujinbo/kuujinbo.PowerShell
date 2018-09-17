<#
.SYNOPSIS
    Load or parse a user hive to satisfy HKCU registry verification.
.NOTES
    -- Script-level variables set:
       ** $script:_HKU_MOUNTED  => successfully found / loaded a user hive
       ** $script:_HKU_USER_ID => username **OR** SID
    -- The calling user's registry hive **ALWAYS** ignored; GPO settings only
       applied for interactive login; function assumes it's being called from
       a remote session.
#>
function Mount-HKU {
    [CmdletBinding()]
    param( )
    
    if (!$script:_HKU_MOUNTED) {
        $HKUKeyName = $HKUUsername = $null;
        # $HKUPathPart = $null; # SID **OR** SamAccountName
        if ($getHku.IsPresent) {
            # current user **CALLING** this function
            $scriptUsername, $scriptUserSid = (whoami.exe /user)[-1] -split '\s+';
            $loggedIn = gci Registry::HKEY_USERS | 
                where { $_.Name -ne "HKEY_USERS\$scriptUserSid" -and $_.Name -match '^HKEY_USERS\\S-1-5-21-[-\d]+$'; } |
                select $_ -ExpandProperty Name -First 1;
            if ($loggedIn -ne $null) { # HKEY_USERS logged-in user found
                $sid = $loggedIn -replace '.*\\', '';
                $script:_HKU_USER_ID = (Convert-LoggedInSidToUsername $sid);

                $script:_HKU_MOUNTED = $true;
            } else { # get most recently modified user hive from all user profiles on machine
                $baseUsername = $scriptUsername -replace '.*\\', '';
                $hive = gci c:/users -File -Filter 'ntuser.dat' -Recurse -Depth 1 -Hidden -ErrorAction SilentlyContinue | 
                            where { $_.Directory.Name -ne $baseUsername; } |
                            sort LastWriteTime -Descending |
                            select -First 1;
                
                if ($hive) {
                    $script:_HKU_USER_ID = $hive.Directory.Name;
                    # ~/Cmdlets/Stig/ReadOnlyVariables.ps1
                    $keyName = "$($REGISTRY_HIVE.HKEY_USERS)\$($script:_HKU_USER_ID)";
                    $regLoadOutput = REG LOAD $keyName $hive.FullName 2> $null;
                    if ($regLoadOutput) { 
                        $script:_HKU_MOUNTED = $true; 
                    }
                }
            }
        }
    }
}
