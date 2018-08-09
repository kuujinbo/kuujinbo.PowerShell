<#
.SYNOPSIS
    Convert a SID to username.
.NOTES
    User must be logged in.
#>
function Convert-LoggedInSidToUsername {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$sid
    )

    $path = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" 'ProfileImagePath';
    if ($path -ne $null) { 
        return ($path.Split([System.IO.Path]::DirectorySeparatorChar))[-1]; 
    } else { return $null; }
}