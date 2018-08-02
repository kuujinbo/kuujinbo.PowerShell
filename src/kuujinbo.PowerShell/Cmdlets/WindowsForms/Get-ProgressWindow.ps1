<#
.SYNOPSIS
    Get a WPF window used to give user progress/status for long-running scripts.
    for long-running scripts. A .NET synchronized hashtable and .NET background
    runspace are required to send messages from multiple (different) sources to
    the single GUI component.
.SEE ALSO
    Update-ProgressWindow function directly below.    
#>
function Get-ProgressWindow {
    [CmdletBinding()]
    param()
    $syncHash = [hashtable]::Synchronized(@{});
    $newRunspace = [RunspaceFactory]::CreateRunspace();
    $newRunspace.ApartmentState = "STA";
    $newRunspace.ThreadOptions = "ReuseThread";         
    $newRunspace.Open();
    $newRunspace.SessionStateProxy.SetVariable("syncHash", $syncHash);
    $psCmd = [PowerShell]::Create();
    $psCmd.AddScript({   
        [xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Script Status" WindowStartupLocation="CenterScreen"
    SizeToContent="WidthAndHeight" MinWidth ="476" MinHeight="476" ShowInTaskbar="True">
    <StackPanel Margin="8">
    <TextBox x:Name="textbox" Height="440" Width="440"
        ScrollViewer.VerticalScrollBarVisibility="Auto"
    />
    <Button Name="buttonClose" Content="Close" Width="76" Margin="0,8" />
    </StackPanel>
</Window>
"@;
        $reader = (New-Object System.Xml.XmlNodeReader $xaml);
        $syncHash.Window = [Windows.Markup.XamlReader]::Load($reader);
        $syncHash.Window.TopMost = $true;
        $syncHash.Window.Add_Closing({
            Show-WpfMessageBox 'wtf' 'wtf';
            $syncHash = $null;            
            $global:syncHash = $null;            
            $newRunspace.Dispose();
            $psCmd.Dispose();
        });

        $syncHash.Window.Add_Closed({
            Show-WpfMessageBox 'wtf' 'wtf';
            $syncHash = $null;            
            $global:syncHash = $null;            
            $newRunspace.Dispose();
            $psCmd.Dispose();
        });

        $syncHash.TextBox = $syncHash.window.FindName("textbox");
        $syncHash.Button = $syncHash.window.FindName("buttonClose");
        $syncHash.Button.add_Click({ $syncHash.Window.Close(); });
        $syncHash.Window.ShowDialog() | Out-Null;
        $syncHash.Error = $Error;
    });
    $psCmd.Runspace = $newRunspace
    $psCmd.BeginInvoke() | Out-Null;

    $syncHash;
}


<#
.SYNOPSIS
    Updates long-running script progress window.
.SEE ALSO
    Get-ProgressWindow function directly above.
#>
function Update-Progress {
    [CmdletBinding()]
    param (
        [string]$title
        ,[parameter(Mandatory=$true)]$text
        ,[bool]$append = $true
    )

    Write-Verbose $text;   
    # sanity check the update/progress window is alive:
    $hasProgressWindow = Test-Path variable:global:syncHash; 

    # write to console if GUI progress window not setup
    if (-not $hasProgressWindow -or $syncHash -eq $null) {
        Write-Host $text;
        return;
    }

    $syncHash.Textbox.Dispatcher.Invoke([Action]{
        if (-not [string]::IsNullOrEmpty($title)) {
            $syncHash.Window.Title = $title;
        }
        if ($append) {
            $syncHash.TextBox.AppendText($text);
            $syncHash.TextBox.AppendText([Environment]::NewLine);
            $syncHash.TextBox.ScrollToLine($syncHash.TextBox.LineCount-1);
        } else {
            $syncHash.TextBox.Text = $text
        }
    }, 'Normal');
}