<#
.SYNOPSIS
    Add a group of CheckBox controls to a ListBox control.
.PARAMETER $textContent
    Collection of text used to set each CheckBox `Content` property.
.PARAMETER $selectAll
    Check all checkboxes     
#>
function Get-WpfForm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][xml]$xaml
    )

    $reader = (New-Object System.Xml.XmlNodeReader $xaml);
    $form = [Windows.Markup.XamlReader]::Load($reader);
    Set-XamlPsVars -xaml $xaml -uiElement $form;

    return $form;
}