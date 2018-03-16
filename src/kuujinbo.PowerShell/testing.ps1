# load dot source script file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
. (Join-Path $scriptDir 'Stig/File.ps1');
. (Join-Path $scriptDir 'Stig/Stig.ps1');


$r = Get-Rules (Join-Path (Get-DesktopPath) '.ps-STIG/U_Windows_10_STIG_V1R12_Manual-xccdf.xml');

foreach ($rr in $r.keys) {
    if ($r.$rr.registry.length -gt 0) {
        $array =  $r.$rr.registry;
        $hive = $REGISTRY_HIV[$array[0]] + ':' + $array[1];

        "(Get-RegistryValue $hive $($array[2]))";
        # "(Get-Item -LiteralPath $($hive)).GetValue('$($array[2])', `$null)";
    }
}