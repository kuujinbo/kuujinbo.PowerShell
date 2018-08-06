Set-Variable CATs -option ReadOnly -value (([ordered]@{
    low = 'CAT I';
    medium = 'CAT II';
    high = 'CAT III';
}).AsReadOnly());

Set-Variable REGISTRY_HIVE -option ReadOnly -value (([ordered]@{
    HKEY_LOCAL_MACHINE = 'HKLM';
    HKEY_CURRENT_USER = 'HKCU';
    HKEY_CLASSES_ROOT = 'HKCR';
    HKEY_CURRENT_CONFIG = 'HKCC';
    HKEY_USERS = 'HKU';
}).AsReadOnly());

# .ckl XML node names
Set-Variable CKL_STATUS -option ReadOnly -value ([string] 'STATUS');
Set-Variable CKL_DETAILS -option ReadOnly -value ([string] 'FINDING_DETAILS');
Set-Variable CKL_COMMENTS -option ReadOnly -value ([string] 'COMMENTS');

# .ckl XML status values
Set-Variable CKL_STATUS_OPEN -option ReadOnly -value ([string] 'Open');
Set-Variable CKL_STATUS_PASS -option ReadOnly -value ([string] 'NotAFinding');
Set-Variable CKL_STATUS_NA -option ReadOnly -value ([string] 'Not_Applicable');
Set-Variable CKL_STATUS_NOT_REVIEWED -option ReadOnly -value ([string] 'Not_Reviewed');

# incomplete SCAP scan results
Set-Variable SCAP_DETAILS -option ReadOnly -value ([string] 'SCAP scanned.');
Set-Variable SCAP_COMMENTS -option ReadOnly -value ([string] 'Not a finding.');