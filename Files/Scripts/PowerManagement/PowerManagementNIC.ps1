# Custom Title
$host.ui.RawUI.WindowTitle =  "Optimize Next Gen v3.8 | Powershell Script"

# Start log
Start-Transcript -Path ("$env:TEMP\SettingsBackup\Logs\PowerManagementNIC.log") -Append | out-null

$intNICid=0; do
{
	# Read network adapter properties
	$objNICproperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f $intNICid)) -ErrorAction SilentlyContinue)
	
	# Determine if the Network adapter index exists 
	If ($objNICproperties)
	{
		# Filter network adapters
		If (($objNICproperties."*ifType" -eq 6 -or $objNICproperties."*ifType" -eq 71 -or $objNICproperties."*ifType" -eq 243 -or $objNICproperties."*ifType" -eq 244) -and 
		    ($objNICproperties.DeviceInstanceID -notlike "ROOT\*") -and
			($objNICproperties.DeviceInstanceID -notlike "SW\*") -and
            ($objNICproperties.DeviceInstanceID -notlike "*vwifimp_wfd*")
			)
		{

			# Read hardware properties
			$objHardwareProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Enum\{0}" -f $objNICproperties.DeviceInstanceID) -ErrorAction SilentlyContinue)
			If ($objHardwareProperties.FriendlyName)
			{ $strNICDisplayName = $objHardwareProperties.FriendlyName }
			else 
			{ $strNICDisplayName = $objNICproperties.DriverDesc }
			
			# Read Network properties
			$objNetworkProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Network\{0}\{1}\Connection" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", $objNICproperties.NetCfgInstanceId) -ErrorAction SilentlyContinue)
		    
			# Inform user
			Write-Host -n -f White "                ID     : "; Write-Host -f Yellow ("{0:D4}" -f $intNICid)
			Write-Host -n -f White "                Network: "; Write-Host $objNetworkProperties.Name
            Write-Host -n -f White "                NIC    : "; Write-Host $strNICDisplayName
			
			# Report action
			Write-Host -n -f White "                Actions: "; Write-Host -n -f Green ("- Power saving disabled")[4A[92C
			
			#Disable power saving
            Set-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f $intNICid)) -Name "PnPCapabilities" -Value "24" -Type DWord
		}
	} 
	# Next NIC ID
	$intNICid+=1
} while ($intNICid -lt 255)

# Stop log
Stop-Transcript | out-null
