<#
.SYNOPSIS
    Get .NET STIG results that **CANNOT BE AUTOMATED**.
#>
function Get-DotNetManualResults {
    [CmdletBinding()]
    param()

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