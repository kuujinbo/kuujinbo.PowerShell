<#
function Get-CimRegistryValue($path, $valueName) {
    # ReturnValue -eq 0 # success => sSubKeyName and sValueName **BOTH** exist
    # ReturnValue -eq 1 # fail => sSubKeyName exists, but sValueName does **NOT** exist
    # ReturnValue -eq 2 # fail => sSubKeyName does not exist
}
#>

# dot source all .ps1 files
Get-ChildItem -Path "$PSScriptRoot/../cmdlets/" -filter *.ps1 | foreach { . $_.FullName; }
Get-ChildItem -Recurse -Path "$PSScriptRoot/cmdlets/" -filter *.ps1 | foreach { . $_.FullName; }

Export-ModuleMember -Variable *;
Export-ModuleMember -Cmdlet *;
Export-ModuleMember -Function *;