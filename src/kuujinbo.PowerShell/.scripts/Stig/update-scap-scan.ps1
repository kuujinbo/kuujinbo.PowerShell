#region load modules
# ----------------------------------------------------------------------------
$stigModPath = Join-Path $PSScriptRoot '../../Modules/StigBase.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;
$formsModPath = Join-Path $PSScriptRoot '../../Modules/WindowsForms.psm1';
Import-Module $formsModPath -DisableNameChecking -Force;
# ----------------------------------------------------------------------------

$MIN_HEIGHT = 23;
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
                <RowDefinition Height="*"  MinHeight="$MIN_HEIGHT" />
                <RowDefinition Height="*"  MinHeight="$MIN_HEIGHT" />
                <RowDefinition Height="*"  MinHeight="$MIN_HEIGHT" />
                <RowDefinition Height="*"  MinHeight="$MIN_HEIGHT" />
                <RowDefinition Height="*"  MinHeight="$MIN_HEIGHT" />
                <RowDefinition Height="*"  MinHeight="$MIN_HEIGHT" />
            </Grid.RowDefinitions>
            <TextBlock Text=".ckl Directory"
                Grid.Row="1" Grid.ColumnSpan="2" Margin="0,8,0,2" 
            />
            <TextBox Name="cklDirectory" 
                Grid.Row="2" Grid.Column="0" MinWidth="476" 
            />
            <Button Name="buttonBrowseDirectory" 
                Grid.Row="2" Grid.Column="1" Content="Browse...." Width="76" Height="$MIN_HEIGHT"
                VerticalAlignment="Top" HorizontalAlignment="Left" Margin="8,0,0,0"
            />
            <TextBlock Text="Details"
                Grid.Row="3" Grid.ColumnSpan="2" Margin="0,8,0,2"
            />
            <TextBox Name="detailsText" 
                Grid.Row="4" Grid.ColumnSpan="2" Text="$SCAP_DETAILS"
            />
            <TextBlock Text="Comments"
                Grid.Row="5" Grid.ColumnSpan="2" Margin="0,8,0,2"
            />
            <TextBox Name="commentText" 
                Grid.Row="6" Grid.ColumnSpan="2" Text="$SCAP_COMMENTS"
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
        $cklDirectory.Text = $dir;
    }
});

$buttonRun.add_Click({
# only run script if passes sanity check
    $dir = $cklDirectory.Text.Trim();
    $details = $detailsText.Text.Trim();
    $comments = $commentText.Text.Trim();
    $validDir = $dir -and (Test-Path $dir -PathType Container);
    $validDetails = ![string]::IsNullOrEmpty($details); 
    $validComments = ![string]::IsNullOrEmpty($comments); 
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