<# 
----------------------------------------
covered by SCAP
----------------------------------------
V-7055 /  SV-7438r2_rule 
V-7061 / SV-7444r3_rule
V-30926 / SV-40966r1_rule
V-31026 / V-31026
#>

<# 
TODO
V-7063 / SV-7446r3_rule
    Fix Text: All publishers' certificates must have documented approvals from the IAO.
#>

<# 
TODO
V-7067 / SV-7450r3_rule
    Check Text: If the application is a COTS product, the requirement is Not Applicable (NA).
#>

<# 
TODO
V-18395 / SV-19930r2_rule
    - Search for all the Mscorlib.dll files:
        %systemroot%\Microsoft.NET\Framework
        %systemroot%\Microsoft.NET\Framework64

    - Determine .Net Framework installed versions: http://support.microsoft.com/kb/318785
    - Verify extended support is available for the installed versions of .Net Framework.
        -- Verify the .Net Framework support dates with Microsoft Product Lifecycle Search link.
           http://support.microsoft.com/lifecycle/search/?sort=PN&alpha=.NET+Framework

    - If any versions of the .Net Framework are installed and support is no longer available, this is a finding.
#>

<#
.SYNOPSIS
    Get .NET STIG one-off / specific rule check results.
#>
function Get-DotNetCombinedResults {
    $result = @{};
    $result += Get-DotNetManualResults;

    $V30935 = @{
        'SV-40977r1_rule' = @('HKLM:\SOFTWARE\Microsoft\.NETFramework', 'AllowStrongNameBypass', '0');
    };
    $result += Get-RegistryResults $V30935;
    
    return $result; 
}

<#
.SYNOPSIS
    Get .NET STIG results that **CANNOT BE AUTOMATED**.
#>
function Get-DotNetManualResults {
    return @{
        # V-7069 
        'SV-7452r2_rule' = @(
            $CKL_STATUS_OPEN, 
            @'
Requires verification of organizational policy and documentation regarding the location of system and application specific CAS policy configuration files and the frequency in which backups occur.
'@
        );
        # V-30986
        'SV-41030r1_rule' = @(
            $CKL_STATUS_OPEN, 
            @'
Requires verification of organizational policy that provides documentation for:
- Each .Net 4.0 application they run on the system.
- The .Net runtime host that invokes the application. 
- The security measures employed to control application access to system resources or user access to application.
'@
        );
    };
}