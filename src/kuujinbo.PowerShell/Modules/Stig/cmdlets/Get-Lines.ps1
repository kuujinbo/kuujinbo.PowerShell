function Get-Lines {
    param(
        [Parameter(Mandatory)] [string]$text
    )

    return $text.Split(
        [string[]] (, "`r`n", "`n", "`r"), 
        [StringSplitOptions]::RemoveEmptyEntries
    );
}