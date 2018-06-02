<#
.SYNOPSIS
    Get mscorlib.dll product versions
#>
function Get-MSCorLibVersions {
    [CmdletBinding()]
    param()

    $dlls = @();
    foreach ($dir in @('C:\Windows\Microsoft.NET\Framework',
                       'C:\Windows\Microsoft.NET\Framework64')) {
        if (Test-Path $dir) {
            $dlls += Get-ChildItem -Filter mscorlib.dll -Path $dir -File -Recurse;
        }
    }

    $result = @{};
    foreach ($d in $dlls) {
        $result.Add(
            "$($d.FullName)",
            [System.Diagnostics.FileVersionInfo]::GetVersionInfo($d.fullname).ProductVersion
        );        
    }

    return $result;
}