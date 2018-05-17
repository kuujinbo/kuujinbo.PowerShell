# dot source all functions
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Remote/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/.NET/*.ps1" | foreach { . $_.FullName; }