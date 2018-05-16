<#
.SYNOPSIS
    Get registry rules where **ONLY** equality test is done.
#>
function Get-OneNote2010Registry {
    [CmdletBinding()]
    param()

    @{
        'SV-33934r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\onenote\security', 'EnableDEP', '1')
    };
}