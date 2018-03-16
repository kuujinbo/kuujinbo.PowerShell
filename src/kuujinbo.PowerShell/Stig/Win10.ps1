# load dot source script file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
. (Join-Path $scriptDir 'dot-source/Stig.ps1');

function Get-Version {
    param([Parameter(Mandatory=$true)] $cimSession)
    $cmdArgs = @{
        hDefKey=$HKLM;
        sSubKeyName='software\microsoft\windows nt\currentversion';
        sValueName='releaseid';
    };

    (Invoke-CimMethod -CimSession $cimSession -Namespace root/cimv2 -ClassName StdRegProv -MethodName GetStringValue -Arguments $cmdArgs).sValue;
}