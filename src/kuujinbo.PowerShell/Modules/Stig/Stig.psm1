#region constants
Set-Variable CIM_CLASS_OS -option Constant -value ([string] 'Win32_OperatingSystem');
Set-Variable CIM_REGISTRY_NAMESPACE -option Constant -value ([string] 'root/cimv2');
Set-Variable CIM_REGISTRY_PROVIDER_CLASSNAME -option Constant -value ([string] 'StdRegProv');

Set-Variable CATs -option Constant -value (@{
    low = 'CAT I';
    medium = 'CAT II';
    high = 'CAT III';
});

Set-Variable REGISTRY_HIVE -option Constant -value (@{
    HKEY_LOCAL_MACHINE = 'HKLM';
    HKEY_CURRENT_USER = 'HKCU';
    HKEY_CLASSES_ROOT = 'HKCR';
    HKEY_CURRENT_CONFIG = 'HKCC';
    HKEY_USERS = 'HKUS';
});

Set-Variable HKCR -option Constant -value ([uint32] 2147483648);
Set-Variable HKCU -option Constant -value ([uint32] 2147483649);
Set-Variable HKLM -option Constant -value ([uint32] 2147483650);
Set-Variable HKUS -option Constant -value ([uint32] 2147483651);
Set-Variable HKCC -option Constant -value ([uint32] 2147483653);

Set-Variable CKL_STATUS -option Constant -value ([string] 'STATUS');
Set-Variable CKL_DETAILS -option Constant -value ([string] 'FINDING_DETAILS');
Set-Variable CKL_COMMENTS -option Constant -value ([string] 'COMMENTS');
#endregion


#region remoting utilities
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
#endregion


#region utility-functions
function Get-Lines {
    param(
        [Parameter(Mandatory)] [string]$text
    )

    return $text.Split(
        [string[]] (, "`r`n", "`n", "`r"), 
        [StringSplitOptions]::RemoveEmptyEntries
    );
}

function Get-Win10Version {
    Get-RegistryValue 'HKLM:\software\microsoft\windows nt\currentversion' releaseid;
}
#endregion


#region registry helpers
<#
.SYNOPSIS
    Get registry value
.DESCRIPTION
    The Get-RegistryValue cmdlet gets a registry value from the supplied path
    and value name.
.NOTES
    Caller **MUST** check return value if testing for the existence of the
    value name; if does not exist will be $null.
.EXAMPLE
    $params = @{path = 'HKLM:\software\microsoft\windows nt\currentversion'; name = 'releaseid'};
    $result = Get-RegistryValue $params;    
#>
function Get-RegistryValue {
    param(
        [Parameter(Mandatory)] [string]$path
        , [Parameter(Mandatory)] [string]$valueName
    );
    if (Test-Path -LiteralPath $path) {
        # return needed, or wrong type returned
        return (Get-Item -LiteralPath $path).GetValue($valueName, $null);
    }
    return $null; # explicitly return default value
}

<#
.SYNOPSIS
    Set registry key value
.DESCRIPTION
    The Set-RegistryValue cmdlet adds or updates a registry key value from
    the supplied parameters.
.EXAMPLE
    $registryPath = 'HKCU:\Software\Testing\TestPath';
    $registryName = 'Version';
    $registryType = 'DWORD';
    $registryValue = 25;
    Set-RegistryValue $registryPath $Name $registryType $registryValue;
#>
function Set-RegistryValue {
    param(
        [Parameter(Mandatory)] [string]$path
        , [Parameter(Mandatory)] [string]$valueName
        , [Parameter(Mandatory)] [string]$valueType
        , [Parameter(Mandatory)] $value
    );

    if (!(Test-Path -LiteralPath $path)) {
        New-Item -Path $path -Force | Out-Null;
    } 
    New-ItemProperty -Path $path -Name $valueName `
        -PropertyType $valueType -Value $value `
        -Force | Out-Null;
}


function Get-CimRegistryValue($path, $valueName) {
    # ReturnValue -eq 0 # success => sSubKeyName and sValueName **BOTH** exist
    # ReturnValue -eq 1 # fail => sSubKeyName exists, but sValueName does **NOT** exist
    # ReturnValue -eq 2 # fail => sSubKeyName does not exist
}
#endregion

#region AuditPol
<#
.SYNOPSIS
    Get AuditPol STDOUT in a PowerShell data structure.
.DESCRIPTION
    The Get-AuditPol cmdlet parses AuditPol.exe STDOUT and converts result
    into a PowerShell data structure.
#>
function Get-AuditPol {
    # suppress STDERR if run with insufficient privileges
    $audit = ((AuditPol /get /category:* 2>$null) | Out-String) -join '';
    if (!$audit) { return $null; }

    $lines = Get-Lines $audit;
    # remove headers
    $lines =  $lines[2..($lines.length-1)];

    $result = @{};
    $group = '';
    foreach ($line in $lines) {
        $subCategory, $setting = [Regex]::Split($line.Trim(), '\s{2,}', 2);

        if ($setting -eq $null) {
            $group = $subCategory;
            $result.$group = @{};
        } else {
            $result.$group.$subCategory = $setting;
        }
    }
    return $result;
}
#endregion

#region rule file filter
function Get-WantedRules {
    param(
        [Parameter(Mandatory)] [string]$xmlRulesInPath
        ,[Parameter(Mandatory)] [string]$xmlRulesOutPath
        ,[Parameter(Mandatory)] [hashtable]$wantedRules

    )

    [xml]$cklTemplate = Get-Content -Path $xmlRulesInPath -ErrorAction Stop;
    if ($cklTemplate) {
        foreach ($group in $cklTemplate.Benchmark.Group) {
            foreach ($rule in $group.Rule) {
                if (!$wantedRules.ContainsKey($group.id)) {
                    $group.ParentNode.RemoveChild($group) | out-null;
                }
            }
        }
        $cklTemplate.Save($xmlRulesOutPath);
    }
}
#endregion


#region CKL generator
<#
.SYNOPSIS
    Export STIG scan results to a .ckl file
.DESCRIPTION
    The Export-Ckl cmdlet exports STIG scan results from a host to a .ckl
    file. 
.NOTES
    Tested on STIG Viewer 2.6.1. To save template file:
    [1] Checklist => Create Checklist - Check Marked STIG(s)
    [2] File => Save Checklist As...
#>
function Export-Ckl {
    param(
        [Parameter(Mandatory)] [string]$cklInPath
        ,[Parameter(Mandatory)] [string]$cklOutPath
        ,[Parameter(Mandatory)] [hashtable]$data
    )

    [xml]$cklTemplate = Get-Content -Path $cklInPath -ErrorAction Stop;
    if ($cklTemplate) {
        foreach ($iStig in $cklTemplate.CHECKLIST.STIGS.iSTIG) {
            foreach ($vuln in $iStig.VULN) {
                $id = $vuln.STIG_DATA.ATTRIBUTE_DATA[0];
                if ($data.ContainsKey($id)) {
                    $vuln.$CKL_STATUS = $data.$id.$CKL_STATUS;
                    if ($data.$id.ContainsKey($CKL_DETAILS)) { 
                        $vuln.$CKL_DETAILS = $data.$id.$CKL_DETAILS; 
                    }
                    if ($data.$id.ContainsKey($CKL_COMMENTS)) { 
                        $vuln.$CKL_COMMENTS = $data.$id.$CKL_COMMENTS; 
                    }
                }
            }
        }
        $cklTemplate.Save($cklOutPath);
    }
}
#endregion


#region rule file parser
<#
.SYNOPSIS
    Get STIG rules XML file in a PowerShell data structure.
.DESCRIPTION
    The Get-Rules cmdlet parses A STIG rule XML file and converts into a
    PowerShell data structure.
#>
function Get-Rules {
    param(
        [Parameter(Mandatory)] [string]$xmlRulesPath
        , [string]$regWorkingOutPath
    )

    [xml]$cklTemplate = Get-Content -Path $xmlRulesPath -ErrorAction Stop;
    if ($cklTemplate) {
        $result = @{};
        $working = New-Object System.Text.StringBuilder;
        foreach ($group in $cklTemplate.Benchmark.Group) {
            foreach ($rule in $group.Rule) {
                $result[$group.id] = New-Object -TypeName PSObject -Property (@{
                    title = $rule.title;
                    severity = $CATs[$rule.severity];
                });
                if ($regWorkingOutPath) { 
                    $a = Get-RegistryInfoFromCheckContent $rule.check.'check-content' $group.id;
                    if ($a.length -gt 0) { 
                        $hive = $REGISTRY_HIVE[$a[0]] + ':' + $a[1];
                        $working.AppendLine(
                            "'$($group.id)' = @('$hive', '$($a[2])', '$($a[4])');"
                        ) | Out-Null;
                    }
                }
            }
        }

        if ($regWorkingOutPath) { $working.ToString() | Out-File -FilePath $regWorkingOutPath; }

        return $result;
    }
}

function Get-RegistryInfoFromCheckContent {
    param(
        [Parameter(Mandatory)] [string]$text
        , [Parameter(Mandatory)] [string]$rule
    )
    <#
        STIG authors **RIDICULOUSLY** inconsistent, but should be in groups of 5:
        Registry Hive, Registry Path, Value Name, [Value] Type, Value
    #>
    $result = @();
    $wanted = "^(?:registry|value|type)[^:]*:(?'value'.*)";
    $lines = Get-Lines $text;
    foreach ($line in $lines) {
        if ($line -match $wanted) {
            $result += $matches['value'].Trim();
        }
    }

    if (($result.length -gt 0) -and ($result.length % 5 -eq 0)) { 
        return $result; 
    } else  { 
        return @(); 
    }
}
#endregion