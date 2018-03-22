Import-Module (Join-Path $PSScriptRoot '../Modules/Stig/Stig.psm1') -DisableNameChecking -Force -Verbose;

$registryPath = 'HKCU:\Software\Testing\TestPath';
$registryName = 'Version';

# get 
$params = @{path = $registryPath; name = $registryName};
$result = Get-RegistryValue $params;    
Get-RegistryValue


# set
$registryType = 'DWORD';
$registryValue = 20;

Set-RegistryValue $registryPath $Name $registryType $registryValue;