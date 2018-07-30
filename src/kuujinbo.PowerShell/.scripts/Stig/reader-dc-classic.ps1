#region load modules
# ----------------------------------------------------------------------------
# for THIS script
$stigModPath = Join-Path $PSScriptRoot '../../Modules/Stig/ReaderDcClassic.psm1';
Import-Module $stigModPath -DisableNameChecking -Force;


# ----------------------------------------------------------------------------
#endregion

Set-Variable TEMPLATE -option ReadOnly -value ([string] "$($PSScriptRoot)/TEMPLATE-reader-dc-classic-V1R4.ckl");

$results = Get-RegistryResults (Get-ReaderDcClassicRegistry -version 2017);
$results;
