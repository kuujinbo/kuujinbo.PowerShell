param(
    [Parameter(Mandatory)][string]$startDirectory
);

#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot 'Modules/Stig/DotNet.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;

# in-memory modules for `Invoke-Command`
$dynamicScript = Get-ScriptBlockFilesForRemote @(
    "$PSScriptRoot/Modules/Stig/cmdlets/ReadOnlyVariables.ps1"
    ,"$PSScriptRoot/Modules/Stig/cmdlets/.NET/Get-ConfigFileResults.ps1"
);
# ----------------------------------------------------------------------------
#endregion

#region main
# ----------------------------------------------------------------------------

# REQUIRED if script runs multiple times from same command prompt; otherwise
# previous runtime errors will be written to subsequent error logs
$error.clear();

$separator = '=' * 40;
$errorFile = (Join-Path $startDirectory `
             "_errors-$((Get-Date).ToString('yyyy-MM-dd-HH.mm.ss'))-$($env:username).txt");
$ckls = Get-ChildItem -Path $startDirectory -Filter *.ckl -File | foreach { $_.fullname; }

foreach ($ckl in $ckls) {
    try {
        $hostname = ([xml](Get-Content $ckl)).CHECKLIST.ASSET.HOST_NAME;
        if (!$hostname) {$hostname = [System.IO.Path]::GetFileNameWithoutExtension($ckl); }

        Write-Output $separator;
        Write-Output "Connecting to [$hostname] => scan will take 40-120 seconds to complete.";
        $sw = [System.Diagnostics.Stopwatch]::StartNew();
        $session = New-PSSession -ComputerName $hostname -ErrorAction Stop;
        Invoke-Command -Session $session -ScriptBlock $dynamicScript -ErrorAction Stop;
    
        # scan remote host
        $cklData = Invoke-Command -Session $session -ErrorAction Stop -ScriptBlock  {
            return Get-ConfigFileResults c:/;
        } -ArgumentList $hostname;

        $out = Join-Path $startDirectory "00-$($hostname).ckl";
        # write .ckl file
        # Export-Ckl $ckl $ckl $cklData;
        Export-Ckl $ckl $out $cklData;
        $sw.Stop();
        if (!$error) {
            Write-Output "Scan for [$hostname] completed in $($sw.elapsed.totalseconds) seconds.";
        }
        else { $error | Out-File -Append $errorFile; }

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