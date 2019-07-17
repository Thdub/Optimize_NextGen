@echo off

%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN

:: Set variables
	for /f "tokens=2 delims==" %%j in ('wmic os get Caption /value') do (
	set "Win_Edition=%%j"
	)
:: Find either LTSC or Server
	echo %Win_Edition% | findstr /i /c:"Enterprise S" >nul && (
	set "Win_Edition=Windows 10 LTSC"
	goto :START
	) || (
	goto :Find_Server_Edition
	)

:Find_Server_Edition
	echo %Win_Edition% | findstr /i /c:"Server" >nul && (
	set "Win_Edition=Windows Server 2019"
	goto :START
	) || (
	echo Script can not be run on %Win_Edition%.
	goto :PAUSE_BEFORE_EXIT
	)

:START
	call :WStore_Check
:: Titlebar
	echo ]0;Registry Tweaks
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to apply %Win_Edition% registry tweaks...
	@pause >NUL 2>&1
:: Start Process
	cls
::===============================================================================================================
:: Telemetry
::===============================================================================================================
	echo Processing telemetry blocking tweaks...[100X
	<nul set /p DummyName=[2X[2C-Registry: [100X
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling auto-Recommended-Updates install
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d 0 >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "AllowOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling Application Compatibility telemetry
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /v "HaveUploadedForTarget" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\AIT" /v "AITEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "DontRetryOnError" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "IsCensusDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "TaskEnableRun" /t REG_DWORD /d "1" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" /v "UpgradeEligible" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TelemetryController" /f >nul 2>&1
:: Disabling CEIP
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\IE" /v "CEIPEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\IE" /v "SqmLoggerRunning" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Reliability" /v "CEIPEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Reliability" /v "SqmLoggerRunning" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "DisableOptinExperience" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "SqmLoggerRunning" /t REG_DWORD /d "0" /f >nul 2>&1
	sc.exe config DiagTrack start= disabled >nul 2>&1
	sc.exe stop DiagTrack >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\SQMLogger" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling telemetry uploading
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DiagTrackAuthorization" /t REG_DWORD /d "0" /f >nul 2>&1
	takeown /f %ProgramData%\Microsoft\Diagnosis /A /r /d y >nul 2>&1
	icacls %ProgramData%\Microsoft\Diagnosis /grant:r *S-1-5-32-544:F /T /C >nul 2>&1
	del /F /Q /S "%ProgramData%\Microsoft\Diagnosis\*.rbs" >nul 2>&1
	del /F /Q /S "%ProgramData%\Microsoft\Diagnosis\ETLLogs\*" >nul 2>&1
	echo [92mDone.[97m

	<nul set /p DummyName=[2C-Office Registry: 
	reg add HKCU\Software\Microsoft\Office\Common\ClientTelemetry /v DisableTelemetry /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\Feedback /v enabled /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\Feedback /v includescreenshot /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Outlook\Options\Mail /v EnableLogging /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Word\Options /v EnableLogging /t REG_DWORD /d "0" /f >nul 2>&1
	:: moved to policy
	reg add HKCU\Software\Microsoft\Office\Common\ClientTelemetry /v SendTelemetry /t REG_DWORD /d 3 /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v qmenable /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v updatereliabilitydata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\General /v shownfirstrunoptin /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\General /v skydrivesigninoption /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\ptwatson /v ptwoptin /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Firstrun /v disablemovie /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM /v Enablelogging /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM /v EnableUpload /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM /v EnableFileObfuscation /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v accesssolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v olksolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v onenotesolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v pptsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v projectsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v publishersolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v visiosolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v wdsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v xlsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v agave /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v appaddins /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v comaddins /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v documentfiles /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v templatefiles /t REG_DWORD /d "1" /f >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[2C-Office Policies: 
	reg add HKCU\Software\Policies\Microsoft\Office\Common\clienttelemetry /v sendtelemetry /t REG_DWORD /d 3 /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v qmenable /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v updatereliabilitydata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common\General /v shownfirstrunoptin /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common\General /v skydrivesigninoption /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common\ptwatson /v ptwoptin /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Firstrun /v disablemovie /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM /v Enablelogging /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM /v EnableUpload /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM /v EnableFileObfuscation /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v accesssolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v olksolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v onenotesolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v pptsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v projectsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v publishersolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v visiosolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v wdsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v xlsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v agave /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v appaddins /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v comaddins /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v documentfiles /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v templatefiles /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\Software\Policies\Microsoft\Office\Common\clienttelemetry /v sendtelemetry /t REG_DWORD /d 3 /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common /v qmenable /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\Software\Policies\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common /v updatereliabilitydata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\General /v shownfirstrunoptin /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\General /v skydrivesigninoption /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\ptwatson /v ptwoptin /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Firstrun /v disablemovie /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM /v Enablelogging /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM /v EnableUpload /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM /v EnableFileObfuscation /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v accesssolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v olksolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v onenotesolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v pptsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v projectsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v publishersolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v visiosolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v wdsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v xlsolution /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v agave /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v appaddins /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v comaddins /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v documentfiles /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v templatefiles /t REG_DWORD /d "1" /f >nul 2>&1
	echo [92mDone.[97m
	echo [93mTelemetry blocking task has completed successfully.[97m
	echo:

::============================================================================================================
:: Privacy_Settings
::============================================================================================================
	echo Blocking ads and tracking, adding more privacy settings...
	<nul set /p DummyName=[2C-Setting Preferences added to Group Policy in 'Custom Policies': 
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.BingNews_8wekyb3d8bbwe!AppexNews" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /v "Rank" /t REG_DWORD /d "99" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Photos_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.calendar" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.mail" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.System.Continuum" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AudioTroubleshooter" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackgroundAccess" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BdeUnlock" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.RasToastNotifier" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WiFiNetworkManager" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[2C-Processing additional tweaks: 
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v "FPEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "OptimizeWindowsSearchResultsForScreenReaders" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "Use FormSuggest" /t REG_SZ /d "no" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Privacy" /v "EnableEncryptedMediaExtensions" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI\ShowSearchHistory" /ve /t REG_DWORD /d "0" /f >nul 2>&1
	if not "%Win_Games%" == "Games_ON" (
		reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	)
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >nul 2>&1
:: Clearing unique ad-tracking ID token
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayVisible" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-202914Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280810Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280811Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280813Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280815Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310091Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310092Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314559Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338380Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338381Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f >nul 2>&1
:: Patching Explorer leaks
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "AllowOnlineTips" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "0" /f >nul 2>&1
	if not "%Win_Games%" == "Games_ON" (
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	)
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceAppSuggestionsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HasAboveLockTips" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1
	if not "%Win_Games%" == "Games_ON" (
		reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	)
	reg add "HKLM\SOFTWARE\Microsoft\Input\Settings" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\OneDrive" /v "PreventNetworkTrafficPreUserSignIn" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Browser" /v "AllowAddressBarDropdown" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >nul 2>&1
:: Clearing unique ad-tracking ID token
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowScreenMonitoring" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowTextSuggestions" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "RequirePrinting" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "AllowPrelaunch" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "PreventFirstRunPage" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "PreventLiveTileDataCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "ShowMessageWhenOpeningSitesInInternetExplorer" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v "PreventTabPreloading" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging" /v "AllowMessageSync" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatePeriod" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgrade" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgradePeriod" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "SystemSettingsDownloadMode" /f >nul 2>&1
	echo [92mDone.[97m

::============================================================================================================
:: Miscellaneous
::============================================================================================================
	<nul set /p DummyName=[2C-Adding miscellaneous settings: 
:: Disabling CEIP
	reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling remote Scripted Diagnostics Provider query
	reg add "HKLM\Software\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "EnableQueryRemoteServer" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "DisableQueryRemoteServer" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling remote Scheduled Diagnostics execution
	reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling auto-reboot after update install
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling Peernet
	reg add "HKLM\Software\Policies\Microsoft\Peernet" /v "Disabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\BITS" /v "DisablePeerCachingClient" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\BITS" /v "DisablePeerCachingServer" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling telemetry uploading
 :: os64bit
	reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableEnterpriseAuthProxy" /t REG_DWORD /d "1" /f >nul 2>&1
 :: Changing default telemetry proxy to localhost
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "TelemetryProxy" /t REG_SZ /d "localhost:0" /f >nul 2>&1
:: Checking Error Reporting privacy settings
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_SZ /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "MachineID" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\WMR" /v "Disable" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "DefaultConsent" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "NewUserDefaultConsent" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling Removable drive indexing
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableRemovableDriveIndexing" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling Remote Assistance
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling Teredo/IPv6 tunneling
	netsh int teredo set state disabled >nul 2>&1
:: Preventing device meta-data collection
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "DeviceMetadataServiceURL" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul 2>&1
:: Patching IGMP
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "0" /f >nul 2>&1
:: Patching Web Proxy Auto Discovery
	netsh winhttp reset proxy >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "0" /f >nul 2>&1
:: Patching DNS Smart Name Resolution
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v "DisableSmartNameResolution" /t REG_DWORD /d "1" /f >nul 2>&1
:: Patching Link-local Multicast Name Resolution
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "1" /f >nul 2>&1
:: Patching Windows SMB data leaks
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "0" /f >nul 2>&1
:: Patching NVIDIA telemetry leaks
	reg query "HKCU\Software" | findstr /i "NVIDIA" >nul && (
		reg add "HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f >nul 2>&1
	)
:: Patching Internet Explorer/Edge data leaks
	reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Privacy" /v "EnableInPrivateBrowsing" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v "DisableLogging" /t REG_DWORD /d "1" /f >nul 2>&1
:: Patching Windows Defender data leaks
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
:: Patching Windows MRT data leaks
	reg add "HKLM\Software\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "SpyNetReportingLocation" /t REG_SZ /d "0" /f >nul 2>&1
:: Patching Maps/SystemSettings leaks
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d "0" /f >nul 2>&1
:: Clearing unique ad-tracking ID token
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /t REG_SZ /d "null" /f >nul 2>&1
:: Configuring SmartScreen control permissions
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	echo [92mDone.[97m
	echo [93mPrivacy settings task has completed successfully.[97m
	echo:

::===============================================================================================================
:: Performances Settings
::===============================================================================================================
:: Start performances registry tweaks
	echo Performances optimization...
	<nul set /p DummyName=[2C-Preferences already present in Group Policy: 
:: Do not allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services
	reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f >nul 2>&1
:: Do not use biometrics
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /t REG_DWORD /d "0" /f >nul 2>&1
:: Do not allow StorageSense
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense" /v "AllowStorageSenseGlobal" /t REG_DWORD /d "0" /f >nul 2>&1
:: Force display shutdown button on logon
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "shutdownwithoutlogon" /t REG_DWORD /d "0" /f >nul 2>&1

:: Check Windows edition before adding Shutdown Event Tracker value and do not display Server Manager at logon.
	if "%Win_Edition%" == "Windows Server 2019" ( goto :Windows_Server_policies ) else ( goto :Power_1 )

:Windows_Server_policies
:: Do not display Shutdown Event Tracker on Windows Server (No shutdown reason)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v "ShutDownReasonOn" /t REG_DWORD /d "0" /f >nul 2>&1
:: Do not display Manage Your Server page at logon (Windows Server)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\MYS" /v "DisableShowAtLogon" /t REG_DWORD /d "1" /f >nul 2>&1

:Power_1
:: Never turn off the display (plugged in)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" /v "ACSettingIndex" REG_DWORD /d "0" /f >nul 2>&1
:: Never turn off the hard disk (plugged in)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E" /v "ACSettingIndex" REG_DWORD /d "0" /f >nul 2>&1
:: Power button (shutdown)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280" /v "ACSettingIndex" REG_DWORD /d "3" /f >nul 2>&1
:: Sleep button (do nothing:because sleep is disabled)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB" /v "ACSettingIndex" REG_DWORD /d "0" /f >nul 2>&1
:: Do not allow standby states (S1-S3)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" /v "ACSettingIndex" REG_DWORD /d "0" /f >nul 2>&1
:: Additional measure: allow network connectivity during connected-standby (plugged in)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" /v "ACSettingIndex" REG_DWORD /d "1" /f >nul 2>&1
:: Domain password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
:: Turn off Power Throttling
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disable Windows Scaling Heuristics
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t REG_DWORD /d "0" /f >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[2C-Additional tweaks: 
:: Fix keyboard speed and numlock at startup
	reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2" /f >nul 2>&1
	reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
	reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2" /f >nul 2>&1
	reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
:: Wallpaper quality 100%
	reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d "256" /f >nul 2>&1
:: MenuShow (no delay)
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>&1
:: More than 15 items allowed to Open with...
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /t REG_DWORD /d "200" /f >nul 2>&1
:: No "shortcut" text added to shortcut name at creation
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f >nul 2>&1
:: No advertising banner in Snipping Tool
	reg add "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /t REG_DWORD /d "0" /f >nul 2>&1
:: Increase icons cache
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d "8192" /f >nul 2>&1

:: Check Windows edition before adding DisableCAD value
	if "%Win_Edition%" == "Windows Server 2019" ( goto :DisableCAD_Allowed ) else ( goto :DisableCAD_Skipped )

:DisableCAD_Allowed
:: Disable ALT+CTRL+DEL on startup (Windows Server only)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /t REG_DWORD /d "1" /f >nul 2>&1

:DisableCAD_Skipped
:: Prevent creation of Microsoft Account
	if not "%Win_Store%" == "Store_ON" (
		reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoConnectedUser" /t REG_DWORD /d "1" /f >nul 2>&1
	)
:: Hide Insider page
	reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disable hibernation and fast start (best setting for SSD)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
:: Kill CreateExplorerShellUnelevatedTask in task scheduler
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
	echo [92mDone.[97m
	echo [93mPerformances registry settings task has completed successfully.[97m& echo:

:PAUSE_BEFORE_EXIT
	<nul set /p dummyName=Press any key to exit...
	pause >nul 2>&1
exit /b

::============================================================================================================
:WStore_Check
::============================================================================================================
	for /f "tokens=3 delims= " %%a in ('PowerShell Get-AppxPackage -Name Microsoft.StorePurchaseApp ^| findstr /i /c:"Status"') do ( if "%%a" == "Ok" ( goto :WStore_Ask ))
	goto :eof

:WStore_Ask
	<nul set /p DummyName=Microsoft Store has been detected, do you want to apply Store and Store Apps settings? [Y/N] (press No if you use the store)
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& set "Win_Store=Store_ON" & goto :WGames_Ask )
	if errorlevel 1 ( echo [92mYes[97m& set "Win_Store=Store_OFF" & echo: & goto :eof )

:WGames_Ask
	<nul set /p DummyName=Do you want to apply game related tweaks? [Y/N] (press No if you play games)
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& set "Win_Games=Games_ON" & echo: & goto :eof )
	if errorlevel 1 ( echo [92mYes[97m& set "Win_Games=Games_OFF" & echo: & goto :eof )

::============================================================================================================

::============================================================================================================
:NOADMIN
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
::============================================================================================================
