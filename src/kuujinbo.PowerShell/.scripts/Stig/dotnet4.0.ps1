param(
    # contains .ckl files with previous scan results
    [Parameter(ParameterSetName='cklDirectory')][string]$cklDirectory

    # .txt file: one/more hostname per line. NO previous scan results.
    ,[Parameter(ParameterSetName='txtHostsFile')][string]$txtHostsFile

    # command line: CSV hostname(s). NO previous scan results.
    ,[Parameter(ParameterSetName='hostnames')]
    [ValidateNotNullOrEmpty()]
    [string[]]$hostnames

    ,[Parameter(ParameterSetName='txtHostsFile', Mandatory=$true)]
    [Parameter(ParameterSetName='hostnames', Mandatory=$true)]
    [Parameter(ParameterSetName='cklDirectory')]
    [string]$outputDirectory

    ,[Parameter(ParameterSetName='txtHostsFile')]
    [Parameter(ParameterSetName='hostnames')]
    [Parameter(ParameterSetName='cklDirectory')]
    [int]$throttleLimit = 5

    # blank template .ckl ONLY used for these parameter sets
    ,[Parameter(ParameterSetName='txtHostsFile')]
    [Parameter(ParameterSetName='hostnames')]
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
return Get-ConfigFileResults -allDrives -getHostInfo -ErrorAction SilentlyContinue;
'@;

# ----------------------------------------------------------------------------
#endregion

Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-dotnet4.0-V1R4.ckl");
Set-Variable JOB_NAME -option ReadOnly -value ([string] '.NET 4.0-V1R4');
$errorFile = (Join-Path $outputDirectory `
    "_errors-$((Get-Date).ToString('yyyy-MM-dd-HH.mm.ss'))-$($env:username).txt"
);
$hostnames = if ($hostnames) { $hostnames; }
             else { Get-Content $txtHostsFile | where { $_ -match '\S' }; }

try {
    $rootJob = Invoke-Command -ComputerName $hostnames -ErrorAction Stop `
        -ThrottleLimit $throttleLimit -AsJob -ScriptBlock $dynamicScript;
    $childJobs = $rootJob.ChildJobs;

    while ($job = $childJobs | where { $_.HasMoreData; }) {
        foreach ($complete in $job | where { $_.State -eq 'Completed'; }) {
            $result = Receive-Job -Job $complete;
            # $cklOutPath = Join-Path $outputDirectory "$((New-Guid).ToString()).ckl"; 
            $cklOutPath = Join-Path $outputDirectory "$($complete.Location).ckl"; 
            Export-Ckl -cklInPath $TEMPLATE -cklOutPath $cklOutPath -data $result;
            Write-Host "$(Get-JobCompletedText $complete $JOB_NAME)";

            if ($result.errors.Length -gt 0) {
                $hostError = $complete.Location;
                $jobErrors = @"
========================================
$hostError errors:
$($result.errors)
========================================
"@;

                Write-Host "Error(s) on [$hostError]. See [$errorFile] when script is finished." `
                           -ForegroundColor Red -BackgroundColor Black;
                $jobErrors >> $errorFile;
            }

        }
        Write-JobProgress $rootJob $JOB_NAME;

        Start-Sleep -Milliseconds 760;
    } 
    Write-Host (Get-JobCompletedText $rootJob $JOB_NAME -rootJob);   
} catch {
    $e = '';
    $e = "[$hostname] => $($_.Exception.Message)";
    $e | Out-File -Append $errorFile;
    $e | Write-Host -ForegroundColor Red -BackgroundColor Black;
} finally {
    foreach ($fail in $childJobs | where { $_.State -ne 'Completed'; } ) {
        "$($fail.Location) => $($fail.State) => $($fail.JobStateInfo.Reason.Message)" `
            | Write-Host -ForegroundColor Red -BackgroundColor Black;
    }
    Get-PSSession | Remove-PSSession;
    Get-Job | Remove-Job -Force;
    $error.Clear();
}