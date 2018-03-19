# load dot source script file
$thisScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
. (Join-Path $thisScriptDir 'Stig/File.ps1');
. (Join-Path $thisScriptDir 'Stig/Stig.ps1');

$r = Get-Rules (Join-Path (Get-DesktopPath) '.ps-STIG/U_Windows_10_STIG_V1R12_Manual-xccdf.xml');
$parsed = @{};
foreach ($key in $r.Keys) {
    if ($r.$key.registry.length -gt 0) {
        $array =  $r.$key.registry;
        $expected = $array[4].Trim(); 
        if ($expected.length -eq 1) { $expected = "-eq $expected"; }
        $parsed[$key] = New-Object -TypeName PSObject -Property (@{
            hive = $REGISTRY_HIV[$array[0]] + ':' + $array[1]; 
            value = $array[2];
            expected = $expected;
        });
    }
}
$parsed | ConvertTo-Json | Out-File (Join-Path $thisScriptDir reg-raw.json);


foreach ($rr in $r.keys) {
    if ($r.$rr.registry.length -gt 0) {
        $array =  $r.$rr.registry;
        $hive = $REGISTRY_HIV[$array[0]] + ':' + $array[1];

        "(Get-RegistryValue $rr $hive $($array[2]))";
    }
}