<#
.SYNOPSIS
    Update SCAP scan results sent to a .ckl file.
.NOTES
    SCAP scans only mark 'Status' in the .ckl file, and neglect to enter 
    **ANY** data in both the 'Finding Details', and 'Comments' fields.

    DISA STIG Viewer 2.7.1. 
#>
function Update-ScapScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$cklDirectory
        , [string]$findingDetails = $SCAP_DETAILS 
        , [string]$findingComments = $SCAP_COMMENTS
    )

    $ckls = gci -File -Filter *.ckl -Path $cklDirectory;
    $totalFiles = $remainingFiles = $ckls.Length;
    $currentCount = 1;

    foreach ($ckl in $ckls) {
        $scapCkl = New-Object System.Xml.XmlDocument;
        $scapCkl.PreserveWhitespace = $true;
        $scapCkl.Load($ckl.FullName); 

        Write-Progress -Activity "Updating $currentCount of $totalFiles .ckl files." `
                       -Status "$($ckl.FullName)" `
                       -PercentComplete (($totalFiles - $remainingFiles) / $totalFiles * 100);
        
        foreach ($iStig in $scapCkl.CHECKLIST.STIGS.iSTIG) {
            foreach ($vuln in $iStig.VULN) {
                $scapPass = $vuln.$CKL_STATUS -eq $CKL_STATUS_PASS;
                $details = $vuln.$CKL_DETAILS;
                $comments = $vuln.$CKL_COMMENTS;

                if ($scapPass `
                    -and [string]::IsNullOrWhiteSpace($details) `
                    -and [string]::IsNullOrWhiteSpace($comments)) 
                {
                    $vuln.$CKL_DETAILS = $findingDetails;
                    $vuln.$CKL_COMMENTS = $findingComments;
                }
            }
        }
        $utf = New-Object System.Text.UTF8Encoding($false);
        $writer = New-Object System.Xml.XmlTextWriter($ckl.FullName, $utf);
        $scapCkl.Save($writer);
        $writer.Dispose(); 
        --$remainingFiles;  
        ++$currentCount;                  
    }
}