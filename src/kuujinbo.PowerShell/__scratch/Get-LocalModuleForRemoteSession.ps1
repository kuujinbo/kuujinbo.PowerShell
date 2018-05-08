<#
.SYNOPSIS
    Dynamically get a local module for remote sessions; i.e. `Invoke-Command`.
.DESCRIPTION
    The Get-LocalModuleForRemoteSession cmdlet dynamically generates a script 
    block from a local module for use when calling `Invoke-Command`.
.NOTES
    `Invoke-Command -FilePath ...` is the usual answer to import common code 
    into a remote session, but dumping various functions from modules and 
    script files is more complicated, (can't pass parameters as-is) error 
    prone, and unmaintainable.
.EXAMPLE
    $dynamicScript = Get-LocalModuleForRemoteSession 'C:\PSmodules\MYModule.psm1';
    $session = New-PSSession -ComputerName $computer;
    # suppress constant import errors
    Invoke-Command -Session $session -ScriptBlock $dynamicScript -ErrorAction SilentlyContinue;
#>
function Get-LocalModuleForRemoteSession {
    param( [string] $modulePath );

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($modulePath);
    $moduleObject = Get-Module $baseName;
    if (!$moduleObject) 
    { 
        Import-Module $modulePath -DisableNameChecking;
        $moduleObject = Get-Module $baseName;
    }

    $moduleDefinition = @"
if (Get-Module $baseName) { Remove-Module $baseName; }
New-Module -name $baseName {
    $($moduleObject.Definition);
    Export-ModuleMember -Function "*";
    Export-ModuleMember -Variable "*";
    Export-ModuleMember -Alias "*";
    Export-ModuleMember -Cmdlet "*";
} | Import-Module -DisableNameChecking;
"@;

    return [ScriptBlock]::Create($moduleDefinition);
}