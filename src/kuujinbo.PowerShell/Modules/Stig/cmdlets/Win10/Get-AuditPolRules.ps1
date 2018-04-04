<#
.SYNOPSIS
    Get W10 STIG AuditPol rules 
.DESCRIPTION
    The Get-AuditPolRules cmdlet gets all W10 W10 STIG AuditPol rules.
.NOTES
    Current return value is manually created.
.TODO
    Automate or partially automate generating data structure.
#>
function Get-AuditPolRules {
    # ID, Group, Category/Subcategory, Expected (pass)
    @{
        'V-63459' = @('Logon/Logoff', 'Logoff', 'Success');
        'V-63463' = @('Logon/Logoff', 'Logon', 'Failure');
        'V-63467' = @('Logon/Logoff', 'Logon', 'Success;');
        'V-63469' = @('Logon/Logoff', 'Special Logon', 'Success');
        'V-75027' = @('Object Access', 'File Share', 'Failure');
        'V-74721' = @('Object Access', 'File Share', 'Success');
        'V-74411' = @('Object Access', 'Other Object Access Events', 'Success');
        'V-74409' = @('Object Access', 'Other Object Access Events', 'Failure');
        'V-63471' = @('Object Access', 'Removable Storage', 'Failure');
        'V-63473' = @('Object Access', 'Removable Storage', 'Success');
        'V-63475' = @('Policy Change', 'Audit Policy Change', 'Failure');
        'V-63479' = @('Policy Change', 'Audit Policy Change', 'Success');
        'V-63481' = @('Policy Change', 'Authentication Policy Change', 'Success');
        'V-71761' = @('Policy Change', 'Authorization Policy Change', 'Success');
        'V-63483' = @('Privilege Use', 'Sensitive Privilege Use', 'Failure');
        'V-63487' = @('Privilege Use', 'Sensitive Privilege Use', 'Success');
        'V-63491' = @('System', 'IPSec Driver', 'Failure');
        'V-63495' = @('System', 'IPSec Driver', 'Success');
        'V-63499 ' = @('System', 'Other System Events', 'Success');
        'V-63503' = @('System', 'Other System Events', 'Failure');
        'V-63507' = @('System', 'Security State Change', 'Success');
        'V-63511' = @('System', 'Security System Extension', 'Failure');
        'V-63513' = @('System', 'Security System Extension', 'Success');
        'V-63515' = @('System', 'System Integrity', 'Failure');
        'V-63517' = @('System', 'System Integrity', 'Success');
        'V-63431' = @('Account Logon', 'Credential Validation', 'Failure');
        'V-63435' = @('Account Logon', 'Credential Validation', 'Success');
        'V-63439' = @('Account Management', 'Other Account Management Events', 'Failure');
        'V-63441' = @('Account Management', 'Other Account Management Events', 'Success');
        'V-63443' = @('Account Management', 'Security Group Management', 'Failure');
        'V-63445' = @('Account Management', 'Security Group Management', 'Success');
        'V-63447' = @('Account Management', 'User Account Management', 'Failure');
        'V-63449' = @('Account Management', 'User Account Management', 'Success');
        'V-63451' = @('Detailed Tracking', 'Plug and Play Events', 'Success');
        'V-63453' = @('Detailed Tracking', 'Process Creation', 'Success');
        'V-71759' = @('Logon/Logoff', 'Account Lockout', 'Failure');
        'V-63455' = @('Logon/Logoff', 'Account Lockout', 'Success');
        'V-63457' = @('Logon/Logoff', 'Group Membership', 'Success');
    };
}