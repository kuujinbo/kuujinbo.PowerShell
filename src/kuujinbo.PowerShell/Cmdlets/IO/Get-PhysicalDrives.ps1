<#
.SYNOPSIS
    Get Physical drive information, including drive letter.
.NOTES
    Modified from here:
    https://itknowledgeexchange.techtarget.com/powershell/mapping-physical-drives-to-logical-drives-part-3/
#>
function Get-PhysicalDrives {
    Get-WmiObject Win32_DiskDrive | foreach {
        $disk = $_;
        $partitions = @"
ASSOCIATORS OF 
    {Win32_DiskDrive.DeviceID='$($disk.DeviceID)'}
    WHERE AssocClass = Win32_DiskDriveToDiskPartition
"@;
        Get-WmiObject -Query $partitions | foreach {
            $partition = $_;
            $drives = @"
ASSOCIATORS OF 
    {Win32_DiskPartition.DeviceID='$($partition.DeviceID)'}
    WHERE AssocClass = Win32_LogicalDiskToPartition
"@;
            Get-WmiObject -Query $drives | foreach {
                New-Object -Type PSCustomObject -Property @{
                    Disk        = $disk.DeviceID;
                    DiskModel   = $disk.Model;
                    Partition   = $partition.Name;
                    DriveLetter = $_.DeviceID;
                    VolumeName  = $_.VolumeName;
                };
            }
        }
    }
}