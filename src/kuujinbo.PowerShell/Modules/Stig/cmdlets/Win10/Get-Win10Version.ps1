function Get-Win10Version {
    [CmdletBinding()]
    param()

    Get-RegistryValue 'HKLM:\software\microsoft\windows nt\currentversion' releaseid;
}