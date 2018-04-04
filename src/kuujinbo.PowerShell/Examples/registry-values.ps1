Import-Module (Join-Path $PSScriptRoot '../Modules/Stig/Stig.psm1') -DisableNameChecking -Force -Verbose;
$registryPath = 'HKCU:\Software\Testing\TestPath';
$registryName = 'Version';

# get 
$result = Get-RegistryValue $registryPath $registryName;
$regPath = "$registryPath [$registryName]";
if ($result -ne $null) {
    Write-Host "$regPath => $result";
} else {
    Write-Host "$regPath does not exist";
}


# set
<#
$registryType = 'DWORD';
$registryValue = 20;

Set-RegistryValue $registryPath $Name $registryType $registryValue;
#>