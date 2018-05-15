============================================================================
Office 2010 STIG
============================================================================

[1] Please don't mess with ANY of the scripts. It will GREATLY help the developer troubleshoot when anyone using this script needs help if the developer has the **ORIGINAL** code. If you want to experiment (there's a lot of code in 'Modules') make a copy of everything and work on that instead.

If you keep a shortcut to this directory and run the script from the UNC path, any updates and additions made by the developer will be transparent to you. See [4] below to run the script from a UNC path or mapped drive.

[2] The script is named 'office-2010.ps1'. It expects a FULL path to a directory that contains previously run SCAP scans with .ckl files. The .ckl files **MUST* either:

    [a] Have hostname in first field under 'Computing'.
    OR
    [b] Have it's filename itself named the host to be scanned.

For example, from the powershell command line:

----------------------------------------------------------------------------
PS >> \\PATH-TO-SCRIPT\office-2010.ps1 \\PATH-TO-CONTAINING-DIRECTORY-WITH-.ckl-FILES
----------------------------------------------------------------------------

Change the second parameter above:

    \\psns.sy\unnpi-departments\C109\Limited\C109-SHARED\109.31\powershell

To the directory with your .ckl files.

[3] Very simple error logging is being done - error file has the following format:

"_errors-$((Get-Date).ToString('yyyy-MM-dd-HH.mm.ss'))-$($env:username).txt"

[4] Depending on you powershell environment you may need to run the following cmdlet to get rid of the annoying security warning about running scripts from a UNC path or mapped drive:

----------------------------------------------------------------------------
Set-ExecutionPolicy Bypass -Scope CurrentUser
----------------------------------------------------------------------------