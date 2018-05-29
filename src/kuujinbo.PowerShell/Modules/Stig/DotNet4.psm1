# dot source all functions
. (Join-Path "$PSScriptRoot/../../Cmdlets/IO" Get-PhysicalDrives.ps1)
. (Join-Path "$PSScriptRoot/../../Cmdlets/Net" Get-HostInfo.ps1)

Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Remote/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/.NET/*.ps1" | foreach { . $_.FullName; }