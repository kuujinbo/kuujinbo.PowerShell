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
$sw = [System.Diagnostics.Stopwatch]::StartNew();

try {
    if ($hosts -and $hosts.Length -gt 0) {
        $mainJob = Invoke-Command -ComputerName $hosts -ErrorAction SilentlyContinue `
            -ThrottleLimit 5 `
            -AsJob -ScriptBlock $dynamicScript;
    }

    $jobs = $mainJob.ChildJobs;
    $totalJobs = $jobs.Count;


    while ($mainJob.PSEndTime -eq $null) {

        while ($remaining = $jobs | where { $_.HasMoreData }) {
            $seconds = $sw.Elapsed.Totalseconds.ToString('0.00');
            $finished = $jobs | where { $_.PSEndTime; };
            foreach ($f in $finished) {            
                if ($f.HasMoreData) { 
                    $result = $f | Receive-Job;
                    #$result;
                    $cklOutPath = Join-Path $outputDirectory "$((New-Guid).ToString()).ckl"; 
                    # $cklOutPath = Join-Path $outputDirectory "$($_.Location).ckl"; 
                    Export-Ckl -cklInPath $TEMPLATE -cklOutPath $cklOutPath -data $result;
                    
                    Write-Host "$(Get-CompletedJobText $f)" ; 
                }

                if ($results.errors.Length -gt 0) {
                    $jobErrors = @"
$($_.Location) Errors:
========================================
$($results.errors)
"@;
                    Write-Host $jobErrors;
                    $jobErrors >> $errorFile;
                }
            }

            $running = $jobs | where { $_.State -eq 'running' -and $_.PSEndTime -eq $null; };
            $status = if ($running) { "$($($running | select -ExpandProperty Location) -join ', ')" }
                        else { ''; }

            Write-Progress -Activity "$totalJobs total job(s) / $($remaining.Count) remaining. Runtime $seconds seconds." `
                            -Status "Current job(s): [$status]" `
                            -PercentComplete (($totalJobs - $remaining.Count) / $totalJobs * 100);

            Start-Sleep -Milliseconds 500;
        }
    }

    Write-Host (Get-CompletedJobText $mainJob -mainJob);
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