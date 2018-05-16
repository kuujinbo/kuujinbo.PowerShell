<# 
.SYNOPSIS
    Get path to user's desktop
.DESCRIPTION
    The Get-DesktopPath cmdlet is a simple wrapper to get path to user's desktop.
#>
function Get-DesktopPath {
    [CmdletBinding()]
    param()
    [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop);
}