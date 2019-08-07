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
	echo %hide_cursor%%white%]0;Scheduled Tasks Enabler& cls

:: Start when you're ready.
	echo Restoring Telemetry tasks is a bad idea, but ok,
	<nul set /p dummyName=press any key to start Scheduled Tasks restoration...%show_cursor%
	pause >nul 2>&1

:: Start Process
	cls
	echo Setting tasks...
	<nul set /p DummyName=[2C-Microsoft tasks: 
	schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\AitAgent" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ApplicationData\AppUriVerifierDaily" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ApplicationData\AppUriVerifierInstall" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ApplicationData\DsSvcCleanup" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\BthSQM" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Device information\Device" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Device Setup\Metadata Refresh" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\End Of Support\Notify1" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\End Of Support\Notify2" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\ErrorDetails\ErrorDetailsUpdate" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Flighting\OneSettings\RefreshCache" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\Installation" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Location\Notifications" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ActivateWindowsSearch" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ConfigureInternetTimeService" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\DispatchRecoveryTasks" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ehDRMInit" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\InstallPlayReady" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\mcupdate" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\MediaCenterRecoveryTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ObjectStoreRecoveryTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\OCURActivate" /Enable >nul 2>&1" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\OCURDiscovery" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscovery" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscoveryW1" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PBDADiscoveryW2" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PvrRecoveryTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\PvrScheduleTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\RegisterSearch" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\ReindexSearchRoot" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\SqlLiteRecoveryTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Media Center\UpdateRecordPath" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\NlaSvc\WiFiTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PushToInstall\LoginCheck" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\PushToInstall\Registration" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\RemovalTools\MRT_ERROR_HB" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SettingSync\BackgroundUploadTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SettingSync\BackupTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\gwx\launchtrayprocess" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\gwx\refreshgwxconfig" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\gwx\refreshgwxconfigandcontent" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Logon-10s" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Logon-5d" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\MachineUnlock-10s" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\MachineUnlock-5d" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfIdle-10s" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfIdle-5d" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfSleep-10s" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\OutOfSleep-5d" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\refreshgwxconfig-B" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Telemetry-4xd" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Time-10s" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Setup\GWXTriggers\Time-5d" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\CreateObjectTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitorToastTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefresh" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefreshTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyUpload" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SideShow\SessionAgent" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\SideShow\SystemDataProviders" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Reboot" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_Broker_Display" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_RebootDisplay" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_WnfDisplay" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_WnfDisplay" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\UPnP\UPnPHostConfig" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\User Profile Service\HiveUploadTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\WaaSMedic\PerformRemediation" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmRep" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
	schtasks /Change /TN "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
	for /f "tokens=1,2 delims==" %%s IN ('wmic path win32_useraccount where name^='%username%' get sid /value ^| find /i "SID"') do set "UserSID=%%t"
	schtasks /Change /TN "\OneDrive Standalone Update Task-%UserSID%" /Enable >nul 2>&1
	echo %done%
	<nul set /p DummyName=[2C-Office tasks: 
	schtasks /Change /TN "Microsoft\Office\Office 15 Subscription Heartbeat" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Automatic Updates" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Automatic Updates 2.0" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office ClickToRun Service Monitor" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Feature Updates" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Feature Updates Logon" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentLogOn2016" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallBack" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Enable >nul 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Enable >nul 2>&1
	echo %done%
	<nul set /p DummyName=[2C-Performances tweaks: 
:: Disable scheduled defragmentation
	schtasks /Change /TN "Microsoft\Windows\Defrag\ScheduledDefrag" /Enable >nul 2>&1
:: Disable System Restore Scheduled Task
	schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Enable >nul 2>&1	
:: Kill CreateExplorerShellUnelevatedTask
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
	echo %done%
:: Success
	echo %yellow%Scheduled tasks optimization has completed successfully.%white%& echo:
	<nul set /p dummyName=Press any key to exit...%show_cursor%
	pause >nul 2>&1
	exit /b

:No_Admin
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
