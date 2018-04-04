Set-Variable CIM_CLASS_OS -option ReadOnly -value ([string] 'Win32_OperatingSystem');
Set-Variable CIM_REGISTRY_NAMESPACE -option ReadOnly -value ([string] 'root/cimv2');
Set-Variable CIM_REGISTRY_PROVIDER_CLASSNAME -option ReadOnly -value ([string] 'StdRegProv');

Set-Variable CATs -option ReadOnly -value (@{
    low = 'CAT I';
    medium = 'CAT II';
    high = 'CAT III';
});

Set-Variable REGISTRY_HIVE -option ReadOnly -value (@{
    HKEY_LOCAL_MACHINE = 'HKLM';
    HKEY_CURRENT_USER = 'HKCU';
    HKEY_CLASSES_ROOT = 'HKCR';
    HKEY_CURRENT_CONFIG = 'HKCC';
    HKEY_USERS = 'HKUS';
});

Set-Variable HKCR -option ReadOnly -value ([uint32] 2147483648);
Set-Variable HKCU -option ReadOnly -value ([uint32] 2147483649);
Set-Variable HKLM -option ReadOnly -value ([uint32] 2147483650);
Set-Variable HKUS -option ReadOnly -value ([uint32] 2147483651);
Set-Variable HKCC -option ReadOnly -value ([uint32] 2147483653);

# XML node names
Set-Variable CKL_STATUS -option ReadOnly -value ([string] 'STATUS');
Set-Variable CKL_DETAILS -option ReadOnly -value ([string] 'FINDING_DETAILS');
Set-Variable CKL_COMMENTS -option ReadOnly -value ([string] 'COMMENTS');

