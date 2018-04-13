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
    param(
        [Parameter(Mandatory)] [string]$path
    )

    # two calls with `-filter` faster than one call with `-include` and multiple extensions
    $files = Get-ChildItem -Path $path -Filter *.exe.config -Recurse -File | foreach { $_.fullname; }
    $files += Get-ChildItem -Path $path -Filter machine.config -Recurse -File | foreach { $_.fullname; }

    $attrRef = 'ref';
    $attrEnabled = 'enabled';
    $fail = @{
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
                        { $fail.'V-7070' += $file; }

                        # V-32025 <channel ref='tcp' secure='true' />
                        if ($channel.GetAttribute($attrRef) -eq 'tcp' `
                            -and $channel.GetAttribute('secure') -ne 'true')
                        { $fail.'V-32025' += $file; }
                    }
                }
            }

            $legacy = $xml.SelectSingleNode('//NetFx40_LegacySecurityPolicy');
            if ($legacy -ne $null `
                -and $legacy.GetAttribute($attrEnabled) -eq 'true') 
            { $fail.'V-30937' += $file; }

            $loadFrom = $xml.SelectSingleNode('//loadFromRemoteSources');
            if ($loadFrom -ne $null `
                -and $loadFrom.GetAttribute($attrEnabled) -eq 'true') 
            { $fail.'V-30968' += $file; }

            $proxy = $xml.SelectNodes('//defaultProxy');
            if ($proxy.Count -gt 0) { $fail.'V-30972' += $file; }
        } catch  {
            $fail.'errors' += "[$file] => $($_.exception.message)";
        }
    }

    # return [hashtable] $fail;
    return [hashtable] (Get-CklResults $fail);
}



<#
.SYNOPSIS
    Get parsed scan results.
#>
function Get-CklResults {
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
                $cklResults.$key = @($CKL_STATUS_PASS, "All scanned files correctly configured");
            } else {
                $cklResults.$key = @($CKL_STATUS_OPEN, "Incorrectly configured files: $($results.$key)");
            }
        }
    }

    return [hashtable] $cklResults;
}