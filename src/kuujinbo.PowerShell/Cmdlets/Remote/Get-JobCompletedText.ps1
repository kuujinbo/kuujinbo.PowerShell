<#
.SYNOPSIS
    Get PowerShell remote background job simple completion status text.
#>
function Get-JobCompletedText {
    [CmdletBinding()]
    param(
        # System.Management.Automation.PSRemotingJob
        [Parameter(Mandatory)] $job
        ,[string]$jobName = ''
        ,[switch]$rootJob
    );
    
    if ($jobName) { $jobName = "[$jobName] - "; };
    $runtime = ($job.PSEndTime - $job.PSBeginTime).ToString('mm\:ss\.ff');
    $result = if ($rootJob.IsPresent) { "$($jobName)All jobs completed in $runtime."; }
              # child job
              else { "$($jobName)Job completed on $($job.Location) in $runtime."; }

    return $result;
}