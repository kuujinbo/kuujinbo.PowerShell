<#
.SYNOPSIS
    Export STIG scan results to a .ckl file
.NOTES
    Tested on STIG Viewer 2.7. To save template file:
    [1] Checklist => Create Checklist - Check Marked STIG(s)
    [2] File => Save Checklist As...
#>
function Export-Ckl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$cklInPath
        ,[Parameter(Mandatory)] [string]$cklOutPath
        ,[Parameter(Mandatory)] [hashtable]$data # key value => @(status, details, comments)
        ,[switch]$dataRuleIdKey
    )

    $errorText = "Scan results not saved => error processing [$cklInPath]";
    try {
        # [xml]$cklTemplate = Get-Content -Path $cklInPath -ErrorAction Stop;

        $cklTemplate = New-Object System.Xml.XmlDocument;
        $cklTemplate.PreserveWhitespace = $true;
        $cklTemplate.Load($cklInPath); 

        if ($cklTemplate) {
            $keyNodeIndex = 0; 
            if ($dataRuleIdKey.IsPresent) { $keyNodeIndex = 3; }

            foreach ($iStig in $cklTemplate.CHECKLIST.STIGS.iSTIG) {
                foreach ($vuln in $iStig.VULN) {
                    # vulnerability Id format => 'V-\d{4,5}'
                    # OR
                    # vulnerability rule Id format => '^SV-\d{4,5}r2_rule'
                    $id = $vuln.STIG_DATA.ATTRIBUTE_DATA[$keyNodeIndex];
                    if ($data.ContainsKey($id)) {
                        [string[]]$values = $data.$id;
                        $vuln.$CKL_STATUS = $values[0];

                        # `Escape()` => sanity-check invalid XML characters
                        $details = $values[1];
                        if ($details -ne $null) {
                            $vuln.$CKL_DETAILS = [System.Security.SecurityElement]::Escape(($details)); 
                        }

                        $comments = $values[2];
                        if ($comments -ne $null) {
                            $vuln.$CKL_COMMENTS = [System.Security.SecurityElement]::Escape($values[2]); 
                        }
                    }
                }
            }
            # else XmlDocument.Save(string filename) is utf-8 BOM encoded
            $utf = New-Object System.Text.UTF8Encoding($false);
            $writer = New-Object System.Xml.XmlTextWriter($cklOutPath, $utf);
            $cklTemplate.Save($writer);
            # $cklTemplate.Save($cklOutPath);
            $writer.Dispose();
        } else {
            return $errorText;
        }
    } catch {
        return "$($errorText):`r`n $($_.Exception.Message)";
    }
    return $null;
}