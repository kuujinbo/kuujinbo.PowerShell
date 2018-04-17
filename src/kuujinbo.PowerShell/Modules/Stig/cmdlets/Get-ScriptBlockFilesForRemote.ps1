<#
.SYNOPSIS
    Dynamically get a ScriptBlock for remote sessions; i.e. `Invoke-Command`.
.DESCRIPTION
    The Get-ScriptBlockFilesForRemote cmdlet dynamically generates a script 
    block from the specified .ps1 files that are used as a parameter when 
    calling `Invoke-Command`.
.NOTES
    `Invoke-Command -FilePath ...` is the usual answer to import common code 
    into a remote session, but dumping various functions from modules and 
    script files is more complicated, (can't pass parameters as-is) error 
    prone, and unmaintainable.
.EXAMPLE
    $dynamicScript = Get-ScriptBlockFilesForRemote -recurse -psFiles file0,file1,file2;
    $session = New-PSSession -ComputerName $computer;
    Invoke-Command -Session $session -ScriptBlock $dynamicScript;
#>
function Get-ScriptBlockFilesForRemote {
    param(
        # **FULL** path to file
        [string[]] $psFiles
    );

    $scripts = New-Object System.Text.StringBuilder;
    foreach ($psFile in $psFiles) {
        $ext = [System.IO.Path]::GetExtension($psFile);
        if ($ext -eq '.ps1') {
            $scripts.AppendLine([System.IO.File]::ReadAllText($psFile)) | Out-Null; 
        }
    }

    return [ScriptBlock]::Create($scripts.ToString());
}