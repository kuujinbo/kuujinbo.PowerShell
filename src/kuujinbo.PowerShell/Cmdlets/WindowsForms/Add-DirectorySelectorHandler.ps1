<#
.SYNOPSIS
    Add an event handler a button that calls a directory selector control.
.PARAMETER $button
    A WPF button control, which **MUST** set it's `Tag` property to the 
    associated WPF textbox control name.
.EXAMPLE
    -- xaml:
        <TextBox Name="inputDirectory" />
        <Button Name="buttonInputDirectory" 
                Content="Browse...."
                Tag="inputDirectory"
        />    

    -- powershell
    Add-DirectorySelectorHandler $buttoninputDirectory; 

.NOTES
    -- PowerShell has major WPF inconsistencies and scoping issues; the 
       `Invoke-Expression` call is one way to deal with these issues. 
    -- Also see 
        ./Set-XamlPsVars.ps1
#>
function Add-DirectorySelectorHandler {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Windows.Controls.Button]$button
    )

    $button.add_Click({ 
        $dir = Select-Directory;
        if ($dir -and (Test-Path $dir -PathType Container)) {
            Invoke-Expression "`$global:$($this.Tag).Text = '$dir'"
        }
    });
}