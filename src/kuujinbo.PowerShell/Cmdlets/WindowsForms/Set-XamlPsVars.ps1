<#
.SYNOPSIS
    Set/map WPF XAML nodes to powershell variables for each individual GUI control
    to allow setting properties and event handlers in calling script.
#>
function Set-XamlPsVars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][xml]$xaml
        ,[Parameter(Mandatory=$true)][Windows.UIElement]$uiElement
    )
    $xaml.SelectNodes("//*[@Name]") | foreach {
        Set-Variable -Name ($_.Name) -Value $uiElement.FindName($_.Name) -Scope Global;
    };
}