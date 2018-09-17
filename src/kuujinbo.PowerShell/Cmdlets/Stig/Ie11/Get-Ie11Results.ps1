function Get-Ie11Results {
    [CmdletBinding()]
    param( )
}


<#
.SYNOPSIS
    Get HKU registry rules
#>
function Get-Ie11HKLM {
    [CmdletBinding()]
    param( )

    @{
        'SV-59337r8_rule' = @("HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings", 'SecureProtocols', '2560');
        'SV-79207r1_rule' = @("HKLM:Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings", 'PreventIgnoreCertErrors', '1');
    };
}

function Get-Ie11HKU {
    [CmdletBinding()]
    param( )

    @{
        'SV-59341r4_rule' = @("Registry::HKEY_USERS\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing Criteria", 'State', '0x23C00');
        'SV-59673r1_rule' = @("Registry::HKEY_USERS\Software\Policies\Microsoft\Internet Explorer\Main", 'Use FormSuggest', 'no');
        'SV-59681r1_rule' = @("Registry::HKEY_USERS\Software\Policies\Microsoft\Internet Explorer\Main", 'FormSuggest Passwords', 'no');
        # 'SV-59681r1_rule' = @("Registry::HKEY_USERS\Software\Policies\Microsoft\Internet Explorer\Main", 'FormSuggest PW Ask', 'no');
    };
}