<#
.SYNOPSIS
    Dynamically get a ScriptBlock for remote sessions; i.e. `Invoke-Command`.
.DESCRIPTION
    The Get-ScriptBlockForRemote cmdlet dynamically generates a script 
    block from .ps1 files located in one or more directories used as a 
    parameter when calling `Invoke-Command`.
.NOTES
    `Invoke-Command -FilePath ...` is the usual answer to import common code 
    into a remote session, but dumping various functions from modules and 
    script files is more complicated, (can't pass parameters as-is) error 
    prone, and unmaintainable.
.EXAMPLE
    $dynamicScript = Get-ScriptBlockForRemote -recurse -scriptDirectories @("$PSScriptRoot/Modules/Stig/cmdlets");
    $session = New-PSSession -ComputerName $computer;
    Invoke-Command -Session $session -ScriptBlock $dynamicScript;
#>
function Get-ScriptBlockForRemote {
    param(
        [string[]] $scriptDirectories
        ,[switch] $recurse
    );

    $scripts = New-Object System.Text.StringBuilder;

    $baseCmdlet = 'Get-ChildItem ';
    if ($recurse.IsPresent) { $baseCmdlet += '-Recurse '}

    foreach ($dir in $scriptDirectories) {
        $cmdlet = $baseCmdlet + " -Path $dir -Filter *.ps1";
        Invoke-Expression $cmdlet | `
            foreach { 
                $scripts.AppendLine([System.IO.File]::ReadAllText($_.FullName)) | Out-Null; 
            };
    }

    return [ScriptBlock]::Create($scripts.ToString());
}