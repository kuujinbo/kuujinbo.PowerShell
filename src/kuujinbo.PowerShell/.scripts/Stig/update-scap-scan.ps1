#region load modules
$stigModPath = Join-Path $PSScriptRoot '../../Modules/StigBase.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;
$formsModPath = Join-Path $PSScriptRoot '../../Modules/WindowsForms.psm1';
Import-Module $formsModPath -DisableNameChecking -Force;
#endregion

#region WPF setup
$xmlConfigPath = (Join-Path "$PSScriptRoot" 'config/update-scap-scan.xml')
$form = Get-WpfForm (Get-XmlConfig $xmlConfigPath);
Add-DirectorySelectorHandler $buttonBrowseDirectory;  
$detailsText.Text = "$SCAP_DETAILS";
$commentText.Text = "$SCAP_COMMENTS";
#endregion

$buttonRun.add_Click({
# only run script if passes sanity check
    $dir = $cklDirectory.Text.Trim();
    $details = $detailsText.Text.Trim();
    $comments = $commentText.Text.Trim();
    $validDir = $dir -and (Test-Path $dir -PathType Container);
    $validDetails = ![string]::IsNullOrWhiteSpace($details); 
    $validComments = ![string]::IsNullOrWhiteSpace($comments); 
    if ($validDir -and $validDetails -and $validDetails) { 
        $form.Close();
        Update-ScapScan -cklDirectory $dir -findingDetails $details -findingComments $comments;
    }
# let user know missing required parameters      
    else {
        $err = "Cannot run script - missing required field(s):`n`n";
        if (!$validDir) { $err += "-- .ckl directory`n"; }
        if (!$validDetails) { $err += "-- Details`n"; }
        if (!$validComments) { $err += "-- Comments`n"; }
        Show-WpfMessageBox -caption 'Missing Fields' `
            -text $err `
            -icon ([System.Windows.MessageBoxImage]::Hand);        
    }
});

$form.Title = 'SCAP scan .ckl Update';
$form.ShowDialog() | Out-Null;