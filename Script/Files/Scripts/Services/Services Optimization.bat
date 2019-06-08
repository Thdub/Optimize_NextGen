@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN
:: Check for TI rights and send to NSudo tasks
%windir%\system32\whoami.exe /USER | find /i "S-1-5-18" 1>NUL && (
goto :Svc_Optimization
) || (
goto :Check_Caption
)

:Check_Caption
:: Check Windows Edition
:: Set Variables
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
	echo %Win_Edition% | findstr /i /c:"Server 2019" >nul && (
	set "Win_Edition=Windows Server 2019"
	goto :START
	) || (
	goto :Services_Optimization_Failed
	)

:START
:: Set window Title
	echo ]0;Optimize %Win_Edition% Services
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to start services optimization task...
	@pause >NUL 2>&1
:: Start process
	cls
	<nul set /p dummyName=Applying complete services optimization with NSudo...
:: Run NSudo from Utilities folder
	"%~dp0..\..\..\Files\Utilities\NSudoG.exe" -U:T -P:E -ShowWindowMode:Hide -wait "%~dpnx0"&& (
	goto :Services_Optimization_Success
	) || (
	goto :Services_Optimization_Failed
	)

:Svc_Optimization
	echo %Win_Edition% | findstr /i /c:"LTSC" >nul && (
	goto :Start_LTSC_Services
	)
	echo %Win_Edition% | findstr /i /c:"Server 2019" >nul && (
	goto :Start_Server_Services
	)

:Start_LTSC_Services
:: Set Services for LTSC
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KtmRm,LicenseManager,lltdsvc,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,"Tib Mounter Service""
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,WlanSvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,"AMD External Events Utility",IAStorDataMgrSvc,"Intel^(R^) Capability Licensing Service TCP IP Interface","Intel^(R^) Security Assist",mmsminisrv,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Start_Server_Services
:: Set Services for Windows Server
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KPSSVC,KtmRm,LicenseManager,lltdsvc,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,"Tib Mounter Service""
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,"AMD External Events Utility",IAStorDataMgrSvc,"Intel^(R^) Capability Licensing Service TCP IP Interface","Intel^(R^) Security Assist",mmsminisrv,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv,WebClient"
goto :Start_Svc_Optimization

:Start_Svc_Optimization
:: Optimize Services
	for %%G in (%AUTO%) do reg query HKLM\SYSTEM\ControlSet001\Services\%%G /v Start 1>NUL 2>NUL && reg add HKLM\SYSTEM\ControlSet001\Services\%%G /v Start /t REG_DWORD /d 2 /f >NUL 2>&1
	for %%G in (%DEMAND%) do reg query HKLM\SYSTEM\ControlSet001\Services\%%G /v Start 1>NUL 2>NUL && reg add HKLM\SYSTEM\ControlSet001\Services\%%G /v Start /t REG_DWORD /d 3 /f >NUL 2>&1
	for %%G in (%DISABLED%) do reg query HKLM\SYSTEM\ControlSet001\Services\%%G /v Start 1>NUL 2>NUL && reg add HKLM\SYSTEM\ControlSet001\Services\%%G /v Start /t REG_DWORD /d 4 /f >NUL 2>&1
	for %%G in (%AUTO%) do sc config %%G start= AUTO >NUL 2>&1
	for %%G in (%DEMAND%) do sc config %%G start= DEMAND >NUL 2>&1
	for %%G in (%DISABLED%) do sc config %%G start= DISABLED >NUL 2>&1
	exit /b

:Services_Optimization_Failed
	echo [91mServices optimization task failed.[97m
	goto :PAUSE_BEFORE_EXIT

:Services_Optimization_Success
	echo [92mDone.[97m
	echo [93m%Win_Edition% services optimization task has completed successfully.[97m
	goto :PAUSE_BEFORE_EXIT

:PAUSE_BEFORE_EXIT
	echo:
	<nul set /p dummyName=Press any key to exit...
	pause >NUL 2>&1
	exit /b

:NOADMIN
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
