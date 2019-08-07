@echo off
C:\Windows\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :No_Admin
%windir%\system32\whoami.exe /USER | find /i "S-1-5-18" 1>nul && (
	goto :Services_Optimization_Task
) || (
	goto :Variables
)

::============================================================================================================
:Variables
::============================================================================================================
	set "colors=blue=[94m,green=[92m,red=[31m,yellow=[93m,white=[97m
	set "%colors:,=" & set "%"
	set "hide_cursor=[?25l"
	set "show_cursor=[?25h"
	set "yes=[?25l[92mYes[97m"
	set "no=[?25l[31mNo[97m"
	set "done=[?25l[92mDone.[97m"
	set "NextGen_UserName=%username%"
	if not exist "%systemroot%\system32\robocopy.exe" goto :Error_No_Robocopy
	if not defined NextGen_UserName (goto :Error_No_User) else if exist "%systemdrive%\Users\%NextGen_UserName%\AppData\Local\Temp\" (
		set "Tmp_Folder=%systemdrive%\Users\%NextGen_UserName%\AppData\Local\Temp\Optimize_NextGen_%random%.tmp\" & set "User_Tmp_Folder=%systemdrive%\Users\%NextGen_UserName%\AppData\Local\Temp"
	)
REM Check Windows architecture,edition and build number
	for /f "tokens=1* delims==" %%A in ('wmic os get Caption^,BuildNumber /value') do (
		for /f "tokens=*" %%S in ("%%B") do (
			if "%%A"=="BuildNumber" set "Build_Number=%%S"
			if "%%A"=="Caption" set "OS_Name=%%S"
	))
REM Exit if OS is not 64 bit, or buildnumber less than 1809
	if %Build_Number% LSS 17763 ( goto :Inferior_Build )
REM LTSC editions
	if %Build_Number% EQU 17763 (
		if "%OS_Name%"=="Microsoft Windows Server 2019 Datacenter" ( set "Win_Edition=Windows Server 2019" & set "Win_Edition_Title=%OS_Name:~0,29%" & goto :START )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Standard" ( set "Win_Edition=Windows Server 2019" & set "Win_Edition_Title=%OS_Name:~0,29%" & goto :START )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Essentials" ( set "Win_Edition=Windows Server 2019" & set "Win_Edition_Title=%OS_Name:~0,29%" & goto :START )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise LTSC" ( set "Win_Edition=Windows 10 LTSC" & set "Win_Edition_Title=Microsoft Windows 10 LTSC" & goto :START )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise N LTSC" ( set "Win_Edition=Windows 10 LTSC" & set "Win_Edition_Title=Microsoft Windows 10 LTSC" & goto :START )
	)
REM Anomaly
	if %Build_Number% GTR 17763 (
		if "%OS_Name%"=="Microsoft Windows Server 2019 Datacenter" ( goto :Error_Frankenbuild )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Standard" ( goto :Error_Frankenbuild )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Essentials" ( goto :Error_Frankenbuild )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise LTSC" ( goto :Error_Frankenbuild )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise N LTSC" ( goto :Error_Frankenbuild )
	)
REM Regular Windows 10 editions
	if "%OS_Name%"=="Microsoft Windows 10 Education" ( set "Win_Edition=Windows 10 Education" & set "Win_Edition_Title=%OS_Name%" & goto :Regular_Editions )
	if "%OS_Name%"=="Microsoft Windows 10 Enterprise" ( set "Win_Edition=Windows 10 Enterprise" & set "Win_Edition_Title=%OS_Name%" & goto :Regular_Editions )
	if "%OS_Name%"=="Microsoft Windows 10 Pro" ( set "Win_Edition=Windows 10 Pro" & set "Win_Edition_Title=%OS_Name%" & goto :Regular_Editions )
	set "OS_Name=%OS_Name:~0,20%"
	if "%OS_Name%"=="Microsoft Windows 10" ( set "Win_Edition=Windows 10" & set "Win_Edition_Title=%OS_Name%" ) else ( goto :Error_Edition_Not_Found )
:Regular_Editions
	set "Win_Regular_Edition=Windows 10"
	call :LITE_Notice

::============================================================================================================
:START
::============================================================================================================
:: Resize window
	"%~dp0..\..\..\Files\Utilities\consolesize.exe" 140 30 140 9999

:: Titlebar
	echo %hide_cursor%%white%]0;Optimize %Win_Edition% Services& cls

:: Backup choice
	<nul set /p DummyName=Do you want to backup services startup configuration? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %hide_cursor%%no%& echo: & goto :Start_Checks )
	if errorlevel 1 ( echo %hide_cursor%%yes%& call :Backup_Services )
:Start_Checks
	if "%Win_Edition%"=="Windows Server 2019" (
		sc query WlanSvc >nul
		if errorlevel 1060 ( set "WLan_Service=Missing" & goto :File_and_Printer_Sharing_Setting )
	)
REM Check_WiFi_Connection_Status
	for /f "usebackq" %%A in ('wmic path WIN32_NetworkAdapter where 'NetConnectionID="Wi-Fi"' get NetConnectionStatus') do if %%A equ 2 ( set "WLan_Service=Enable_WLan_Service" ) else ( set "WLan_Service=Disable_WLan_Service" )

	if "%WLan_Service%"=="Disable_WLan_Service" (
			<nul set /p DummyName=%hide_cursor%%yellow%Note:%white% You are not connected to any Wi-Fi network, do you want to disable Wlan Service? [Y/N] ^(Press Y if you don't use wifi^)%show_cursor%
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %no%& set "WLan_Service=Enable_WLan_Service" & goto :File_and_Printer_Sharing_Setting )
			if errorlevel 1 ( echo %yes%& set "WLan_Service=Disable_WLan_Service" )
	)

:File_and_Printer_Sharing_Setting
	<nul set /p DummyName=(E)nable or (D)isable File and Printer Sharing? [E/D] ^(Press D if you don't have home network and/or network printer^)%show_cursor%
	choice /c DE >nul 2>&1
	if errorlevel 2 ( echo %hide_cursor%%green%Enable%white%& set "File_and_Printer_Sharing=Enable_File_and_Printer_Sharing" & goto :Launch_Nsudo_for_Svc_Optimization )
	if errorlevel 1 ( echo %hide_cursor%%red%Disable%white%& set "File_and_Printer_Sharing=Disable_File_and_Printer_Sharing" )

:Launch_Nsudo_for_Svc_Optimization
REM Options recap
	if "%File_and_Printer_Sharing%"=="Disable_File_and_Printer_Sharing" ( set "Services_Style_1=%red%DISABLED" ) else ( set "Services_Style_1=%green%ENABLED" )
	if "%WLan_Service%"=="Disable_WLan_Service" ( set "Services_Style_2=%red%DISABLED" )
	if "%WLan_Service%"=="Enable_WLan_Service" ( set "Services_Style_2=%green%ENABLED" )
	if "%WLan_Service%"=="Missing" ( set "Services_Style_2=%red%DOES NOT EXIST" )
	echo %hide_cursor%%yellow%Options set: %blue%File and Printer Sharing %Services_Style_1%%yellow% - %blue%WLAN AutoConfig service %Services_Style_2%%white%
	<nul set /p DummyName=Applying complete services optimization with NSudo...%show_cursor%
REM Rocket launch
	"%~dp0..\..\..\Files\Utilities\NSudoC.exe" -U:T -P:E -Wait -UseCurrentConsole "%~dpnx0"&& ( goto :Services_Optimization_Success ) || ( goto :Services_Optimization_Failed )

:Services_Optimization_Task
	if "%Win_Edition%"=="Windows Server 2019" (
		if not "%File_and_Printer_Sharing%"=="Enable_File_and_Printer_Sharing" ( goto :Server_Services )
		goto :Server_Services_NW
	) else (
		if not "%File_and_Printer_Sharing%"=="Enable_File_and_Printer_Sharing" ( goto :LTSC_Services )
		goto :LTSC_Services_NW
	)

:LTSC_Services
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,jhi_service,KeyIso,KtmRm,LicenseManager,lltdsvc,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:LTSC_Services_NW
REM Set Services for LTSC with File and Printer Sharing enabled
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FDResPub,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,jhi_service,KeyIso,KtmRm,LanmanServer,LanmanWorkstation,LicenseManager,lltdsvc,lmhosts,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SSDPSRV,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,upnphost,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,lfsvc,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Server_Services
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,jhi_service,KeyIso,KPSSVC,KtmRm,LicenseManager,lltdsvc,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WebClient,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Server_Services_NW
REM Set Services for Windows Server with File and Printer Sharing enabled
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FDResPub,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,jhi_service,KeyIso,KPSSVC,KtmRm,LanmanServer,LanmanWorkstation,LicenseManager,lltdsvc,lmhosts,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SSDPSRV,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,upnphost,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,lfsvc,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WebClient,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Start_Svc_Optimization
	setlocal EnableDelayedExpansion
	for %%g in (%AUTO%) do (
		set "AUTO_Svc=%%g"
		set "AUTO_Svc=!AUTO_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!AUTO_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!AUTO_Svc!" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		sc config "!AUTO_Svc!" start= AUTO >nul 2>&1
	)

	for %%g in (%DEMAND%) do (
		set "DEMAND_Svc=%%g"
		set "DEMAND_Svc=!DEMAND_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!DEMAND_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!DEMAND_Svc!" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
		sc config "!DEMAND_Svc!" start= DEMAND >nul 2>&1
	)

	for %%g in (%DISABLED%) do (
		set "DISABLED_Svc=%%g"
		set "DISABLED_Svc=!DISABLED_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!DISABLED_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!DISABLED_Svc!" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		sc config "!DISABLED_Svc!" start= DISABLED >nul 2>&1
	)
	setlocal DisableDelayedExpansion

REM CldFlt, ClipSVC, InstallService (Cloud files filter driver, Store and Store apps Service,)
		set "More_Services=CldFlt,ClipSVC,InstallService"
		if "%Win_Store%"=="Store_ON" (
			for %%g in (%More_Services%) do (
				reg add "HKLM\SYSTEM\ControlSet001\Services\%%g " /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
				sc config "%%g" start= DEMAND >nul 2>&1
		)) else (
			for %%g in (%More_Services%) do (
				reg add "HKLM\SYSTEM\ControlSet001\Services\%%g " /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
				sc config "%%g" start= DISABLED >nul 2>&1
		))

REM WLan Service
	if "%WLan_Service%"=="Missing" ( exit /b )
	if "%WLan_Service%"=="Enable_WLan_Service" (
		reg add "HKLM\SYSTEM\ControlSet001\Services\WlanSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		sc config "WlanSvc" start= AUTO >nul 2>&1
	) else (
		reg add "HKLM\SYSTEM\ControlSet001\Services\WlanSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		sc config "WlanSvc" start= DISABLED >nul 2>&1
	)
	exit /b

:Services_Optimization_Success
	echo %done%
	echo %hide_cursor%Services optimization task for %blue%%Win_Edition%%yellow% has completed successfully.%white%& echo:
	goto :PAUSE_BEFORE_EXIT

:Services_Optimization_Failed
	echo %hide_cursor%%hide_cursor%%red%%Win_Edition% services optimization task failed.%white%& echo:

:PAUSE_BEFORE_EXIT
	<nul set /p dummyName=Press any key to exit...%show_cursor%
	pause >nul 2>&1
	exit /b

::============================================================================================================
:: Error Messages
::============================================================================================================
:No_Admin
	echo %white%You must have administrator rights to run this script.
	goto :Exit_on_Error

:Inferior_Build
	echo %white%Optimize NextGen can not be run on your system ^(%Win_Edition% build %Build_Number%^).
	goto :Exit_on_Error

:Error_Frankenbuild
	echo %white%Frankenbuilds are not accepted.
	goto :Exit_on_Error

:Error_Edition_Not_Found
	echo We could not find your Windows Edition, the script can not continue.
	goto :Exit_on_Error

:Error_No_Robocopy
	echo Robocopy.exe doesn't exist, the script can not continue.
	goto :Exit_on_Error

:Error_No_User
	echo We could not find your User profile, the script can not continue.
	goto :Exit_on_Error

:LITE_Notice
	echo %hide_cursor%%white%Optimize NextGen was primarily made for LTSC and Windows Server,
	echo and won't ^(yet^) process services optimization in %Win_Edition%.& echo:
	echo It will fully support all W10 editions soon.
	goto :Exit_on_Error
	
:Exit_on_Error
	<nul set /p DummyName=Press any key to exit...
	pause >nul
	exit /b

::============================================================================================================
:Backup_Services
::============================================================================================================
	<nul set /p DummyName=Backing up current services startup configuration...%show_cursor%
	mkdir "%Tmp_Folder%" >nul 2>&1
	mkdir "%~dp0..\..\..\Backup\Services Backup" >nul 2>&1
	cd /d "%~dp0"
REM Create lock file
	echo >lock.tmp
REM Backup services through vbs script, getting services count argument from it
	for /f "delims=" %%i in ('cscript //nologo "%~dp0Cur_services_startup_config_backup.vbs" "iSvc_Cnt"') do ( set "iSvc_Cnt=%%i" )
	echo:
	<nul set /p DummyName=%iSvc_Cnt%
:Wait_for_lock_Cur
	if exist "lock.tmp" goto :Wait_for_lock_Cur
	for /r %%a in (*.reg) do ( set "Cur_Service_Backup_Path=%%~dpna" & set "Cur_Service_Backup_Name=%%~na" )
	call "%~dp0..\..\..\Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)( start=.*)$" "$1$3$4" /m /f "%Cur_Service_Backup_Path%.bat" /o - >nul 2>&1
	call "%~dp0..\..\..\Files\Utilities\JREPL.bat" "(HKEY_LOCAL_MACHINE.*)_(.*)\d(.*)$" "$1$3" /m /f "%Cur_Service_Backup_Path%.reg" /o - >nul 2>&1
 	robocopy "%~dp0..\..\..\Files\Scripts\Services" "%~dp0..\..\..\Backup\Services Backup" *.reg *.bat /Mov /is /it /S /xf "Services Optimization.bat" >nul 2>&1
	echo %hide_cursor%[1A[9D%green%Done.%white%[1B
	echo %yellow%Default services startup configuration saved as "%Cur_Service_Backup_Name%".%white%
	echo:
	goto :eof
