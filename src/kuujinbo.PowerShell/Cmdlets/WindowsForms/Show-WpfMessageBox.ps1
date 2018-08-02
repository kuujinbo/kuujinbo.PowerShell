<#
.SYNOPSIS
    Show user simple status message using a WPF MessageBox control.
.NOTES
###########################################################################
MessageBoxButton enum:

http://msdn.microsoft.com/en-us/library/system.windows.messageboxbutton.aspx            
OK
OKCancel
YesNo
YesNoCancel 

MessageBoxImage enum
http://msdn.microsoft.com/en-us/library/system.windows.messageboximage.aspx
Asterisk       The message box contains a symbol consisting of a lowercase letter i in a circle.
Error          The message box contains a symbol consisting of white X in a circle with a red background.
Exclamation    The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.
Hand           The message box contains a symbol consisting of a white X in a circle with a red background.
Information    The message box contains a symbol consisting of a lowercase letter i in a circle.
None	       No icon is displayed.
Question	   The message box contains a symbol consisting of a question mark in a circle.
Stop	       The message box contains a symbol consisting of white X in a circle with a red background.
Warning	       The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.
###########################################################################
#>
function Show-WpfMessageBox { 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$text
        ,[Parameter(Mandatory=$true)][string]$caption
        ,[System.Windows.MessageBoxButton]$button = [System.Windows.MessageBoxButton]::OK
        ,[System.Windows.MessageBoxImage]$icon = [System.Windows.MessageBoxImage]::Information
        
    )
    [Windows.MessageBox]::Show($text, $caption, $button, $icon);
}