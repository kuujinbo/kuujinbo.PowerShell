<#
.SYNOPSIS
    Get a System.Xml.XmlDocument from a file.
.PARAMETER $xmlPath
    Full path to XML config file.
.EXAMPLE
    [xml]$xaml = Get-XmlConfig 'c:/test.xml';
#>
function Get-XmlConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$xmlPath
    )

    return [xml]([System.IO.File]::ReadAllText($xmlPath));
}