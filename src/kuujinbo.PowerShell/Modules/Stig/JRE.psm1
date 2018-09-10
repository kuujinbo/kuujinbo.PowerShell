# dot source all *.ps1 files
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Stig/JRE/*.ps1" | foreach { . $_.FullName; }