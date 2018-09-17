$_SCRIPT_TITLE = 'Adobe Acrobat Reader DC Classic STIG - Version 1 Release 4';
Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-reader-dc-classic-V1R4.ckl");
Set-Variable JOB_NAME -option ReadOnly -value ([string] 'Reader DC Classic V1R4');

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
$result += Get-RegistryResults (Get-ReaderDcClassicHKLM -version 2017);
$result += Get-RegistryResults -getHku -rules (Get-ReaderDcClassicHKU -version 2017);
$result.'hostinfo' = Get-HostInfo;
Dismount-HKU;

return $result;
'@;
# ----------------------------------------------------------------------------
#endregion

#region WPF setup
# ----------------------------------------------------------------------------
$xmlConfigPath = (Join-Path "$PSScriptRoot" 'config/reader-dc-classic.xml')
$form = Get-WpfForm (Get-XmlConfig $xmlConfigPath);
Add-DirectorySelectorHandler $buttonBrowseDirectory;  
# ----------------------------------------------------------------------------
#endregion

#region main
# ----------------------------------------------------------------------------
function Start-Script {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$outputDirectory
        ,[Parameter(Mandatory)] [string[]]$remoteHosts
    );

    $openLog = New-Object System.Text.StringBuilder;
    try {
        $rootJob = Invoke-Command -ComputerName $remoteHosts -ErrorAction Stop `
            -ThrottleLimit 5 -AsJob -ScriptBlock $dynamicScript;
        $childJobs = $rootJob.ChildJobs;

        while ($job = $childJobs | where { $_.HasMoreData; }) {
            foreach ($complete in $job | where { $_.State -eq 'Completed'; }) {
                $result = Receive-Job -Job $complete;

                # one-off hard-coded: local IAVM policy should ALWAYS be implemented
                $result.'V-65811' = @('NotAFinding', 
                    'Not a finding: local procedure implements the 21 day Information Assurance Vulnerability Management (IAVM) process.'
                );

                $null = $openLog.Append((Get-OpenRules $complete.Location  $result));
                $cklOutPath = Join-Path $outputDirectory "$($complete.Location).ckl"; 
                Export-Ckl -cklInPath $TEMPLATE -cklOutPath $cklOutPath -data $result;

                Write-Host "$(Get-JobCompletedText $complete $JOB_NAME)";
            }
            Write-JobProgress $rootJob $JOB_NAME;

            Start-Sleep -Milliseconds 760;
        } 
        Write-Host (Get-JobCompletedText $rootJob $JOB_NAME -rootJob);   

        $logFilename = 'adobe-DC-V1R4-open-{0:yyyMMdd.HHmmss}.csv' -f (Get-Date);
        $openLog.ToString() | Set-Content -Path (Join-Path $outputDirectory $logFilename)
        #                     ^^^^^^^^^^^ Exhell is too stupid to read Unicode

    } catch {
        $e = '';
        $e = "[$hostname] => $($_.Exception.Message)";
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
}

$buttonRun.add_Click({
    $dir = $outputDirectory.Text.Trim();
    $hosts = Get-TrimmedLines $hostnames.Text;

    $validDir = $dir -and (Test-Path $dir -PathType Container);
    $validHosts = $hosts.Length -gt 0;
    if ($validDir -and $validHosts) { 
        $_OUTPUT_DIRECTORY = $dir;
        $_HOSTNAMES = $hosts;
        $form.Close();

        Start-Script $dir $hosts; 
    }
    # user missing required parameters      
    else {
        $err = "Cannot run script - missing required field(s):`n`n";
        if (!$validDir) { $err += "-- Output directory`n"; }
        if (!$validHosts) { $err += "-- Host name(s)`n"; }
        Show-WpfMessageBox -caption 'Missing Fields' `
            -text $err `
            -icon ([System.Windows.MessageBoxImage]::Hand);        
    }
});
$form.Title = $_SCRIPT_TITLE;
$form.ShowDialog() | Out-Null;
# ----------------------------------------------------------------------------
#endregion