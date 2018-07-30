# dot source all .ps1 files
Get-ChildItem -Path "$PSScriptRoot/../../Cmdlets/Text/*.ps1" | foreach { . $_.FullName; }
Get-ChildItem -Recurse -Path "$PSScriptRoot/../../Cmdlets/Stig/" -filter *.ps1 | foreach { . $_.FullName; }

Export-ModuleMember -Variable *;
Export-ModuleMember -Cmdlet *;
Export-ModuleMember -Function *;