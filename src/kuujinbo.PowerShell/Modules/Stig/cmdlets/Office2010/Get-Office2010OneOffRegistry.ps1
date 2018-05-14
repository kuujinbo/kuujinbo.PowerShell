function Get-Office2010OneOffRegistry {
    @{
        # pp
        'SV-33869r1_rule' = @(
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\filevalidation', 'OpenInProtectedView', '1')
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\powerpoint\security\filevalidation', 'DisableEditFromPV', '1')
        );
        # word
        'SV-33868r1_rule' = @(
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\filevalidation', 'OpenInProtectedView', '1')
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\word\security\filevalidation', 'DisableEditFromPV', '1')
        );
        #excel
        'SV-33867r1_rule' = @(
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\filevalidation', 'OpenInProtectedView', '1')
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\excel\security\filevalidation', 'DisableEditFromPV', '1')
        );
        # outlook
        'SV-33505r2_rule' = @(
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\common\mailsettings', 'PlainWrapLen', '132')
            ,@('HKCU:\Software\Policies\Microsoft\Office\14.0\outlook\options\mail', 'Message Plain Format Mime', '1')
        );
    };
}
<#
            'SV-33502r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\outlook\options\rss', 'Disable', '0')
    # For all environments where the Outlook e-mail client has access to public Internet web sites, RSS integration into Outlook is not permitted, and should be validated as follows. 
            'SV-33502r1_rule' = @('HKCU:\Software\Policies\Microsoft\Office\14.0\outlook\options\rss', 'Disable', '1')


#>