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
$dynamicScript = Get-ScriptBlockFromFiles -psFiles @(
    "$PSScriptRoot/../../Cmdlets/Stig/ReadOnlyVariables.ps1"
    ,"$PSScriptRoot/../../Cmdlets/IO/Get-PhysicalDrives.ps1"
    ,"$PSScriptRoot/../../Cmdlets/Net/Get-HostInfo.ps1"
    ,"$PSScriptRoot/../../Cmdlets/Stig/.NET/Get-ConfigFileResults.ps1"
) -inlineBlock @'
# Start-Sleep -Seconds (Get-Random -Maximum 10 -Minimum 2);

# return Get-ConfigFileResults -allDrives -getHostInfo -ErrorAction SilentlyContinue;
return Get-ConfigFileResults -allDrives -ErrorAction SilentlyContinue;
'@;

# ----------------------------------------------------------------------------
#endregion

Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-dotnet4.0-V1R4.ckl");

$separator = '=' * 40;
$errorFile = (Join-Path $outputDirectory `
    "_errors-$((Get-Date).ToString('yyyy-MM-dd-HH.mm.ss'))-$($env:username).txt"
);

try {
    if ($hosts -and $hosts.Length -gt 0) {
        $mainJob = Invoke-Command -ComputerName $hosts -ErrorAction Stop `
            -ThrottleLimit 5 `
            -AsJob -ScriptBlock $dynamicScript;
    }

    $jobs = $mainJob.ChildJobs;

    while ($mainJob.PSEndTime -eq $null) {
        while ($remaining = $jobs | where { $_.HasMoreData; }) {
            $finished = $jobs | where { $_.PSEndTime -ne $null; };
            foreach ($f in $finished) {            
                if ($f.HasMoreData) { 
                    $result = $f | Receive-Job;
                    $cklOutPath = Join-Path $outputDirectory "$((New-Guid).ToString()).ckl"; 
                    # $cklOutPath = Join-Path $outputDirectory "$($_.Location).ckl"; 
                    # Export-Ckl -cklInPath $TEMPLATE -cklOutPath $cklOutPath -data $result;
                    
                    Write-Host "$(Get-CompletedJobText $f)" ; 
                }

                if ($result.errors.Length -gt 0) {
                    $jobErrors = @"
$($f.Location) Errors:
========================================
$($result.errors)
"@;
                    Write-Host $jobErrors;
                    $jobErrors >> $errorFile;
                }
            }

            Write-JobProgress $mainJob $remaining.Count;

            Start-Sleep -Milliseconds 760;
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