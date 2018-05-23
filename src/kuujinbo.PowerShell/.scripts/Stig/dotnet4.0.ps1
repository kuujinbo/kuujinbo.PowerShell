param(
    # contains .ckl files with previous scan results
    [Parameter(ParameterSetName='cklDirectory')][string]$cklDirectory

    # .txt file: one/more hostname per line. NO previous scan results.
    ,[Parameter(ParameterSetName='hostfile')][string]$hostfile

    # command line: CSV hostname(s). NO previous scan results.
    ,[Parameter(ParameterSetName='hosts')][string[]]$hosts

    ,[Parameter(ParameterSetName='hostfile', Mandatory=$true)]
    [Parameter(ParameterSetName='hosts', Mandatory=$true)]
    [Parameter(ParameterSetName='cklDirectory')]
    [string]$outputDirectory

    # blank template .ckl ONLY used for these parameter sets
    ,[Parameter(ParameterSetName='hostfile')]
    [Parameter(ParameterSetName='hosts')]
    [switch]$useTemplate=$true

    ,[switch]$allDrives
    ,[switch]$testMode
);

#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot '../../Modules/Stig/DotNet4.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;

# in-memory modules for `Invoke-Command`
$dynamicScript = Get-ScriptBlockFilesForRemote @(
    "$PSScriptRoot/../../Cmdlets/Stig/ReadOnlyVariables.ps1"
    "$PSScriptRoot/../../Cmdlets/IO/Get-PhysicalDrives.ps1"
    ,"$PSScriptRoot/../../Cmdlets/Stig/.NET/Get-ConfigFileResults.ps1"
);
# ----------------------------------------------------------------------------
#endregion


try {
    if ($hosts -and $hosts.Length -gt 0) {
        foreach ($hostname in $hosts) {
            try {
                $session = New-PSSession -ComputerName $hostname -ErrorAction Stop;
                Invoke-Command -Session $session -ScriptBlock $dynamicScript -ErrorAction Stop;
                Invoke-Command -Session $session -ErrorAction Stop -AsJob -ScriptBlock  {
                    # Start-Sleep -Seconds (Get-Random -Maximum 20 -Minimum 10);
                    # return Get-PhysicalDrives;
                    return Get-ConfigFileResults c:/;
                } -ArgumentList $hostname | Out-Null;
                Write-Host "Starting [$hostname] scan....";
            } catch {
                $e = '';
                #$e = "[$hostname] => $($_.Exception.Message)";
                #$e | Out-File -Append $errorFile;
                $e | Write-Host -ForegroundColor Red -BackgroundColor Yellow;
            }

        }
    }

    $completed = 0;
    $sw = [System.Diagnostics.Stopwatch]::StartNew();

    while ($runningJobs = Get-Job -State Running) {
        $currentHosts = @();
        foreach ($job in $runningJobs) {
            $currentHosts += $job.Location;
        }

        $seconds = $sw.Elapsed.Totalseconds.ToString('0.00');
        Write-Progress -Activity "Scanning hosts" `
                       -Status "$($runningJobs.Count) scan(s) running. Current runtime $seconds seconds." `
                       -CurrentOperation ($currentHosts -join ',') `
                       -PercentComplete ($completed / $hosts.Length * 100);

        Start-Sleep -Milliseconds 500;

        Get-Job -State Completed | foreach {
            $results = $_ | Receive-Job;
            $_ | Remove-Job;
            Write-Host ('#' * 76);
            Write-Host "[$($_.Location)] scan completed in $seconds seconds. $($results.'files') files scanned";
            Write-Host $results;
            ++$completed;
        };

    }

    $sw.Stop();
    Write-Host "All scans completed in $($sw.Elapsed.Totalseconds.ToString('0.00')) seconds."
} catch {
    $e = '';
    #$e = "[$hostname] => $($_.Exception.Message)";
    #$e | Out-File -Append $errorFile;
    $e | Write-Host -ForegroundColor Red -BackgroundColor Yellow;
} finally {
    Get-PSSession | Remove-PSSession;
}