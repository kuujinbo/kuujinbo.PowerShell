<#


$cs = New-CimSession -ComputerName $h;
Get-CimInstance -ComputerName $h -ClassName $CIM_CLASS_OS | select caption, OSArchitecture;
   
# WN10-CC-000310 => Users must be prevented from changing installation options.
# SOFTWARE\Policies\Microsoft\Windows\Installer
$x = Invoke-CimMethod -CimSession $cs -Namespace $CIM_REGISTRY_NAMESPACE -ClassName $CIM_REGISTRY_PROVIDER_CLASSNAME -MethodName GetDWORDValue -Arguments @{hDefKey=$HKLM; sSubKeyName=$subkey; sValueName=$value} | select uvalue;


$class = Get-CimClass -Namespace root/cimv2 -ClassName StdRegProv;
$class.CimClassMethods | select Name;

OUTPUT:
----------------------------------------------------------------------------
CreateKey
DeleteKey
EnumKey
EnumValues
DeleteValue
SetDWORDValue
SetQWORDValue
GetDWORDValue
GetQWORDValue
SetStringValue
GetStringValue
SetMultiStringValue
GetMultiStringValue
SetExpandedStringValue
GetExpandedStringValue
SetBinaryValue
GetBinaryValue
CheckAccess
SetSecurityDescriptor
GetSecurityDescriptor

$subkey = 'SOFTWARE\Policies\Microsoft\Windows\Installer';
$value = 'EnableUserControl';
Invoke-CimMethod -Namespace root/cimv2 -ClassName StdRegProv -MethodName GetDWORDValue -Arguments @{hDefKey=$hklm; sSubKeyName=$subkey; sValueName=$value}


function Get-CimRegistryValue($path, $valueName) {
    # ReturnValue -eq 0 # success => sSubKeyName and sValueName **BOTH** exist
    # ReturnValue -eq 1 # fail => sSubKeyName exists, but sValueName does **NOT** exist
    # ReturnValue -eq 2 # fail => sSubKeyName does not exist
}


Set-Variable CIM_CLASS_OS -option ReadOnly -value ([string] 'Win32_OperatingSystem');
Set-Variable CIM_REGISTRY_NAMESPACE -option ReadOnly -value ([string] 'root/cimv2');
Set-Variable CIM_REGISTRY_PROVIDER_CLASSNAME -option ReadOnly -value ([string] 'StdRegProv');

Set-Variable HKCR -option ReadOnly -value ([uint32] 2147483648);
Set-Variable HKCU -option ReadOnly -value ([uint32] 2147483649);
Set-Variable HKLM -option ReadOnly -value ([uint32] 2147483650);
Set-Variable HKUS -option ReadOnly -value ([uint32] 2147483651);
Set-Variable HKCC -option ReadOnly -value ([uint32] 2147483653);

#>