<#
.SYNOPSIS
    Dynamically get a ScriptBlock for remote sessions; i.e. `Invoke-Command`.
.NOTES
    `Invoke-Command -FilePath ...` is the usual answer to import common code 
    into a remote session, but dumping various functions from modules and 
    script files is more complicated, (can't pass parameters as-is) error 
    prone, and unmaintainable.
.EXAMPLE
$scriptDirectories = @(
    "$PSScriptRoot/PATH-00"
    ,"$PSScriptRoot/PATH-01"
);

$psFiles = @(
    "$PSScriptRoot/script00.ps1"
    ,"$PSScriptRoot/script01.ps1"
    # ....
);

$dynamicScript = Get-ScriptBlock -scriptDirectories $scriptDirectories -psFiles $psFiles `
    -inlineBlock @'
$result = @{};
$result += Get-Hashtable00;
$result += Get-Hashtable01;

return $result;
'@;
#>
function Get-ScriptBlock {
    [CmdletBinding()]
    param(
        # all .ps1 files in each directory
        [string[]] $scriptDirectories
        ,[switch] $recurse

        # **FULL** path to files
        ,[string[]] $psFiles

        # execute inline script block(s)
        ,[string]$inlineBlock
    );
    $scripts = New-Object System.Text.StringBuilder;

    $params = @{
        'File' = $true;
        'Filter' = '*.ps1';
    }
    if ($recurse.IsPresent) { $params.'Recurse' = $true; }
    foreach ($dir in $scriptDirectories) {
        $params.'Path' = $dir;
        Get-ChildItem @params | `
            foreach { 
                $scripts.AppendLine([System.IO.File]::ReadAllText($_.FullName)) | Out-Null; 
            };
    }

    foreach ($psFile in $psFiles) {
        $ext = [System.IO.Path]::GetExtension($psFile);
        if ($ext -eq '.ps1') {
            $scripts.AppendLine([System.IO.File]::ReadAllText($psFile)) | Out-Null; 
        }
    }

    if ($inlineBlock) { $scripts.AppendLine($inlineBlock) | Out-Null; }

    return [ScriptBlock]::Create($scripts.ToString());
}