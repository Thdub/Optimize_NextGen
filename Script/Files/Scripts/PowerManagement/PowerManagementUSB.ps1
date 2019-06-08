# Custom Title
$host.ui.RawUI.WindowTitle =  "Optimize Next Gen v3.8 | Powershell Script"

# Start log
Start-Transcript -Path ("$env:TEMP\SettingsBackup\Logs\PowerManagementUSB.log") -Append | out-null

# Start process for usbhubs
$hubs = Get-WmiObject Win32_USBHub
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt)
{
	$IN = $p.InstanceName.ToUpper()
	foreach ($h in $hubs)
	{
		$PNPDI = $h.PNPDeviceID
                if ($IN -like "*$PNPDI*")
                {
                     $p.enable = $False
                     $p.psbase.put()
                }
	}
}

# Stop log
Stop-Transcript | out-null
