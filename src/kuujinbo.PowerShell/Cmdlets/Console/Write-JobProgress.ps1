function Write-JobProgress {
    [CmdletBinding()]
    param(
        # System.Management.Automation.PSRemotingJob
        [Parameter(Mandatory)] $mainJob
        ,[Parameter(Mandatory)] [int]$remaining
    );

    $jobs = $mainJob.ChildJobs;
    $totalJobs = $jobs.Count;
    $queued = ($jobs | where { $_.State -eq 'notstarted'; }).Count;

    $running = $jobs | where { $_.State -eq 'running' -and $_.PSEndTime -eq $null; };
    $status = if ($running) { "$($($running | select -ExpandProperty Location) -join ', ')" }
              else { ''; }
    $elapsed = ((Get-Date) - $mainJob.PSBeginTime).ToString('mm\:ss\.ff');

    Write-Progress -Activity "$totalJobs total job(s). $remaining remaining / $queued queued. Runtime $elapsed." `
                   -Status "$($running.Count) running: [$status]" `
                   -PercentComplete (($totalJobs - $remaining) / $totalJobs * 100);
}