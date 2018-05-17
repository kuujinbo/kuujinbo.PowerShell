<#
.SYNOPSIS
    Get selected files from GUI
.NOTES
    Tested on STIG Viewer 2.7. To save template file:
    [1] Checklist => Create Checklist - Check Marked STIG(s)
    [2] File => Save Checklist As...
#>
function Get-OpenFileDialogFiles {
    [CmdletBinding()]
    param(
        [string]$title = 'Select one or more File(s)'
        ,[string]$filter = 'All files (*.*)|*.*'
        ,[bool]$multiSelect = $true
    )

    Add-Type -AssemblyName System.Windows.Forms;

    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Multiselect = $multiSelect;
        Filter = $filter;
        Title = $title;
        RestoreDirectory = $true;
    }
 
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $openFileDialog.FileNames;
    } else { return @(); }
}