<#
.SYNOPSIS
    Get an array of line entries from a string:
        -- Ignore all whitespace lines.
        -- Trim() each line entry.
#>
function Get-TrimmedLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$text
    )

    return $text.Split(
        [string[]] (, "`r`n", "`n", "`r"), 
        [StringSplitOptions]::RemoveEmptyEntries
    ) `
        | where { ![string]::IsNullOrWhiteSpace($_) }  `
        | . {
            process { $_.Trim(); }
        };
}