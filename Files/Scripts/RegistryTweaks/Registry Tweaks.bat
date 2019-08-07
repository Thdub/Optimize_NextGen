@echo off
C:\Windows\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :No_Admin

:: Set variables
	set "colors=blue=[94m,green=[92m,red=[31m,yellow=[93m,white=[97m
	set "%colors:,=" & set "%"
	set "hide_cursor=[?25l"
	set "show_cursor=[?25h"
	set "yes=[?25l[92mYes[97m"
	set "no=[?25l[31mNo[97m"
	set "done=[?25l[92mDone.[97m"
	set "Win_Store=Store_OFF"
	set "Win_Games=Games_OFF"

REM Get User SID
	for /f "tokens=1,2 delims==" %%s IN ('wmic path win32_useraccount where name^='%username%' get sid /value ^| find /i "SID"') do set "User_SID=%%t"

REM Check Windows architecture,edition and build number
	for /f "tokens=1* delims==" %%A in ('wmic os get OSArchitecture^,Caption^,BuildNumber /value') do (
		for /f "tokens=*" %%S in ("%%B") do (
			if "%%A"=="BuildNumber" set "Build_Number=%%S"
			if "%%A"=="Caption" set "OS_Name=%%S"
			if "%%A"=="OSArchitecture" set "OS_Architecture=%%S"
	))

REM Exit if OS is not 64 bit, or buildnumber less than 1809
	if not "%OS_Architecture%"=="64-bit" ( goto :Error_No_64bit_System )
	if %Build_Number% LSS 17763 ( goto :Inferior_Build )

REM LTSC editions
	if %Build_Number% EQU 17763 (
		if "%OS_Name%"=="Microsoft Windows Server 2019 Datacenter" ( set "Win_Edition=Windows Server 2019" & goto :START )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Standard" ( set "Win_Edition=Windows Server 2019" & goto :START )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Essentials" ( set "Win_Edition=Windows Server 2019" & goto :START )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise LTSC" ( set "Win_Edition=Windows 10 LTSC" & goto :START )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise N LTSC" ( set "Win_Edition=Windows 10 LTSC" & goto :START )
	)

REM Regular editions
	set "OS_Name=%OS_Name:~0,20%"
	if "%OS_Name%"=="Microsoft Windows 10" ( set "Win_Edition=Windows 10" & goto :START ) else ( goto :Error_Edition_Not_Found )

:START
	if not "%Win_Edition%"== "Windows Server 2019" ( call :WStore_Check )

:: Titlebar
	echo %hide_cursor%%white%]0;Registry Tweaks& cls

:: Start when you're ready.
	<nul set /p dummyName=Press any key to apply %Win_Edition% registry tweaks...%show_cursor%
	pause >nul 2>&1

:: Start Process
	cls
	if not "%Win_Edition%"=="Windows Server 2019" ( call :WStore_Check )
	echo %hide_cursor%Optimizing privacy:
	call :Telemetry_Settings
	call :Privacy_Settings
	echo %yellow%Privacy registry settings task has completed successfully.%white%& echo:
	echo %show_cursor%Optimizing performances:
	call :Performances_Settings
	call :Power_Settings
	echo %yellow%Performances registry settings task has completed successfully.%white%& echo:
	<nul set /p dummyName=Press any key to exit...%show_cursor%
	pause >nul 2>&1
exit /b

:Telemetry_Settings
	<nul set /p DummyName=[2X[2C-Processing telemetry blocking tweaks...[103X%show_cursor%
REM Disabling Application Compatibility telemetry, CEIP, telemetry uploading, recommended updates
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d "0" >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "AllowOSUpgrade" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /v "HaveUploadedForTarget" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\AIT" /v "AITEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "DontRetryOnError" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "IsCensusDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "TaskEnableRun" /t REG_DWORD /d "1" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" /v "UpgradeEligible" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TelemetryController" /f >nul 2>&1
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
	reg delete "HKLM\SYSTEM\ControlSet002\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\WMI\AutoLogger\Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\Diagtrack-Listener" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\SQMLogger" /f >nul 2>&1	
	reg delete "HKLM\SYSTEM\ControlSet002\Control\WMI\AutoLogger\SQMLogger" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DiagTrackAuthorization" /t REG_DWORD /d "0" /f >nul 2>&1
	takeown /f %ProgramData%\Microsoft\Diagnosis /A /r /d y >nul 2>&1
	icacls %ProgramData%\Microsoft\Diagnosis /grant:r *S-1-5-32-544:F /T /C >nul 2>&1
	del /F /Q /S "%ProgramData%\Microsoft\Diagnosis\*.rbs" >nul 2>&1
	del /F /Q /S "%ProgramData%\Microsoft\Diagnosis\ETLLogs\*" >nul 2>&1
REM Disabling Office Telemetry
	reg add "HKCU\Software\Microsoft\Office\Common\ClientTelemetry" /v "DisableTelemetry" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "sendcustomerdata" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common\Feedback" /v "enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common\Feedback" /v "includescreenshot" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Outlook\Options\Mail" /v "EnableLogging" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Word\Options" /v "EnableLogging" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\Common\ClientTelemetry" /v "SendTelemetry" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "qmenable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common" /v "updatereliabilitydata" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common\General" /v "shownfirstrunoptin" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common\General" /v "skydrivesigninoption" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Common\ptwatson" /v "ptwoptin" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\Firstrun" /v "disablemovie" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM" /v "Enablelogging" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM" /v "EnableUpload" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM" /v "EnableFileObfuscation" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "accesssolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "olksolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "onenotesolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "pptsolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "projectsolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "publishersolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "visiosolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "wdsolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications" /v "xlsolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "agave" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "appaddins" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "comaddins" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "documentfiles" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes" /v "templatefiles" /t REG_DWORD /d "1" /f >nul 2>&1
	echo %done%
	goto :eof

:Privacy_Settings
	<nul set /p DummyName=[2X[2C-Patching data leaks, blocking ads and tracking...%show_cursor%
REM Turn off Microsoft Edge page prediction
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v "FPEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Send Do Not Track requests in Microsoft Edge
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f >nul 2>&1
REM Do not optimize taskbar web search results for screen readers
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "OptimizeWindowsSearchResultsForScreenReaders" /t REG_DWORD /d "0" /f >nul 2>&1
REM Do not show search and sites suggestions as I type
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "0" /f >nul 2>&1
REM Do not save form entries
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "Use FormSuggest" /t REG_SZ /d "no" /f >nul 2>&1
REM Do not use Windows Defender SmartScreen in Microsoft Edge
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f >nul 2>&1
REM Do not let sites save protected media licenses on my device
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Privacy" /v "EnableEncryptedMediaExtensions" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn Off Cortana in Microsoft Edge
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "0" /f >nul 2>&1
REM Do not show search history
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI\ShowSearchHistory" /ve /t REG_DWORD /d "0" /f >nul 2>&1
REM Patch NVIDIA telemetry leaks
	reg query "HKCU\Software" | findstr /i "NVIDIA" >nul && ( reg add "HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f >nul 2>&1 )
REM Disable Game Mode
	if not "%Win_Games%"=="Games_ON" (
		reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	)
REM Turn off Game Bar Tips
	reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off Getting to know you for inking and typing personalization
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
REM Do not send Microsoft info about how I write to help us improving typing and writing in the future
	reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Windows Feedback
	reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off Location Service permission
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable unique ad-tracking ID token for relevant ads
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off SmartScreen for Store apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off share apps across devices
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
REM ContentDeliveryManager settings (default value else causing crash)
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable Live Tiles
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable preinstalled apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Lockscreen settings
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayVisible" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable automatically installating suggested apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn on "Get tips, tricks and suggestions as you use Windows"
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable automatic download of content, ads and suggestions
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
REM Turn off Start Menu suggestions
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Dynamic ads
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "0" /f >nul 2>&1
REM Delivery Optimization settings: Do not act as a peercaching client for Windows Update
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
REM Do not sync with Devices
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
REM Do not let apps access diagnostic information
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
REM Do not let apps access my notifications
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
REM Do not let apps apps control radios
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
REM Disable Location
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
REM Patch Explorer leaks
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f >nul 2>&1
REM Remove People icon from taskbar
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "0" /f >nul 2>&1
REM Games settings
	if not "%Win_Games%"=="Games_ON" (
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	)
REM Disable Windows Ink Workspace app suggestions
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceAppSuggestionsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off notifications from apps and other senders
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable websearch
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HasAboveLockTips" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable sync
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Cortana
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1
REM Games settings
	if not "%Win_Games%"=="Games_ON" ( reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1 )
REM Patch Contacts leaks from personalization settings
	reg add "HKLM\SOFTWARE\Microsoft\Input\Settings" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Bluetooth ads
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable address bar drop-down list to minimize connections from Microsoft Edge to Microsoft services
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Browser" /v "AllowAddressBarDropdown" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Experiments
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "0" /f >nul 2>&1
REM Patch Windows MRT data leaks
	reg add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "SpyNetReportingLocation" /t REG_SZ /d "0" /f >nul 2>&1
REM Disable Speech models download
	reg add "HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
REM Sensor permission
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable and clear unique ad-tracking ID token for relevant ads
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /t REG_SZ /d "null" /f >nul 2>&1
REM Deny App access
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
REM Delivery Optimization settings
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f >nul 2>&1
REM Prevent device meta-data collection
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "DeviceMetadataServiceURL" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable Smartscreen (preventive, Smartscreen is turned off by Group Policy)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
REM Disable telemetry uploading (registry keys differ from Group Policy ones)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
REM More settings
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowScreenMonitoring" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowTextSuggestions" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "RequirePrinting" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Store automatic updates download
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f >nul 2>&1
REM Disable telemetry log events
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable remote Scripted Diagnostics Provider query
	reg add "HKLM\SOFTWARE\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "EnableQueryRemoteServer" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable remote Scheduled Diagnostics execution
	reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Windows Error Reporting
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontShowUI" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "MachineID" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\WMR" /v "Disable" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "DefaultConsent" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "NewUserDefaultConsent" /t REG_DWORD /d "0" /f >nul 2>&1
REM Patch Windows Defender data leaks
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "\0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
REM Patch Windows SMB data leaks
	reg add "HKLM\SYSTEM\ControlSet001\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Remote Assistance
	reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable BluetoothSession AutoLogger
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\BluetoothSession" /v Start /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\WMI\Autologger\BluetoothSession" /v Start /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\BluetoothSession" /v Start /t REG_DWORD /d "0" /f >nul 2>&1
REM Patch Link-local Multicast Name Resolution
	reg add "HKLM\SYSTEM\ControlSet001\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable Geolocation service
	reg add "HKLM\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f >nul 2>&1
REM Patch IGMP
	reg add "HKLM\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "0" /f >nul 2>&1
REM Patch Web Proxy Auto Discovery
	netsh winhttp reset proxy >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "0" /f >nul 2>&1
REM Disable Teredo/IPv6 tunneling
	netsh int teredo set state disabled >nul 2>&1
REM Turn off Tailored Experiences for current user (preventive, turned off by gpo)
	reg add "HKU\%User_SID%\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Prevent OneDrive to run at startup (preventive)
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1
	reg delete "HKU\%User_SID%\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1
	echo %done%
	goto :eof

::============================================================================================================
:Performances_Settings
::============================================================================================================
	<nul set /p DummyName=[2C-Processing registry keys...%show_cursor%
REM Domain password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1	
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
REM Fix keyboard speed and numlock at startup
	reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2" /f >nul 2>&1
	reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
	reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d "2" /f >nul 2>&1
	reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
	reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
REM Wallpaper quality 100%
	reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d "256" /f >nul 2>&1
REM MenuShow (no delay)
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul 2>&1
REM More than 15 items allowed to "Open with"
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /t REG_DWORD /d "200" /f >nul 2>&1
REM No "shortcut" text added to shortcut name at creation
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f >nul 2>&1
REM No advertising banner in Snipping Tool
	reg add "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /t REG_DWORD /d "0" /f >nul 2>&1
REM Increase icons cache
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d "16384" /f >nul 2>&1
REM Tune programs startup delay
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d "0" /f >nul 2>&1
REM Hide Insider page
	reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable long paths
	reg add "HKLM\SYSTEM\ControlSet001\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Memory Management (default setting on Windows 10, but set to 1 on Windows Server)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f >nul 2>&1
REM Prefetch parameters (Superfetch feature has been removed since v1809 anyway)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
REM Startup options
  REM Disable boot files defragmentation at startup
	reg add "HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" /v "Enable" /t REG_SZ /d "N" /f >nul 2>&1
  REM Disable updating Group Policy at startup
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousMachineGroupPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousUserGroupPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
  REM Disable creation of last known good configuration at startup
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "ReportBootOk" /t REG_SZ /d "0" /f >nul 2>&1
  REM Disable Windows logging system crash
	reg add "HKLM\SYSTEM\ControlSet001\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "0" /f >nul 2>&1
  REM Cancel the Disk Check when Windows starts
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "\0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "\0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "\0" /f >nul 2>&1
  REM Place Windows Kernel into RAM (default settings normally, not changed)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
REM Shutdown options
  REM Lowest waiting time for processes to end after shutdown request
	reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "1000" /f >nul 2>&1
  REM Lowest waiting time for services to stop after shutdown request
	reg add "HKLM\SYSTEM\ControlSet001\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f >nul 2>&1
	echo %done%
	goto :eof

::============================================================================================================
:Power_Settings
::============================================================================================================
	<nul set /p DummyName=[2C-Processing Power settings...%show_cursor%
REM Disable hibernation
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off Windows fast startup
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Turn off Power Throttling
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1
	echo %done%
	goto :eof

::============================================================================================================
:WStore_Check
::============================================================================================================
	<nul set /p DummyName=Checking for Microsoft Store before applying settings...[89X%show_cursor%
	for /f "tokens=3 delims= " %%a in ('Powershell Get-AppxPackage -Name Microsoft.StorePurchaseApp ^| findstr /i /c:"Status"') do (
		if "%%a"=="Ok" ( echo %done%& goto :WStore_Ask ))
	echo %hide_cursor%%yellow%Microsoft Store is not installed.%white%& echo %Shell_Title%& goto :eof

:WStore_Ask
	echo %Shell_Title%[1A
	<nul set /p DummyName=Microsoft Store has been detected, do you want to apply Store and Store Apps settings? [Y/N] (Press No if you use Microsoft Store)%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %no%&set "Win_Store=Store_ON" & goto :WGames_Ask )
	if errorlevel 1 ( echo %yes%&set "Win_Store=Store_OFF" & echo: & goto :eof )

:WGames_Ask
	<nul set /p DummyName=Do you want to apply game related tweaks? [Y/N] (Press No if you play games)%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %no%&set "Win_Games=Games_ON" & echo: & goto :eof )
	if errorlevel 1 ( echo %yes%&set "Win_Games=Games_OFF" & echo: & goto :eof )

::============================================================================================================
:: Error Messages
::============================================================================================================
:No_Admin
	echo %white%You must have administrator rights to run this script.
	goto :Exit_on_Error

:Inferior_Build
	echo %white%Optimize NextGen can not be run on your system ^(%Win_Edition% build %Build_Number%^).
	goto :Exit_on_Error

:Error_No_64bit_System
	echo %white%Optimize NextGen can only run on 64 bit OS.
	goto :Exit_on_Error

:Error_Edition_Not_Found
	echo We could not find your Windows Edition, the script can not continue.
	goto :Exit_on_Error

:Exit_on_Error
	<nul set /p DummyName=Press any key to exit...%show_cursor%
	pause >nul
	exit /b
