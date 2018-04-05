<#
.SYNOPSIS
    Export STIG scan results to a .ckl file
.DESCRIPTION
    The Export-Ckl cmdlet exports STIG scan results from a host to a .ckl
    file. 
.NOTES
    Tested on STIG Viewer 2.6.1. To save template file:
    [1] Checklist => Create Checklist - Check Marked STIG(s)
    [2] File => Save Checklist As...
#>
function Export-Ckl {
    param(
        [Parameter(Mandatory)] [string]$cklInPath
        ,[Parameter(Mandatory)] [string]$cklOutPath
        ,[Parameter(Mandatory)] [hashtable]$data # key value => @(status, details, comments)
    )

    [xml]$cklTemplate = Get-Content -Path $cklInPath -ErrorAction Stop;
    if ($cklTemplate) {
        foreach ($iStig in $cklTemplate.CHECKLIST.STIGS.iSTIG) {
            foreach ($vuln in $iStig.VULN) {
                $id = $vuln.STIG_DATA.ATTRIBUTE_DATA[0];
                if ($data.ContainsKey($id)) {
                    [string[]]$values = $data.$id;
                    $vuln.$CKL_STATUS = $values[0];
                    $vuln.$CKL_DETAILS = $values[1]; 
                    if ($values[2] -ne $null) { 
                        $vuln.$CKL_COMMENTS = $values[2]; 
                    }
                }
            }
        }
        # else XmlDocument.Save(string filename) is utf-8 BOM encoded
        $utf = New-Object System.Text.UTF8Encoding($false);
        $writer = New-Object System.Xml.XmlTextWriter($cklOutPath, $utf);
        $cklTemplate.Save($writer);
        $writer.Dispose();
    }
}