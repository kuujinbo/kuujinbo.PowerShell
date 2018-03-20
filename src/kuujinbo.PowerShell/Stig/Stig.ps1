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
});

# HKEY_LOCAL_MACHINE
Set-Variable HKLM -option Constant -value ([uint32] 2147483650);
# HKEY_CURRENT_USER 
Set-Variable HKCU -option Constant -value ([uint32] 2147483649);
#HKEY_CLASSES_ROOT 
Set-Variable HKCR -option Constant -value ([uint32] 2147483648);
# HKEY_CURRENT_CONFIG 
Set-Variable HKCC -option Constant -value ([uint32] 2147483653);

Set-Variable _dotSourceCallerScript -option Constant -value ([string] $MyInvocation.ScriptName);
# ONLY allow dot source access to this script
if ($_dotSourceCallerScript -eq '') {
    Write-Host 'DO NOT call this script directly; ONLY use via dot source.';
    exit;
}
Set-Variable _dotSourceCallerDirectory -option Constant -value ([string] (Split-Path -Parent $_dotSourceCallerScript));
#endregion

#region utility-functions
# ----------------------------------------------------------------------------
<#
.SYNOPSIS
    Get full path to calling script directory
.DESCRIPTION
    The Get-CallingScriptDirectory cmdlet gets the full path to calling 
    script directory.
#>
function Get-CallingScriptDirectory {
    $_dotSourceCallerDirectory;
}

function Get-Lines {
    param(
        [Parameter(Mandatory=$true)] [string]$text
    )

    return $text.Split(
        [string[]] (, "`r`n", "`n", "`r"), 
        [StringSplitOptions]::RemoveEmptyEntries
    );
}
# ----------------------------------------------------------------------------
#endregion


#region registry helpers
# ----------------------------------------------------------------------------
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
function Get-RegistryValue($path, $valueName) {
    if (Test-Path -LiteralPath $path) {
        # return needed, or wrong type returned
        return (Get-Item -LiteralPath $path).GetValue($valueName, $null);
    }
    return $null; # explicitly return default value
}

function Get-CimRegistryValue($path, $valueName) {
    # ReturnValue -eq 0 # success => sSubKeyName and sValueName **BOTH** exist
    # ReturnValue -eq 1 # fail => sSubKeyName exists, but sValueName does **NOT** exist
    # ReturnValue -eq 2 # fail => sSubKeyName does not exist
}
# ----------------------------------------------------------------------------
#endregion


#region rule file parser
# ----------------------------------------------------------------------------
<#
.SYNOPSIS
    Get STIG rules XML file in a PowerShell data structure.
.DESCRIPTION
    The Get-Rules cmdlet parses A STIG rule XML file and converts into a
    PowerShell data structure.
#>
function Get-Rules {
    param(
        [Parameter(Mandatory=$true)] [string]$xmlRulesPath
        , [string]$regWorkingOutPath
    )

    [xml]$xmlRules = Get-Content -Path $xmlRulesPath -ErrorAction Stop;
    if ($xmlRules) {
        $result = @{};
        $working = New-Object System.Text.StringBuilder;
        foreach ($group in $xmlRules.Benchmark.Group) {
            foreach ($rule in $group.Rule) {
                $result[$group.id] = New-Object -TypeName PSObject -Property (@{
                    title = $rule.title;
                    severity = $CATs[$rule.severity];
                });
                if ($regWorkingOutPath) { 
                    $a = Parse-CheckContent $rule.check.'check-content' $group.id;
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



function Parse-CheckContent {
    param(
        [Parameter(Mandatory=$true)] [string]$text
        , [Parameter(Mandatory=$true)] [string]$rule
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
# ----------------------------------------------------------------------------
#endregion


#region AuditPol
# ----------------------------------------------------------------------------
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
# ----------------------------------------------------------------------------
#endregion