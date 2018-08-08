$_SCRIPT_TITLE = 'Adobe Acrobat Reader DC Classic STIG - Release 4';
Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-reader-dc-classic-V1R4.ckl");
Set-Variable JOB_NAME -option ReadOnly -value ([string] 'reader_dc_classic');

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


#region WPF setup
# ----------------------------------------------------------------------------
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="" WindowStartupLocation="CenterScreen"
    Background="{DynamicResource {x:Static SystemColors.ControlBrushKey}}"
    HorizontalContentAlignment="Center" SizeToContent="WidthAndHeight"
    ResizeMode="NoResize"
>
    <DockPanel>
        <Grid DockPanel.Dock="Top" Margin='8,0' >
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" />
                <ColumnDefinition Width="Auto" />
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height="*" />
                <RowDefinition Height="*" />
                <RowDefinition Height="*" />
                <RowDefinition Height="*" />
                <RowDefinition Height="*" MinHeight="276"/>
            </Grid.RowDefinitions>
            <TextBlock Text="Output Directory"
                Grid.Row="1" Grid.ColumnSpan="2" Margin="0,8,0,2" 
            />
            <TextBox Name="outputDirectory" 
                Grid.Row="2" Grid.Column="0" MinWidth="476" 
            />
            <Button Name="buttonBrowseDirectory" 
                Grid.Row="2" Grid.Column="1" Content="Browse...." Height="23" Width="76"
                VerticalAlignment="Top" HorizontalAlignment="Left" Margin="8,0,0,0"
            />
            <TextBlock Text="Host Name(s)"
                Grid.Row="3" Grid.ColumnSpan="2" Margin="0,8,0,2"
            />
            <TextBox Name="hostnames" 
                Grid.Row="4" Grid.ColumnSpan="2"
                TextWrapping="Wrap" AcceptsReturn="True"
                HorizontalScrollBarVisibility="Disabled" VerticalScrollBarVisibility="Auto"
            />
        </Grid>
        <StackPanel Orientation="Horizontal" DockPanel.Dock="Bottom" Margin="8" VerticalAlignment="Top">
            <Button Name="buttonRun" 
                Content="Run" Height="25" MinWidth="76"
            />
        </StackPanel>
    </DockPanel>
</Window>
"@;

$reader = (New-Object System.Xml.XmlNodeReader $xaml);
$form = [Windows.Markup.XamlReader]::Load($reader);
Set-XamlPsVars -xaml $xaml -uiElement $form;

$buttonBrowseDirectory.add_Click({
    $dir = Select-Directory;
    if ($dir -and (Test-Path $dir -PathType Container)) {
        $outputDirectory.Text = $dir;
    }
});
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

    try {
        # ignore script user when attempting to load user hive(s); no
        # guarantee GPO(s) applied during remote session
        $name, $sid = (whoami /user)[-1] -split '\s+';

        $rootJob = Invoke-Command -ComputerName $remoteHosts -ErrorAction Stop `
            -ThrottleLimit $throttleLimit -AsJob -ScriptBlock $dynamicScript;
        $childJobs = $rootJob.ChildJobs;

        while ($job = $childJobs | where { $_.HasMoreData; }) {
            foreach ($complete in $job | where { $_.State -eq 'Completed'; }) {
                $result = Receive-Job -Job $complete;

                $result;

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
# let user know missing required parameters      
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