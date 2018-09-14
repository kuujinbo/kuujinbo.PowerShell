function Mount-HKU {

    $HKUKeyName = $HKUUsername = $null;
    $HKUPathPart = $null; # SID **OR** SamAccountName
    $regLoad = $null;     # text [string] output from `REG LOAD` DOS command
    if ($getHku.IsPresent) {
        # current user **CALLING** this function
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
}
