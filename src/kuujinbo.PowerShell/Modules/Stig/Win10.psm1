# dot source all STIG functions
Get-ChildItem -Path "$PSScriptRoot/cmdlets/*.ps1" | foreach { . $_.FullName; }

# dot source all Win10-specific STIG functions
Get-ChildItem -Path "$PSScriptRoot/cmdlets/Win10/*.ps1" | foreach { . $_.FullName; }