<#
.SYNOPSIS
    Export STIG scan results to a .ckl file
.DESCRIPTION
    The Export-Ckl cmdlet exports STIG scan results from a host to a .ckl
    file. 
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
    )

    $errorText = "Scan results not saved => error processing [$cklInPath]";
    try {
        [xml]$cklTemplate = Get-Content -Path $cklInPath -ErrorAction Stop;
        if ($cklTemplate) {
            foreach ($iStig in $cklTemplate.CHECKLIST.STIGS.iSTIG) {
                foreach ($vuln in $iStig.VULN) {
                    $id = $vuln.STIG_DATA.ATTRIBUTE_DATA[0];
                    if ($data.ContainsKey($id)) {
                        [string[]]$values = $data.$id;
                        $vuln.$CKL_STATUS = $values[0];
                        # `Escape()` => sanity-check invalid XML characters
                        $vuln.$CKL_DETAILS = [System.Security.SecurityElement]::Escape(($values[1])); 
                        if ($values[2] -ne $null) { 
                            $vuln.$CKL_COMMENTS = [System.Security.SecurityElement]::Escape($values[2]); 
                        }
                    }
                }
            }
            # else XmlDocument.Save(string filename) is utf-8 BOM encoded
            $utf = New-Object System.Text.UTF8Encoding($false);
            $writer = New-Object System.Xml.XmlTextWriter($cklOutPath, $utf);
            $cklTemplate.PreserveWhitespace = $true;
            $cklTemplate.Save($writer);
            $writer.Dispose();
        } else {
            return $errorText;
        }
    } catch {
        return "$($errorText):`r`n $($_.Exception.Message)";
    }
    return $null;
}