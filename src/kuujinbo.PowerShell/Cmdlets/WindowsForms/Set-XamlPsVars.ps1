<#
.SYNOPSIS
    Set poweshell variables received from WPF XAML from WPF XAML to allow
    setting properties and event handlers in a calling script.
#>
function Set-XamlPsVars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][xml]$xaml
        ,[Parameter(Mandatory=$true)][Windows.UIElement]$uiElement
    )
    $xaml.SelectNodes("//*[@Name]") | foreach {
        Set-Variable -Name ($_.Name) -Value $uiElement.FindName($_.Name) -Scope Global
    };
}