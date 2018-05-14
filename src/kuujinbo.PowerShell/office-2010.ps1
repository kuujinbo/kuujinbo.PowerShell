param(
    [Parameter(Mandatory)][string]$cklDirectory
);

#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot 'Modules/Stig/Office2010.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;

# in-memory modules for `Invoke-Command`
$dynamicScript = Get-ScriptBlockForRemote @(
    "$PSScriptRoot/Modules/Stig/cmdlets"
    ,"$PSScriptRoot/Modules/Stig/cmdlets/Office2010"
);
# ----------------------------------------------------------------------------
#endregion

#region main
# ----------------------------------------------------------------------------

# REQUIRED if script runs multiple times from same command prompt; otherwise
# previous runtime errors will be written to subsequent error logs
$error.clear();

$separator = '=' * 40;
$errorFile = (Join-Path $cklDirectory `
             "_errors-$((Get-Date).ToString('yyyy-MM-dd-HH.mm.ss'))-$($env:username).txt");
$ckls = Get-ChildItem -Path $cklDirectory -Filter *.ckl -File | foreach { $_.fullname; }

foreach ($ckl in $ckls) {
    try {
        $hostname = ([xml](Get-Content $ckl)).CHECKLIST.ASSET.HOST_NAME;
        if (!$hostname) {$hostname = [System.IO.Path]::GetFileNameWithoutExtension($ckl); }

        Write-Output $separator;
        Write-Output "Connecting to [$hostname] ....";
        $sw = [System.Diagnostics.Stopwatch]::StartNew();
        $session = New-PSSession -ComputerName $hostname -ErrorAction Stop;
        Invoke-Command -Session $session -ScriptBlock $dynamicScript -ErrorAction Stop;
    
        # scan remote host
        $cklData = Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock  {
            $global:cklData = @{};
            Write-Host 'Scanning Access Registry....';
            $global:cklData += Get-RegistryResults (Get-Access2010Registry);
            Write-Host 'Scanning Excel Registry....';
            $global:cklData += Get-RegistryResults (Get-Excel2010Registry);
            Write-Host 'Scanning OneNote Registry....';
            $global:cklData += Get-RegistryResults (Get-OneNote2010Registry);
            Write-Host 'Scanning Outlook Registry....';
            $global:cklData += Get-RegistryResults (Get-Outlook2010Registry);
            Write-Host 'Scanning PowerPoint Registry....';
            $global:cklData += Get-RegistryResults (Get-Pp2010Registry);
            Write-Host 'Scanning Word Registry....';
            $global:cklData += Get-RegistryResults (Get-Word2010Registry);
            Write-Host 'Scanning Registry requiring multiple key/value pair checks....';
            $global:cklData += Get-RegistryResultsMultiple (Get-Office2010OneOffRegistry);

            return $global:cklData; 
        } -ArgumentList $hostname;


        $cklData.keys.count;


        $out = Join-Path $cklDirectory "00-$($hostname).ckl";
        # write .ckl file
        # Export-Ckl $ckl $ckl $cklData;
        Export-Ckl $ckl $out $cklData -dataRuleIdKey;
        $sw.Stop();

        #if (!$error) {
        #    Write-Output "Scan for [$hostname] completed in $($sw.elapsed.totalseconds) seconds.";
        #}
        #else { $error | Out-File -Append $errorFile; }

        # write errors from scan results
        if ($cklData.'errors'.length -gt 0) {
            "$separator`r`n$hostname" | Out-File -Append $errorFile; 
            $cklData.'errors' | Out-File -Append $errorFile; 
            $separator | Out-File -Append $errorFile; 
        } 

        Remove-PSSession $session;
    } catch {
        $e = '';
        $e = "[$hostname] => $($_.Exception.Message)";
        $e | Out-File -Append $errorFile;
        $e | Write-Host -ForegroundColor Red -BackgroundColor Black;
    }
}

Get-PSSession | Remove-PSSession;
# ----------------------------------------------------------------------------
#endregion