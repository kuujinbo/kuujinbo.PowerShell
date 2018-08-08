<#
.SYNOPSIS
    Get STIG registry results.
.PARAMETER $rules
    Must be in this format:
        
    @{
        'VULNERABILITY-OR-RULE_ID' = @(HKLM:\PATH', 'NAME', 'EXPECTED_VALUE');
    };

    'EXPECTED_VALUE' => [string] or [regex]. (PowerShell does the right thing
    when making string/numeric equality tests)
.NOTES
    Retrieving remote HKEY_USERS settings requires special processing; no
    guarantee any GPO(s) will be applied.
#>
function Get-RemoteHkuRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable]$rules
        ,[Parameter(Mandatory)] [string]$currentUserName
        ,[Parameter(Mandatory)] [string]$currentSID
        ,[switch] $invoke
    );

    # check if there are any currently logged-in users
    $name, $sid = (whoami.exe /user)[-1] -split '\s+';
    $name = $name -replace '.*\\', '';
    $loggedIn = gci Registry::HKEY_USERS | 
        where { $_.Name -ne "HKEY_USERS\$sid" -and $_.Name -match '^HKEY_USERS\\S-1-5-21-[-\d]+$'; } |
        select $_ -ExpandProperty Name  -First 1;

    $registryLoaded = $false;
    if ($loggedIn -ne $null) {
        $sid = $loggedIn -replace '.*\\', '';
        $registryLoaded = $true;
    } else {
        $hive = gci c:/users -File -Filter 'ntuser.dat' `
                 -Recurse -Depth 1 -Hidden -ErrorAction SilentlyContinue | 
                 where { $_.Directory.Name -ne $name; } |
                 sort LastWriteTime -Descending |
                 select -First 1;

        $hivePath = $hive.FullName;
        $username = $hive.Directory.Name;
        $tempPath = "HKU\$username";
        Write-host $tempPath;
        $null = REG LOAD $tempPath $hivePath;
    }

    # TODO:
    # [1] parse paths above / update $rules path
    # [2] pass new data structure into Get-RegistryValue 
    # [3] track 'Open' rules => rule ID / host
    # [4] add queried username / SID.

    $results = @{};

    # clean-up if we manually loaded hive 
    if (!$registryLoaded) {
        [GC]::Collect();
        $null = REG UNLOAD $tempPath;
    }

    return $results;
}