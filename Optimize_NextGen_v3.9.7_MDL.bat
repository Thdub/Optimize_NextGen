:: Optimize NextGen v3.9.7
:: Written by Th.Dub @ResonantStep - 2019

@echo off
setlocal disableDelayedExpansion

%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :NOADMIN
%windir%\system32\whoami.exe /USER | find /i "S-1-5-18" 1>nul && goto :NSudo_Tasks

:: Run not defined
	if "%Run%" == "" (
		call :TmpFolder_Check
		set "launchpath=%~x1"
		set "Run=First"
		set "Tmp_Folder=%TEMP%\Optimize_NextGen_%random%.tmp\" )

:: First run
	if "%Run%" == "First" (
		if "%launchpath%" == "" (
			set "launchpath=%~dp0"
			set "Run_With_Arg=%~1"
			robocopy /MIR "%~dp0\" "%Tmp_Folder%\" >nul 2>&1
			goto :FirstRun_Tmp_Folder )

		if "%launchpath%" == ".exe" (
			set "launcher=SFX"
			set "launchpath=%~dp1"
			set "Run_With_Arg=%~2"
			cd /d "%~dp0RarSFX0"
			robocopy /MIR "%~dp0RarSFX0" "%Tmp_Folder%\" >nul 2>&1 )

:FirstRun_Tmp_Folder
		if exist "%Tmp_Folder%Backup\" ( rmdir "%Tmp_Folder%Backup\" /s /q >nul 2>&1 )
	)

:: Not first run
	if not "%Run%" == "First" (
		if "%RestartWindow%" == "Show" ( goto :Restart_Computer )
		if exist "%TEMP%\RarSFX0" ( rmdir "%TEMP%\RarSFX0" /s /q >nul 2>&1 )

:: Resize window keeping buffer size
		call :conSize 151 48 151 9999
		goto :START
	)

::============================================================================================================
:: Set Variables
::============================================================================================================
:: Arguments
	if "%Run_With_Arg%" == "/fast" ( set "FastMode=Unlocked" )
	if "%Run_With_Arg%" == "/full" ( set "FullMode=Unlocked" )
	if "%Run_With_Arg%" == "/secret" ( set "SecretMode=Unlocked" )
	if "%Run_With_Arg%" == "/offline" ( set "SecretMode=Unlocked" & set "OfflineMode=Unlocked" )

:: TitleBar
	set "Shell_Title=[97m]0;Optimize Next Gen v3.9.7[97m"
	set "Shell_Title2=[97m]0;Indexing Options[97m"

:: Tasks
	set "PowerSchemeCreation=PowerSchemeCreation_OFF"
	set "WC_SingleTask=WC_SingleTask_OFF"
	set "Clean=Clean_ON"
	set "PolicyDefinitions=All"
	set "Win_Store=Store_OFF"
	set "Win_Store=Games_OFF"
	set "Restore_GameExplorer=Restore_GameExplorer_OFF"
	for /f "usebackq" %%A in ('wmic path WIN32_NetworkAdapter where 'NetConnectionID="Wi-Fi"' get NetConnectionStatus') do if %%A equ 2 ( set "WLan_Service=Enabled" ) else ( set "WLan_Service=Disabled" )

:: Values
	set "Idx_Tmp_Folder=%TEMP%\Indexing_Options_%random%.tmp"
	set "Idx_lock=%Idx_Tmp_Folder%\wait%random%.lock"
	set "Idx_scriptname=%Idx_Tmp_Folder%\SearchScopeTask.ps1"
	set "SPACE49=                                                 "
	set "STAR47=***********************************************"
	set "stuff=nostuff"
	set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass"
	set "windir=%windir%"

:: Check Windows Build and Edition
	for /f "tokens=2 delims==" %%i in ('wmic os get Caption /value') do ( set "Win_Edition=%%i" )
	for /f "tokens=2 delims==" %%j in ('wmic os get BuildNumber /value') do ( set "BUILD=%%j" )
	if %BUILD% LSS 17763 ( goto :Inferior_Build ) else ( goto :Check_Caption )

:Check_Caption
	echo %Win_Edition% | findstr /i /c:"LTSC" >nul && (
		set "Win_Edition=Windows 10 LTSC"
		set "Win_Edition_Title=Microsoft Windows 10 LTSC"
		goto :First_Run )
	echo %Win_Edition% | findstr /i /c:"Server 2019" >nul && (
		set "Win_Edition=Windows Server 2019"
		set "Win_Edition_Title=Microsoft Windows Server 2019"
		goto :First_Run )
	echo %Win_Edition% | findstr /i /c:"Pro" >nul && (
		set "Win_Edition=Windows 10 Pro"
		set "Win_Edition_Title=Microsoft Windows 10 Pro"
	) || (
		set "Win_Edition=Windows 10"
		set "Win_Edition_Title=Microsoft Windows 10" )
	set "Win_Regular_Edition=Windows 10"
	set "Shell_Title=[97m]0;Optimize Next Gen v3.9.7 LITE[97m"
	echo [?25l[97mOptimize NextGen was primarily made for LTSC and Windows Server,
	echo and won't (yet) process services optimization in %Win_Edition%.& echo:
	echo It will fully support all W10 editions soon.
	<nul set /p DummyName=Going to main menu in a few seconds...[?25h
	timeout /t 8 /nobreak >nul 2>&1
	goto :First_Run

:Inferior_Build
	echo [97mOptimize NextGen can not be run on your system (%Win_Edition% build %BUILD%).
	<nul set /p DummyName=Press any key to exit...
	pause >nul
	exit /b

::============================================================================================================
:First_Run
::============================================================================================================
:: Launch script from temp folder
	if "%Run%" == "First" (
		set "Run=Second"
		if "%SecretMode%" == "Unlocked" (
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Hide "%Tmp_Folder%Optimize_NextGen_v3.9.7_MDL.bat" && exit /b ) else (
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Show "%Tmp_Folder%Optimize_NextGen_v3.9.7_MDL.bat" && exit /b ))

::============================================================================================================
:START
::============================================================================================================
:: Remove Temp Directory
	cd /d "%TEMP%"
	if exist "%TEMP%\SettingsBackup" ( rmdir "SettingsBackup" /s /q >nul 2>&1 )
:: Display title in titlebar
	echo [?25l%Shell_Title%[?25h
	cls
	if "%SecretMode%" == "Unlocked" ( goto :TASK_F_Secret )
	if "%FullMode%" == "Unlocked" ( goto :TASK_1 )
	if "%FastMode%" == "Unlocked" ( goto :TASK_F )
	call :Color_title
	echo:
	echo:
	echo 1. Optimize& echo:
	echo 2. Restore& echo:
	<nul set /p DummyName=Select your option, or 0 to exit: 
	choice /c 120 /n /m "" >nul 2>&1
	if errorlevel 3 ( echo [?25l3& cls & goto :TmpFolder_Remove )
	if errorlevel 2 ( echo [?25l2& cls & goto :Restore_MENU )
	if errorlevel 1 ( echo [?25l1& cls & goto :Optimize_MENU )

::============================================================================================================
:Optimize_MENU
::============================================================================================================
	set "FastMode=Locked"
	set "FullMode=Locked"
	set "SecretMode=Locked"
	echo [?25l%Shell_Title%
	cls
	call :Color_title
	echo:
	echo:
	echo 1. Apply FULL Optimization& echo:
	echo 2. Apply Registry Tweaks and Tasks Settings only& echo:
	echo 3. Apply Group Policy Settings only& echo:
	if "%Win_Regular_Edition%" == "Windows 10" (
	echo [31m4. Apply Services Optimization only[97m& echo: ) else (
	echo 4. Apply Services Optimization only& echo: )
	echo 5. Apply Power Management Settings only& echo:
	echo 6. Enable Write Caching on all Disks& echo:
	echo 7. Optimize System SSD (Send TRIM Request)& echo:
	if "%Win_Edition%" == "Windows Server 2019" (
	echo 8. Optimize Memory Settings ^(Windows Server only^)& echo: ) else (
	echo [31m8. Optimize Memory Settings[97m ^(Windows Server only^)& echo: )
	echo 9. Set Indexing Options& echo:
	echo G. Deactivate [33mG[97mame Explorer& echo:
	echo T. [33mT[97melemetry Task Only& echo:
	echo U. Enable [33mU[97mltimate Performance Power Scheme with Default GUID& echo:
	echo P. [33mP[97mrivacy Task Only& echo:
	echo F. [33mF[97mast Mode: Full Optimization without Prompts and Backups& echo:
	echo E. Clear [33mE[97mvent Viewer Logs& echo:
	echo R. Go to [33mR[97mestore Menu& echo:
	echo 0. Exit[?25h& echo:

	<nul set /p DummyName=Select your option, or 0 to exit: 
	choice /c 123456789GTUPFER0 /n /m "" >nul 2>&1

	if errorlevel 17 ( echo 0[?25l& cls & goto :TmpFolder_Remove )
	if errorlevel 16 ( echo R[?25l& cls & goto :Restore_MENU )
	if errorlevel 15 ( echo E& cls & goto :TASK_E )
	if errorlevel 14 ( echo F[?25l& cls & goto :TASK_F )
	if errorlevel 13 ( echo P& cls & goto :TASK_P )
	if errorlevel 12 ( echo U& cls & goto :TASK_U )
	if errorlevel 11 ( echo T& cls & goto :TASK_T )
	if errorlevel 10 ( echo G& cls & goto :TASK_G )
	if errorlevel 9 ( echo 9& cls & goto :TASK_I )
	if errorlevel 8 ( echo 8& cls & goto :TASK_M )
	if errorlevel 7 ( echo 7& cls & goto :TASK_O )
	if errorlevel 6 ( echo 6[?25l& cls & goto :TASK_W )
	if errorlevel 5 ( echo 5& cls & goto :TASK_5 )
	if errorlevel 4 ( echo 4& cls & goto :TASK_4 )
	if errorlevel 3 ( echo 3& cls & goto :TASK_3 )
	if errorlevel 2 ( echo 2& cls & goto :TASK_2 )
	if errorlevel 1 ( echo 1& cls & goto :TASK_1 )

::============================================================================================================
:Restore_MENU
::============================================================================================================
	set "FastMode=Locked"
	set "FullMode=Locked"
	set "SecretMode=Locked"
	echo [?25l%Shell_Title%
	cls
	call :Color_title
	echo:
	echo:
	echo 1. Remove Registry Tweaks& echo:
	echo 2. Reset Group Policy& echo:
	echo 3. Restore Group Policy from Backup& echo:
	echo 4. Restore Services Start State from Backup& echo:
	if "%Win_Edition%" == "Windows Server 2019" (
	echo 5. Restore Default Memory Settings ^(Windows Server only^)& echo: ) else (
	echo [31m5. Restore Default Memory Settings[97m ^(Windows Server only^)& echo: )
	echo 6. Restore Windows Default Indexed Locations.& echo:
	echo G. Reactivate [33mG[97mame Explorer& echo:
	echo O. Go to [33mO[97mptimize Menu& echo:
	echo 0. Exit[?25h& echo:

	<nul set /p DummyName=Select your option, or 0 to exit: 
	choice /c 123456GO0 /n /m "" >nul 2>&1

		if errorlevel 9 ( echo 9[?25l& cls & goto :TmpFolder_Remove )
		if errorlevel 8 ( echo 7[?25l& cls & goto :Optimize_MENU )
		if errorlevel 7 ( echo G& cls & goto :RTASK_G )
		if errorlevel 6 ( echo 6& cls & goto :RTASK_6 )
		if errorlevel 5 ( echo 5& cls & goto :RTASK_5 )
		if errorlevel 4 ( echo 4& cls & goto :RTASK_4 )
		if errorlevel 3 ( echo 3& cls & goto :RTASK_3 )
		if errorlevel 2 ( echo 2& cls & goto :RTASK_2 )
		if errorlevel 1 ( echo 1& cls & goto :RTASK_1 )

::============================================================================================================
:: Set All Tasks
::============================================================================================================
:TASK_1
	set "FullMode=Unlocked"
	call :Color_title2
	call :Backup_Services1
	call :Backup_GPO
	call :Reset_GPO
	if not "%Win_Edition%" == "Windows Server 2019" ( call :WStore_Check )
	call :Telemetry_Settings
	call :Privacy_Settings
	echo Optimizing performances...
	call :Enable_Ultimate_Performance
	call :Start_Performances_Registry_Tweaks
	call :Performances_1
	call :Performances_2
	call :Performances_3
	call :Performances_4
	call :Power_Management
	call :WriteCaching
	call :Save_PS_Scripts
	call :Tweak_PS_Scripts_Logs
	call :TRIM_Request
	call :MMAgent
	echo [93mPerformances optimization task has completed successfully.[97m& echo:
	echo Starting Group Policy task...
	call :Custom_Policies
	call :Firefox_Policy_Prompt
	call :GP_Update
	call :Save_Registry_Scripts
	call :Save_GPO_Scripts
	call :Save_Services_Scripts
	call :Save_Scripts_Success
	call :Run_NSudo
	if not "%Win_Regular_Edition%" == "Windows 10" ( call :Backup_Services_After_Optimization )
	<nul set /p DummyName=Do you want to set indexing options? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 echo [31mAborted[97m& goto :IndexingOptions_End
	if errorlevel 1 echo [92mYes[97m
	<nul set /p DummyName=Select option:
	call :Indexing_Options
	:IndexingOptions_End
	echo:
	<nul set /p DummyName=Fix EventLog cosmetic errors? [Y/N][?25h
	choice /c YN >nul 2>&1
	if errorlevel 2 echo [31mAborted[97m& goto :EventLog_TaskEnd
	if errorlevel 1 call :EventLog_Cosmetics
	:EventLog_TaskEnd
	echo:
	call :Game_Explorer
	if not "%Win_Store%" == "Store_ON" ( echo: )
	call :Save_All_Settings
	call :Cleaning
	goto :Restart_Warning

:TASK_2
	call :Color_title2
	if not "%Win_Edition%" == "Windows Server 2019" ( call :WStore_Check )
	call :Telemetry_Settings
	call :Privacy_Settings
	echo Optimizing performances...
	call :Start_Performances_Registry_Tweaks
	call :Performances_1
	call :Performances_2
	call :Performances_3
	call :Performances_4
	echo [93mPerformances registry settings task has completed successfully.[97m& echo:
	call :Save_Registry_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	goto :RETURN_TO_MAIN_MENU

:TASK_3
	call :Color_title2
	call :Backup_GPO
	call :Reset_GPO
	if not "%Win_Edition%" == "Windows Server 2019" ( call :WStore_Check )
	echo Starting Group Policy task...[100X
	call :Custom_Policies
	call :Firefox_Policy_Prompt
	call :GP_Update
	<nul set /p DummyName=Saving scripts for restore purpose...
	call :Save_GPO_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	goto :RETURN_TO_MAIN_MENU

:TASK_4
	call :Color_title2
	if "%Win_Edition%" == "Windows 10" ( echo Services Optimization can not be run ^(yet^) on regular Windows 10 editions.& goto :RETURN_TO_OPT_MENU )
	if "%Win_Edition%" == "Windows 10 Pro" ( echo Services Optimization can not be run ^(yet^) on %Win_Edition%.& goto :RETURN_TO_OPT_MENU )
	call :Backup_Services1
	call :Run_NSudo
	call :Backup_Services_After_Optimization
	<nul set /p DummyName=Saving scripts for restore purpose...
	call :Save_Services_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	goto :RETURN_TO_MAIN_MENU

:TASK_5
	call :Color_title2
	echo Applying power management settings...
	call :Enable_Ultimate_Performance
	call :Start_Performances_Registry_Tweaks
	call :Power_1
	call :Power_2
	echo [92mDone.[97m
	<nul set /p DummyName=[5CAdditional tweaks: 
	call :Power_3
	echo [92mDone.[97m
	call :Power_Management
	echo %Shell_Title%[1A
	robocopy /MIR "%Tmp_Folder%Files\Scripts\PowerManagement" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement" >nul 2>&1
	cd /d "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement"
	call :Tweak_PSscripts
	call :Tweak_PS_Scripts_Logs
	call :Save_Before_End
	echo [93mPower Management settings optimization task has completed successfully.[97m& echo:
	goto :Restart_Warning_2

:TASK_W
	set "WC_SingleTask=WC_SingleTask_ON"
	call :Color_title2
	echo Enabling Write Caching on all disks...
	call :WriteCaching_SingleTask
	robocopy /MIR "%Tmp_Folder%Files\Scripts\WriteCaching" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching" >nul 2>&1
	cd /d "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching"
	call :Tweak_PSscripts
	call :Save_Before_End
	goto :Restart_Information

:TASK_O
	call :Color_title2
	<nul set /p DummyName=Checking first if "C:" drive is a SSD...
	for /f %%a in ('Powershell "Get-PhysicalDisk | Where DeviceID -EQ 0 | Select MediaType" ^| findstr /i /c:SSD') do ( if "%%a" == "SSD" (
		echo [92mDone.[97m
		<nul set /p DummyName=Sending TRIM request to system SSD...
		call :TRIM_Command ) else (
			echo [92mDone.[97m
			echo [93mSystem drive is not a SSD, task canceled.[97m ))
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_M
	call :Color_title2
	if not "%Win_Edition%" == "Windows Server 2019" (
		echo This settings can only be applied on Windows Server.
		goto :RETURN_TO_OPT_MENU )
	<nul set /p DummyName=Enabling MemoryCompression and PageCombining: 
	call :MemoryCompression_Enable
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_G
	set "Win_Store=Store_OFF"
	call :Color_title2
	call :Game_Explorer_Task
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_T
	call :Color_title2
	call :Telemetry_Settings
	goto :RETURN_TO_MAIN_MENU

:TASK_U
	call :Color_title2
	<nul set /p DummyName=Enabling Ultimate Performance PowerScheme: 
	call :Enable_Ultimate_Performance_START
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_P
	call :Color_title2
	call :Privacy_Settings
	goto :RETURN_TO_MAIN_MENU

:TASK_I
	echo %Shell_Title2%
	cls
	call :Color_title2
	echo: & echo:
	call :Indexing_Options
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_F
	set "FastMode=Unlocked"
	set "Network=OFF"
	cd /d "%Tmp_Folder%"
:: Create Lock file
	echo >Lock.tmp
:: Create script that will be launched simultaneously to release prompt when Lock file is deleted
	@echo @echo off >"%Tmp_Folder%Lock.bat"
	@echo :loop_1 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) >>"%Tmp_Folder%Lock.bat"
	@echo "%Tmp_Folder%Files\Utilities\GetKey.exe" /N >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 48 ^( @echo ^>"%%Tmp_Folder%%Lock_ZERO.tmp" ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 0 ^( goto :loop_1 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :loop_2 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) else ^( del /F /Q /S "%Tmp_Folder%Lock.tmp" ^>nul ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :finish >>"%Tmp_Folder%Lock.bat"
	@echo ^(goto^) 2^>nul ^& del /F /Q /S "%%~f0" ^>nul 2^>^&1 >>"%Tmp_Folder%Lock.bat"
:: Prompt and get key
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	echo [93mNote: [97mIn fast mode no backup is made, and there are no options/choices offered like in full mode.&echo [6CDefault settings are geared towards maximum performances.&echo:
	echo Fast mode defaults:& echo [2C-Group Policy security settings are reset.& echo [2C-Firefox Policy Template is imported.& echo [2C-Indexed locations are set to Windows Start Menus only.& echo [2C-Microsoft Store and Store apps are disabled.
	if not "%Win_Regular_Edition%" == "Windows 10" ( echo [2C-File and Printer Sharing services are disabled.& echo [2C-Wireless Lan service will also be automatically disabled if you are not currently connected to any Wi-Fi Network. )
	echo:
	<nul set /p DummyName=Press any key to proceed, or 0 to return to Optimize menu.[?25h

:Lock1_CheckLoop
	if exist "%Tmp_Folder%Lock.tmp" ( goto :Lock1_CheckLoop )
	if exist "%Tmp_Folder%Lock_ZERO.tmp" (
		call :Lock_ZERO_Delete_Loop
		goto :Optimize_MENU )
	cls
	call :Color_title2
	call :Reset_GPO
	call :Telemetry_Settings
	call :Privacy_Settings
	echo Optimizing performances...
	call :Enable_Ultimate_Performance
	call :Start_Performances_Registry_Tweaks
	call :Performances_1
	call :Performances_2
	call :Performances_3
	call :Performances_4
	call :Power_Management
	call :WriteCaching
	call :MMAgent
	echo [93mPerformances optimization task has completed successfully.[97m& echo:
	echo Starting Group Policy task...
	call :Custom_Policies
	call :Firefox_Policy_Template
	call :GP_Update
	call :Run_NSudo
	if not "%Win_Regular_Edition%" == "Windows 10" (
		if "%WLan_Service%" == "Disabled" ( echo [93mNote:[97m You are not connected to any Wi-Fi network, Wlan service will be disabled. )
		echo [93mNote:[97m File and Printer Sharing services are disabled by default in fast mode.
		call :Apply_NSudo
		echo: )
	set "Style=startmenus"
	call :Indexing_Options_Task
	echo:
	<nul set /p DummyName=Fixing Event Viewer logs errors...[?25h
	call :EventLog_Cosmetics
::	Game Explorer task is bypassed for now
::	echo:
::	call :Game_Explorer
	call :Cleaning
	goto :Restart_Warning

:TASK_F_Secret
	set "FastMode=Unlocked"
	set "Network=OFF"
	set "Style=startmenus"
	call :Reset_GPO
	call :Telemetry_Settings
	call :Privacy_Settings
	call :Enable_Ultimate_Performance
	call :Start_Performances_Registry_Tweaks
	call :Performances_1
	call :Performances_2
	call :Performances_3
	call :Performances_4
	call :Power_Management
	call :WriteCaching
	call :MMAgent
	call :Custom_Policies
	call :Firefox_Policy_Template
	call :GP_Update
	call :Run_NSudo
	call :Apply_NSudo
	call :Indexing_Options_Task
	call :EventLog_Cosmetics
::	Game Explorer task is bypassed for now
::	call :Game_Explorer
	call :Cleaning
	goto :Restart_Computer

:TASK_E
	call :Color_title2
	call :Clear_EventViewer_Logs
	goto :RETURN_TO_MAIN_MENU

:RTASK_1
	call :Color_title2
	call :Remove_Tweaks
	call :Save_Registry_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	call :GPO_Redundant_Settings
	goto :RETURN_TO_MAIN_MENU

:RTASK_2
	call :Color_title2
:RTASK_2notitle
	call :Backup_GPO
	call :Reset_GPO
	call :Custom_Policies_Preferences_Remove
	call :GP_Update
	call :Save_Before_End
	echo [97mYour Group Policy settings have been reset.
	goto :Restart_Information

:RTASK_3
	call :Color_title2
	call :Restore_GPO
	call :GP_Update
	echo [97mYour Group Policy settings have been restored.
	goto :Restart_Information

:RTASK_4
	call :Color_title2
	call :Restore_Services
	goto :RETURN_TO_MAIN_MENU

:RTASK_5
	if not "%Win_Edition%" == "Windows Server 2019" (
		call :Color_title
		echo This settings can only be applied on Windows Server.& echo:
		<nul set /p DummyName=Press any key to return to Restore menu...[?25h
		pause >nul
		goto :Restore_MENU )
	call :Color_title2
	<nul set /p DummyName=Disabling MemoryCompression and PageCombining: 
	call :MemoryCompression_Disable
	echo:
	goto :RETURN_TO_MAIN_MENU

:RTASK_6
	call :Color_title2
	set "Style=default"
	call :Indexing_Options_Task
	echo:
	goto :RETURN_TO_MAIN_MENU

:RTASK_G
	call :Color_title2
	call :Game_Explorer_Restore
	goto :RETURN_TO_MAIN_MENU

::============================================================================================================
:Color_title
::============================================================================================================
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE49%[97m****%STAR47% ) else (
		if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE49%[97m****%STAR47% ) else ( echo %SPACE49%[97m%STAR47% ))
	if "%Win_Regular_Edition%" == "Windows 10" ( echo %SPACE49%Optimize Next Gen LITE for %Win_Edition_Title% ) else ( echo %SPACE49%Optimize Next Gen for %Win_Edition_Title% )
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE49%****%STAR47% ) else (
		if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE49%****%STAR47% ) else ( echo %SPACE49%%STAR47% ))
	echo:
	goto :eof

::============================================================================================================
:Color_title2
::============================================================================================================
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE49%[93m****%STAR47% ) else (
		if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE49%[93m****%STAR47% ) else ( echo %SPACE49%[93m%STAR47% ))
	if "%Win_Regular_Edition%" == "Windows 10" ( echo %SPACE49%Optimize Next Gen LITE for %Win_Edition_Title% ) else ( echo %SPACE49%Optimize Next Gen for %Win_Edition_Title% )
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE49%****%STAR47%[97m ) else (
		if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE49%****%STAR47%[97m ) else ( echo %SPACE49%%STAR47%[97m ))
	echo:
	goto :eof

::============================================================================================================
:Backup_Services1
::============================================================================================================
	<nul set /p DummyName=Backing up current services startup configuration...[?25h
	cd /d "%Tmp_Folder%Files\Scripts\Services"
:: Create lock file
	echo >lock.tmp
:: Backup services through vbs script, getting services count argument from it
	for /f "delims=" %%i in ('cscript //nologo "%Tmp_Folder%Files\Scripts\Services\Cur_services_startup_config_backup.vbs" "iSvc_Cnt"') do Set "iSvc_Cnt=%%i"
	echo:
	<nul set /p DummyName=%iSvc_Cnt%
:Wait_for_lock_Cur
	if exist "lock.tmp" goto :Wait_for_lock_Cur
	for /r %%a in (*.reg) do ( set "Cur_Service_Backup_Path=%%~dpna" & set "Cur_Service_Backup_Name=%%~na" )
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)( start=.*)$" "$1$3$4" /m /f "%Cur_Service_Backup_Path%.bat" /o - >nul 2>&1
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(HKEY_LOCAL_MACHINE.*)_(.*)\d(.*)$" "$1$3" /m /f "%Cur_Service_Backup_Path%.reg" /o - >nul 2>&1
 	robocopy "%Tmp_Folder%Files\Scripts\Services" "%TEMP%\SettingsBackup\Services Backup" *.reg *.bat /Mov /is /it /S /xf "Services Optimization.bat" >nul 2>&1
	echo [1A[9D[92mDone.[97m[1B
	echo [93mDefault services startup configuration saved as "%Cur_Service_Backup_Name%".[97m& echo:
	goto :eof

::============================================================================================================
:Backup_GPO
::============================================================================================================
	cd /d "%TEMP%"
	<nul set /p DummyName=Backing up current Group Policy...
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\Current GPO\LGPO" >nul 2>&1
:: Remove folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
:: Copy policy files
	robocopy "%windir%\system32\GroupPolicy" "%TEMP%\SettingsBackup\GroupPolicy Backup\Current GPO\GroupPolicy" *.pol /is /it /S >nul 2>&1
:: Export GPO with LGPO
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /b "%TEMP%\SettingsBackup\GroupPolicy Backup\Current GPO\LGPO" /n LGPO >nul 2>&1
:: Export Group Policy Security Settings
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings" >nul 2>&1
	if exist "%launchpath%Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" (
		move /y "%launchpath%Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings\securityconfig.bak" >nul 2>&1 )
	secedit /export /cfg "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings\securityconfig.cfg" >nul 2>&1
:: Force rename policy files to .bak as an additional safety measure
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >nul 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >nul 2>&1
	echo [92mDone.[97m
	echo:
	goto :eof

::============================================================================================================
:Reset_GPO
::============================================================================================================
	<nul set /p DummyName=Resetting Group Policy...[?25h
	del /F /Q /S "%windir%\system32\GroupPolicy\User\registry.pol" >nul 2>&1
	del /F /Q /S "%windir%\system32\GroupPolicy\Machine\registry.pol" >nul 2>&1
	echo [92mDone.[97m
	if "%FastMode%" == "Unlocked" (
		echo Resetting Group Policy Security Settings...
		goto :Reset_GPO_Task )
	<nul set /p DummyName=Do you want to reset your Group Policy Security Settings as well? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mAborted[97m& echo: & goto :eof )
	echo [92mYes[97m
:Reset_GPO_Task
	if not exist "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings" mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings" >nul 2>&1
	cd /d "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings"
:: Full GPO reset
	secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb
	if "%FastMode%" == "Unlocked" (
		echo [4A[43C[93mThe task has completed.[97m& echo:
		goto :eof )
	echo [3A[93mThe task has completed.[97m
	echo: [140X
	goto :eof

::============================================================================================================
:: Registry Tweaks
::============================================================================================================
:Telemetry_Settings
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
	<nul set /p DummyName=[2C-Tasks: 
:: Disable Tasks
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
	if not "%Win_Games%" == "Games_ON" (
		schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable >nul 2>&1
		schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable >nul 2>&1 )
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
	<nul set /p DummyName=[2C-Office Tasks: 
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
	<nul set /p DummyName=[2C-Office Registry: 
	reg add HKCU\Software\Microsoft\Office\Common\ClientTelemetry /v DisableTelemetry /t REG_DWORD /d "1" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\Feedback /v enabled /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\Feedback /v includescreenshot /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Outlook\Options\Mail /v EnableLogging /t REG_DWORD /d "0" /f >nul 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Word\Options /v EnableLogging /t REG_DWORD /d "0" /f >nul 2>&1
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
	echo [93mTelemetry blocking task has completed successfully.[97m& echo:
	goto :eof

::============================================================================================================
:Privacy_Settings
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
		reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1 )
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
:: Ads
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
		reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1 )
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
	if not "%Win_Games%" == "Games_ON" ( reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1 )
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
:: Disable web search
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
	call :Miscellaneous
	echo [93mPrivacy settings task has completed successfully.[97m& echo:
	goto :eof

::============================================================================================================
:Miscellaneous
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
		reg add "HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f >nul 2>&1 )
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
	goto :eof

::============================================================================================================
:: Performances Settings
::============================================================================================================
:Enable_Ultimate_Performance
	<nul set /p DummyName=[2C-Enabling Ultimate Performance PowerScheme: 
:Enable_Ultimate_Performance_START
	set "PowerSchemeCreation=PowerSchemeCreation_OFF"
	powercfg /S e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
	if errorlevel 1 ( goto :Creat_PwrScheme ) else ( goto :Ultimate_Performance_Success )

:Creat_PwrScheme
	powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
	for /f "tokens=4" %%f in ('powercfg -list ^| findstr /c:"Ultimate Performance"') do set "GUID=%%f"
	powercfg /S %GUID% >nul 2>&1
	set "PowerSchemeCreation=PowerSchemeCreation_ON"
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -ShowWindowMode:Hide -wait "%~dpnx0"&& ( goto :Enable_Ultimate_Performance_START )

:GUID_Trick
:: Ultimate Performance Registry
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "Description" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-18,Provides ultimate performance on higher end PCs." /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "FriendlyName" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-19,Ultimate Performance" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "DCSettingIndex" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "DCSettingIndex" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes" /v "ActivePowerScheme" /t REG_SZ /d "e9a42b02-d5df-448d-aa00-03f14749eb61" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "Description" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-18,Provides ultimate performance on higher end PCs." /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "FriendlyName" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-19,Ultimate Performance" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "DCSettingIndex" /t REG_DWORD /d "1800" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\9d7815a6-7ee4-497e-8888-515a05f02364" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\9d7815a6-7ee4-497e-8888-515a05f02364" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "DCSettingIndex" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\2a737441-1930-4402-8d77-b2bebba308a3\48e6b7a6-50f5-4782-a5d4-53bb8f07e226" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\5ca83367-6e45-459f-a27b-476b1d01c936" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\5ca83367-6e45-459f-a27b-476b1d01c936" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\7648efa3-dd9c-4e3e-b566-50f929386280" /v "DCSettingIndex" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\96996bc0-ad50-47ec-923b-6f41874dd9eb" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\54533251-82be-4824-96c1-47b60b740d00" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\7516b95f-f776-4464-8c53-06167f40cc99\3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\7516b95f-f776-4464-8c53-06167f40cc99\3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e" /v "DCSettingIndex" /t REG_DWORD /d "900" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\637ea02f-bbcb-4015-8e2c-a1c7b9c0b546" /v "ACSettingIndex" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\637ea02f-bbcb-4015-8e2c-a1c7b9c0b546" /v "DCSettingIndex" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\8183ba9a-e910-48da-8769-14ae6dc1170a" /v "ACSettingIndex" /t REG_DWORD /d "10" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\8183ba9a-e910-48da-8769-14ae6dc1170a" /v "DCSettingIndex" /t REG_DWORD /d "10" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469" /v "ACSettingIndex" /t REG_DWORD /d "5" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469" /v "DCSettingIndex" /t REG_DWORD /d "5" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\bcded951-187b-4d05-bccc-f7e51960c258" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\bcded951-187b-4d05-bccc-f7e51960c258" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\d8742dcb-3e6a-4b3c-b3fe-374623cdcf06" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\d8742dcb-3e6a-4b3c-b3fe-374623cdcf06" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1

:: Delete GUID
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\%GUID%" /f >nul 2>&1
	exit /b

:Ultimate_Performance_Success
	echo [92mDone.[97m
	goto :eof

:Start_Performances_Registry_Tweaks
	echo   -Registry settings:
	<nul set /p DummyName=[5CPreferences already present in Group Policy: 
	goto :eof

:Performances_1
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
	goto :eof

:Performances_2
:: Domain password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >nul 2>&1

:Power_2
:: Turn off Power Throttling
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1
	goto :eof

:Performances_3
:: Disable Windows Scaling Heuristics
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t REG_DWORD /d "0" /f >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[5CAdditional tweaks: 
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
:: Disable ALT+CTRL+DEL on startup (Windows Server)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /t REG_DWORD /d "1" /f >nul 2>&1

:DisableCAD_Skipped
:: Prevent creation of Microsoft Account
	if not "%Win_Store%" == "Store_ON" ( reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoConnectedUser" /t REG_DWORD /d "1" /f >nul 2>&1 )
:: Hide Insider page
	reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f >nul 2>&1

:Power_3
:: Disable hibernation and fast start (best setting for SSD)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	goto :eof

:Performances_4
:: Kill CreateExplorerShellUnelevatedTask in task scheduler
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
	echo [92mDone.[97m
	goto :eof

::============================================================================================================
:: Disable Power Management
::============================================================================================================
:Power_Management
	echo   -Power Management:
:: Disable "allow the computer to turn off this device to save power" for HID Devices under PowerManagement tab in Device Manager
	<nul set /p DummyName=[5CDisabling "Allow the computer to turn off this device to save power" for HID Devices under Power Management tab in Device Manager: 
	setlocal EnableExtensions DisableDelayedExpansion
	set "DetectionCount=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendOn" /t REG_DWORD') do call :ProcessLine "%%i"
	if not %DetectionCount% == 0 ( endlocal & goto :SelectiveSuspend_part2 )

:ProcessLine
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendOn" /t REG_DWORD /d "0" /f >nul 2>&1
	set /A DetectionCount+=1
	goto :eof

:SelectiveSuspend_part2
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection2_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "EnableSelectiveSuspend" /t REG_DWORD') do call :ProcessLine2 "%%i"
	if not %Detection2_Count% == 0 ( endlocal & goto :SelectiveSuspend_part3 )

:ProcessLine2
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "EnableSelectiveSuspend" /t REG_DWORD /d "0" /f >nul 2>&1
	set /A Detection2_Count+=1
	goto :eof

:SelectiveSuspend_part3
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection3_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendEnabled" /t REG_DWORD') do call :ProcessLine3 "%%i"
	if not %Detection3_Count% == 0 ( endlocal & goto :SelectiveSuspend_part4 )

:ProcessLine3
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
	set /A Detection3_Count+=1
	goto :eof

:SelectiveSuspend_part4
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection4_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendEnabled" /t REG_BINARY') do call :ProcessLine4 "%%i"
	if not %Detection4_Count% == 0 ( endlocal & goto :SelectiveSuspend_part5 )

:ProcessLine4
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendEnabled" /t REG_BINARY /d "00" /f >nul 2>&1
	set /A Detection4_Count+=1
	goto :eof

:SelectiveSuspend_part5
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection5_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "DeviceSelectiveSuspended" /t REG_DWORD') do call :ProcessLine5 "%%i"
	if not %Detection5_Count% == 0 ( echo [92mDone.[97m& endlocal & goto :SelectiveSuspend_Scripts )

:ProcessLine5
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f >nul 2>&1
	set /A Detection5_Count+=1
	goto :eof

:SelectiveSuspend_Scripts
:: Disable "allow the computer to turn off this device to save power" for USBHub under PowerManagement tab in Device Manager
	<nul set /p DummyName=[5CDisabling "Allow the computer to turn off this device to save power" for USB Hubs under Power Management tab in Device Manager: 
	%PScommand% -File "%Tmp_Folder%Files\Scripts\PowerManagement\PowerManagementUSB.ps1" >nul 2>&1
	echo [92mDone.[97m

:: Disable "allow the computer to turn off this device to save power" for Network Adapters under PowerManagement tab in Device Manager
	echo [5CDisabling "Allow the computer to turn off this device to save power" for Network Adapters under Power Management tab in Device Manager...[?25l
	%PScommand% -File "%Tmp_Folder%Files\Scripts\PowerManagement\PowerManagementNIC.ps1"
	echo [5C[92mDone.[97m Please reboot the machine for the changes to take effect.[?25h
	goto :eof

::============================================================================================================
:WriteCaching
::============================================================================================================
	<nul set /p DummyName=[2C-Enabling Write Caching on all disks: 
:WriteCaching_SingleTask
	cd /d "%Tmp_Folder%Files\Scripts\WriteCaching"
	if "%WC_SingleTask%" == "WC_SingleTask_OFF" (
		%PScommand% ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME" >nul 2>&1 ) else (
			%PScommand% ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME" )
	if "%WC_SingleTask%" == "WC_SingleTask_OFF" ( echo [92mDone.[97m ) else ( echo [?25h[11A[12C[92mDone.[97m[11B )
	set "WC_SingleTask=WC_SingleTask_OFF"
	cd /d "%TEMP%"
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:Save_PS_Scripts
::============================================================================================================
	robocopy /MIR "%Tmp_Folder%Files\Scripts\WriteCaching" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching" >nul 2>&1
	robocopy /MIR "%Tmp_Folder%Files\Scripts\PowerManagement" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement" >nul 2>&1
	cd /d "%Temp%\SettingsBackup\Scripts (Restore or Apply again)"
	call :Tweak_PSscripts
	goto :eof

:Tweak_PSscripts
:: Change log path to script folder
	for /r %%a in (*.ps1) do ( call "%Tmp_Folder%Files\Utilities\JREPL.bat" "Start-Transcript -Path(.*)env(.*)Logs(.*)" "Start-Transcript -Path$1PSScriptRoot$3" /m /f "%%a" /o - )
	cd /d "%TEMP%"
	goto :eof

:Tweak_PS_Scripts_Logs
:: Just cosmetic
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" ":\r\n" ": " /m /f "%TEMP%\SettingsBackup\Logs\PowerManagementNIC.log" /o -
	goto :eof

::============================================================================================================
:TRIM_Request
::============================================================================================================
	<nul set /p DummyName=[2C-SSD optimization: Checking first if "C:" drive is a SSD...
	for /f %%a in ('Powershell "Get-PhysicalDisk | Where DeviceID -EQ 0 | Select MediaType" ^| findstr /i /c:SSD') do ( if "%%a" == "SSD" ( goto :TRIM_Choice ) else (
		echo [93mSystem drive is not a SSD.[97m
		goto :TRIM_Task_End ))
:TRIM_Choice
	echo [93mYour system drive is a SSD.[97m
	<nul set /p DummyName=[3CDo you want to optimize your drive (send TRIM request)? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mAborted[97m& goto :TRIM_Task_End )
	if errorlevel 1 ( echo [92mYes[97m& (
		<nul set /p DummyName=[5CSending TRIM request to system SSD ^(Optimize^)...
		goto :TRIM_Command ))
:TRIM_Command
	%PScommand% "Optimize-Volume -DriveLetter C -ReTrim" >nul 2>&1
	echo [92mDone.[97m

:TRIM_Task_End
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:MMAgent
::============================================================================================================
	if not "%Win_Edition%" == "Windows Server 2019" ( goto :eof )
	<nul set /p DummyName=[2C-Enabling MemoryCompression and PageCombining: 

:MemoryCompression_Enable
	for /f "tokens=3 delims= " %%a in ('Powershell Get-MMAgent ^| findstr /i /c:"MemoryCompression"') do ( if "%%a" == "True" ( goto :PageCombining_Enable ))
	%PScommand% "Enable-MMAgent -MemoryCompression" >nul 2>&1

:PageCombining_Enable
	for /f "tokens=3 delims= " %%a in ('Powershell Get-MMAgent ^| findstr /i /c:"PageCombining"') do ( if "%%a" == "True" ( goto :MMAgent_End ))
	%PScommand% "Enable-MMAgent -PageCombining" >nul 2>&1
	goto :MMAgent_End

:MemoryCompression_Disable
	for /f "tokens=3 delims= " %%a in ('Powershell Get-MMAgent ^| findstr /i /c:"MemoryCompression"') do ( if "%%a" == "False" ( goto :PageCombining_Disable ))
	%PScommand% "Disable-MMAgent -MemoryCompression" >nul 2>&1

:PageCombining_Disable
	for /f "tokens=3 delims= " %%a in ('Powershell Get-MMAgent ^| findstr /i /c:"PageCombining"') do ( if "%%a" == "False" ( goto :MMAgent_End ))
	%PScommand% "Disable-MMAgent -PageCombining" >nul 2>&1
	goto :MMAgent_End

:MMAgent_End
	echo [92mDone.[97m
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:: Import firefox and custom policy sets, create .pol files from parsed lgpo text and import new group policy
::============================================================================================================
:Custom_Policies
	<nul set /p DummyName=[2C-Importing Custom Policies Set to "PolicyDefinitions" folder: 
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" CustomPolicies.admx CustomPolicies.adml /is /it /S >nul 2>&1
	echo [92mDone.[97m
	goto :eof

:Firefox_Policy_Prompt
	<nul set /p DummyName=[3CDo you want to add Firefox Policy Template and related Group Policy settings as well? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 (
		echo [31mAborted[97m
		goto :Start_LGPO_No_Firefox )
	echo [92mYes[97m

:Firefox_Policy_Template
	<nul set /p DummyName=[2C-Importing Firefox Policy Template to "PolicyDefinitions" folder: 
:: Get OS Language
	for /f "tokens=2 delims==" %%a in ('wmic os get OSLanguage /Value') do set OSLanguage=%%a
	if "%OSLanguage%" == "1031" (
		robocopy /MIR "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\de-DE" "%windir%\PolicyDefinitions\de-DE" >nul 2>&1
		goto :Firefox_Policy_Template_End )
	if "%OSLanguage%" == "1034" (
		robocopy /MIR "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\es-ES" "%windir%\PolicyDefinitions\es-ES" >nul 2>&1
		goto :Firefox_Policy_Template_End )
	if "%OSLanguage%" == "1036" (
		robocopy /MIR "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\fr-FR" "%windir%\PolicyDefinitions\fr-FR" >nul 2>&1
		goto :Firefox_Policy_Template_End )
	if "%OSLanguage%" == "1040" (
		robocopy /MIR "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\it-IT" "%windir%\PolicyDefinitions\it-IT" >nul 2>&1
		goto :Firefox_Policy_Template_End )
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\en-US" "%windir%\PolicyDefinitions\en-US" firefox.adml mozilla.adml /is /it /S >nul 2>&1
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" firefox.admx mozilla.admx /is /it /S >nul 2>&1

:Firefox_Policy_Template_End
	echo [92mDone.[97m

:Start_LGPO
	<nul set /p DummyName=[2C-Creating registry.pol files from parsed LGPO text: 
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine" "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User" >nul 2>&1
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\User_MDL.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User\registry.pol" >nul 2>&1
:: Check Windows edition
	if not "%Win_Edition%" == "Windows Server 2019" ( goto :LTSC_LGPO ) else ( goto :SERVER_LGPO )

:LTSC_LGPO
	if not "%Win_Store%" == "Store_ON" (
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\LTSC_Machine.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\LTSC_Machine_ST.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 )
	goto :LGPO_SUCCESS

:SERVER_LGPO
	if not "%Win_Store%" == "Store_ON" (
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Machine.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Machine_ST.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 )
	goto :LGPO_SUCCESS

:Start_LGPO_No_Firefox
	<nul set /p DummyName=[2C-Creating registry.pol files from parsed LGPO text: 
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine" "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User" >nul 2>&1
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\User_MDL.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User\registry.pol" >nul 2>&1
:: Check Windows edition
	if not "%Win_Edition%" == "Windows Server 2019" ( goto :LTSC_LGPO_No_Firefox ) else ( goto :SERVER_LGPO_No_Firefox )

:LTSC_LGPO_No_Firefox
	if not "%Win_Store%" == "Store_ON" (
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\LTSC_Machine_NF.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\LTSC_Machine_NF_ST.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 )
	goto :LGPO_SUCCESS

:SERVER_LGPO_No_Firefox
	if not "%Win_Store%" == "Store_ON" (
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Machine_NF.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Machine_NF_ST.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >nul 2>&1 )
	goto :LGPO_SUCCESS

:LGPO_SUCCESS
	echo [92mDone.[93m %Win_Edition% policy files successfully created.[97m
:: Import_New_GPO
	<nul set /p DummyName=[2C-Importing new Group Policy: 
	robocopy "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[2C-Importing Group Policy Security Settings: 
	%PScommand% "Add-Content -Path "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" -Value ',%USERNAME%'" >nul 2>&1
:: Password policy
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" /areas SECURITYPOLICY >nul 2>&1
:: Delegation rights
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" /areas USER_RIGHTS >nul 2>&1
	echo [92mDone.[97m
	echo [93mGroup Policy task has completed successfully.[97m
	echo %Shell_Title%
	goto :eof

::============================================================================================================
:GP_Update
::============================================================================================================
	<nul set /p DummyName=Updating Group Policy...[140X
	GPUpdate /Force >nul 2>&1
	echo [92mDone.[97m
	echo:
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	goto :eof

::============================================================================================================
:: Save Scripts
::============================================================================================================
:Save_Registry_Scripts
	<nul set /p DummyName=Saving scripts for restore purpose...
	mkdir "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Registry Tweaks" >nul 2>&1
	mkdir "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\ScheduledTasks" >nul 2>&1
	robocopy /MIR "%Tmp_Folder%Files\Scripts\RegistryTweaks" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Registry Tweaks" >nul 2>&1
	robocopy /MIR "%Tmp_Folder%Files\Scripts\ScheduledTasks" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\ScheduledTasks" >nul 2>&1
	goto :eof

:Save_GPO_Scripts
	robocopy /MIR "%Tmp_Folder%Files\Scripts\GroupPolicy" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Group Policy" >nul 2>&1
	goto :eof

:Save_Services_Scripts
	robocopy /MIR "%Tmp_Folder%Files\Scripts\Services" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Services" >nul 2>&1
	goto :eof

:Save_Scripts_Success
	echo [93mScripts successfully saved.[97m
	echo:
	goto :eof

::============================================================================================================
:: Services Optimization
::============================================================================================================
:Run_NSudo
	if "%Win_Regular_Edition%" == "Windows 10" ( echo Services optimization task...[31mSkipped[97m^ (not available yet on Windows 10 regular editions^).& echo: & goto :eof )

	echo Starting services optimization task...
	sc query WlanSvc >nul
	if errorlevel 1060 (
		set "WLan_Service=Missing"
		if "%FastMode%" == "Unlocked" ( goto :eof ) else ( goto :Printer_Sharing_Choice ))

	if "%FastMode%" == "Unlocked" ( goto :eof )

	if "%WLan_Service%" == "Disabled" (
		<nul set /p DummyName=[93mNote:[97m You are not connected to any Wi-Fi network, do you want to disable Wlan Service? [Y/N] (Press Y if you don't use wifi)
		choice /c YN >nul 2>&1
		if errorlevel 2 ( echo [31mNo[97m && set "WLan_Service=Enabled" )
		if errorlevel 1 ( echo [92mYes[97m && set "WLan_Service=Disabled" ))

:Printer_Sharing_Choice
	<nul set /p DummyName=(E)nable or (D)isable File and Printer Sharing? [E/D] (Press D if you don't have home network and/or network printer)
	choice /c DE >nul 2>&1
	if errorlevel 2 (
		echo [92mEnable[97m
		set "Network=ON"
		goto :Apply_Nsudo )
	set "Network=OFF"
	echo [31mDisable[97m

:Apply_Nsudo
	<nul set /p DummyName=Applying complete services optimization with NSudo...
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -Wait -UseCurrentConsole "%~dpnx0"&& ( goto :eof ) || ( goto :Services_Optimization_Failed )

:Svc_Optimization
	if "%Win_Edition%" == "Windows 10 LTSC" ( goto :Start_LTSC_Services ) else ( goto :Start_Server_Services )

:Start_LTSC_Services
if "%Network%" == "ON" ( goto :LTSC_Services_NW )
:: Set Services for LTSC
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KtmRm,LicenseManager,lltdsvc,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:LTSC_Services_NW
:: Set Services for LTSC with File and Printer Sharing enabled
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FDResPub,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KtmRm,LanmanServer,LanmanWorkstation,LicenseManager,lltdsvc,lmhosts,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SSDPSRV,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,upnphost,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,lfsvc,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Start_Server_Services
if "%Network%" == "ON" ( goto :Server_Services_NW )
:: Set Services for Windows Server
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KPSSVC,KtmRm,LicenseManager,lltdsvc,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WebClient,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Server_Services_NW
:: Set Services for Windows Server with File and Printer Sharing enabled
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FDResPub,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KPSSVC,KtmRm,LanmanServer,LanmanWorkstation,LicenseManager,lltdsvc,lmhosts,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SSDPSRV,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,upnphost,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,Tib$Mounter$Service"
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,lfsvc,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WebClient,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,AMD$External$Events$Utility,Acronis$VSS$Provider,AcronisAgent,ARSM,IAStorDataMgrSvc,Intel^(R^)$Capability$Licensing$Service$TCP$IP$Interface,Intel^(R^)$Security$Assist,NIHardwareService,NIHostIntegrationAgent,mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Start_Svc_Optimization
	setlocal EnableDelayedExpansion
	for %%g in (%AUTO%) do (
		set "AUTO_Svc=%%g" 
		set "AUTO_Svc=!AUTO_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!AUTO_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!AUTO_Svc!" /v Start /t REG_DWORD /d 2 /f >nul 2>&1
		sc config "!AUTO_Svc!" start= AUTO >nul 2>&1
	)

	for %%g in (%DEMAND%) do (
		set "DEMAND_Svc=%%g"
		set "DEMAND_Svc=!DEMAND_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!DEMAND_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!DEMAND_Svc!" /v Start /t REG_DWORD /d 3 /f >nul 2>&1
		sc config "!DEMAND_Svc!" start= DEMAND >nul 2>&1
	)	

	for %%g in (%DISABLED%) do (
		set "DISABLED_Svc=%%g"
		set "DISABLED_Svc=!DISABLED_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!DISABLED_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!DISABLED_Svc!" /v Start /t REG_DWORD /d 4 /f >nul 2>&1
		sc config "!DISABLED_Svc!" start= DISABLED >nul 2>&1
	)

:: Wlan option
	if "%WLan_Service%" == "Missing" ( goto :Services_Optimization_Success )
	if "%WLan_Service%" == "Enabled" (
		reg add "HKLM\SYSTEM\ControlSet001\Services\WlanSvc" /v Start /t REG_DWORD /d 2 /f >nul 2>&1
		sc config "WlanSvc" start= AUTO >nul 2>&1 ) else (
			reg add "HKLM\SYSTEM\ControlSet001\Services\WlanSvc" /v Start /t REG_DWORD /d 4 /f >nul 2>&1
			sc config "WlanSvc" start= DISABLED >nul 2>&1 )

:Services_Optimization_Success
	setlocal DisableDelayedExpansion
	echo [92mDone.[97m
	echo [93m%Win_Edition% services optimization task has completed successfully.[97m
	exit /b

:Services_Optimization_Failed
	echo [31mServices optimization task failed.[97m
	goto :eof

::============================================================================================================
:Backup_Services_After_Optimization
::============================================================================================================
	echo:
	<nul set /p DummyName=Backing up optimized services startup configuration...
	cd /d "%Tmp_Folder%Files\Scripts\Services"
:: Create lock file
	echo >lock.tmp
:: Backup services through vbs script, getting services count argument from it
	cscript //nologo "%Tmp_Folder%Files\Scripts\Services\Opt_services_startup_config_backup.vbs"
:Wait_for_lock_Opt
	if exist "lock.tmp" goto :Wait_for_lock_Opt
	for /r %%a in (*.reg) do ( set "Opt_Service_Backup_Path=%%~dpna" & set "Opt_Service_Backup_Name=%%~na" )
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)( start=.*)$" "$1$3$4" /m /f "%Opt_Service_Backup_Path%.bat" /o - >nul 2>&1
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(HKEY_LOCAL_MACHINE.*)_(.*)\d(.*)$" "$1$3" /m /f "%Opt_Service_Backup_Path%.reg" /o - >nul 2>&1
	robocopy "%Tmp_Folder%Files\Scripts\Services" "%TEMP%\SettingsBackup\Services Backup" *.reg *.bat /Mov /is /it /S /xf "Services Optimization.bat" >nul 2>&1
	echo [92mDone.[97m
	echo [93mOptimized services startup configuration saved as "%Opt_Service_Backup_Name%".[97m
	echo:
	goto :eof

::============================================================================================================
:Indexing_Options
::============================================================================================================
	set "Index=0"
	set "IndexedFolder="
	set "Increment_Index="
	if "%FullMode%" == "Unlocked" ( set "line_down4=4B" & set "line_down3=3B" & set "line_down2=2B" & set "line_down1=1B" ) else ( set "line_down4=2A" & set "line_down3=4A" & set "line_down2=6A" & set "line_down1=8A" )
	set "line_up=2" & set "line_up2=7" & set "line_up3=2"
	set "Idx_1=-1" & set "Idx_2=-2" & set "Idx_3=-3" & set "Idx_4=-4" & set "Idx_5=-5" & set "Idx_6=-6" & set "Idx_7=-7" & set "Idx_8=-8" & set "Idx_9=-9" & set "Idx_10=-10"
	set "Idx_11=-11" & set "Idx_12=-12" & set "Idx_13=-13" & set "Idx_14=-14" & set "Idx_15=-15" & set "Idx_16=-16" & set "Idx_17=-17" & set "Idx_18=-18" & set "Idx_19=-19" & set "Idx_20=-20"
	set "IndexedFolder_1=" & set "IndexedFolder_2=" & set "IndexedFolder_3=" & set "IndexedFolder_4=" & set "IndexedFolder_5=" & set "IndexedFolder_6=" & set "IndexedFolder_7=" & set "IndexedFolder_8=" & set "IndexedFolder_9=" & set "IndexedFolder_10="
	set "IndexedFolder_11=" & set "IndexedFolder_12=" & set "IndexedFolder_13=" & set "IndexedFolder_14=" & set "IndexedFolder_15=" & set "IndexedFolder_16=" & set "IndexedFolder_17=" & set "IndexedFolder_18=" & set "IndexedFolder_19=" & set "IndexedFolder_20="
	echo:
	echo [?25l1. Set custom locations
	if not "%FullMode%" == "Unlocked" ( echo: )
	echo 2. Add Windows start menus only
	if not "%FullMode%" == "Unlocked" ( echo: )
	echo 3. Remove all locations from indexing options
	if not "%FullMode%" == "Unlocked" ( echo: )
	echo 4. Default indexing options settings
	if not "%FullMode%" == "Unlocked" ( 
		echo: & echo:
		<nul set /p DummyName=Select your option, or 0 to cancel and return to previous menu: [?25h
		choice /c 12340 /n /m "" >nul 2>&1 ) else (
			echo 0. Cancel
			<nul set /p DummyName=[6ASelect[8C[?25h
			choice /c 12340 /n /m "" >nul 2>&1 )

	if errorlevel 5 (
		if "%FullMode%" == "Unlocked" ( echo [?25l0& echo [14D[%line_down4%[31m0. Cancel[97m& echo: ) else ( echo 0 )
		set "Clean=Clean_OFF"
		goto :Index_Task_Clean )

	if errorlevel 4 (
		echo [?25l4
		if "%FullMode%" == "Unlocked" ( echo [14D[%line_down3%[92m4. Default indexing options settings[97m[2B ) else (
			echo [14D[%line_down3%[92m4. Default indexing options settings[97m[4B )
		set "Style=default"
		goto :Indexing_Options_Task )

	if errorlevel 3 (
		echo [?25l3
		if "%FullMode%" == "Unlocked" ( echo [14D[%line_down2%[92m3. Remove all locations from indexing options[97m[3B ) else (
			echo [14D[%line_down2%[92m3. Remove all locations from indexing options[97m[6B )
		set "Style=reset"
		goto :Indexing_Options_Task )

	if errorlevel 2 (
		echo [?25l2
		if "%FullMode%" == "Unlocked" ( echo [14D[%line_down1%[92m2. Add Windows start menus only[97m[4B ) else (
			echo [14D[%line_down1%[92m2. Add Windows start menus only[97m[8B )
		set "Style=startmenus"
		goto :Indexing_Options_Task )

	if errorlevel 1 (
		echo [?25l1
		if "%FullMode%" == "Unlocked" ( echo [92m1. Set custom locations[97m[5B ) else (
			echo [10A[92m1. Set custom locations[97m[10B )
		set "Style=custom"
		goto :PathSelection )

	goto :eof

:PathSelection
	setlocal EnableDelayedExpansion
	call "%Tmp_Folder%Files\Utilities\Browser.bat"

:: User hits cancel
	if "%IndexedFolder%" == "" (
		if "%FullMode%" == "Unlocked" (
			<nul set /p DummyName=[%line_up2%ASelect option:[2X
			endlocal && goto :Indexing_Options )
		<nul set /p DummyName=[%line_up3%ASelect your option, or 0 to cancel and return to previous menu: [2X[10A
		endlocal && goto :Indexing_Options )

:: Path entered
	if "%Index%" == "0" (
		echo You selected "%IndexedFolder%"
		set "Increment_Index=incr"
		goto :SelectMorePaths )

:: User hits cancel
	if "!IndexedFolder_%Index%!" == "" (
		set "IndexedFolder="
		set "Filler=%line_up%"
		set /a "Filler-=1"
		echo [%line_up%A[140X

:Filler_Loop
		if "%Filler%" == "0" ( goto :Filler_Loop_End )
		echo [140X
		set /a "Filler-=1"
		goto :Filler_Loop

:Filler_Loop_End
		set /a "line_up2=%line_up2%+%line_up%"
		set /a "line_up3=%line_up3%+%line_up%"
		if "%FullMode%" == "Unlocked" (
			<nul set /p DummyName=[%line_up2%ASelect option:[2X
			endlocal && goto :Indexing_Options )
		<nul set /p DummyName=[%line_up3%ASelect your option, or 0 to cancel and return to previous menu: [2X[10A
		endlocal && goto :Indexing_Options
	)

:: Path entered
	if not "!IndexedFolder_%Index%!" == "%IndexedFolder%" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_1%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_2%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_3%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_4%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_5%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_6%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_7%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_8%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_9%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_10%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_11%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_12%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_13%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_14%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_15%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_16%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_17%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_18%!" (
	if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_19%!" ( if not "!IndexedFolder_%Index%!" == "!IndexedFolder_%Idx_20%!" (

	echo You selected "!IndexedFolder_%Index%!"
	set /a "line_up+=2"
	set "Increment_Index=incr"
	goto :SelectMorePaths )))))))))))))))))))))

	set "IndexedFolder_%Index%="
	set "Increment_Index=no_incr"
	set /a "line_up+=1"
	goto :SelectMorePaths

:SelectMorePaths
	<nul set /p DummyName=Do you want to add another path to indexed locations? [Y/N][?25h
	choice /C:YN /M "" >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& goto :PathResult )
	if "%Increment_Index%" == "incr" (
		set /a "Index+=1"
		set /a "Idx_1+=1" & set /a "Idx_2+=1" & set /a "Idx_3+=1" & set /a "Idx_4+=1" & set /a "Idx_5+=1" & set /a "Idx_6+=1" & set /a "Idx_7+=1"
		set /a "Idx_8+=1" & set /a "Idx_9+=1" & set /a "Idx_10+=1" & set /a "Idx_11+=1" & set /a "Idx_12+=1" & set /a "Idx_13+=1" & set /a "Idx_14+=1"
		set /a "Idx_15+=1" & set /a "Idx_16+=1" & set /a "Idx_17+=1" & set /a "Idx_18+=1" & set /a "Idx_19+=1" & set /a "Idx_20+=1" )
	echo [92mYes[97m[?25l
	goto :PathSelection

:PathResult
	echo:
	if "%Index%" == "0" (
		echo Indexed location is "%IndexedFolder%"
		set "More_Paths=Skip"
		goto :Indexing_Options_Task )
	if "%Index%" == "1" ( if "!IndexedFolder_%Index%!" == "" (
		echo Indexed location is "%IndexedFolder%"
		set "More_Paths=Skip"
		goto :Indexing_Options_Task ))
	echo Indexed locations are
	echo "%IndexedFolder%"
	set /a "Count=%Index%"
	if %Index% GTR 0 ( if "!IndexedFolder_%Index%!" == "" ( set /a "Count-=1" ))

:ResultLoop
	if "%Count%" == "0" ( goto :Indexing_Options_Task )
	set "Index2=!IndexedFolder_%Count%!"
	echo "%Index2%"
	set /a "Count-=1"
	goto :ResultLoop

:Indexing_Options_Task
	if "%Style%" == "custom" ( echo: )
	mkdir "%Idx_Tmp_Folder%" >nul 2>&1
	set "Clean=Clean_ON"
	<nul set /p DummyName=Setting indexing options...[?25h

:: Get SID
	for /f "tokens=1,2 delims==" %%s IN ('wmic path win32_useraccount where name^='%username%' get sid /value ^| find /i "SID"') do set "SID=%%t"

:: Make PS Script
	@echo $host.ui.RawUI.WindowTitle = "Optimize Next Gen v3.9.7 | Powershell Script">>%Idx_scriptname%
	@echo Add-Type -path "%Tmp_Folder%Files\Utilities\Microsoft.Search.Interop.dll">>%Idx_scriptname%
	@echo $sm = New-Object Microsoft.Search.Interop.CSearchManagerClass>>%Idx_scriptname%
	@echo $catalog = $sm.GetCatalog^("SystemIndex"^)>>%Idx_scriptname%
	@echo $crawlman = $catalog.GetCrawlScopeManager^(^)>>%Idx_scriptname%
	@echo $crawlman.RevertToDefaultScopes^(^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	if "%Style%" == "default" ( goto :MakeDefault )
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\ProgramData\Microsoft\Windows\Start Menu\*"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\Local\Temp\*"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\*"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("iehistory://{%SID%}"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	if "%Style%" == "default" ( goto :MakeDefault )
	if "%Style%" == "reset" ( goto :Finish_Ps )
	if "%Style%" == "startmenus" ( goto :AddStartMenus )
	if "%Style%" == "custom" ( goto :SetCustomPaths )

:MakeDefault
	@echo $crawlman.AddUserScopeRule^("file:///C:\Users\*",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.AddUserScopeRule^("file:///C:\ProgramData\Microsoft\Windows\Start Menu\*",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.AddUserScopeRule^("iehistory://{%SID%}",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	goto :Reindex

:AddStartMenus
	@echo $crawlman.AddUserScopeRule^("file:///%ProgramData%\Microsoft\Windows\Start Menu\Programs\*",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	@echo $crawlman.AddUserScopeRule^("file:///%AppData%\Microsoft\Windows\Start Menu\Programs\*",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	goto :Finish_Ps

:SetCustomPaths
	@echo $crawlman.AddUserScopeRule^("file:///%IndexedFolder%\*",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	if "%More_Paths%" == "Skip" ( goto :Finish_Ps )

:MorePathsLoop
	if "%Index%" == "0" ( goto :Finish_Ps )
	if %Index% GTR 0 ( if "!IndexedFolder_%Index%!" == "" ( set /a "Index-=1" ))
	set "Index2=!IndexedFolder_%Index%!"
	@echo $crawlman.AddUserScopeRule^("file:///%Index2%\*",$true,$false,$null^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%
	set /a "Index-=1"
	goto :MorePathsLoop

:Finish_Ps
	@echo $crawlman.RemoveDefaultScopeRule^("file:///%UserProfile%\Favorites\*"^)>>%Idx_scriptname%
	@echo $crawlman.SaveAll^(^)>>%Idx_scriptname%

:Reindex
	@echo $Catalog.Reindex^(^)>>%Idx_scriptname%
	if "%FullMode%" == "Unlocked" ( copy /b /v /y "%Idx_scriptname%" "%Tmp_Folder%SearchScopeTask2.ps1" >nul 2>&1 )
	@echo Remove-Item "%Idx_lock%">>%Idx_scriptname%
:: Execute Task
	@echo Locked>"%Idx_lock%"
	PowerShell -NoProfile -ExecutionPolicy Unrestricted -File "%Idx_scriptname%" -force >nul 2>&1

:Wait
	if exist "%Idx_lock%" ( goto :Wait )

:Index_Task_Clean
	if "%Clean%" == "Clean_OFF" (
		if "%FullMode%" == "Unlocked" ( echo [1A[93mNo indexing location has been set.[97m[?25l )
		if not "%FullMode%" == "Unlocked" ( echo: & echo [93mNo indexing location has been set.[97m[?25l )
		goto :eof )
	echo [92mDone.
	echo [93mIndexing options setting task has completed successfully.[97m[?25l
	echo %Shell_Title%[1A
	if "%FullMode%" == "Unlocked" (
		mkdir "%launchpath%Backup\Scripts (Restore or Apply again)\Indexing Options\" >nul 2>&1
		move /y	"%Tmp_Folder%SearchScopeTask2.ps1" "%launchpath%Backup\Scripts (Restore or Apply again)\Indexing Options\SearchScopeTask.ps1" >nul 2>&1 )

:CleanMore_1
	del /F /Q /S "%Idx_scriptname%" >nul 2>&1
	if not exist "%Idx_scriptname%" ( goto :CleanMore_2 ) else ( goto :CleanMore_1 )

:CleanMore_2
	rmdir "%Idx_Tmp_Folder%\" /s /q >nul 2>&1
	if not exist "%Idx_Tmp_Folder%\" ( goto :eof ) else ( goto :CleanMore_2 )

::============================================================================================================
:EventLog_Cosmetics
::============================================================================================================
::Fix EventLog Cosmetic Errors
	wevtutil sl "Microsoft-Windows-DeviceSetupManager/Admin" /e:false /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /v "EnableLevel" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-User Device Registration/Admin" /v "OwningPublisher" /t REG_SZ /d "{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-User Device Registration/Admin" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	echo [92mDone.[97m
	goto :eof

::============================================================================================================
:WStore_Check
::============================================================================================================
	<nul set /p DummyName=Checking for Microsoft Store before applying settings...[60X
	for /f "tokens=3 delims= " %%a in ('Powershell Get-AppxPackage -Name Microsoft.StorePurchaseApp ^| findstr /i /c:"Status"') do ( if "%%a" == "Ok" ( echo [92mDone.[97m& goto :WStore_Ask ))
	echo [93mMicrosoft Store is not installed.[97m& echo %Shell_Title%& goto :eof

:WStore_Ask
	echo %Shell_Title%[1A
	<nul set /p DummyName=Microsoft Store has been detected, do you want to apply Store and Store Apps settings? [Y/N] (Press No if you use the store)
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& set "Win_Store=Store_ON" & goto :WGames_Ask )
	if errorlevel 1 ( echo [92mYes[97m& set "Win_Store=Store_OFF" & echo: & goto :eof )

:WGames_Ask
	<nul set /p DummyName=Do you want to apply game related tweaks? [Y/N] (Press No if you play games)
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& set "Win_Games=Games_ON" & echo: & goto :eof )
	if errorlevel 1 ( echo [92mYes[97m& set "Win_Games=Games_OFF" & echo: & goto :eof )

::============================================================================================================
:Game_Explorer
::============================================================================================================
	if "%Win_Games%" == "Games_ON" ( goto :eof )
	if exist "%windir%\System32\gameux.dll" (
		if "%FastMode%" == "Unlocked" (
			<nul set /p DummyName= Game Explorer is active.
			goto :Game_Explorer_Task2 ) else (
				echo Game Explorer is active: gameux.dll injects into games at startup and connects to MS servers.
				<nul set /p DummyName=Do you want to deactivate Game Explorer? [Y/N]
				choice /c YN >nul 2>&1
				if errorlevel 2 ( echo [31mAborted[97m& goto :eof )
				echo [92mYes[97m
				goto :Game_Explorer_Task2 )
	) else ( echo Game Explorer is already deactivated, option bypassed.&& goto :eof )

:Game_Explorer_Task
	if not exist "%windir%\System32\gameux.dll" ( echo Game Explorer is already deactivated.&& goto :eof )

:Game_Explorer_Task2
	<nul set /p DummyName=Disabling Games Explorer...
	if exist "%windir%\System32\gameux.dll.bak" ( del /F /Q /S "%windir%\System32\gameux.dll.bak" >nul 2>&1 )
	if exist "%windir%\System32\GameUXLegacyGDFs.dll.bak" ( del /F /Q /S "%windir%\System32\GameUXLegacyGDFs.dll.bak" >nul 2>&1 )
	if exist "%windir%\SysWOW64\gameux.dll.bak" ( del /F /Q /S "%windir%\SysWOW64\gameux.dll.bak" >nul 2>&1 )
	if exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" ( del /F /Q /S "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" >nul 2>&1 )
	if exist "%windir%\System32\gameux.dll" (
		takeown /f "%windir%\System32\gameux.dll" >nul 2>&1
		icacls "%windir%\System32\gameux.dll" /grant:r *S-1-5-32-544:f /C /Q >nul 2>&1
		ren "%windir%\System32\gameux.dll" "gameux.dll.bak" >nul 2>&1
		if exist "%windir%\System32\GameUXLegacyGDFs.dll" (
			takeown /f "%windir%\System32\GameUXLegacyGDFs.dll" >nul 2>&1
			icacls "%windir%\System32\GameUXLegacyGDFs.dll" /grant:r *S-1-5-32-544:f /C /Q >nul 2>&1
			ren "%windir%\System32\GameUXLegacyGDFs.dll" "GameUXLegacyGDFs.dll.bak" >nul 2>&1 ))
	if exist "%windir%\SysWOW64\gameux.dll" (
		takeown /f "%windir%\SysWOW64\gameux.dll" >nul 2>&1
		icacls "%windir%\SysWOW64\gameux.dll" /grant:r *S-1-5-32-544:f /C /Q >nul 2>&1
		ren "%windir%\SysWOW64\gameux.dll" "gameux.dll.bak" >nul 2>&1
		if exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll" (
			takeown /f "%windir%\SysWOW64\GameUXLegacyGDFs.dll" >nul 2>&1
			icacls "%windir%\SysWOW64\GameUXLegacyGDFs.dll" /grant:r *S-1-5-32-544:f /C /Q >nul 2>&1
			ren "%windir%\SysWOW64\GameUXLegacyGDFs.dll" "GameUXLegacyGDFs.dll.bak" >nul 2>&1 ))

	if exist "%windir%\System32\gameux.dll" ( echo [31mOperation failed.[97m ) else ( echo [92mDone.[97m )
	goto :eof

::============================================================================================================
:Clear_EventViewer_Logs
::============================================================================================================
	for /f "tokens=*" %%G in ('wevtutil.exe el') do (call :Clear_EV "%%G")
	echo:
	echo [93mEvent Logs have been cleared.[97m
	goto :eof

:Clear_EV
	echo clearing %1
	wevtutil.exe cl %1
	goto :eof

::============================================================================================================
:Save_All_Settings
::============================================================================================================
	<nul set /p DummyName=Saving all settings...
	cd /d "%Tmp_Folder%"
	robocopy "%TEMP%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S >nul 2>&1
	echo [93mSettings successfully saved.[97m& echo:
:: Ask if user want to archive
	<nul set /p DummyName=Do you want to "zip" saved setttings and scripts? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mAborted[97m& goto :eof )
	if errorlevel 1 ( echo [92mYes[97m& goto :Archive )

::============================================================================================================
:Archive
::============================================================================================================
:: Check 7z first (fastest)
	if exist "%ProgramFiles%\7-Zip\7z.exe" (
		"%ProgramFiles%\7-Zip\7z.exe" a "%launchpath%Backup.zip" "%TEMP%\SettingsBackup\*" -r -y >nul 2>&1
		goto :Archiving_Success )

:WinRAR
:: xcopy workaround for winrar adding parent folders to archive when specifying path as argument
	if exist "%programFiles%\WinRAR\WinRAR.exe" (
		xcopy "%TEMP%\SettingsBackup" "%Tmp_Folder%SettingsBackup" /e /h /k /i /y >nul 2>&1
		cd /d "%Tmp_Folder%SettingsBackup\"
		"%programFiles%\WinRAR\WinRAR.exe" a "%launchpath%Backup.zip" -ibck -r -u -y >nul 2>&1
		cd /d "%Tmp_Folder%" & rmdir "%Tmp_Folder%SettingsBackup" /s /q >nul 2>&1
		goto :Archiving_Success )

:PS
:: Last chance (slowest)
	%PScommand% "Compress-Archive -Path "$env:TEMP\SettingsBackup\*" -CompressionLevel Fastest -DestinationPath "$env:%launchpath%Backup.zip" -Update" 1>nul 2>nul && ( goto :Archiving_Success ) || (
		echo [31mArchiving failed.[97m
		goto :eof )

:Archiving_Success
	echo [93mSettings successfully zipped.[97m
	rmdir "%launchpath%Backup" /s /q >nul 2>&1
	goto :eof

::============================================================================================================
:Cleaning
::============================================================================================================
:: Clean empty devices in device manager
	%Tmp_Folder%Files\Utilities\DeviceCleanupCmd.exe * -s -n >nul 2>&1

:: Clear System EventViewer Logs
	wevtutil.exe cl "System" >nul 2>&1

:Cleaning_Temp_Folder
	cd /d "%TEMP%"
	if not exist "%TEMP%\SettingsBackup" ( goto :eof ) else (
		cd /d "%TEMP%\SettingsBackup"
		for /f "delims=" %%i in ('dir /b') do ( rmdir "%%i" /s /q >nul 2>&1 ) || ( del /F /Q /S "%%i" >nul 2>&1 )
		cd /d "%TEMP%"
		rmdir "SettingsBackup" /s /q >nul 2>&1
		goto :Cleaning )

::============================================================================================================
:: Close And Restart Countdown Thingy
::============================================================================================================
:Restart_Warning
	echo:
	echo All tasks have completed.
:Restart_Warning_2
	echo You will need to restart your PC to finish optimizing your system.
	goto :Restart_Question

:Restart_Information
	echo:
	echo You might have to restart your computer for all settings to be effective.
	goto :Restart_Question

:Restart_Question
	<nul set /p DummyName=Do you want to restart the PC now? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& echo: & goto :RETURN_TO_MAIN_MENU )
	if errorlevel 1 ( echo [92mYes[97m& echo: & goto :Restart_Computer )

:Save_Before_End
	robocopy "%TEMP%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S >nul 2>&1
	goto :Cleaning

:RETURN_TO_MAIN_MENU
	cd /d "%Tmp_Folder%"
:: Create Lock file
	echo >Lock.tmp
:: Create script that will be launched simultaneously to release prompt when Lock file is deleted
	@echo @echo off >"%Tmp_Folder%Lock.bat"
	@echo :loop_1 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) >>"%Tmp_Folder%Lock.bat"
	@echo "%Tmp_Folder%Files\Utilities\GetKey.exe" /N >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 48 ^( @echo ^>"%%Tmp_Folder%%Lock_ZERO.tmp" ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 0 ^( goto :loop_1 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :loop_2 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) else ^( del /F /Q /S "%Tmp_Folder%Lock.tmp" ^>nul ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :finish >>"%Tmp_Folder%Lock.bat"
	@echo ^(goto^) 2^>nul ^& del /F /Q /S "%%~f0" ^>nul 2^>^&1 >>"%Tmp_Folder%Lock.bat"
:: Prompt and get key
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	<nul set /p DummyName=Press any key to return to Start menu, or 0 to exit...[?25h

:Lock1_CheckLoop2
	if exist "%Tmp_Folder%Lock.tmp" ( goto :Lock1_CheckLoop2 )
	if exist "%Tmp_Folder%Lock_ZERO.tmp" (
		call :Lock_ZERO_Delete_Loop
		cls & goto :TmpFolder_Remove )
	set "FastMode=Locked"
	set "FullMode=Locked"
	set "SecretMode=Locked"
	goto :START

:RETURN_TO_OPT_MENU
	echo:
	<nul set /p DummyName=Press any key to return to Optimization menu...[?25h
	pause >nul
	goto :Optimize_MENU

:Restart_Computer
	if "%OfflineMode%" == "Unlocked" ( goto :TmpFolder_Remove )
	if "%SecretMode%" == "Unlocked" (
		if "%RestartWindow%" == "Show" (
			call :conSize 151 10 151 9999
			echo %Shell_Title%
			cls & call :Color_title2
			set "Timer=21"
			goto :Restart_Task
		) else (
			set "RestartWindow=Show"
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Show "%~dpnx0" && exit /b )
	) else ( set "Timer=12" )
	echo: [?25l

:Restart_Task
	setlocal EnableDelayedExpansion
	cd /d "%Tmp_Folder%"
:: Create Lock file
	echo >Lock.tmp
:: Create script that will be launched simultaneously to release prompt when Lock file is deleted
	@echo @echo off >"%Tmp_Folder%Lock.bat"
	@echo :loop_1 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) >>"%Tmp_Folder%Lock.bat"
	@echo "%Tmp_Folder%Files\Utilities\GetKey.exe" /N >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 48 ^( @echo ^>"%%Tmp_Folder%%Lock_ZERO.tmp" ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 13 ^( @echo ^>"%%Tmp_Folder%%Lock_ENTER.tmp" ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 0 ^( goto :loop_1 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :loop_2 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) else ^( del /F /Q /S "%Tmp_Folder%Lock.tmp" ^>nul ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :finish >>"%Tmp_Folder%Lock.bat"
	@echo ^(goto^) 2^>nul ^& del /F /Q /S "%%~f0" ^>nul 2^>^&1 >>"%Tmp_Folder%Lock.bat"
	if not "%SecretMode%" == "Unlocked" ( echo Press [93mENTER[97m to reboot now, [93m0[97m to cancel and exit, or any other key to cancel and return to Start menu.[?25l[2A ) else (
		echo All tasks have completed.& echo: & echo Press [93mENTER[97m to reboot now, [93m0[97m to cancel and exit, or any other key to cancel and go to Start menu.[?25l[2A )
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
	for /l %%n in (%Timer% -1 1) do (
		dir * /s/b | findstr /c:Lock.tmp > nul && (
			if %%n GEQ 10 (
				if not "%SecretMode%" == "Unlocked" (
					<nul set /p "=Restarting in %%n seconds...!CR!" ) else (
						<nul set /p "=Your system will restart in %%n seconds to finish optimization.!CR!" ))
			if %%n LEQ 9 (
				if not "%SecretMode%" == "Unlocked" (
					<nul set /p "=Restarting in %%n seconds... !CR!" ) else (
						<nul set /p "=Your system will restart in %%n seconds to finish optimization. !CR!" ))
			if %%n EQU 0 ( goto :Final_Stuff )
			ping -n 2 localhost > nul
		) || (
			if exist "%Tmp_Folder%Lock_ENTER.tmp" (
				call :Lock_ENTER_Delete_Loop
				goto :Final_Stuff )
			if exist "%Tmp_Folder%Lock_ZERO.tmp" (
				call :Lock_ZERO_Delete_Loop
				if not "%FullMode%" == "Unlocked" ( call :Settings_Check )
				goto :TmpFolder_Remove )
			if "%SecretMode%" == "Unlocked" ( call :conSize 151 48 151 9999 )
			set "FastMode=Locked"
			set "FullMode=Locked"
			set "SecretMode=Locked"
			goto :START )
	)

:Final_Stuff
	call :Lock1_Delete_Loop
	cd /d "%TEMP%"
	if not "%FullMode%" == "Unlocked" ( call :Settings_Check && call :Cleaning )
	if "%Win_Edition%" == "Windows Server 2019" (
		reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\CapabilityIndex\Kernel.Soft.Reboot" | findstr /I /C:Microsoft-Windows-CoreSystem-SoftReboot-FoD-Package >nul && (
			"%windir%\System32\cmd.exe" /c shutdown.exe /r /soft /t 0
			goto :TmpFolder_Remove ))
	"%windir%\System32\cmd.exe" /c shutdown.exe /r /f /t 00
	goto :TmpFolder_Remove

::============================================================================================================
:: CleaningLoops
::============================================================================================================
:Lock1_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock.tmp" ( goto :eof ) else (
			del /F /Q /S "%Tmp_Folder%Lock.tmp" >nul 2>&1
			goto :Lock_ZERO_Delete_Loop ))

:Lock_ZERO_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock_ZERO.tmp" ( goto :eof ) else (
			del /F /Q /S "%Tmp_Folder%Lock_ZERO.tmp" >nul 2>&1
			goto :Lock_ZERO_Delete_Loop ))

:Lock_ENTER_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock_ENTER.tmp" ( goto :eof ) else (
			del /F /Q /S "%Tmp_Folder%Lock_ENTER.tmp" >nul 2>&1
			goto :Lock_ENTER_Delete_Loop ))

:Settings_Check
	cd /d "%TEMP%"
	if not exist "%TEMP%\SettingsBackup\" ( goto :eof ) else (
		rmdir "%TEMP%\SettingsBackup" >nul 2>&1
		goto :Settings_Check )
	goto :eof

:TmpFolder_Remove
	cd /d "%TEMP%"
	if not exist "%Tmp_Folder%" ( goto :eof ) else (
		rmdir "%Tmp_Folder%" /s /q >nul 2>&1
		goto :TmpFolder_Remove )

:TmpFolder_Check
	cd /d "%TEMP%"
	for /f "delims=" %%a in ('dir /b /ad ^| findstr /i /r "Optimize_NextGen_[0-9]*.tmp"') do ( rmdir "%%a" /s /q >nul 2>&1 ) || ( goto :eof )
	goto :eof

::============================================================================================================
:Remove_Tweaks
::============================================================================================================
	echo Removing privacy settings tweaks...
	<nul set /p DummyName=[2C-Preferences added to Group Policy in 'Custom Policies': 
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /f >nul 2>&1
	reg delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.BingNews_8wekyb3d8bbwe!AppexNews" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Photos_8wekyb3d8bbwe!App" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.calendar" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.mail" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.System.Continuum" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AudioTroubleshooter" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackgroundAccess" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BdeUnlock" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.RasToastNotifier" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WiFiNetworkManager" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /f >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[2C-Additional tweaks: 
	reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Allow" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Input\Settings" /v "HarvestContacts" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
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
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "4" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\DiagTrack" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "1" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\OneDrive" /v "PreventNetworkTrafficPreUserSignIn" /f >nul 2>&1
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
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceAppSuggestionsEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HasAboveLockTips" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /f >nul 2>&1
	reg delete "HKCU\Software\Policies\Microsoft\MicrosoftEdge" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /f >nul 2>&1
	echo [92mDone.[97m
	echo [93mPrivacy settings task has completed successfully.[97m
	echo:
	echo Removing performances tweaks...
	echo   -Registry settings:
	<nul set /p DummyName=[5CPreferences already present in Group Policy: 
:: Allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services
	reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "1" /f >nul 2>&1
:: Use biometrics
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /f >nul 2>&1
:: Allow StorageSense
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense" /v "AllowStorageSenseGlobal" /f >nul 2>&1
:: By default displays shutdown button on logon
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "shutdownwithoutlogon" /f >nul 2>&1
:: Check Windows edition before adding Shutdown Event Tracker value and do not display Server Manager at logon.
	if "%Win_Edition%" == "Windows Server 2019" ( goto :Windows_Server_Policies_Remove ) else ( goto :Power_Remove_Next )
:Windows_Server_Policies_Remove
:: Display Shutdown Event Tracker (Windows Server)
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v "ShutDownReasonOn" /f >nul 2>&1
:: Display Manage Your Server page at logon (Windows Server)
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\MYS" /v "DisableShowAtLogon" /f >nul 2>&1
:Power_Remove_Next
:: Power saving settings
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" /f >nul 2>&1
:: Button settings
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB" /f >nul 2>&1
:: Domain password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "1" /f >nul 2>&1
:: Turn on Power Throttling
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1
:: Enable Windows Scaling Heuristics
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /f >nul 2>&1
	echo [92mDone.[97m
	<nul set /p DummyName=[5CAdditional tweaks: 
:: Wallpaper compression
	reg delete "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /f >nul 2>&1
:: MenuShowDelay default delay value
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f >nul 2>&1
:: Max 15 items allowed to Open with
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /f >nul 2>&1
:: Add "-shortcut" to shortcut name at creation
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /f >nul 2>&1
:: Show advertising banner in Snipping Tool
	reg delete "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /f >nul 2>&1
:: Default icons cache size
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /f >nul 2>&1
:: Requirement of ALT+CTRL+DEL at logon screen (Windows Server setting)
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /f >nul 2>&1
:: Allow creation and logon of Microsoft Account
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoConnectedUser" /t REG_DWORD /d "0" /f >nul 2>&1
:: Show Insider page
	reg delete "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /f >nul 2>&1
:: Enable hibernation and fast start
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
:: Kill CreateExplorerShellUnelevatedTask in task scheduler
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
	echo [92mDone.[97m
	echo [93mPerformances registry settings task has completed successfully.[97m
	echo:
	goto :eof

:GPO_Redundant_Settings
	echo [93mNote:[97m Some important registry settings are redundantly included as Group Policy settings.
	echo If you launched full/fast optimization or Group Policy single task before, the tweaks you just removed are still stored as GPO.
	echo It means that tweaks are removed, but a future "GpUpdate" command would re-add them.
	echo In this case, it's better to launch Group Policy task again with these tweaks removed, or to reset Group Policy totally.
	echo:
	<nul set /p DummyName=Do you want to set Group Policy again with the registry tweaks removed (1)? Reset Group Policy totally (2)? or leave it like this (3)? [1/2/3]
	choice /c 123 >nul 2>&1
	if errorlevel 3 ( echo 3& echo: & goto :eof )
	if errorlevel 2 ( echo 2& echo: & goto :RTASK_2notitle )
	if errorlevel 1 ( echo 1& echo: & goto :Delete_GPO_Redundant_Settings )

:Delete_GPO_Redundant_Settings
	del /F /Q /S "%windir%\system32\GroupPolicy\User\registry.pol" >nul 2>&1
	del /F /Q /S "%windir%\system32\GroupPolicy\Machine\registry.pol" >nul 2>&1
	mkdir "%TEMP%\GPO_Restore\GroupPolicy\User" >nul 2>&1
	mkdir "%TEMP%\GPO_Restore\GroupPolicy\Machine" >nul 2>&1
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\User_MDL.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\User\registry.pol" >nul 2>&1
	if exist "%windir%\PolicyDefinitions\firefox.admx" ( goto :LGPO_Restore_Firefox ) else ( goto :LGPO_Restore_No_Firefox )

:LGPO_Restore_Firefox
	if not "%Win_Edition%" == "Windows Server 2019" (
		if not "%Win_Store%" == "Store_ON" (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\LTSC_Machine.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
				"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\LTSC_Machine_ST.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 )
	) else (
		if not "%Win_Store%" == "Store_ON" (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\Server_Machine.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
				"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\Server_Machine_ST.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 ))
	goto :LGPO_Restore_End

:LGPO_Restore_No_Firefox
	if not "%Win_Edition%" == "Windows Server 2019" (
		if not "%Win_Store%" == "Store_ON" (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\LTSC_Machine_NF.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
				"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\LTSC_Machine_NF_ST.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 )
	) else (
		if not "%Win_Store%" == "Store_ON" (
			"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\Server_Machine_NF.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 ) else (
				"%Tmp_Folder%Files\Utilities\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\Server_Machine_NF_ST.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >nul 2>&1 ))

:LGPO_Restore_End
	robocopy "%TEMP%\GPO_Restore\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >nul 2>&1
	if exist "%TEMP%\GPO_Restore" ( rmdir "%TEMP%\GPO_Restore" /s /q >nul 2>&1 )
	<nul set /p DummyName=Updating Group Policy...
	GPUpdate /Force >nul 2>&1
	echo [93mPolicy update has completed successfully.[97m
	echo:
	goto :eof

::============================================================================================================
:Custom_Policies_Preferences_Remove
::============================================================================================================
	reg delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.BingNews_8wekyb3d8bbwe!AppexNews" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Photos_8wekyb3d8bbwe!App" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.calendar" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.mail" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.System.Continuum" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AudioTroubleshooter" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackgroundAccess" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BdeUnlock" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.RasToastNotifier" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WiFiNetworkManager" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /f >nul 2>&1
	goto :eof

::============================================================================================================
:Restore_GPO
::============================================================================================================
:: Remove folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
	<nul set /p DummyName=Saving current policy files...
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak" (
		copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak" "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" >nul 2>&1
		copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak" "%windir%\system32\GroupPolicy\User\registry.bak_bak" >nul 2>&1 )
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >nul 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >nul 2>&1
	echo [92mDone.[97m& echo:
	<nul set /p DummyName=Restoring Group Policy from backup...
	if exist "%launchpath%Backup\GroupPolicy Backup\Current GPO\GroupPolicy" (
		robocopy "%launchpath%Backup\GroupPolicy Backup\Current GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\Machine" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\User" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		echo [92mDone.[97m
		echo [93mGroup Policy settings restored from backup folder.[97m& echo:
		goto :eof )
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" (
		copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" "%windir%\system32\GroupPolicy\Machine\registry.pol" >nul 2>&1
		copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak_bak" "%windir%\system32\GroupPolicy\User\registry.pol" >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\Machine" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\User" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		echo [92mDone.[97m
		echo [93mGroup Policy settings restored from registry.bak files.[97m& echo:
		goto :eof )
	echo [31mGroup Policy backup not found.[97m
	echo [93mRestore operation failed.[97m
	cd /d "%windir%\system32\GroupPolicy\Machine" & del /F /Q /S "registry.bak" >nul 2>&1
	cd /d "%windir%\system32\GroupPolicy\User" & del /F /Q /S "registry.bak" >nul 2>&1
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	echo:
	<nul set /p DummyName=Would you like to reset Group Policy instead? [Y/N]
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo [31mNo[97m& echo: & goto :RETURN_TO_MAIN_MENU )
	if errorlevel 1 ( echo [92mYes[97m& echo: & goto :RTASK_2notitle )

::============================================================================================================
:Restore_Services
::============================================================================================================
	<nul set /p DummyName=Restoring initial services startup configuration...
	if exist "%launchpath%Backup\Services Backup" ( goto :Restore_Services_CheckforFile ) else ( goto :Restore_Services_Fail)

:Restore_Services_CheckforFile
	cd /d "%launchpath%Backup\Services Backup"
	for /f %%i in ('dir /b /s "*.bat" 2^>nul ^| find /i "Current"') do ( set "Services_Backup_Exists=%%i" )
	if not "%Services_Backup_Exists%" == "" ( goto :Restore_Services_Backup ) else ( goto :Restore_Services_Fail )

:Restore_Services_Backup
:: Set dynamic file which will have pause skipped
	echo [93mServices startup configuration backup found.[97m
	<nul set /p DummyName=Finding oldest file in backup folder, and restoring startup configuration with NSudo...
	set "DynScriptName=%Temp%\NoPause.bat"
:: Order by date to select oldest backup and then save it as dynamic file without pause
	for /f "delims=" %%a in ( 'dir /b /a-d /tw /od "%launchpath%Backup\Services Backup\*.bat" 2^>nul ^| find /i "Current"') do (
		set "Services_Configuration_to_Backup=%%~na"
		findstr /i /v "pause" "%launchpath%Backup\Services Backup\%%a">"%DynScriptName%"
		goto :Restore_Services_Backup_Action )

:Restore_Services_Backup_Action
:: Run dynamic script with NSudo
	if exist "%launchpath%Backup\Services Backup\%Services_Configuration_to_Backup%.reg" ( "%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -wait -UseCurrentConsole -ShowWindowMode:Show reg import "%launchpath%Backup\Services Backup\%Services_Configuration_to_Backup%.reg" >nul 2>&1 )
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -wait -ShowWindowMode:Hide "%DynScriptName%"
	echo [92mDone.[97m
	if exist "%DynScriptName%" ( del /F /Q /S "%DynScriptName%" >nul 2>&1 )
:: Inform user
	echo [93m"%Services_Configuration_to_Backup%" successfully restored.[97m& set "Services_Backup_Exists=" & echo: & goto :eof )

:Restore_Services_Fail
	echo [31mServices backup not found.[97m
	echo [93mRestore operation failed.[97m& echo:
	goto :eof

::============================================================================================================
:Game_Explorer_Restore
::============================================================================================================
	if exist "%windir%\System32\gameux.dll" ( echo Game Explorer is already active.& echo: && goto :eof )
	<nul set /p =Enabling Games Explorer...
	if exist "%windir%\System32\gameux.dll.bak" ( ren "%windir%\System32\gameux.dll.bak" "gameux.dll" >nul 2>&1 )
	if exist "%windir%\System32\GameUXLegacyGDFs.dll.bak" ( ren "%windir%\System32\GameUXLegacyGDFs.dll.bak" "GameUXLegacyGDFs.dll" >nul 2>&1 )
	if exist "%windir%\SysWOW64\gameux.dll.bak" ( ren "%windir%\SysWOW64\gameux.dll.bak" "gameux.dll" >nul 2>&1 )
	if exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" ( ren "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" "GameUXLegacyGDFs.dll" >nul 2>&1 )
	if not exist "%windir%\System32\gameux.dll" ( echo [31mOperation failed.[97m& goto :Game_Explorer_Hard_Restore ) else ( echo [92mDone.[97m& echo: & goto :eof )

:Game_Explorer_Hard_Restore
:: In case anything goes wrong...
	set "Restore_GameExplorer=Restore_GameExplorer_ON"
	<nul set /p =Restoring Game Explorer from WinSxs folder...
	if exist "%windir%\System32\gameux.dll.bak" ( del /F /Q /S "%windir%\System32\gameux.dll.bak" >nul 2>&1 )
	if exist "%windir%\System32\GameUXLegacyGDFs.dll.bak" ( del /F /Q /S "%windir%\System32\GameUXLegacyGDFs.dll.bak" >nul 2>&1 )
	if exist "%windir%\SysWOW64\gameux.dll.bak" ( del /F /Q /S "%windir%\SysWOW64\gameux.dll.bak" >nul 2>&1 )
	if exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" ( del /F /Q /S "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" >nul 2>&1 )

:: Launch NSudo to get permissions on WinSxs folder
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -Wait -UseCurrentConsole "%~dpnx0"&& ( goto :eof )

:Game_Explorer_Hard_Restore_Task
	cd /d "%windir%\WinSxS"

	for /f %%i in ('dir /b /s "gameux.dll" 2^>nul ^| find /i "amd64_"') do ( set "gameux_64=%%i" )
	if not "%gameux_64%" == "" ( if not exist "%windir%\System32\gameux.dll" ( mklink /H "%windir%\System32\gameux.dll" "%gameux_64%" >nul 2>&1 ))
	for /f %%j in ('dir /b /s "gameux.dll" 2^>nul ^| find /i "wow64_"') do ( set "gameux_32=%%j" )
	if not "%gameux_32%" == "" ( if not exist "%windir%\SysWOW64\gameux.dll" ( mklink /H "%windir%\SysWOW64\gameux.dll" "%gameux_32%" >nul 2>&1 ))
	for /f %%k in ('dir /b /s "GameUXLegacyGDFs.dll" 2^>nul ^| find /i "amd64_"') do ( set "gameuxL_64=%%k" )
	if not "%gameuxL_64%" == ""	( if not exist "%windir%\System32\GameUXLegacyGDFs.dll" ( mklink /H "%windir%\System32\GameUXLegacyGDFs.dll" "%gameuxL_64%" >nul 2>&1 ))
	for /f %%l in ('dir /b /s "GameUXLegacyGDFs.dll" 2^>nul ^| find /i "wow64_"') do ( set "gameuxL_32=%%l" )
	if not "%gameuxL_32%" == ""	( if not exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll" ( mklink /H "%windir%\SysWOW64\GameUXLegacyGDFs.dll" "%gameuxL_32%" >nul 2>&1 ))

	if not exist "%windir%\System32\gameux.dll" ( echo [31mOperation failed.[97m ) else ( echo [92mOperation was successful.[97m )

	set "Restore_GameExplorer=Restore_GameExplorer_OFF"
	cd /d "%Tmp_Folder%"
	echo:
	goto :eof

::============================================================================================================
:NOADMIN
::============================================================================================================
	echo [97mYou must have administrator rights to run this script.
	<nul set /p DummyName=Press any key to exit...
	pause >nul
	goto :eof

::============================================================================================================
:conSize  winWidth  winHeight  bufWidth  bufHeight
::============================================================================================================
	mode con: cols=%1 lines=%2
	%PScommand% "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%3;$B.height=%4;$W.buffersize=$B;}"
	goto :eof

::============================================================================================================
:NSudo_Tasks
::============================================================================================================
	if "%PowerSchemeCreation%" == "PowerSchemeCreation_ON" ( goto :GUID_Trick )
	if "%Restore_GameExplorer%" == "Restore_GameExplorer_ON" ( goto :Game_Explorer_Hard_Restore_Task ) else ( goto :Svc_Optimization )
	goto :eof
