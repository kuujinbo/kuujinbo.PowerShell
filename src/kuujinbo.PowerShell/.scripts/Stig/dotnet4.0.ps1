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
    ,"$PSScriptRoot/../../Cmdlets/IO/Get-PhysicalDrives.ps1"
    ,"$PSScriptRoot/../../Cmdlets/Net/Get-HostInfo.ps1"
    ,"$PSScriptRoot/../../Cmdlets/Stig/.NET/Get-ConfigFileResults.ps1"
);
$dynamicScript = [ScriptBlock]::Create(
    $dynamicScript.ToString() `
    + @'
# Start-Sleep -Seconds (Get-Random -Maximum 10 -Minimum 2);

return Get-ConfigFileResults -allDrives -getHostInfo -ErrorAction SilentlyContinue;
'@
)
# ----------------------------------------------------------------------------
#endregion

Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-dotnet4.0-V1R4.ckl");

$separator = '=' * 40;
$errorFile = (Join-Path $outputDirectory `
    "_errors-$((Get-Date).ToString('yyyy-MM-dd-HH.mm.ss'))-$($env:username).txt"
);

try {
    if ($hosts -and $hosts.Length -gt 0) {
        $jobs = Invoke-Command -ComputerName $hosts -ErrorAction SilentlyContinue `
            -AsJob -ScriptBlock $dynamicScript;
    }

    $completed = 0;
    $sw = [System.Diagnostics.Stopwatch]::StartNew();

    while ($jobs = Get-Job -State Running) {
        $currentHosts = @();
        foreach ($job in $hosts) {
            $currentHosts += $job;
        }

        $seconds = $sw.Elapsed.Totalseconds.ToString('0.00');
        Write-Progress -Activity "Scanning hosts" `
                       -Status "$($runningJobs.Count) scan(s) running. Current runtime $seconds seconds." `
                       -CurrentOperation ($currentHosts -join ',') `
                       -PercentComplete ($completed / $hosts.Length * 100);

        Start-Sleep -Milliseconds 500;
    }

    while ($completedJobs = Get-Job -State Completed) {
        foreach ($job in $runningJobs) {
            $currentHosts += $job.Location;
        }


        
        Get-Job -State Completed | foreach {
            $results = $_ | Receive-Job;
            $_ | Remove-Job;



            if ($results.errors.Length -gt 0) {
                $jobErrors = @"
$($_.Location) Errors:
========================================
$($results.errors)
"@;

                Write-Host $jobErrors;
                $jobErrors >> $errorFile;
            }
            
            Write-Host ('#' * 76);
            Write-Host "[$($_.Location)] scan completed in $seconds seconds. $($results.'files') files scanned";


            $results;
            $cklOutPath = Join-Path $outputDirectory "$((New-Guid).ToString()).ckl"; 
            # $cklOutPath = Join-Path $outputDirectory "$($_.Location).ckl"; 
            Write-Host $cklOutPath;
            Write-Host $TEMPLATE;
            Export-Ckl -cklInPath $TEMPLATE -cklOutPath $cklOutPath -data $results;

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
    # clean up
    Get-Job | Remove-Job -Force;
    Get-PSSession | Remove-PSSession;
    $error.Clear();
}