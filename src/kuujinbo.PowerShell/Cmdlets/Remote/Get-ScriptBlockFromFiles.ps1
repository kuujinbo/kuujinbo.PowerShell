<#
.SYNOPSIS
    Dynamically get a ScriptBlock for remote sessions; i.e. `Invoke-Command`.
.DESCRIPTION
    The Get-ScriptBlockFromFiles cmdlet dynamically generates a script 
    block from the specified .ps1 files and [OPTIONAL] inline PowerShell
    code that is passed to `Invoke-Command`.
.NOTES
    `Invoke-Command -FilePath ...` is the usual answer to import common code 
    into a remote session, but dumping various functions from modules and 
    script files is more complicated, (can't pass parameters as-is) error 
    prone, and unmaintainable.
.EXAMPLE
    $dynamicScript = Get-ScriptBlockFromFiles -psFiles @(file00,file01,file02) `
                     -inlineBlock @'
Start-Sleep -Seconds (Get-Random -Maximum 10 -Minimum 2);
return Get-Date;
'@;

    $mainJob = Invoke-Command -ComputerName $hosts `
        -ThrottleLimit 5 `
        -AsJob -ScriptBlock $dynamicScript;
#>
function Get-ScriptBlockFromFiles {
    [CmdletBinding()]
    param(
        # **FULL** path to file
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $psFiles

        ,[string]$inlineBlock
    );

    $scripts = New-Object System.Text.StringBuilder;
    foreach ($psFile in $psFiles) {
        $ext = [System.IO.Path]::GetExtension($psFile);
        if ($ext -eq '.ps1') {
            $scripts.AppendLine([System.IO.File]::ReadAllText($psFile)) | Out-Null; 
        }
    }

    if ($inlineBlock) { $scripts.AppendLine($inlineBlock) | Out-Null; }

    return [ScriptBlock]::Create($scripts.ToString());
}