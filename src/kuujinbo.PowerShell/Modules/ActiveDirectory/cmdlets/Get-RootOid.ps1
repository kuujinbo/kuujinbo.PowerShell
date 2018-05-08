<#
.SYNOPSIS
    Get a root object identifier (OID) that should be used to name Active
    Directory schema attributes and classes.
.NOTES
    https://gallery.technet.microsoft.com/scriptcenter/Generate-an-Object-4c9be66a
    https://gallery.technet.microsoft.com/scriptcenter/56b78004-40d0-41cf-b95e-6e795b2e8a06/
#>

function Get-RootOid {
    [CmdletBinding()]
    param()

    $prefix = '1.2.840.113556.1.8000.2554'; 
    $guid = [System.Guid]::NewGuid().ToString();
    $parts = @();
    $substrings = @((0,4), (4,4), (9,4), (14,4), (19,4), (24,6), (30,6));
    foreach ($s in $substrings) {
        $parts += [UInt64]::Parse($guid.Substring($s[0], $s[1]), 'AllowHexSpecifier');
    }

    return "$prefix.$($parts -join '.')";
}