<#
.SYNOPSIS
    Get the first active console user logged into specified host/machine.
#>
function Get-LoggedOnUser {
    [CmdletBinding()]
    param(
        [string]$remoteHost
    );
    
    $query = & query user "/server:$remoteHost" 2> $null;
    # redirect error output stream              ^^^^^^^^
    # if no logged-in users, or bad hostname, will error out

    if ($query -ne $null) {
# USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
        for ($i = 1; $i -lt $query.Length; ++$i) {
            $line = $query[$i].Trim();
            if ($line -match '\s+console\s+' -and $line -match '\s+active\s+') {
                return ($line -split "\s{2,}")[0];
            }
        }
    }

    return $null;
}