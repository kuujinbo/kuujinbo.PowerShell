<#
.SYNOPSIS
    Write PowerShell remote background job progress.
#>
function Write-JobProgress {
    [CmdletBinding()]
    param(
        # System.Management.Automation.PSRemotingJob
        [Parameter(Mandatory)] $rootJob
        ,[string]$jobName = ''
    );

    if ($jobName) { $jobName = "[$jobName] - "; };
    $childJobs = $rootJob.ChildJobs;
    $totalJobs = $childJobs.Count;
    $queued = ($childJobs | where { $_.State -eq 'notstarted'; }).Count;
    $remaining = $totalJobs - ($childJobs | where { $_.State -eq 'Completed'; }).Count;

    $running = $childJobs | where { $_.State -eq 'running' -and $_.PSEndTime -eq $null; };
    $status = if ($running) { "$($($running | select -ExpandProperty Location) -join ', ')" }
              else { ''; }
    $elapsed = ((Get-Date) - $rootJob.PSBeginTime).ToString('mm\:ss\.ff');

    Write-Progress -Activity "$($jobName)$totalJobs total job(s). $remaining remaining / $queued queued. Runtime $elapsed." `
                   -Status "$($running.Count) running: [$status]" `
                   -PercentComplete (($totalJobs - $remaining) / $totalJobs * 100);
}