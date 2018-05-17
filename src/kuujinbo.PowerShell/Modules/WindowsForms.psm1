# dot source all functions from the following directories
Get-ChildItem -Path "$PSScriptRoot/../Cmdlets/WindowsForms/*.ps1" | foreach { . $_.FullName; }