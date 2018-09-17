#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot '../../Modules/WindowsForms.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;

# in-memory modules for `Invoke-Command`
# ----------------------------------------------------------------------------
#endregion

# TODO: add remote script statements 
$stigMap = @{
    'Adobe Acrobat Reader DC Classic Track :: Release: 4 :: 2018-07-27' = @'
'@;
    'Microsoft Access 2010 :: Release: 9 :: 2016-10-28' = @'
'@;
    'Microsoft Excel 2010 :: Release: 10 :: 2016-10-28' = @'
'@;
    'Microsoft Office System 2010 :: Release: 11 :: 2017-07-28' = @'
'@;
    'Microsoft OneNote 2010 :: Release: 8 :: 2015-01-23' = @'
'@;
    'Microsoft Outlook 2010 :: Release: 12 :: 2016-10-28' = @'
'@;
    'Microsoft PowerPoint 2010 :: Release: 9 :: 2016-10-28' = @'
'@;
    'Microsoft Publisher 2010 :: Release: 10 :: 2016-10-28' = @'
'@;
    'Microsoft Word 2010 :: Release: 10 :: 2016-10-28' = @'
'@;
    'Microsoft DotNet Framework 4.0 STIG :: Release: 5 :: 2018-07-27' = @'
'@;
    'Microsoft Internet Explorer 11 :: Release: 16 :: 2018-07-27' = @'
'@;
    'Microsoft InfoPath 2013 STIG :: Release: 5 :: 2018-04-27' = @'
'@;
    'Java Runtime Environment (JRE) version 8 :: Release: 5 :: 2018-01-26' = @'
'@;
    'Windows 10 :: Release: 14 :: 2018-07-27' = @'
'@;
};

#region WPF
# ----------------------------------------------------------------------------
$xmlConfigPath = (Join-Path "$PSScriptRoot" 'config/all-combined.xml')
$form = Get-WpfForm (Get-XmlConfig $xmlConfigPath);

Add-CheckBoxes $stigListBox ($stigMap.Keys | sort) -checkAll;
Add-DirectorySelectorHandler $buttonInputDirectory; 
Add-DirectorySelectorHandler $buttonOutputDirectory; 

$buttonRun.add_Click({
    $inDir = $inputDirectory.Text.Trim();
    $outDir = $outputDirectory.Text.Trim();
    $validInDir = $inDir -and (Test-Path $inDir -PathType Container);
    $validOutDir = $outDir -and (Test-Path $outDir -PathType Container);

    #if ($validInDir -and $validOutDir) { 
        foreach ($cb in $stigListBox.Items) {
            Write-Host "$($cb.Content) :: $($cb.IsChecked)";
        }
        $form.Close();
<#
    }
    else {
        $err = "Cannot run script - missing required field(s):`n`n";
        if (!$validInDir) { $err += "-- Input directory`n"; }
        if (!$validOutDir) { $err += "-- Output directory`n"; }
        Show-WpfMessageBox -caption 'Missing Fields' `
            -text $err `
            -icon ([System.Windows.MessageBoxImage]::Hand);        
    }
#>

});

<#

#>
# ----------------------------------------------------------------------------
#endregion

$null = $form.ShowDialog();