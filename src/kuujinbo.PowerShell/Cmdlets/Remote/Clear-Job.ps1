<#
.SYNOPSIS
    Clean up a remote job on completion.
#>
function Clear-Job {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [System.Management.Automation.Job]$rootJob
    );

    $sb = New-Object System.Text.StringBuilder;
    foreach ($fail in $rootJob.ChildJobs | where { $_.State -ne 'Completed'; } ) {
        $null = $sb.AppendLine(
            "$($fail.Location) => $($fail.State) => $($fail.JobStateInfo.Reason.Message)"
        );
    }
    Get-PSSession | Remove-PSSession;
    Get-Job | Remove-Job -Force;
    $error.Clear();

    $sb.ToString() | Write-Host -ForegroundColor Red -BackgroundColor Black;
}