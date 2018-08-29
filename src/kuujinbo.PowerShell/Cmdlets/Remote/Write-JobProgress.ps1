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
    $elapsed = ((Get-Date) - $rootJob.PSBeginTime).ToString('mm\:ss\.ff');
    $percentComplete = ($totalJobs - $remaining) / $totalJobs * 100; 
    if (!$percentComplete) { $percentComplete = 0; }    # script start

    Write-Progress -Activity "$($jobName)$totalJobs total job(s). $remaining remaining / $queued queued. Runtime $elapsed." `
                   -Status ('{0:0.##}% complete' -f $percentComplete ) `
                   -PercentComplete $percentComplete;
}