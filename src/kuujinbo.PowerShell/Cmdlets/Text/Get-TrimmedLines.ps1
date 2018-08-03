<#
.SYNOPSIS
    Get an array of line entries from a string:
        -- Ignore all whitespace lines.
        -- Trim() each line entry.
.OUTPUTS
   [string[]] - If $text is null or whitespace, returns empty array
#>
function Get-TrimmedLines {
    [CmdletBinding()]
    param(
        [string]$text = ''
    )

    $lines = $text.Split(
        [string[]] (, "`r`n", "`n", "`r"), 
        [StringSplitOptions]::RemoveEmptyEntries
    ) `
        | where { ![string]::IsNullOrWhiteSpace($_) }  `
        | . {
            process { $_.Trim(); }
        };

    if ($lines -ne $null) { return $lines; }
    else { return New-Object string[] 0; }
}