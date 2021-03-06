Add-Type -AssemblyName System.Windows.Forms
Add-Type ľAssemblyName PresentationFramework;
Add-Type ľAssemblyName PresentationCore;
Add-Type ľAssemblyName WindowsBase;

# dot source all functions from the following directories
Get-ChildItem -Path "$PSScriptRoot/../Cmdlets/Text/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../Cmdlets/WindowsForms/*.ps1" | foreach { . $_.FullName; }