# dot source all functions
. (Join-Path "$PSScriptRoot/../../Cmdlets/Net" Get-HostInfo.ps1)

Import-Module (Join-Path $PSScriptRoot '../WindowsForms.psm1') -DisableNameChecking -Force;

Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Registry/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Remote/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/Adobe/*.ps1" | foreach { . $_.FullName; }