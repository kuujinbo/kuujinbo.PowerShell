<#
.SYNOPSIS
    Get anti-virus status from a Windows **client** OS. (Windows 7 and above)
#>
function Get-ClientOsAntiVirusProduct {
    param(
        [string]$hostname = $env:computername
    );

    function ConvertTo-Hex {
        [Parameter(Mandatory)]param([uint32]$number);
        
        '0x{0:x}' -f $number;
    }

    try {
        $result = Get-WmiObject -Namespace 'root\SecurityCenter2' `
                 -Class AntiVirusProduct -ComputerName $hostname `
                 -ErrorAction Stop;

        $productStateHexValue  = ConvertTo-Hex $result.productState;
        $enabled = if ($productStateHexValue.Substring(3,2) -notmatch '00|01') { $true; }
                   else { $false; };
        $updated = if ($productStateHexValue.Substring(5) -eq '00') { $true; }
                   else { $false; }

        return @{
            displayName = $result.displayName;
            instanceGuid = $result.instanceGuid;
            productState = $result.productState;
            enabled = $enabled;
            updated = $updated;
            pathToSignedProductExe = $result.pathToSignedProductExe;
            pathToSignedReportingExe = $result.pathToSignedReportingExe;
        };
    } catch {
        Write-Warning "[$($hostname)] => $($_.Exception.Message)";
    }
}