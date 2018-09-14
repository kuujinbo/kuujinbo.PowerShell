#region rules lookup
    $config = @{
        'SV-81429r4_rule' = 'deployment.config'; # file exists
        'SV-81431r3_rule' = 'deployment.system.config'; # file\:\\C\:\\Program Files (x86)\\Java\\jre\\lib\\deployment.properties
    # 'deployment.system.config.mandatory=true'
    };
        # 'SV-81433r2_rule' = 'deployment.properties';  # file exists
        # 'SV-81447r3_rule' = 'deployment.user.security.exception.sites';  # file exists
        # 'SV-81455r1_rule' = 'Ensure only one instance of JRE is in the list of installed software. If more than one instance of JRE is listed, this is a finding.';
        # 'SV-81449r2_rule' = 'deployment.user.security.exception.sites=C:/Program Files (x86)/Java/jre/lib/security/exception.sites'; # pending


'SV-59337r7_rule'
'SV-59341r4_rule'
'SV-59673r1_rule'
'SV-59681r1_rule'
'SV-79207r1_rule'


function Get-JREPropRules {
    @{
        'SV-81213r1_rule' = 'deployment.security.revocation.check=ALL_CERTIFICATES';
        'SV-81435r2_rule' = 'deployment.security.level=VERY_HIGH,deployment.security.level.locked';
        'SV-81437r3_rule' = 'deployment.webjava.enabled=true,deployment.webjava.enabled.locked';
        'SV-81439r2_rule' = 'deployment.security.askgrantdialog.notinca=false,deployment.security.askgrantdialog.notinca.locked';
        'SV-81441r2_rule' = 'deployment.security.askgrantdialog.show=false,deployment.security.askgrantdialog.show.locked';
        'SV-81443r2_rule' = 'deployment.security.validation.ocsp=true,deployment.security.validation.ocsp.locked';
        'SV-81445r2_rule' = 'deployment.security.blacklist.check=true,deployment.security.blacklist.check.locked';
        'SV-81451r2_rule' = 'deployment.security.validation.crl=true,deployment.security.validation.crl.locked';
        'SV-81453r2_rule' = 'deployment.insecure.jres=PROMPT,deployment.insecure.jres.locked';
    };
}
#endregion

<#
.SYNOPSIS
    Get JRE scan results.
.NOTES
    All STIG rules scanned; SCAP does nothing, and probably never will because
    the rules as written are broken and incomplete. Not to mention the JRE 
    deploy process and associated config files are over-engineered.
#>
function Get-JREResults {
    [CmdletBinding()]
    param(
        [string]$configPath
        # [Parameter(Mandatory)] [string]$configPath
    )

    $installed = Get-JREInstalledVersions; # SV-81455r1_rule
    if ($installed -is [Hashtable]) {

    } else {
        if ($installed -eq $null) {

        } else {
        }
    }

    # most most current JRE version enforced by local policy. (IAVM/ACAS)
    $results = @{
        'SV-81457r1_rule' = $NOT_A_FINDING_POLICY;
    };


    # get/parse deployment.config file



    #region deployment.properties file
    $propsConfigPath = 'C:\Program Files\Java\jre\lib\deployment.properties';
    $propRules = Get-JREPropRules;

    $results += Get-JREPropConfigResults $propsConfigPath $propRules
    #endregion

<#
HKLM\SOFTWARE\JavaSoft\Java Runtime Environment
HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment



#>
    return $results;
}

<#
.SYNOPSIS
    Get installed JRE version(s) info.
#>
function Get-JREInstalledVersions {
    [CmdletBinding()]

    $systems = @{
        '64' = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*';
        '32' = 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*';
    };
    $nameMatch = '\bjava\b';
    $propNames = @('DisplayName', 'DisplayVersion', 'InstallLocation');

    $result = @{}
    foreach ($key in $systems.Keys) {
        $install = Get-ItemProperty $systems.$key | 
            where { $_.DisplayName -match $nameMatch;  } | 
            select $propNames;
        # PASS
        if ($install -ne $null -and $install -is [PSCustomObject]) { 
            $result[$key] = $install;
        # FAIL: multiple versions installed
        } elseif ($install -is [array]) { 
            $installed = ($install | foreach { $_.DisplayVersion; }) -join ',';
            $result.$key = 'FAIL: Multiple JRE versions installed. ({0})' -f $installed;
        # JRE not installed
        } else { $result.$key = $null; }
    }
    return $result;
}

<#
.SYNOPSIS
    Get installed JRE version info.
#>
function Get-JREInstalledVersions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$path
    );

    $nameMatch = '\bjava\b';
    $propNames = @('DisplayName', 'DisplayVersion', 'InstallLocation');
    $install = Get-ItemProperty $path | 
        where { $_.DisplayName -match $nameMatch;  } | 
        select $propNames;

    if ($install -ne $null) {
        # PASS => PSCustomObject w/$propNames
        return $install;
    } elseif ($install -is [array]) {
        # FAIL: multiple versions installed => version numbers array 
        return $install | foreach { $_.DisplayVersion; }
    }
    # JRE not installed
    return $null;
}

<#
.SYNOPSIS
    Get JRE deployment.properties file scan results.
#>
function Get-JREPropConfigResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [hashtable]$rules
        ,[Parameter(Mandatory)] [string]$configPath
    )

    $propConfig = @{};
    Get-TrimmedLines ([System.IO.File]::ReadAllText($configPath)) |
        foreach { $propConfig.$_ = $null;};

    $results = @{};
    foreach ($key in $rules.Keys) {
        $pass = $true;
        $value = $rules.$key
        $value -split ',' | foreach {
            $pass = $propConfig.ContainsKey($_) -and $pass;
        }
        $results.$key = if ($pass) {
            @($CKL_STATUS_PASS, "Not a Finding: required value(s) match. ($value)");
        } else {
            @($CKL_STATUS_OPEN, "Open: Required value(s) ($value) not set.");
        }
    }
    return $results;
}