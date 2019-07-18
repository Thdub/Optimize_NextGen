# Cmdlet
[CmdletBinding()]
Param(
[Parameter(Mandatory=$True)]
[ValidateNotNull()]
[Array]$Disks,

[Parameter(Mandatory=$True)]
[ValidateNotNull()]
[boolean]$WriteCache,
  
[Parameter(Mandatory=$True)]
[ValidateNotNull()]
[Array]$Servers
)

# Custom Title
$host.ui.RawUI.WindowTitle =  "Optimize Next Gen v3.9.6 | Powershell Script"
$runStart = [DateTime]::Now

# Set dskcache.exe utility flag
if ($WriteCache) {$flag="+"} else {$flag="-"}

# Start log
Start-Transcript -Path "$env:TEMP\SettingsBackup\Logs\DiskWriteCaching.log" -Append | out-null

foreach ($server in $servers)
{ 

	$Disk=Get-WmiObject Win32_DiskDrive

    foreach ($DiskN in $Disks)
      {
        # Check if required disk available otherwise skip changes
        if (!($Disk.Index -contains $DiskN)) {Write-Host $server Disk $DiskN does not exist, or is not available at this time. -f Yellow}
        else
        {

        # Get Diskname and Disk serial number
        $DiskName=($disk | where Index -eq $diskN).Caption
        $DiskSN=($disk | where Index -eq $diskN).SerialNumber
        
		Write-Host $server "Changing write caching for" ($DiskName+" - SN:"+$DiskSN) "- DiskNumber:" $DiskN -f Yellow
		Start-Process -FilePath ".\..\..\..\Files\Utilities\dskcache.exe" -ArgumentList "$($flag)w PhysicalDrive$($DiskN)" -WindowStyle Hidden
       }}

}

Write-Host "Run duration: " -n
Write-Host ([Math]::Round((([DateTime]::Now).Subtract($runStart)).TotalMinutes,2)) -f Yellow -n
Write-Host " minutes" -n

# Stop log
Stop-Transcript | out-null
