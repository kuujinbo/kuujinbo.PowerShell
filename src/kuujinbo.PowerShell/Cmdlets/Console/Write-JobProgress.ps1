function Write-JobProgress {
    [CmdletBinding()]
    param(
        # System.Management.Automation.PSRemotingJob
        [Parameter(Mandatory)] $mainJob
        ,[Parameter(Mandatory)] [int]$remaining
    );

    $jobs = $mainJob.ChildJobs;
    $totalJobs = $jobs.Count;

    $running = $jobs | where { $_.State -eq 'running' -and $_.PSEndTime -eq $null; };
    $status = if ($running) { "$($($running | select -ExpandProperty Location) -join ', ')" }
              else { ''; }
    $seconds = ((Get-Date) - $mainJob.PSBeginTime).Totalseconds.ToString('0.00');

    Write-Progress -Activity "$totalJobs total job(s) / $($remaining) remaining. Runtime $seconds seconds." `
                   -Status "Current job(s): [$status]" `
                   -PercentComplete (($totalJobs - $remaining) / $totalJobs * 100);
}