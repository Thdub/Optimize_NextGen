@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN
:: Set window Title
	echo ]0;Remove Optimization Tweaks
:: Set variable
	for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%A
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to remove optimization tweaks...
	@pause >NUL 2>&1
	cls
::===============================================================================================================
:: Start Process
::===============================================================================================================
	echo Removing privacy settings tweaks...
	<nul set /p dummyName=%BS%  -Preferences added to Group Policy in 'Custom Policies': 
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AllowMUUpdateService" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT"/v "DontReportInfectionInformation" /f >NUL 2>&1
	reg delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.BingNews_8wekyb3d8bbwe!AppexNews" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Photos_8wekyb3d8bbwe!App" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.calendar" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.mail" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.System.Continuum" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AudioTroubleshooter" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackgroundAccess" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BdeUnlock" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.RasToastNotifier" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WiFiNetworkManager" /f >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Additional tweaks: 
	reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Input\Settings" /v "HarvestContacts" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t REG_SZ /d "Allow" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "4" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\DiagTrack" /v "Start" /t REG_DWORD /d "2" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "3" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\OneDrive" /v "PreventNetworkTrafficPreUserSignIn" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "NoTileApplicationNotification" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayVisible" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-202914Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280810Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280811Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280813Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280815Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310091Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310092Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314559Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338380Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338381Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceAppSuggestionsEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HasAboveLockTips" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /f >NUL 2>&1
	reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /f >NUL 2>&1
	reg delete "HKCU\Software\Policies\Microsoft\MicrosoftEdge" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f >NUL 2>&1
	echo [92mDone.[97m
	echo [93mPrivacy settings task has completed successfully.[97m
	echo:
	echo Removing performances tweaks...
	echo   -Registry settings:
	<nul set /p dummyName=%BS%     Preferences already present in Group Policy: 
:: Allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services
	reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "1" /f >NUL 2>&1
:: Use biometrics
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /f >NUL 2>&1
:: Display Shutdown Event Tracker
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Policies\Microsoft\Windows NT\Reliability" /f >NUL 2>&1
:: Power saving settings
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" /f >NUL 2>&1
:: Button settings
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB" /f >NUL 2>&1
:: Password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >NUL 2>&1
:: Turn on Power Throttling
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >NUL 2>&1
:: Enable Windows Scaling Heuristics
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /f >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%     Additional tweaks: 
:: Wallpaper compression
	reg delete "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /f >NUL 2>&1
:: MenuShow default delay
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f >NUL 2>&1
:: Max 15 items allowed to Open with
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /f >NUL 2>&1
::Add "-shortcut" to shortcut name at creation
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /f >NUL 2>&1
:: Show advertising banner in Snipping Tool
	reg delete "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /f >NUL 2>&1
:: Default icons cache size
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /f >NUL 2>&1
:: Requires ALT+CTRL+DEL at logon screen (Windows Server)
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /f >NUL 2>&1
:: Allow creation and logon of Microsoft Account
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoConnectedUser" /f >NUL 2>&1
:: Show Insider page
	reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /f >NUL 2>&1
:: Enable hibernation and fast start (best setting for SSD)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
:: Kill CreateExplorerShellUnelevatedTask in task scheduler
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >NUL 2>&1
	echo [92mDone.[97m
	echo [93mPerformances registry settings task has completed successfully.[97m
	echo:
:: GPUpdate
	<nul set /p dummyName=Updating policy...[140X
	GPUpdate /Force /Target:Computer >NUL && echo:
	<nul set /p dummyName=[93mComputer Policy update has completed successfully.[1A[32D
	GPUpdate /Force /Target:User >NUL && echo: & echo:
	echo User Policy update has completed successfully.& echo:
	echo [4A[18C[92mDone.[97m[2B
	echo:
:: Pause before exit
	<nul set /p dummyName=Press any key to exit...
	pause >NUL 2>&1
	exit /b
::===============================================================================================================
:NOADMIN
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
::===============================================================================================================
