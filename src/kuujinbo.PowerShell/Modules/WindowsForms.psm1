Add-Type -AssemblyName System.Windows.Forms
Add-Type –AssemblyName PresentationFramework;
Add-Type –AssemblyName PresentationCore;
Add-Type –AssemblyName WindowsBase;

# dot source all functions from the following directories
Get-ChildItem -Path "$PSScriptRoot/../Cmdlets/WindowsForms/*.ps1" | foreach { . $_.FullName; }