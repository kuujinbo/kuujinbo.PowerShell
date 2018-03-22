$json = @"
{
    "V-63325":  {
                    "expected":  " -eq 0",
                    "hive":  "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Installer\\",
                    "value":  "AlwaysInstallElevated"
                },
    "V-63743":  {
                    "expected":  " -eq 1",
                    "hive":  "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Internet Explorer\\Feeds\\",
                    "value":  "DisableEnclosureDownload"
                },
    "V-63585":  {
                    "expected":  "1",
                    "hive":  "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WcmSvc\\GroupPolicy\\",
                    "value":  "fBlockNonDomain"
                },
    "V-63759":  {
                    "expected":  "1",
                    "hive":  "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\LanManServer\\Parameters\\",
                    "value":  "RestrictNullSessAccess"
                }
}
"@;

$obj = $json | ConvertFrom-Json;

foreach ($k in $obj.PSObject.Properties) {
    Write-Host "$($k.Name) :: $($k.Value.expected)";
}