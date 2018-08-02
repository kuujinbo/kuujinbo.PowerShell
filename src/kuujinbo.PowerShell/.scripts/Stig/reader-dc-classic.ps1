param(
    [string]$outputDirectory = ''
    ,[int]$throttleLimit = 5
);


#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot '../../Modules/Stig/ReaderDcClassic.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;

# in-memory modules for `Invoke-Command`
$scriptDirectories = @(
    "$PSScriptRoot/../../Cmdlets/Registry"
    ,"$PSScriptRoot/../../Cmdlets/Stig/Adobe"
);

$psFiles = @(
    "$PSScriptRoot/../../Cmdlets/Stig/ReadOnlyVariables.ps1"
    ,"$PSScriptRoot/../../Cmdlets/Net/Get-HostInfo.ps1"
);

$dynamicScript = Get-ScriptBlock -scriptDirectories $scriptDirectories -psFiles $psFiles `
    -inlineBlock @'
$result = @{};
$result += Get-RegistryResults (Get-ReaderDcClassicRegistry -version 2017);
$result.'hostinfo' = Get-HostInfo;

return $result;
'@;
# ----------------------------------------------------------------------------
#endregion


Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-reader-dc-classic-V1R4.ckl");
Set-Variable JOB_NAME -option ReadOnly -value ([string] 'reader_dc_classic');
$hostnames = @();

try {
    $rootJob = Invoke-Command -ComputerName $hostnames -ErrorAction Stop `
        -ThrottleLimit $throttleLimit -AsJob -ScriptBlock $dynamicScript;
    $childJobs = $rootJob.ChildJobs;

    while ($job = $childJobs | where { $_.HasMoreData; }) {
        foreach ($complete in $job | where { $_.State -eq 'Completed'; }) {
            $result = Receive-Job -Job $complete;

            $result;

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
                Write-Host "[$hostError]: one or scan more error(s). See [$errorFile] when script is finished." `
                           -ForegroundColor Red -BackgroundColor Black;
                # $jobErrors >> $errorFile;
            }

        }
        Write-JobProgress $rootJob $JOB_NAME;

        Start-Sleep -Milliseconds 760;
    } 
    Write-Host (Get-JobCompletedText $rootJob $JOB_NAME -rootJob);   
} catch {
    $e = '';
    $e = "[$hostname] => $($_.Exception.Message)";
    # $e | Out-File -Append $errorFile;
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