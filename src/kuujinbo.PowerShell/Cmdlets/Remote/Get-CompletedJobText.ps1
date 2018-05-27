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
    
    $runtime = ($job.PSEndTime - $job.PSBeginTime).ToString('mm\:ss\.ff');
    $result = if ($mainJob.IsPresent) { "All jobs completed in $runtime."; }
              # child job
              else { "Job completed on $($job.Location) in $runtime."; }

    return $result;
}