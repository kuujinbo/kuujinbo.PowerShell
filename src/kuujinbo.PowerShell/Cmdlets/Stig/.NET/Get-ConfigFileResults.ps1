<#
#---------------------------------------------------------------------------
    Microsoft .Net Framework 4 STIG - Ver 1, Rel 4
#---------------------------------------------------------------------------
#>

<#
.SYNOPSIS
    Get .NET STIG configuration file rule results.
.NOTES
    DISA STIG viewer 2.7
#>
function Get-ConfigFileResults {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='paths', Mandatory=$true)]
        [string[]]$paths

        # see /Cmdlets/IO/Get-PhysicalDrives.ps1
        ,[Parameter(ParameterSetName='allDrives', Mandatory=$true)]
        [switch]$allDrives

        ,[switch]$getHostInfo
    );

    $attrRef = 'ref';
    $attrEnabled = 'enabled';
    $rules = @{
        # V-7070 / SV-7453r2_rule
        'SV-7453r2_rule'  = @();
        # V-30937 
        'SV-40979r1_rule' = @();
        # V-30968
        'SV-41010r1_rule' = @();
        # V-30972
        'SV-41014r1_rule' = @();
        # V-32025
        'SV-42341r1_rule' = @();
    };

    if ($allDrives.IsPresent) {
        $paths = @();
        foreach ($drive in Get-PhysicalDrives) { 
            $paths += "$($drive.DriveLetter)/"; 
        }
    }
    $files = getDotnetFiles $paths;
    $fileCount = $files.files.Length;
    $rules.fileCount = $fileCount;

    foreach ($file in $files.files) {
        try {
            # M$ WTF => C:\Windows\WinSXS config files contain hexadecimal values
            [xml]$xml = Get-Content -Path $file -ErrorAction Stop;

            # V-7070 and V-32025 - crappiest written STIG rules ever....
            # typos and incorrect schema according to M$ documentation:
            # https://msdn.microsoft.com/en-us/library/z415cf9a(v=vs.100).aspx
            $channels = $xml.SelectNodes('//channel');
            # <channel> => https://msdn.microsoft.com/en-us/library/c5zztdc3(v=vs.100).aspx
            foreach ($channel in $channels) {
                $formatters = $channel.SelectNodes('descendant::formatter');
                # <formatter> => https://msdn.microsoft.com/en-us/library/ka23a3hs(v=vs.100).aspx
                foreach ($formatter in $formatters) {
                    if ($formatter.GetAttribute('typeFilterLevel') -eq 'full') {
                        # V-7070  <channel ref='http' port='443' /> 
                        if ($channel.GetAttribute($attrRef) -eq 'http' `
                            -and $channel.GetAttribute('port') -ne '443') 
                        { $rules.'SV-7453r2_rule' += $file; }

                        # V-32025 <channel ref='tcp' secure='true' />
                        if ($channel.GetAttribute($attrRef) -eq 'tcp' `
                            -and $channel.GetAttribute('secure') -ne 'true')
                        { $rules.'SV-42341r1_rule' += $file; }
                    }
                }
            }

            $legacy = $xml.SelectSingleNode('//NetFx40_LegacySecurityPolicy');
            if ($legacy -ne $null `
                -and $legacy.GetAttribute($attrEnabled) -eq 'true') 
            # V-30937
            { $rules.'SV-40979r1_rule' += $file; }

            $loadFrom = $xml.SelectSingleNode('//loadFromRemoteSources');
            if ($loadFrom -ne $null `
                -and $loadFrom.GetAttribute($attrEnabled) -eq 'true') 
            # V-30968
            { $rules.'SV-41010r1_rule' += $file; }

            $proxy = $xml.SelectNodes('//defaultProxy');
            # V-30972
            if ($proxy.Count -gt 0) { $rules.'SV-41014r1_rule' += $file; }
        } catch  {
            $rules.'errors' += "[$file] => $($_.exception.message)";
        }
    }

    $result = [hashtable] (Get-CklResults $rules $fileCount);

    $result.fileCount = $fileCount;
    $result.errors = ($rules.'errors' -join "`r`n");
    if ($getHostInfo.IsPresent) { $result.'hostinfo' = Get-HostInfo; }

    return $result
}

<#
.SYNOPSIS
    Get parsed scan results.  
#>
function Get-CklResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$results
        ,[Parameter(Mandatory)][int]$total
    );

    $parsedResults = @{};
    foreach ($key in $results.Keys) {
        $fails = [string[]] $results.$key; 
        $failCount = $fails.Length;
        if ($failCount -eq 0) {
            $parsedResults.$key = @($CKL_STATUS_PASS, "All ($total) scanned files correctly configured.");
        } else {
            $parsedResults.$key = @(
                $CKL_STATUS_OPEN, 
                "($failCount) out of ($total) files incorrectly configured: $($($results.$key) -join "`n")"
            );
        }
    }
    return [hashtable] $parsedResults;
}

#region helpers
function getDotnetFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$paths
    );

    $files = @();
    $errors = @();
    foreach ($path in $paths) {
        # two calls with `-filter` faster than one call with `-include` and multiple extensions
        $files += Get-ChildItem -Path $path -Filter *.exe.config -Recurse -File `
                -ErrorVariable WTF -ErrorAction SilentlyContinue `
                | foreach { $_.fullname; }
        $errors += $WTF | foreach { $_.Exception.Message; }

        $WTF = $null;
        $files += Get-ChildItem -Path $path -Filter machine.config -Recurse -File `
                -ErrorVariable WTF -ErrorAction SilentlyContinue `
                | foreach { $_.fullname; }
    }

    return @{
        'files' = $files;
        'errors' = $errors;
    };
}
#endregion