<#
#---------------------------------------------------------------------------
    Microsoft .Net Framework 4 STIG - Ver 1, Rel 4
#---------------------------------------------------------------------------
#>
<#
.SYNOPSIS
    Get .NET STIG configuration file rule results.
#>
function Get-ConfigFileResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$path
    )

    # two calls with `-filter` faster than one call with `-include` and multiple extensions
    $files = Get-ChildItem -Path $path -Filter *.exe.config -Recurse -File | foreach { $_.fullname; }
    $files += Get-ChildItem -Path $path -Filter machine.config -Recurse -File | foreach { $_.fullname; }

    $attrRef = 'ref';
    $attrEnabled = 'enabled';
    $rules = @{
        'V-7070'  = @();
        'V-32025' = @();
        'V-30937' = @();
        'V-30968' = @();
        'V-30972' = @();
        'errors'  = @();
    };
    $errors = @();

    foreach ($file in $files) {
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
                        { $rules.'V-7070' += $file; }

                        # V-32025 <channel ref='tcp' secure='true' />
                        if ($channel.GetAttribute($attrRef) -eq 'tcp' `
                            -and $channel.GetAttribute('secure') -ne 'true')
                        { $rules.'V-32025' += $file; }
                    }
                }
            }

            $legacy = $xml.SelectSingleNode('//NetFx40_LegacySecurityPolicy');
            if ($legacy -ne $null `
                -and $legacy.GetAttribute($attrEnabled) -eq 'true') 
            { $rules.'V-30937' += $file; }

            $loadFrom = $xml.SelectSingleNode('//loadFromRemoteSources');
            if ($loadFrom -ne $null `
                -and $loadFrom.GetAttribute($attrEnabled) -eq 'true') 
            { $rules.'V-30968' += $file; }

            $proxy = $xml.SelectNodes('//defaultProxy');
            if ($proxy.Count -gt 0) { $rules.'V-30972' += $file; }
        } catch  {
            $rules.'errors' += "[$file] => $($_.exception.message)";
        }
    }

    $result = [hashtable] (Get-CklResults $rules);
    $result.'files' = $files.Length;
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
    );

    $cklResults = @{
        'errors' = ($results.'errors' -join "`r`n");
    };
    foreach ($key in $results.Keys) {
        if ($key -match '^V-\d+') {
            $fails = [string[]] $results.$key; 
            if ($fails.Length -eq 0) {
                $cklResults.$key = @($CKL_STATUS_PASS, "All scanned files correctly configured.");
            } else {
                $cklResults.$key = @(
                    $CKL_STATUS_OPEN, 
                    "Incorrectly configured files: $($($results.$key) -join "`n")"
                );
            }
        }
    }
    return [hashtable] $cklResults;
}