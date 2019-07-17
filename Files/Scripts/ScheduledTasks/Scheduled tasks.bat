@echo off

%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN
:: Set window Title
	echo ]0;Scheduled Tasks Optimization[97m
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to start scheduled tasks optimization...
	@pause >NUL 2>&1
:: Start Process
	cls
	echo Setting tasks...
	<nul set /p DummyName=[2C-Microsoft tasks: 
	schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\AitAgent" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ApplicationData\AppUriVerifierDaily" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ApplicationData\AppUriVerifierInstall" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ApplicationData\DsSvcCleanup" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Device information\Device" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Device Setup\Metadata Refresh" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\End Of Support\Notify1" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\End Of Support\Notify2" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Flighting\OneSettings\RefreshCache" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\Installation" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Location\Notifications" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ActivateWindowsSearch" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ConfigureInternetTimeService" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\DispatchRecoveryTasks" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ehDRMInit" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\InstallPlayReady" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\mcupdate" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\MediaCenterRecoveryTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ObjectStoreRecoveryTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\OCURActivate" /Disable >nul 2>&1" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\OCURDiscovery" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscovery" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscoveryW1" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscoveryW2" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PvrRecoveryTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PvrScheduleTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\RegisterSearch" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ReindexSearchRoot" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\SqlLiteRecoveryTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\UpdateRecordPath" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\NlaSvc\WiFiTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PushToInstall\LoginCheck" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PushToInstall\Registration" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\RemovalTools\MRT_ERROR_HB" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SettingSync\BackgroundUploadTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SettingSync\BackupTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\gwx\launchtrayprocess" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\gwx\refreshgwxconfig" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\gwx\refreshgwxconfigandcontent" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Logon-10s" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Logon-5d" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\MachineUnlock-10s" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\MachineUnlock-5d" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfIdle-10s" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfIdle-5d" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfSleep-10s" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfSleep-5d" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\refreshgwxconfig-B" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Telemetry-4xd" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Time-10s" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Time-5d" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\CreateObjectTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefresh" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyUpload" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SideShow\SessionAgent" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SideShow\SystemDataProviders" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Reboot" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_Broker_Display" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_RebootDisplay" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_WnfDisplay" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_WnfDisplay" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UPnP\UPnPHostConfig" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\User Profile Service\HiveUploadTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\WaaSMedic\PerformRemediation" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRep" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	for /f "tokens=1,2 delims==" %%s IN ('wmic path win32_useraccount where name^='%username%' get sid /value ^| find /i "SID"') do set "UserSID=%%t"
	schtasks /Change /TN "\OneDrive Standalone Update Task-%UserSID%" /Disable >nul 2>&1
:: Delete Tasks
	schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >nul 2>&1
	schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" >nul 2>&1
	schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\AitAgent" >nul 2>&1
	schtasks /Delete /F /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[2C-Office tasks: 
	schtasks /Change /TN "Microsoft\Office\Office 15 Subscription Heartbeat" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Automatic Updates" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Automatic Updates 2.0" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office ClickToRun Service Monitor" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Feature Updates" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Feature Updates Logon" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentLogOn2016" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Disable >nul 2>&1
	echo [92mDone.[97m
:: Kill CreateExplorerShellUnelevatedTask in task scheduler
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
:: Success
	echo [93mScheduled tasks optimization has completed successfully.[97m& echo:
	<nul set /p dummyName=Press any key to exit...
	pause >nul 2>&1
exit /b

::============================================================================================================
:NOADMIN
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
::============================================================================================================
