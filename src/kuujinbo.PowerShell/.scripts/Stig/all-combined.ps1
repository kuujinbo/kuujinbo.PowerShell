#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot '../../Modules/WindowsForms.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;

# in-memory modules for `Invoke-Command`
# ----------------------------------------------------------------------------
#endregion


[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Combined DISA STIG scanner" WindowStartupLocation="CenterScreen"
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
                <RowDefinition Height="*" />
                <RowDefinition Height="*" />
                <RowDefinition Height="*" MinHeight="276"/>
            </Grid.RowDefinitions>
            <TextBlock Text="Input Directory"
                Grid.Row="1" Grid.ColumnSpan="2" Margin="0,8,0,2" 
            />
            <TextBox Name="inputDirectory" 
                Grid.Row="2" Grid.Column="0" MinWidth="476" 
            />
            <Button Name="buttonInputDirectory" 
                Grid.Row="2" Grid.Column="1" Content="Browse...." Height="23" Width="76"
                VerticalAlignment="Top" HorizontalAlignment="Left" Margin="8,0,0,0"
            />
            <TextBlock Text="Output Directory"
                Grid.Row="3" Grid.ColumnSpan="2" Margin="0,8,0,2" 
            />
            <TextBox Name="outputDirectory" 
                Grid.Row="4" Grid.Column="0" MinWidth="476" 
            />
            <Button Name="buttonOutputDirectory" 
                Grid.Row="4" Grid.Column="1" Content="Browse...." Height="23" Width="76"
                VerticalAlignment="Top" HorizontalAlignment="Left" Margin="8,0,0,0"
            />
            <TextBlock Text="STIGs"
                Grid.Row="5" Grid.ColumnSpan="2" Margin="0,8,0,2"
            />
            <ListBox Name="stigTitles"
                Grid.Row="6" Grid.ColumnSpan="2"
                SelectionMode="Multiple">
            </ListBox>
        </Grid>
        <StackPanel Orientation="Horizontal" DockPanel.Dock="Bottom" Margin="8" VerticalAlignment="Top">
            <Button Name="buttonRun" 
                Content="Run" Height="25" MinWidth="76"
            />
        </StackPanel>
    </DockPanel>
</Window>
"@;

# TODO: add dynamic remote script statements 
$stigMap = @{
    'Adobe Acrobat Reader DC Classic Track :: Release: 4 :: 2018-07-27' = '';
    'Microsoft Access 2010 :: Release: 9 :: 2016-10-28' = '';
    'Microsoft Excel 2010 :: Release: 10 :: 2016-10-28' = '';
    'Microsoft Office System 2010 :: Release: 11 :: 2017-07-28' = '';
    'Microsoft OneNote 2010 :: Release: 8 :: 2015-01-23' = '';
    'Microsoft Outlook 2010 :: Release: 12 :: 2016-10-28' = '';
    'Microsoft PowerPoint 2010 :: Release: 9 :: 2016-10-28' = '';
    'Microsoft Publisher 2010 :: Release: 10 :: 2016-10-28' = '';
    'Microsoft Word 2010 :: Release: 10 :: 2016-10-28' = '';
    'Microsoft DotNet Framework 4.0 STIG :: Release: 5 :: 2018-07-27' = '';
    'Microsoft Internet Explorer 11 :: Release: 16 :: 2018-07-27' = '';
    'Microsoft InfoPath 2013 STIG :: Release: 5 :: 2018-04-27' = '';
    'Java Runtime Environment (JRE) version 8 :: Release: 5 :: 2018-01-26' = '';
    'Windows 10 :: Release: 14 :: 2018-07-27' = '';
};
#region WPF setup
# ----------------------------------------------------------------------------
$form = Get-WpfForm $xaml;
foreach ($s in ($stigMap.Keys | sort)) {
    $null = $stigTitles.Items.Add($s);
}

function Set-TexboxDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$textbox
    )
    $dir = Select-Directory;
    if ($dir -and (Test-Path $dir -PathType Container)) {
        $textbox.Text = $dir;
    }
}
$buttoninputDirectory.add_Click({ Set-TexboxDirectory $inputDirectory; });
$buttonOutputDirectory.add_Click({ Set-TexboxDirectory $outputDirectory; });
# ----------------------------------------------------------------------------
#endregion


$lb.add_SelectionChanged({
    foreach ($li in $lb.SelectedItems) {
        Write-Host $li;
    }
});

$null = $form.ShowDialog();