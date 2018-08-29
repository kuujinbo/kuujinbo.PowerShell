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