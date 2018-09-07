function Get-JREResults {
    $results = @{
        'SV-81457r1_rule' = $NOT_A_FINDING_POLICY;
    };

<#
HKLM\SOFTWARE\JavaSoft\Java Runtime Environment
HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment
#>

    $config = @{
        'SV-81429r4_rule' = 'deployment.config'; # file exists
        'SV-81431r3_rule' = 'deployment.system.config'; # file\:\\C\:\\Program Files (x86)\\Java\\jre\\lib\\deployment.properties
    # 'deployment.system.config.mandatory=true'
    };

    $properties = @{
        'SV-81213r1_rule' = 'deployment.security.revocation.check=ALL_CERTIFICATES';
        'SV-81433r2_rule' = 'deployment.properties';  # file exists
        'SV-81435r2_rule' = 'deployment.security.level=VERY_HIGH,deployment.security.level.locked';
        'SV-81437r3_rule' = 'deployment.webjava.enabled=true,deployment.webjava.enabled.locked';
        'SV-81439r2_rule' = 'deployment.security.askgrantdialog.notinca=false,deployment.security.askgrantdialog.notinca.locked';
        'SV-81441r2_rule' = 'deployment.security.askgrantdialog.show=false,deployment.security.askgrantdialog.show.locked';
        'SV-81443r2_rule' = 'deployment.security.validation.ocsp=true,deployment.security.validation.ocsp.locked';
        'SV-81445r2_rule' = 'deployment.security.blacklist.check=true,deployment.security.blacklist.check.locked';
        'SV-81447r3_rule' = 'deployment.user.security.exception.sites';  # file exists
        'SV-81449r2_rule' = 'deployment.user.security.exception.sites=C:/Program Files (x86)/Java/jre/lib/security/exception.sites'; # pending
        'SV-81451r2_rule' = 'deployment.security.validation.crl=true,deployment.security.validation.crl.locked';
        'SV-81453r2_rule' = 'deployment.insecure.jres=PROMPT,deployment.insecure.jres.locked';
        'SV-81455r1_rule' = 'Ensure only one instance of JRE is in the list of installed software. If more than one instance of JRE is listed, this is a finding.';
    };

    return $results;
}

function Ko {
    # V-66941 SV-81431r3_rule

}