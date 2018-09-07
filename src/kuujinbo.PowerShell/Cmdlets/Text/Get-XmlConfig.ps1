<#
.SYNOPSIS
    Get a System.Xml.XmlDocument from a file.
.PARAMETER $callingScriptPath
    Full path to calling script; XML file base name without extension **MUST**
    be exactly the same.
.EXAMPLE
    [xml]$xaml = Get-XmlConfig $PSCommandPath;
#>
function Get-XmlConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$callingScriptPath
    )

    $basename = [System.IO.Path]::GetFileNameWithoutExtension($callingScriptPath) + '.xml';
    $xmlPath = Join-Path ([System.IO.Path]::GetDirectoryName($callingScriptPath)) $basename;

    return [xml]([System.IO.File]::ReadAllText($xmlPath));
}