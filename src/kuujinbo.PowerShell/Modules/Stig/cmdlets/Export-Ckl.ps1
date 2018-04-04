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
        ,[Parameter(Mandatory)] [hashtable]$data
    )

    [xml]$cklTemplate = Get-Content -Path $cklInPath -ErrorAction Stop;
    if ($cklTemplate) {
        foreach ($iStig in $cklTemplate.CHECKLIST.STIGS.iSTIG) {
            foreach ($vuln in $iStig.VULN) {
                $id = $vuln.STIG_DATA.ATTRIBUTE_DATA[0];
                if ($data.ContainsKey($id)) {
                    $vuln.$CKL_STATUS = $data.$id.$CKL_STATUS;
                    if ($data.$id.ContainsKey($CKL_DETAILS)) { 
                        $vuln.$CKL_DETAILS = $data.$id.$CKL_DETAILS; 
                    }
                    if ($data.$id.ContainsKey($CKL_COMMENTS)) { 
                        $vuln.$CKL_COMMENTS = $data.$id.$CKL_COMMENTS; 
                    }
                }
            }
        }
        $cklTemplate.Save($cklOutPath);
    }
}