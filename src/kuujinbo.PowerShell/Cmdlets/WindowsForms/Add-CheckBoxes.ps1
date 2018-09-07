<#
.SYNOPSIS
    Add a group of CheckBox controls to a ListBox control.
.PARAMETER $textContent
    Collection of text labels used to set each CheckBox `Content` property.
#>
function Add-CheckBoxes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Windows.Controls.ListBox]$listBox
        ,[Parameter(Mandatory=$true)][string[]]$textContent
        ,[switch] $checkAll
    )

    for ($i = 0; $i -lt $textContent.Length; ++$i) {
        $li = New-Object System.Windows.Controls.CheckBox;
        $li.Content = $textContent[$i];
        if ($checkAll.IsPresent) { $li.IsChecked = $true; }
        $null = $listBox.Items.Add($li);
    }
}