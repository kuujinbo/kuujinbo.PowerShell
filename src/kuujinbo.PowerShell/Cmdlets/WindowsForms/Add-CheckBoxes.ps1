function Add-CheckBoxes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Windows.Controls.ListBox]$listBox
        ,[Parameter(Mandatory=$true)][string[]]$items
        ,[switch] $selectAll
    )

    for ($i = 0; $i -lt $items.Length; ++$i) {
        $li = New-Object System.Windows.Controls.CheckBox;
        $li.Content = $items[$i];
        if ($selectAll.IsPresent) { $li.IsChecked = $true; }
        $null = $listBox.Items.Add($li);
    }
}