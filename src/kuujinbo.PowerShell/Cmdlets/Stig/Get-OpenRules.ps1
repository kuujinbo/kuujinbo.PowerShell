<#
.SYNOPSIS
    Get open STIG scan results as a line-by-line two-field CSV string:
    HOSTNAME,RULE_ID_OR_#
.PARAMETER $results
   Key => STIG ID/ rule #
   Value => @(status, details, comments)

   See ~/Cmdlets/Registry/Get-RegistryResults.ps1
#>
function Get-OpenRules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$hostname
        ,[Parameter(Mandatory)] [hashtable]$results
    );

    $open = New-Object System.Text.StringBuilder;
    foreach ($key in $results.Keys) {
        if ($results.$key[0] -eq $CKL_STATUS_OPEN) {
            $null = $open.AppendLine(('{0},{1}' -f $hostname, $key));
        }
    }

    return $open.ToString();
}