<#
.SYNOPSIS
    Get simple completion status text for a PowerShell background job.
#>
function Get-CompletedJobText {
    [CmdletBinding()]
    param(
        # System.Management.Automation.PSRemotingJob
        [Parameter(Mandatory)] $job
        ,[switch]$mainJob
    );
    
    $runtime = ($job.PSEndTime - $job.PSBeginTime).Totalseconds.ToString('0.00'); 
    $result = if ($mainJob.IsPresent) { "All jobs completed in $runtime seconds."; }
              # child job
              else { "Job complete on $($job.Location) in $runtime seconds."; }

    return $result;
}