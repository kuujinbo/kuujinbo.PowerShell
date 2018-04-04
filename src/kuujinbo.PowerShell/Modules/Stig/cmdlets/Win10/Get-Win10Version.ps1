function Get-Win10Version {
    Get-RegistryValue 'HKLM:\software\microsoft\windows nt\currentversion' releaseid;
}