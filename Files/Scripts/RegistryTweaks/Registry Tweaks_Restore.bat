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

:: Titlebar
	echo %hide_cursor%%white%]0;Restore Registry Tweaks to Default Value& cls

:: Start when you're ready.
	<nul set /p dummyName=Press any key to remove registry tweaks...%show_cursor%
	pause >nul 2>&1

:: Start Process
	cls
REM PRIVACY TWEAKS
	<nul set /p DummyName=Removing privacy tweaks...
REM Use page predictions to speed up browsing, improve reading, and make my overall experience better
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v "FPEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Send Do Not Track requests
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "0" /f >nul 2>&1
REM Optimize taskbar web search results for screen readers
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "OptimizeWindowsSearchResultsForScreenReaders" /t REG_DWORD /d "1" /f >nul 2>&1
REM show search and sites suggestions as I type
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "1" /f >nul 2>&1
REM Save form entries
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "Use FormSuggest" /t REG_SZ /d "yes" /f >nul 2>&1
REM Help protect me from malicious sites and downloads with Windows Defender SmartScreen
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "1" /f >nul 2>&1
REM Let sites save protected media licenses on my device
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Privacy" /v "EnableEncryptedMediaExtensions" /t REG_DWORD /d "1" /f >nul 2>&1
REM Have Cortana assist me in Microsoft Edge
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "1" /f >nul 2>&1
REM Show search history
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI\ShowSearchHistory" /ve /t REG_DWORD /d "1" /f >nul 2>&1
REM Patch NVIDIA telemetry leaks ( I don't restore default on purpose, go to hell NVIDIA )
	reg query "HKCU\Software" | findstr /i "NVIDIA" >nul && ( reg add "HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f >nul 2>&1 )
REM Enable Game Mode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Turn on Game Bar Tips
	reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "1" /f >nul 2>&1
REM Turn on "Getting to know you" for inking and typing personalization
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
REM Send Microsoft info about how I write to help us improving typing and writing in the future
	reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Windows Feedback
	reg delete "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /f >nul 2>&1
REM Turn on Location Service permission
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable unique ad-tracking ID token for relevant ads
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Set SmartScreen for Store apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "1" /f >nul 2>&1
REM Turn on share apps across devices
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
REM ContentDeliveryManager settings (default value else causing crash)
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable Live Tiles
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "NoTileApplicationNotification" /t REG_DWORD /d "0" /f >nul 2>&1
REM Enable OEM pre-installed apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Lockscreen settings
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayVisible" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable automatically installating suggested apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Turn on "Get tips, tricks and suggestions as you use Windows"
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable automatic download of content, ads and suggestions
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "NoTileApplicationNotification" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayVisible" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-202914Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280810Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280811Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280813Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280815Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310091Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310092Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314559Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338380Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338381Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /f >nul 2>&1
REM Turn on Start Menu suggestions
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Allow dynamic ads
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "1" /f >nul 2>&1
REM Delivery Optimization settings: Act as a peercaching client for Windows Update
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "1" /f >nul 2>&1
REM Sync with Devices
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
REM Let apps access diagnostic information
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /f >nul 2>&1
REM Let apps access my notifications
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /f >nul 2>&1
REM Let apps control radios
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
REM Enable Location
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
REM Patch Explorer leaks
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "1" /f >nul 2>&1
REM Add People icon on taskbar
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "1" /f >nul 2>&1
REM Games settings
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Windows Ink Workspace app suggestions
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceAppSuggestionsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Turn on notifications from apps and other senders
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Cortana and websearch
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HasAboveLockTips" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Sync
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable websearch in cortana
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "1" /f >nul 2>&1
REM Games settings
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Patch Contacts leaks from personalization
	reg add "HKLM\SOFTWARE\Microsoft\Input\Settings" /v "HarvestContacts" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Bluetooth ads
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Browser" /v "AllowAddressBarDropdown" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Experiments
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "1" /f >nul 2>&1
REM Restore Windows Malware Removal Tool settings
	reg add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "SpyNetReportingLocation" /t REG_SZ /d "1" /f >nul 2>&1
REM Enable Speech models download
	reg add "HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "1" /f >nul 2>&1
REM Sensor permission
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable and clear unique ad-tracking ID token
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /f >nul 2>&1
REM Allow App access
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
REM Delivery Optimization settings, act as a peercaching client for Windows Update
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /f >nul 2>&1
REM Allow device meta-data collection
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "DeviceMetadataServiceURL" /t REG_SZ /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "0" /f >nul 2>&1
REM Restore Smartscreen Admin requirement (Smartscreen is turned off by Group Policy)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "RequireAdmin" /f >nul 2>&1
REM Enable telemetry uploading (registry keys differ from Group Policy ones)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "1" /f >nul 2>&1
REM More settings
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowScreenMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowTextSuggestions" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "RequirePrinting" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Store automatic updates download
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /f >nul 2>&1
REM Enable telemetry log events
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable remote Scripted Diagnostics Provider query
	reg add "HKLM\SOFTWARE\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "EnableQueryRemoteServer" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable remote Scheduled Diagnostics execution
	reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Windows Error Reporting
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "DontShowUI" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "MachineID" /t REG_SZ /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\WMR" /v "Disable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "DefaultConsent" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent" /v "NewUserDefaultConsent" /t REG_DWORD /d "1" /f >nul 2>&1
REM Allow Windows Defender data leaks
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "SOAP:https://wdcp.microsoft.com/WdCpSrvc.asmx\0SOAP:https://wdcpalt.microsoft.com/WdCpSrvc.asmx\0REST:https://wdcp.microsoft.com/wdcp.svc/submitReport\0REST:https://wdcpalt.microsoft.com/wdcp.svc/submitReport\0BOND:https://wdcp.microsoft.com/wdcp.svc/bond/submitreport\0BOND:https://wdcpalt.microsoft.com/wdcp.svc/bond/submitreport" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "1" /f >nul 2>&1
REM Patch Windows SMB data leaks
	reg add "HKLM\SYSTEM\ControlSet001\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictReceivingNTLMTraffic" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v "RestrictSendingNTLMTraffic" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SMB1" /t REG_DWORD /d "1" /f >nul 2>&1
REM Disable Remote Assistance
	reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable BluetoothSession AutoLogger
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\BluetoothSession" /v Start /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\WMI\Autologger\BluetoothSession" /v Start /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\BluetoothSession" /v Start /t REG_DWORD /d "1" /f >nul 2>&1
REM Patch Link-local Multicast Name Resolution
	reg add "HKLM\SYSTEM\ControlSet001\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "DisableParallelAandAAAA" /t REG_DWORD /d "0" /f >nul 2>&1
REM Enable Geolocation service
	reg add "HKLM\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "1" /f >nul 2>&1
REM Fully participate in IGMP
	reg add "HKLM\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "2" /f >nul 2>&1
REM Patch Web Proxy Auto Discovery
	netsh winhttp reset proxy >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UseDomainNameDevolution" /t REG_DWORD /d "1" /f >nul 2>&1
REM Enable Teredo/IPv6 tunneling
	netsh int teredo set state enabled >nul 2>&1
REM Turn on Tailored Experiences for current user
	reg add "HKU\%User_SID%\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
REM Prevent OneDrive to run at startup, again (preventive)
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1
	reg delete "HKU\%User_SID%\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f >nul 2>&1
	echo %done%
	echo %yellow%Privacy registry settings have been removed.%white%
	echo:
REM PERFORMANCES TWEAKS
	<nul set /p DummyName=Removing performances tweaks...%show_cursor%
REM Domain password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >nul 2>&1	
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >nul 2>&1
REM Wallpaper compression
	reg delete "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /f >nul 2>&1
REM MenuShowDelay default delay value
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f >nul 2>&1
REM Max 15 items allowed to Open with
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /f >nul 2>&1
REM Add "-shortcut" to shortcut name at creation
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /f >nul 2>&1
REM Show advertising banner in Snipping Tool
	reg delete "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /f >nul 2>&1
REM Default icons cache size
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /f >nul 2>&1
REM Default programs startup delay
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /f >nul 2>&1
REM Show Insider page
	reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /f >nul 2>&1
REM Disable long paths
	reg add "HKLM\SYSTEM\ControlSet001\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
REM Memory Management (default value is set to 1 on Windows Sezver, to allow more cache for files servers: better to leave it to 0 if OS used as a workstation)
	if "%Win_Edition%"=="Windows Server 2019" (
		reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >nul 2>&1
		reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >nul 2>&1
		reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >nul 2>&1
	)
REM Prefetch parameters (Superfetch feature has been removed since v1809 anyway)
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /f >nul 2>&1
REM Startup options
  REM Enable boot files defragmentation at startup
	reg add "HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" /v "Enable" /t REG_SZ /d "Y" /f >nul 2>&1
  REM Enable updating Group Policy at startup
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousMachineGroupPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "SynchronousUserGroupPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
  REM Enable creation of last known good configuration at startup
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "ReportBootOk" /t REG_SZ /d "1" /f >nul 2>&1
  REM Enable Windows logging system crash
	reg add "HKLM\SYSTEM\ControlSet001\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "LogEvent" /t REG_DWORD /d "1" /f >nul 2>&1
  REM Enable the Disk Check when Windows starts
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "autocheck autochk *" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "autocheck autochk *" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "autocheck autochk *" /f >nul 2>&1
  REM Place Windows Kernel into RAM (default settings normally, not changed)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul 2>&1
REM Shutdown options
  REM Default waiting time for processes to end after shutdown request
	reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "5000" /f >nul 2>&1
  REM Default waiting time for services to stop after shutdown request
	reg add "HKLM\SYSTEM\ControlSet001\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "5000" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "5000" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "5000" /f >nul 2>&1
REM Additional Power Settings
REM Enable hibernation and fast start
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	echo %done%
	echo %yellow%Performances registry settings have been restored to default value.%white%
	echo:
	<nul set /p dummyName=Press any key to exit...%show_cursor%
	pause >nul 2>&1
	exit /b

:No_Admin
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
