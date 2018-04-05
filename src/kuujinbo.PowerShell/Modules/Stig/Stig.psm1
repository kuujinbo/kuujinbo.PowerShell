# dot source all .ps1 files
Get-ChildItem -Path "$PSScriptRoot/../cmdlets/" -filter *.ps1 | foreach { . $_.FullName; }
Get-ChildItem -Recurse -Path "$PSScriptRoot/cmdlets/" -filter *.ps1 | foreach { . $_.FullName; }

Export-ModuleMember -Variable *;
Export-ModuleMember -Cmdlet *;
Export-ModuleMember -Function *;