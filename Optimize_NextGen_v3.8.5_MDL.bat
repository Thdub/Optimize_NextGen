:: Optimize NextGen v3.8.5.2
:: Written by Th.Dub @ResonantStep - 2019

@echo off

%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN
%windir%\system32\whoami.exe /USER | find /i "S-1-5-18" 1>NUL && goto :NSudo_Tasks

	if "%Run%" == "" (
		call :TmpFolder_Check
		set "launchpath=%~x1"
		set "Run=First"
		set "Tmp_Folder=%TEMP%\Optimize_NextGen_%random%.tmp\"
	)

	if "%Run%" == "First" (
		if "%launchpath%" == "" (
			set "launchpath=%~dp0"
			set "Run_With_Arg=%~1"
			robocopy /MIR "%~dp0\" "%Tmp_Folder%\" >NUL 2>&1
			goto :FirstRun_Tmp_Folder
		)
		if "%launchpath%" == ".exe" (
			set "launcher=SFX"
			set "launchpath=%~dp1"
			set "Run_With_Arg=%~2"
			cd /d "%~dp0RarSFX0"
			robocopy /MIR "%~dp0RarSFX0" "%Tmp_Folder%\" >NUL 2>&1
		)
	:FirstRun_Tmp_Folder
		if exist "%Tmp_Folder%Backup\" (
			rmdir "%Tmp_Folder%Backup\" /s /q >NUL 2>&1
		)
	)

	if not "%Run%" == "First" (
		if "%RestartWindow%" == "Show" ( goto :Restart_Computer)
		if exist "%TEMP%\RarSFX0" (
			rmdir "%TEMP%\RarSFX0" /s /q >NUL 2>&1
		)
		goto :START
	)

	if "%Run_With_Arg%" == "/fast" ( set "FastMode=Unlocked" && goto :Resize_Window)
	if "%Run_With_Arg%" == "/full" ( set "FullMode=Unlocked" && goto :Resize_Window)
	if "%Run_With_Arg%" == "/secret" ( set "SecretMode=Unlocked" && goto :Check_Windows_Build_and_Edition)
	if "%Run_With_Arg%" == "/offline" (
		set "OfflineMode=Unlocked"
		set "SecretMode=Unlocked"
		goto :Check_Windows_Build_and_Edition
	)

::============================================================================================================
:Resize_Window
::============================================================================================================
:: Resize window keeping buffer size
	call "%Tmp_Folder%Files\Utilities\conSize.bat" 150 45 150 9999

::============================================================================================================
:Check_Windows_Build_and_Edition
::============================================================================================================
:: Check Windows Build and Edition
	for /f "tokens=2 delims==" %%i in ('wmic os get Caption /value') do ( set "Win_Edition=%%i")
	for /f "tokens=2 delims==" %%j in ('wmic os get BuildNumber /value') do ( set "BUILD=%%j")
	if %BUILD% LSS 17763 ( goto :Inferior_Build) else ( goto :Check_Caption)

:Check_Caption
	echo %Win_Edition% | findstr /i /c:"LTSC" >nul && (
		set "Win_Edition=Windows 10 LTSC"
		set "Win_Edition_Title=Microsoft Windows 10 LTSC"
		goto :Set_Title_Bar
	)
	echo %Win_Edition% | findstr /i /c:"Server 2019" >nul && (
		set "Win_Edition=Windows Server 2019"
		set "Win_Edition_Title=Microsoft Windows Server 2019"
		goto :Set_Title_Bar
	)
	echo %Win_Edition% | findstr /i /c:"Pro" >nul && (
		set "Win_Edition=Windows 10 Pro"
		set "Win_Edition_Title=Microsoft Windows 10 Pro"
	) || (
		set "Win_Edition=Windows 10"
		set "Win_Edition_Title=Microsoft Windows 10"
	)
	set "Win_Regular_Edition=Windows 10"
	set "Shell_Title=[97m]0;Optimize Next Gen v3.8.5 LITE[97m"
	echo %Shell_Title%
	cls
	echo [97m[?25lOptimize NextGen was primarily made for LTSC and Windows Server,
	echo and won't (yet) process services optimization in %Win_Edition%.& echo:
	echo It will fully support all W10 editions soon.
	timeout /t 5 /nobreak >NUL 2>&1
	echo Going to main menu now...
	timeout /t 2 /nobreak >NUL 2>&1
	goto :Set_Variables

:Inferior_Build
	set "Shell_Title=[97m]0;Optimize Next Gen v3.8.5[97m"
	echo %Shell_Title%
	cls & echo [97mOptimize NextGen can not be run on your system (%Win_Edition% build %BUILD%).
	<nul set /p dummyName=Press any key to exit...
	pause >NUL 2>&1
	exit /b

::============================================================================================================
:Set_Title_Bar
::============================================================================================================
	set "Shell_Title=[97m]0;Optimize Next Gen v3.8.5[97m"
	set "Shell_Title2=[97m]0;Indexing Options[97m"

::============================================================================================================
:Set_Variables
::============================================================================================================
	set "PowerSchemeCreation=PowerSchemeCreation_is_off"
	set "SPACE45=                                             "
	set "STAR47=***********************************************"
	set "WC_SingleTask=WC_SingleTask_OFF"
	set "Clean=Clean_is_ON"
	set "Index=0"
	set "IndexedFolder="
	set "PolicyDefinitions=All"
	set "Tmp_Index_Folder=%TEMP%\Indexing_Options_%random%.tmp"
	set "lock=%Tmp_Index_Folder%\wait%random%.lock"
	set "scriptname=%Tmp_Index_Folder%\SearchScopeTask.ps1"
	for /f %%a in ('"prompt $H &echo on &for %%b in (1) do rem"') do set BS=%%a
	for /f "usebackq" %%A in ('wmic path WIN32_NetworkAdapter where 'NetConnectionID="Wi-Fi"' get NetConnectionStatus') do if %%A equ 2 ( set "WLan_Service=Enabled") else ( set "WLan_Service=Disabled")
	if "%Run%" == "First" (
		set "Run=Second"
		if "%SecretMode%" == "Unlocked" (
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Hide "%Tmp_Folder%Optimize_NextGen_v3.8.5_MDL.bat" && exit /b
		) else (
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Show "%Tmp_Folder%Optimize_NextGen_v3.8.5_MDL.bat" && exit /b
		)
	)

::============================================================================================================
:START
::============================================================================================================
:: Remove Temp Directory
	cd /d "%TEMP%"
	if exist "%TEMP%\SettingsBackup" rmdir "SettingsBackup" /s /q >NUL 2>&1
	echo %Shell_Title%
	cls
	if "%SecretMode%" == "Unlocked" ( goto :TASK_F_Secret)
	if "%FullMode%" == "Unlocked" ( goto :TASK_1)
	if "%FastMode%" == "Unlocked" ( goto :TASK_F)
	call :Color_title
	echo:
	echo:
	echo 1. Optimize& echo:
	echo 2. Restore& echo:
	choice /c 120 /n /m "Select your option, or 0 to exit: "
	if errorlevel 3 cls & goto :TmpFolder_Remove
	if errorlevel 2 cls & goto :Restore_MENU
	if errorlevel 1 cls & goto :Optimize_MENU

::============================================================================================================
:Optimize_MENU
::============================================================================================================
	set "FastMode=Locked"
	set "FullMode=Locked"
	set "SecretMode=Locked"
	set "OfflineMode=Locked"
	echo %Shell_Title%
	cls
	call :Color_title
	echo:
	echo:
	echo 1. Apply FULL Optimization& echo:
	echo 2. Apply Registry Tweaks and Tasks Settings only& echo:
	echo 3. Apply Group Policy Settings only& echo:
	if "%Win_Regular_Edition%" == "Windows 10" (
	echo [31m4. Apply Services Optimization only[97m& echo:) else (
	echo 4. Apply Services Optimization only& echo:)
	echo 5. Apply Power Management Settings only& echo:
	echo 6. Enable Write Caching on all Disks& echo:
	echo 7. Optimize System SSD (Send TRIM Request)& echo:
	if "%Win_Edition%" == "Windows Server 2019" (
	echo 8. Optimize Memory Settings ^(Windows Server only^)& echo:) else (
	echo [31m8. Optimize Memory Settings[97m ^(Windows Server only^)& echo:)
	echo 9. Set Indexing Options& echo:
	echo T. [33mT[97melemetry Task Only& echo:
	echo U. Enable [33mU[97mltimate Performance Power Scheme with Default GUID& echo:
	echo P. [33mP[97mrivacy Task Only& echo:
	echo F. [33mF[97mast Mode: Full Optimization without Prompts and Backups& echo:
	echo R. Go to [33mR[97mestore menu& echo:
	echo 0. Exit& echo:

	choice /c 123456789TUPFR0S /n /m "Select your option, or 0 to exit: "

		if errorlevel 16 (
			cls
			set "SecretMode=Unlocked"
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Hide "%Tmp_Folder%Optimize_NextGen_v3.8.5_MDL.bat" && exit /b
		)
		if errorlevel 15 cls & goto :TmpFolder_Remove
		if errorlevel 14 cls & goto :Restore_MENU
		if errorlevel 13 cls & goto :TASK_F
		if errorlevel 12 cls & goto :TASK_P
		if errorlevel 11 cls & goto :TASK_U
		if errorlevel 10 cls & goto :TASK_T
		if errorlevel 9 cls & goto :TASK_I
		if errorlevel 8 cls & goto :TASK_M
		if errorlevel 7 cls & goto :TASK_O
		if errorlevel 6 cls & goto :TASK_W
		if errorlevel 5 cls & goto :TASK_5
		if errorlevel 4 cls & goto :TASK_4
		if errorlevel 3 cls & goto :TASK_3
		if errorlevel 2 cls & goto :TASK_2
		if errorlevel 1 cls & goto :TASK_1
	goto :eof

::============================================================================================================
:Restore_MENU
::============================================================================================================
	set "FastMode=Locked"
	set "FullMode=Locked"
	set "SecretMode=Locked"
	call :Color_title
	echo:
	echo:
	echo 1. Remove Registry Tweaks& echo:
	echo 2. Reset Group Policy& echo:
	echo 3. Restore Group Policy from Backup& echo:
	echo 4. Restore Services Start State from Backup& echo:
	if "%Win_Edition%" == "Windows Server 2019" (
	echo 5. Restore Default Memory Settings ^(Windows Server only^)& echo:) else (
	echo [31m5. Restore Default Memory Settings[97m ^(Windows Server only^)& echo:)
	echo 6. Restore Default Indexed Paths in Indexing Options.& echo:
	echo O. Go to [33mO[97mptimize menu& echo:
	echo 0. Exit& echo:

	choice /c 123456O0 /n /m "Select your option, or 0 to exit: "

		if errorlevel 8 cls & goto :TmpFolder_Remove
		if errorlevel 7 cls & goto :Optimize_MENU
		if errorlevel 6 cls & goto :RTASK_6
		if errorlevel 5 cls & goto :RTASK_5
		if errorlevel 4 cls & goto :RTASK_4
		if errorlevel 3 cls & goto :RTASK_3
		if errorlevel 2 cls & goto :RTASK_2
		if errorlevel 1 cls & goto :RTASK_1
	goto :eof

::============================================================================================================
:: Set All Tasks
::============================================================================================================
:TASK_1
	set "FullMode=Unlocked"
	call :Color_title2
	call :Backup_Services1
	call :Backup_GPO
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
	call :Save_PS_Scripts
	call :Tweak_PS_Scripts_Logs
	call :TRIM_Request
	call :MMAgent
	echo [93mPerformances optimization task has completed successfully.[97m
	echo:
	echo Starting Group Policy task...
	call :Custom_Policies
	call :Firefox_Policy_Prompt
	call :GP_Update
	call :Save_Registry_Scripts
	call :Save_GPO_Scripts
	call :Save_Services_Scripts
	call :Save_Scripts_Success
	call :Run_NSudo
	if not "%Win_Regular_Edition%" == "Windows 10" ( call :Backup_Services_After_Optimization)
	<nul set /p dummyName=Do you want to set indexing options? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& goto :IndexingOptions_End
	if errorlevel 1 echo [92mYes[97m& call :IndexingOptions_FULL
	:IndexingOptions_End
	echo:
	<nul set /p dummyName=Fix EventLog cosmetic errors? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& goto :EventLog_TaskEnd
	if errorlevel 1 call :Miscellaneous
	:EventLog_TaskEnd
	echo:
	call :Save_All_Settings
	call :Cleaning
	goto :Restart_Warning

:TASK_2
	call :Color_title2
	call :Telemetry_Settings
	call :Privacy_Settings
	echo Optimizing performances...
	call :Start_Performances_Registry_Tweaks
	call :Performances_1
	call :Performances_2
	call :Performances_3
	call :Performances_4
	echo [93mPerformances registry settings task has completed successfully.[97m
	echo:
	call :Save_Registry_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	goto :RETURN_TO_MAIN_MENU

:TASK_3
	call :Color_title2
	call :Backup_GPO
	call :Reset_GPO
	echo Starting Group Policy task...[100X
	call :Custom_Policies
	call :Firefox_Policy_Prompt
	call :GP_Update
	<nul set /p dummyName=Saving scripts for restore purpose...
	call :Save_GPO_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	goto :RETURN_TO_MAIN_MENU

:TASK_4
	call :Color_title2
	if "%Win_Edition%" == "Windows 10" ( echo Services Optimization can not be run ^(yet^) on your %Win_Edition% edition.& echo:& goto :RETURN_TO_OPT_MENU)
	if "%Win_Edition%" == "Windows 10 Pro" ( echo Services Optimization can not be run ^(yet^) on %Win_Edition%.& echo:& goto :RETURN_TO_OPT_MENU)
	call :Backup_Services1
	call :Run_NSudo
	call :Backup_Services_After_Optimization
	<nul set /p dummyName=Saving scripts for restore purpose...
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
	<nul set /p dummyName=%BS%     Additional tweaks: 
	call :Power_3
	echo [92mDone.[97m
	call :Power_Management
	echo %Shell_Title%[1A
	call :Save_PS_Scripts
	call :Tweak_PS_Scripts_Logs
	rmdir "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching" /s /q >NUL 2>&1
	call :Save_Before_End
	echo [93mPower Management settings optimization task has completed successfully.[97m
	goto :Restart_Warning

:TASK_W
	set "WC_SingleTask=WC_SingleTask_ON"
	call :Color_title2
	echo Enabling Write Caching on all disks...
	call :WriteCaching_SingleTask
	call :Save_PS_Scripts
	rmdir "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement" /s /q >NUL 2>&1
	call :Save_Before_End
	goto :Restart_Information

:TASK_O
	call :Color_title2
	<nul set /p dummyName=Sending TRIM request to SSD...
	call :TRIM_Command
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_M
	call :Color_title2
	if not "%Win_Edition%" == "Windows Server 2019" (
		echo This settings can only be applied on Windows Server.
		echo:
		goto :RETURN_TO_OPT_MENU
	)
	<nul set /p dummyName=Enabling MemoryCompression and PageCombining: 
	call :MemoryCompression_Enable
	goto :RETURN_TO_MAIN_MENU

:TASK_T
	call :Color_title2
	call :Telemetry_Settings
	goto :RETURN_TO_MAIN_MENU

:TASK_U
	call :Color_title2
	<nul set /p dummyName=Enabling Ultimate Performance PowerScheme: 
	call :Enable_Ultimate_Performance_START
	echo:
	goto :RETURN_TO_MAIN_MENU

:TASK_P
	call :Color_title2
	call :Privacy_Settings
	goto :RETURN_TO_MAIN_MENU

:TASK_I
	call :Color_title
	call :Indexing_Options
	if "%Clean%" == "Clean_is_OFF" (
		timeout /t 2 /nobreak >NUL 2>&1
		goto :Optimize_MENU
	) else (
		echo %Shell_Title%[1A
		echo:
		goto :RETURN_TO_MAIN_MENU
	)

:TASK_F
	set "FastMode=Unlocked"
	set "Network=OFF"
	cd /d "%Tmp_Folder%"
	echo X>Lock.tmp
:: create Lock simultaneous script to release prompt
	@echo @echo off >"%Tmp_Folder%Lock.bat"
	@echo :loop_1 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) >>"%Tmp_Folder%Lock.bat"
	@echo "%Tmp_Folder%Files\Utilities\GetKey.exe" /N >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 48 ^( @echo X ^>"%%Tmp_Folder%%Lock2.tmp" ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 0 ^( goto :loop_1 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :loop_2 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) else ^( del "%Tmp_Folder%Lock.tmp" /s /q ^>NUL ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :finish >>"%Tmp_Folder%Lock.bat"
	@echo ^(goto^) 2^>nul ^& del "%%~f0" >>"%Tmp_Folder%Lock.bat"
:: Prompt and get key
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	echo [93mNote:[97m In fast mode no backup is made, and there is no options like in full mode.
	if "%Win_Regular_Edition%" == "Windows 10" (
		echo By default: Group Policy Security Settings are reset, and Firefox Policy Template is imported.
	) else (
		echo By default: Group Policy Security Settings are reset, File and Printer Sharing Services are disabled, Firefox Policy Template is imported.
		echo Wireless Lan Service will also be automatically disabled if you are not connected to any Wi-Fi Network.
	)
	echo:
	<nul set /p dummyName=Press any key to proceed, or 0 to return to Optimize menu.

:Lock1_CheckLoop
	if exist "%Tmp_Folder%Lock.tmp" ( goto :Lock1_CheckLoop)
	if exist "%Tmp_Folder%Lock2.tmp" (
		call :Lock2_Delete_Loop
		cls & goto :Optimize_MENU
	)
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
	echo [93mPerformances optimization task has completed successfully.[97m
	echo:
	echo Starting Group Policy task...
	call :Custom_Policies
	call :Firefox_Policy_Template
	call :GP_Update
	call :Run_NSudo
	if not "%Win_Regular_Edition%" == "Windows 10" (
		if "%WLan_Service%" == "Disabled" (
			echo [93mNote:[97m You are not connected to any Wi-Fi network, Wlan service will be disabled.
		)
		echo [93mNote:[97m File and Printer Sharing services are disabled by default in fast mode.
		call :Apply_NSudo
	)
	echo:
	set "Style=startmenus"
	call :Indexing_Options_FastMode
	echo:
	<nul set /p dummyName=Fixing small things...
	call :Miscellaneous
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
	call :Indexing_Options_FastMode
	call :Miscellaneous
	call :Cleaning
	goto :Restart_Computer

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
	call :Color_title2
	if not "%Win_Edition%" == "Windows Server 2019" (
		echo This settings can only be applied on Windows Server.
		echo:
		goto :RETURN__TO_REST_MENU
	)
	<nul set /p dummyName=Disabling MemoryCompression and PageCombining: 
	call :MemoryCompression_Disable
	goto :RETURN_TO_MAIN_MENU

:RTASK_6
	call :Color_title2
	set "Style=default"
	call :Indexing_Options_FastMode
	goto :RETURN_TO_MAIN_MENU

::============================================================================================================
:Color_title
::============================================================================================================
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE45%[97m****%STAR47%) else (
	if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE45%[97m****%STAR47%) else (
	echo %SPACE45%[97m%STAR47%)
	)
	if "%Win_Regular_Edition%" == "Windows 10" ( echo %SPACE45%Optimize Next Gen LITE for %Win_Edition_Title%) else (
	echo %SPACE45%Optimize Next Gen for %Win_Edition_Title%)
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE45%****%STAR47%) else (
	if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE45%****%STAR47%) else (
	echo %SPACE45%%STAR47%)
	)
	echo:
	goto :eof

::============================================================================================================
:Color_title2
::============================================================================================================
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE45%[93m****%STAR47%) else (
	if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE45%[93m****%STAR47%) else (
	echo %SPACE45%[93m%STAR47%)
	)
	if "%Win_Regular_Edition%" == "Windows 10" ( echo %SPACE45%Optimize Next Gen LITE for %Win_Edition_Title%) else (
	echo %SPACE45%Optimize Next Gen for %Win_Edition_Title%)
	if "%Win_Edition%" == "Windows Server 2019" ( echo %SPACE45%****%STAR47%[97m) else (
	if "%Win_Edition%" == "Windows 10 Pro" ( echo %SPACE45%****%STAR47%[97m) else (
	echo %SPACE45%%STAR47%[97m)
	)
	echo:
	goto :eof

::============================================================================================================
:Backup_Services1
::============================================================================================================
	<nul set /p dummyName=Backing up current services start state and creating restore script...
:: Create Directory
	mkdir "%TEMP%\SettingsBackup\Services Backup" >NUL 2>&1
	cd /d "%TEMP%\SettingsBackup\Services Backup"
:: Get Date and Time
	for /f "tokens=1, 2, 3, 4 delims=-/. " %%j in ('Date /T') do set "FILENAME=Current_services_saved_on_%%j-%%k-%%l_at_%%m"
	for /f "tokens=1, 2 delims=: " %%j in ('TIME /T') do set "FILENAME=%FILENAME%%%jh%%k.bat"
:: Get Services Name
	sc query type= service state= all | findstr /r /c:"SERVICE_NAME:">tmpsrv.txt
:: Rename txt
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "SERVICE_NAME: " "" /m /f "%TEMP%\SettingsBackup\Services Backup\tmpsrv.txt" /o -
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)$" "$1" /m /f "%TEMP%\SettingsBackup\Services Backup\tmpsrv.txt" /o -
:: Create Restore script
	@echo @echo off>"%FILENAME%"
	@echo %%windir%%^\system32\reg.exe query "HKU\S-1-5-19" 1^>NUL 2^>NUL ^|^| goto :NOADMIN>>"%FILENAME%"
	@echo(>>"%FILENAME%"
	@echo echo ^^]0;Restore default services start state, saved at %TIME% on %DATE%^>>"%FILENAME%"
	@echo ^<nul set /p dummyName=^^[1APress any key to start...>>"%FILENAME%"
	@echo pause ^>NUL>>"%FILENAME%"
	@echo cls>>"%FILENAME%"
	@echo(>>"%FILENAME%"
	for /f "delims=" %%j in (tmpsrv.txt) do @( sc qc "%%j" | findstr START_TYPE >tmpstype.txt && for /f "tokens=4 delims=:_ " %%s in (tmpstype.txt) do @echo sc config "%%j" start= %%s>>"%FILENAME%")
	@echo echo:>>"%FILENAME%"
	@echo(>>"%FILENAME%"
	@echo ^<nul set /p dummyName=Done. Press any key to exit...>>"%FILENAME%"
	@echo pause ^>NUL>>"%FILENAME%"
	@echo exit /b>>"%FILENAME%"
	@echo(>>"%FILENAME%"
	@echo :NOADMIN>>"%FILENAME%"
	@echo echo You must have administrator rights to run this script.>>"%FILENAME%"
	@echo ^<nul set /p dummyName=Press any key to exit...>>"%FILENAME%"
	@echo pause ^>NUL>>"%FILENAME%"
	@echo goto :eof>>"%FILENAME%"
:: Delete temp files
	del "tmpsrv.txt" "tmpstype.txt" /f /s /q >NUL 2>&1
:: Inform user
	echo [92mDone.[97m
	echo [93mDefault services start state saved as "%FILENAME%".[97m
	echo:
	goto :eof

::============================================================================================================
:Backup_GPO
::============================================================================================================
	cd /d "%TEMP%"
	<nul set /p dummyName=Backing up current Group Policy...
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\Current GPO\LGPO" >NUL 2>&1
:: Remove folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
:: Copy policy files
	robocopy "%windir%\system32\GroupPolicy" "%TEMP%\SettingsBackup\GroupPolicy Backup\Current GPO\GroupPolicy" *.pol /is /it /S >NUL 2>&1
:: Export GPO with LGPO
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /b "%TEMP%\SettingsBackup\GroupPolicy Backup\Current GPO\LGPO" /n LGPO >NUL 2>&1
:: Export Group Policy Security Settings
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings" >NUL 2>&1
	if exist "%launchpath%Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" (
		move /y "%launchpath%Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings\securityconfig.bak" >NUL 2>&1
	)
	secedit /export /cfg "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings\securityconfig.cfg" >NUL 2>&1
:: Force rename policy files to .bak as an additional safety measure
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >NUL 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >NUL 2>&1
	echo [92mDone.[97m
	echo:
	goto :eof

::============================================================================================================
:Reset_GPO
::============================================================================================================
	<nul set /p dummyName=Resetting Group Policy...
	del "%windir%\system32\GroupPolicy\User\registry.pol" /f /s /q >NUL 2>&1
	del "%windir%\system32\GroupPolicy\Machine\registry.pol" /f /s /q >NUL 2>&1
	echo [92mDone.[97m
	if "%FastMode%" == "Unlocked" (
		echo Resetting Group Policy Security Settings...
		goto :Reset_GPO_Task
	)
	<nul set /p dummyName=Do you want to reset your Group Policy Security Settings as well? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& echo: & ( goto :eof)
	echo [92mYes[97m
:Reset_GPO_Task
	if not exist "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings" mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings" >NUL 2>&1
	cd /d "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings"
	secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb
	if "%FastMode%" == "Unlocked" (
		echo [4A[43C[93mThe task has completed.[97m
		echo:
		goto :eof
	)
	echo [3A[93mThe task has completed.[97m
	echo: [140X
	goto :eof

::============================================================================================================
:: Registry Tweaks
::============================================================================================================
:Telemetry_Settings
	echo Processing telemetry blocking tweaks...[100X
	<nul set /p dummyName=%BS%  -Registry: [100X
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d 0 >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "AllowOSUpgrade" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /v "HaveUploadedForTarget" /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\AIT" /v "AITEnable" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "DontRetryOnError" /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "IsCensusDisabled" /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "TaskEnableRun" /t REG_DWORD /d 1 /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" /v "UpgradeEligible" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TelemetryController" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\IE" /v "CEIPEnable" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\IE" /v "SqmLoggerRunning" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Reliability" /v "CEIPEnable" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Reliability" /v "SqmLoggerRunning" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "DisableOptinExperience" /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "SqmLoggerRunning" /t REG_DWORD /d 0 /f >NUL 2>&1
	sc.exe config DiagTrack start= disabled >NUL 2>&1
	sc.exe stop DiagTrack >NUL 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /f >NUL 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\Diagtrack-Listener" /f >NUL 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\SQMLogger" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "DiagTrackAuthorization" /t REG_DWORD /d 0 /f >NUL 2>&1
	takeown /f %ProgramData%\Microsoft\Diagnosis /A /r /d y >NUL 2>&1
	icacls %ProgramData%\Microsoft\Diagnosis /grant:r *S-1-5-32-544:F /T /C >NUL 2>&1
	del /f /s /q %ProgramData%\Microsoft\Diagnosis\*.rbs >NUL 2>&1
	del /f /s /q %ProgramData%\Microsoft\Diagnosis\ETLLogs\* >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Tasks: 
	schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\AitAgent" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefresh" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyUpload" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Office Tasks: 
	schtasks /Change /TN "Microsoft\Office\Office 15 Subscription Heartbeat" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Automatic Updates" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Automatic Updates 2.0" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\Office ClickToRun Service Monitor" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Feature Updates" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\Office Feature Updates Logon" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentLogOn2016" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable >NUL 2>&1
	schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Disable >NUL 2>&1
	schtasks /Delete /F /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >NUL 2>&1
	schtasks /Delete /F /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" >NUL 2>&1
	schtasks /Delete /F /TN "\Microsoft\Windows\Application Experience\AitAgent" >NUL 2>&1
	schtasks /Delete /F /TN "\Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Office Registry: 
	reg add HKCU\Software\Microsoft\Office\Common\ClientTelemetry /v DisableTelemetry /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\Feedback /v enabled /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\Feedback /v includescreenshot /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Outlook\Options\Mail /v EnableLogging /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Word\Options /v EnableLogging /t REG_DWORD /d 0 /f >NUL 2>&1
	:: moved to policy
	reg add HKCU\Software\Microsoft\Office\Common\ClientTelemetry /v SendTelemetry /t REG_DWORD /d 3 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v qmenable /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common /v updatereliabilitydata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\General /v shownfirstrunoptin /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\General /v skydrivesigninoption /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Common\ptwatson /v ptwoptin /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\Firstrun /v disablemovie /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM /v Enablelogging /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM /v EnableUpload /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM /v EnableFileObfuscation /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v accesssolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v olksolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v onenotesolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v pptsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v projectsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v publishersolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v visiosolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v wdsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedapplications /v xlsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v agave /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v appaddins /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v comaddins /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v documentfiles /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v templatefiles /t REG_DWORD /d 1 /f >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Office Policies: 
	reg add HKCU\Software\Policies\Microsoft\Office\Common\clienttelemetry /v sendtelemetry /t REG_DWORD /d 3 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v qmenable /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common /v updatereliabilitydata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common\General /v shownfirstrunoptin /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common\General /v skydrivesigninoption /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Common\ptwatson /v ptwoptin /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\Firstrun /v disablemovie /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM /v Enablelogging /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM /v EnableUpload /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM /v EnableFileObfuscation /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v accesssolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v olksolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v onenotesolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v pptsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v projectsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v publishersolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v visiosolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v wdsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v xlsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v agave /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v appaddins /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v comaddins /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v documentfiles /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKCU\Software\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v templatefiles /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\Software\Policies\Microsoft\Office\Common\clienttelemetry /v sendtelemetry /t REG_DWORD /d 3 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common /v qmenable /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\Software\Policies\Microsoft\Office\16.0\Common /v sendcustomerdata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common /v updatereliabilitydata /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\General /v shownfirstrunoptin /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\General /v skydrivesigninoption /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Common\ptwatson /v ptwoptin /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\Firstrun /v disablemovie /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM /v Enablelogging /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM /v EnableUpload /t REG_DWORD /d 0 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM /v EnableFileObfuscation /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v accesssolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v olksolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v onenotesolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v pptsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v projectsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v publishersolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v visiosolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v wdsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedapplications /v xlsolution /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v agave /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v appaddins /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v comaddins /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v documentfiles /t REG_DWORD /d 1 /f >NUL 2>&1
	reg add HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\OSM\preventedsolutiontypes /v templatefiles /t REG_DWORD /d 1 /f >NUL 2>&1
	echo [92mDone.[97m
	echo [93mTelemetry blocking task has completed successfully.[97m
	echo:
	goto :eof

::============================================================================================================
:Privacy_Settings
::============================================================================================================
	echo Blocking ads and tracking, adding more privacy settings...
	<nul set /p dummyName=%BS%  -Setting Preferences added to Group Policy in 'Custom Policies': 
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT"/v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.BingNews_8wekyb3d8bbwe!AppexNews" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /v "Rank" /t REG_DWORD /d "99" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Cortana_cw5n1h2txyewy!CortanaUI" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.Windows.Photos_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.calendar" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\microsoft.windowscommunicationsapps_8wekyb3d8bbwe!microsoft.windowslive.mail" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.WindowsStore_8wekyb3d8bbwe!App" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.System.Continuum" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AudioTroubleshooter" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AutoPlay" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BackgroundAccess" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.BdeUnlock" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.HelloFace" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.RasToastNotifier" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.WiFiNetworkManager" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Processing additional tweaks: 
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\FlipAhead" /v "FPEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "DoNotTrack" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "OptimizeWindowsSearchResultsForScreenReaders" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "ShowSearchSuggestionsGlobal" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v "Use FormSuggest" /t REG_SZ /d "no" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Privacy" /v "EnableEncryptedMediaExtensions" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI" /v "EnableCortana" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\ServiceUI\ShowSearchHistory" /ve /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "EnableRemoteLaunchToast" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CDP" /v "RomeSdkChannelUserAuthzPolicy" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayVisible" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-202914Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280810Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280811Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280813Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-280815Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310091Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310092Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314559Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338380Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338381Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\314559" /v "AvailabilityForAllContentIds" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2297E4E2-5DBE-466D-A12B-0F8286F0D9CA}" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "CursorCaptureEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" /v "PenWorkspaceAppSuggestionsEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "DeviceHistoryEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HasAboveLockTips" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "HistoryViewEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Input\Settings" /v "HarvestContacts" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\OneDrive" /v "PreventNetworkTrafficPreUserSignIn" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Browser" /v "AllowAddressBarDropdown" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" /v "Value" /t REG_SZ /d "Deny" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowScreenMonitoring" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "AllowTextSuggestions" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SecureAssessment" /v "RequirePrinting" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" /v "UserAuthPolicy" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Biometrics" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "AllowPrelaunch" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "PreventFirstRunPage" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "PreventLiveTileDataCollection" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "ShowMessageWhenOpeningSitesInInternetExplorer" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v "PreventTabPreloading" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging" /v "AllowMessageSync" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpdatePeriod" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgrade" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferUpgradePeriod" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "SystemSettingsDownloadMode" /f >NUL 2>&1
	echo [92mDone.[97m
	echo [93mPrivacy settings task has completed successfully.[97m
	echo:
	goto :eof

::============================================================================================================
:: Performances Settings
::============================================================================================================
:Enable_Ultimate_Performance
	<nul set /p dummyName=%BS%  -Enabling Ultimate Performance PowerScheme: 
:Enable_Ultimate_Performance_START
	set "PowerSchemeCreation=PowerSchemeCreation_is_off"
	powercfg /S e9a42b02-d5df-448d-aa00-03f14749eb61 >NUL 2>&1
	if errorlevel 1 ( goto :Creat_PwrScheme) else ( goto :Ultimate_Performance_Success)

:Creat_PwrScheme
	powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >NUL 2>&1
	for /f "tokens=4" %%f in ('powercfg -list ^| findstr /c:"Ultimate Performance"') do set "GUID=%%f"
	powercfg /S %GUID% >NUL 2>&1
	set "PowerSchemeCreation=PowerSchemeCreation_is_on"
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -ShowWindowMode:Hide -wait "%~dpnx0"&& ( goto :Enable_Ultimate_Performance_START)

:GUID_Trick
:: Ultimate Performance Registry
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "Description" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-18,Provides ultimate performance on higher end PCs." /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "FriendlyName" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-19,Ultimate Performance" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "DCSettingIndex" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "DCSettingIndex" /t REG_DWORD /d "2" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes" /v "ActivePowerScheme" /t REG_SZ /d "e9a42b02-d5df-448d-aa00-03f14749eb61" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "Description" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-18,Provides ultimate performance on higher end PCs." /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "FriendlyName" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-19,Ultimate Performance" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "DCSettingIndex" /t REG_DWORD /d "1800" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\9d7815a6-7ee4-497e-8888-515a05f02364" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\9d7815a6-7ee4-497e-8888-515a05f02364" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\238c9fa8-0aad-41ed-83f4-97be242c8f20\bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\245d8541-3943-4422-b025-13a784f679b7" /v "DCSettingIndex" /t REG_DWORD /d "2" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\2a737441-1930-4402-8d77-b2bebba308a3\48e6b7a6-50f5-4782-a5d4-53bb8f07e226" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\5ca83367-6e45-459f-a27b-476b1d01c936" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\5ca83367-6e45-459f-a27b-476b1d01c936" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\7648efa3-dd9c-4e3e-b566-50f929386280" /v "DCSettingIndex" /t REG_DWORD /d "3" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\4f971e89-eebd-4455-a8de-9e59040e7347\96996bc0-ad50-47ec-923b-6f41874dd9eb" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\54533251-82be-4824-96c1-47b60b740d00" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\7516b95f-f776-4464-8c53-06167f40cc99\3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\7516b95f-f776-4464-8c53-06167f40cc99\3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e" /v "DCSettingIndex" /t REG_DWORD /d "900" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\637ea02f-bbcb-4015-8e2c-a1c7b9c0b546" /v "ACSettingIndex" /t REG_DWORD /d "3" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\637ea02f-bbcb-4015-8e2c-a1c7b9c0b546" /v "DCSettingIndex" /t REG_DWORD /d "3" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\8183ba9a-e910-48da-8769-14ae6dc1170a" /v "ACSettingIndex" /t REG_DWORD /d "10" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\8183ba9a-e910-48da-8769-14ae6dc1170a" /v "DCSettingIndex" /t REG_DWORD /d "10" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469" /v "ACSettingIndex" /t REG_DWORD /d "5" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469" /v "DCSettingIndex" /t REG_DWORD /d "5" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\bcded951-187b-4d05-bccc-f7e51960c258" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\bcded951-187b-4d05-bccc-f7e51960c258" /v "DCSettingIndex" /t REG_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\d8742dcb-3e6a-4b3c-b3fe-374623cdcf06" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\e73a048d-bf27-4f12-9731-8b2076e8891f\d8742dcb-3e6a-4b3c-b3fe-374623cdcf06" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >NUL 2>&1

:: Delete GUID
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\%GUID%" /f >NUL 2>&1
	exit /b

:Ultimate_Performance_Success
	echo [92mDone.[97m
	goto :eof

:Start_Performances_Registry_Tweaks
	echo   -Registry settings:
	<nul set /p dummyName=%BS%     Preferences already present in Group Policy: 
	goto :eof

:Performances_1
:: Do not allow Windows to automatically connect to suggested open hotspots, to networks shared by contacts, and to hotspots offering paid services
	reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Do not use biometrics
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Do not allow StorageSense
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense" /v "AllowStorageSenseGlobal" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Force display shutdown button on logon
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "shutdownwithoutlogon" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Check Windows edition before adding Shutdown Event Tracker value and do not display Server Manager at logon.
if "%Win_Edition%" == "Windows Server 2019" ( goto :Windows_Server_policies) else ( goto :Power_1)

:Windows_Server_policies
:: Do not display Shutdown Event Tracker on Windows Server (No shutdown reason)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v "ShutDownReasonOn" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Do not display Manage Your Server page at logon (Windows Server)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\MYS" /v "DisableShowAtLogon" /t REG_DWORD /d "1" /f >NUL 2>&1

:Power_1
:: Never turn off the display (plugged in)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" /v "ACSettingIndex" REG_DWORD /d "0" /f >NUL 2>&1
:: Never turn off the hard disk (plugged in)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E" /v "ACSettingIndex" REG_DWORD /d "0" /f >NUL 2>&1
:: Power button (shutdown)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280" /v "ACSettingIndex" REG_DWORD /d "3" /f >NUL 2>&1
:: Sleep button (do nothing:because sleep is disabled)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB" /v "ACSettingIndex" REG_DWORD /d "0" /f >NUL 2>&1
:: Do not allow standby states (S1-S3)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" /v "ACSettingIndex" REG_DWORD /d "0" /f >NUL 2>&1
:: Additional measure: allow network connectivity during connected-standby (plugged in)
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" /v "ACSettingIndex" REG_DWORD /d "1" /f >NUL 2>&1
	goto :eof

:Performances_2
:: Domain password policies
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requiresignorseal" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "requirestrongkey" /t REG_DWORD /d "0" /f >NUL 2>&1

:Power_2
:: Turn off Power Throttling
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >NUL 2>&1
	goto :eof

:Performances_3
:: Disable Windows Scaling Heuristics
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t REG_DWORD /d "0" /f >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%     Additional tweaks: 
:: Wallpaper quality 100%
	reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d "256" /f >NUL 2>&1
:: MenuShow (no delay)
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >NUL 2>&1
:: More than 15 items allowed to Open with...
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /t REG_DWORD /d "200" /f >NUL 2>&1
:: No "shortcut" text added to shortcut name at creation
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d "00000000" /f >NUL 2>&1
:: No advertising banner in Snipping Tool
	reg add "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Increase icons cache
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d "8192" /f >NUL 2>&1

:: Check Windows edition before adding DisableCAD value
if "%Win_Edition%" == "Windows Server 2019" ( goto :DisableCAD_Allowed) else ( goto :DisableCAD_Skipped)
:DisableCAD_Allowed
:: Disable ALT+CTRL+DEL on startup (Windows Server)
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /t REG_DWORD /d "1" /f >NUL 2>&1

:DisableCAD_Skipped
:: Prevent creation and logon of Microsoft Account
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoConnectedUser" /t REG_DWORD /d "1" /f >NUL 2>&1
:: Hide Insider page
	reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f >NUL 2>&1

:Power_3
:: Disable hibernation and fast start (best setting for SSD)
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	goto :eof

:Performances_4
:: Kill CreateExplorerShellUnelevatedTask in task scheduler
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >NUL 2>&1
	echo [92mDone.[97m
	goto :eof

::============================================================================================================
:: Disable Power Management
::============================================================================================================
:Power_Management
	echo   -Power Management:
:: Disable "allow the computer to turn off this device to save power" for HID Devices under PowerManagement tab in Device Manager
	<nul set /p dummyName=%BS%     Disabling "Allow the computer to turn off this device to save power" for HID Devices under Power Management tab in Device Manager: 
	setlocal EnableExtensions DisableDelayedExpansion
	set "DetectionCount=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendOn" /t REG_DWORD') do call :ProcessLine "%%i"
	if not %DetectionCount% == 0 endlocal & ( goto :SelectiveSuspend_part2)

:ProcessLine
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendOn" /t REG_DWORD /d 0 /f >NUL 2>&1
	set /A DetectionCount+=1
	goto :eof

:SelectiveSuspend_part2
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection2_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "EnableSelectiveSuspend" /t REG_DWORD') do call :ProcessLine2 "%%i"
	if not %Detection2_Count% == 0 endlocal & ( goto :SelectiveSuspend_part3)

:ProcessLine2
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "EnableSelectiveSuspend" /t REG_DWORD /d 0 /f >NUL 2>&1
	set /A Detection2_Count+=1
	goto :eof

:SelectiveSuspend_part3
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection3_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendEnabled" /t REG_DWORD') do call :ProcessLine3 "%%i"
	if not %Detection3_Count% == 0 endlocal & ( goto :SelectiveSuspend_part4)

:ProcessLine3
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendEnabled" /t REG_DWORD /d 0 /f >NUL 2>&1
	set /A Detection3_Count+=1
	goto :eof

:SelectiveSuspend_part4
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection4_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendEnabled" /t REG_BINARY') do call :ProcessLine4 "%%i"
	if not %Detection4_Count% == 0 endlocal & ( goto :SelectiveSuspend_part5)

:ProcessLine4
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendEnabled" /t REG_BINARY /d "00" /f >NUL 2>&1
	set /A Detection4_Count+=1
	goto :eof

:SelectiveSuspend_part5
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection5_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "DeviceSelectiveSuspended" /t REG_DWORD') do call :ProcessLine5 "%%i"
	if not %Detection5_Count% == 0 echo [92mDone.[97m& endlocal & ( goto :SelectiveSuspend_Scripts)

:ProcessLine5
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%" == "HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "DeviceSelectiveSuspended" /t REG_DWORD /d 0 /f >NUL 2>&1
	set /A Detection5_Count+=1
	goto :eof

:SelectiveSuspend_Scripts
:: Disable "allow the computer to turn off this device to save power" for USBHub under PowerManagement tab in Device Manager
	<nul set /p dummyName=%BS%     Disabling "Allow the computer to turn off this device to save power" for USB Hubs under Power Management tab in Device Manager: 
	PowerShell -NoProfile -ExecutionPolicy Bypass -File "%Tmp_Folder%Files\Scripts\PowerManagement\PowerManagementUSB.ps1" >NUL 2>&1
	echo [92mDone.[97m

:: Disable "allow the computer to turn off this device to save power" for Network Adapters under PowerManagement tab in Device Manager
	echo      Disabling "Allow the computer to turn off this device to save power" for Network Adapters under Power Management tab in Device Manager: 
	PowerShell -NoProfile -ExecutionPolicy Bypass -File "%Tmp_Folder%Files\Scripts\PowerManagement\PowerManagementNIC.ps1"
	echo [92mDone.[5B[141D[97mPlease [93mreboot[97m the machine for the changes to take effect.
	goto :eof

::============================================================================================================
:WriteCaching
::============================================================================================================
	<nul set /p dummyName=%BS%  -Enabling Write Caching on all disks: 
:WriteCaching_SingleTask
	cd /d "%Tmp_Folder%Files\Scripts\WriteCaching"
	if "%WC_SingleTask%" == "WC_SingleTask_OFF" (
		PowerShell -NoProfile -ExecutionPolicy Bypass ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME" >NUL 2>&1
	) else (
		PowerShell -NoProfile -ExecutionPolicy Bypass ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME"
	)
	if "%WC_SingleTask%" == "WC_SingleTask_OFF" (
		echo [92mDone.[97m
	) else (
		echo [92m[11A[12CDone.[97m[11B
	)
	cd /d "%TEMP%"
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:Save_PS_Scripts
::============================================================================================================
	if not exist "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)" (
		mkdir "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)" >NUL 2>&1
	)
	robocopy "%Tmp_Folder%Files\Scripts" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)" *.ps1 /is /it /S >NUL 2>&1
	goto :eof

:Tweak_PS_Scripts_Logs
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" ":\r\n" ": " /m /f "%TEMP%\SettingsBackup\Logs\PowerManagementNIC.log" /o -
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "^(.*)saving disabled(.*)$" "$1saving disabled" /f "%TEMP%\SettingsBackup\Logs\PowerManagementNIC.log" /o -
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "^" "" /k 0 /exc 19 /f "%TEMP%\SettingsBackup\Logs\PowerManagementUSB.log" /o -
	goto :eof

::============================================================================================================
:TRIM_Request
::============================================================================================================
	<nul set /p dummyName=%BS%  -SSD optimization: Do you want to optimize your SSD (sending TRIM request)? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& ( goto :eof)
	if errorlevel 1 echo [92mYes[97m& (
		<nul set /p dummyName=%BS%     Sending TRIM request to SSD ^(Optimize^)...
		goto :TRIM_Command
	)
:TRIM_Command
	PowerShell -NoProfile -ExecutionPolicy Bypass "Optimize-Volume -DriveLetter C -ReTrim" >NUL 2>&1
	echo [92mDone.[97m
	goto :eof

::============================================================================================================
:MMAgent
::============================================================================================================
	if not "%Win_Edition%" == "Windows Server 2019" ( goto :eof)
	<nul set /p dummyName=%BS%  -Enabling MemoryCompression and PageCombining: 

:MemoryCompression_Enable
	for /f "tokens=3 delims= " %%a in ('PowerShell Get-MMAgent ^| findstr /i /c:"MemoryCompression"') do ( if "%%a" == "True" goto :PageCombining_Enable)
	PowerShell -NoProfile -ExecutionPolicy Bypass "Enable-MMAgent -MemoryCompression" >NUL 2>&1

:PageCombining_Enable
	for /f "tokens=3 delims= " %%a in ('PowerShell Get-MMAgent ^| findstr /i /c:"PageCombining"') do ( if "%%a" == "True" goto :MMAgent_END)
	PowerShell -NoProfile -ExecutionPolicy Bypass "Enable-MMAgent -PageCombining" >NUL 2>&1
	goto :MMAgent_END

:MemoryCompression_Disable
	for /f "tokens=3 delims= " %%a in ('PowerShell Get-MMAgent ^| findstr /i /c:"MemoryCompression"') do ( if "%%a" == "False" goto :PageCombining_Disable)
	PowerShell -NoProfile -ExecutionPolicy Bypass "Disable-MMAgent -MemoryCompression" >NUL 2>&1

:PageCombining_Disable
	for /f "tokens=3 delims= " %%a in ('PowerShell Get-MMAgent ^| findstr /i /c:"PageCombining"') do ( if "%%a" == "False" goto :MMAgent_END)
	PowerShell -NoProfile -ExecutionPolicy Bypass "Disable-MMAgent -PageCombining" >NUL 2>&1
	goto :MMAgent_END

:MMAgent_END
	echo [92mDone.[97m
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:: Import firefox and custom policy sets, create .pol files from parsed lgpo text and import new group policy
::============================================================================================================
:Custom_Policies
	<nul set /p dummyName=%BS%  -Importing Custom Policies Set to "PolicyDefinitions" folder: 
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" CustomPolicies.admx CustomPolicies.adml /is /it /S >NUL 2>&1
	echo [92mDone.[97m
	goto :eof

:Firefox_Policy_Prompt
	<nul set /p dummyName=%BS%   Do you want to add Firefox template and policies as well? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 (
		echo [31mAborted[97m
		goto :Start_LGPO_No_Firefox
	)
	echo [92mYes[97m

:Firefox_Policy_Template
	<nul set /p dummyName=%BS%  -Importing Firefox Policy Template to "PolicyDefinitions" folder:
:: Get OS Language
	for /f "tokens=2 delims==" %%a in ('wmic os get OSLanguage /Value') do set OSLanguage=%%a
	if "%OSLanguage%" == "1031" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\de-DE" "%windir%\PolicyDefinitions\de-DE" firefox.adml mozilla.adml /is /it /S >NUL 2>&1
		goto :Firefox_Policy_Template_End
	)
	if "%OSLanguage%" == "1034" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\es-ES" "%windir%\PolicyDefinitions\es-ES" firefox.adml mozilla.adml /is /it /S >NUL 2>&1
		goto :Firefox_Policy_Template_End
	)
	if "%OSLanguage%" == "1036" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\fr-FR" "%windir%\PolicyDefinitions\fr-FR" firefox.adml mozilla.adml /is /it /S >NUL 2>&1
		goto :Firefox_Policy_Template_End
	)
	if "%OSLanguage%" == "1040" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\it-IT" "%windir%\PolicyDefinitions\it-IT" firefox.adml mozilla.adml /is /it /S >NUL 2>&1
		goto :Firefox_Policy_Template_End
	)
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\en-US" "%windir%\PolicyDefinitions\en-US" firefox.adml mozilla.adml /is /it /S >NUL 2>&1

:Firefox_Policy_Template_End
	echo [92mDone.[97m

:Start_LGPO
	<nul set /p dummyName=%BS%  -Creating registry.pol files from parsed LGPO text: 
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine" "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User" >NUL 2>&1
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\User_MDL.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User\registry.pol" >NUL 2>&1
:: Check Windows edition
	if not "%Win_Edition%" == "Windows Server 2019" ( goto :LTSC_LGPO) else ( goto :SERVER_LGPO)

:LTSC_LGPO
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\LTSC_Machine.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:SERVER_LGPO
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Machine.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:Start_LGPO_No_Firefox
	<nul set /p dummyName=%BS%  -Creating registry.pol files from parsed LGPO text: 
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine" "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User" >NUL 2>&1
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\User_MDL.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User\registry.pol" >NUL 2>&1
:: Check Windows edition
	if not "%Win_Edition%" == "Windows Server 2019" ( goto :LTSC_LGPO_No_Firefox) else ( goto :SERVER_LGPO_No_Firefox)

:LTSC_LGPO_No_Firefox
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\LTSC_Machine_NF.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:SERVER_LGPO_No_Firefox
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Machine_NF.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:LGPO_SUCCESS
	echo [92mDone.[93m %Win_Edition% policy files successfully created.[97m
:: Import_New_GPO
	<nul set /p dummyName=%BS%  -Importing new Group Policy: 
	robocopy "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Importing Group Policy Security Settings: 
	PowerShell -NoProfile -ExecutionPolicy Bypass "Add-Content -Path "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" -Value ',%USERNAME%'" >NUL 2>&1
:: Password policy
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" /areas SECURITYPOLICY >NUL 2>&1
:: Delegation rights
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" /areas USER_RIGHTS >NUL 2>&1
	echo [92mDone.[97m
	echo [93mGroup Policy task has completed successfully.[97m
	echo:
	goto :eof

::============================================================================================================
:GP_Update
::============================================================================================================
	<nul set /p dummyName=Updating policy...[140X
	GPUpdate /Force /Target:Computer >NUL && echo:
	<nul set /p dummyName=[93mComputer Policy update has completed successfully.[1A[32D
	GPUpdate /Force /Target:User >NUL && echo: & echo:
	echo User Policy update has completed successfully.& echo:
	echo [4A[18C[92mDone.[97m[2B
	echo:
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	goto :eof

::============================================================================================================
:: Save Scripts
::============================================================================================================
:Save_Registry_Scripts
	<nul set /p dummyName=Saving scripts for restore purpose...
	mkdir "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Registry Tweaks" >NUL 2>&1
	robocopy "%Tmp_Folder%Files\Scripts\RegistryTweaks" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Registry Tweaks" *.bat /is /it /S >NUL 2>&1
	goto :eof

:Save_GPO_Scripts
	robocopy "%Tmp_Folder%Files\Scripts\GroupPolicy" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Group Policy" *.bat /is /it /S >NUL 2>&1
	goto :eof

:Save_Services_Scripts
	robocopy "%Tmp_Folder%Files\Scripts\Services" "%TEMP%\SettingsBackup\Scripts (Restore or Apply again)\Services" *.bat /is /it /S >NUL 2>&1
	goto :eof

:Save_Scripts_Success
	echo [93mScripts successfully saved.[97m
	echo:
	goto :eof

::============================================================================================================
:: Services Optimization
::============================================================================================================
:Run_NSudo
	if "%Win_Regular_Edition%" == "Windows 10" ( echo Services optimization task...[92mSkipped.[97m& echo:& goto :eof)

	echo Starting services optimization task...

	sc query WlanSvc >NUL
	if errorlevel 1060 (
		set "WLan_Service=Missing"
		if "%FastMode%" == "Unlocked" ( goto :eof) else ( goto :Printer_Sharing_Choice)
	)
	if "%FastMode%" == "Unlocked" ( goto :eof)
	if "%WLan_Service%" == "Disabled" (
		<nul set /p dummyName=[93mNote:[97m You are not connected to any Wi-Fi network, do you want to disable Wlan Service? [Y/N]
		choice /c YN >NUL 2>&1
		if errorlevel 2 (
			echo [92mEnable[97m && set "WLan_Service=Enabled"
		)
	)

:Printer_Sharing_Choice
	<nul set /p dummyName=(E)nable or (D)isable File and Printer Sharing? [E/D]
	choice /c DE >NUL 2>&1
	if errorlevel 2 (
		echo [92mEnable[97m
		set "Network=ON"
		goto :Apply_Nsudo
	)
	set "Network=OFF"
	echo [31mDisable[97m

:Apply_Nsudo
	<nul set /p dummyName=Applying complete services optimization with NSudo...
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -Wait -UseCurrentConsole "%~dpnx0"&& (
	goto :eof
	) || (
	goto :Services_Optimization_Failed
	)

:Svc_Optimization
if "%Win_Edition%" == "Windows 10 LTSC" ( goto :Start_LTSC_Services) else ( goto :Start_Server_Services)

:Start_LTSC_Services
if "%Network%" == "ON" ( goto :LTSC_Services_NW)
:: Set Services for LTSC
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KtmRm,LicenseManager,lltdsvc,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,"Tib Mounter Service""
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,WlanSvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,"AMD External Events Utility","Acronis VSS Provider",AcronisAgent,ARSM,IAStorDataMgrSvc,"Intel^(R^) Capability Licensing Service TCP IP Interface","Intel^(R^) Security Assist",mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,LanmanWorkstation,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:LTSC_Services_NW
:: Set Services for LTSC with File and Printer Sharing
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,DusmSvc,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,wscsvc,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AssignedAccessManagerSvc,AxInstSV,BDESVC,BITS,camsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevQueryBroker,diagsvc,DisplayEnhancementService,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FDResPub,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KtmRm,LanmanServer,LanmanWorkstation,LicenseManager,lltdsvc,LMS,LxpSvc,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,p2pimsvc,p2psvc,perceptionsimulation,PerfHost,pla,PlugPlay,PNRPAutoReg,PNRPsvc,PolicyAgent,QWAVE,seclogon,SecurityHealthService,Sense,smphost,spectrum,SSDPSRV,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,upnphost,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,wbengine,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wlpasvc,WManSvc,wmiApSrv,WPDBusEnum,wuauserv,cbdhsvc,DevicesFlowUserSvc,WpnUserService,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,"Tib Mounter Service""
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BcastDVRUserService,BluetoothUserService,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,fhsvc,FrameServer,HvHost,icssvc,iphlpsvc,IpxlatCfgSvc,irmon,lfsvc,lmhosts,MapsBroker,MessagingService,MSiSCSI,NaturalAuthentication,NcaSvc,NcbService,NcdAutoSetup,Netlogon,NetTcpPortSharing,PcaSvc,PeerDistSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RetailDemo,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SDRSVC,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,SharedRealitySvc,shpamsvc,SmsRouter,SNMPTRAP,Spooler,ssh-agent,stisvc,TabletInputService,TapiSrv,TermService,tzautoupdate,UevAgentService,UmRdpService,UnistoreSvc,UserDataSvc,VacSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,wcncsvc,WebClient,WerSvc,WFDSConMgrSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,WlanSvc,wlidsvc,WpcMonSvc,WpnService,WwanSvc,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,"AMD External Events Utility","Acronis VSS Provider",AcronisAgent,ARSM,IAStorDataMgrSvc,"Intel^(R^) Capability Licensing Service TCP IP Interface","Intel^(R^) Security Assist",mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,LanmanWorkstation,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Start_Server_Services
if "%Network%" == "ON" ( goto :Server_Services_NW)
:: Set Services for Windows Server
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KPSSVC,KtmRm,LicenseManager,lltdsvc,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,"Tib Mounter Service""
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FDResPub,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,LanmanServer,LanmanWorkstation,lfsvc,lmhosts,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,SSDPSRV,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,upnphost,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WebClient,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,"AMD External Events Utility","Acronis VSS Provider",AcronisAgent,ARSM,IAStorDataMgrSvc,"Intel^(R^) Capability Licensing Service TCP IP Interface","Intel^(R^) Security Assist",mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,LanmanWorkstation,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Server_Services_NW
:: Set Services for Windows Server with File and Printer Sharing
set "AUTO=AudioEndpointBuilder,Audiosrv,BFE,BrokerInfrastructure,CoreMessagingRegistrar,CryptSvc,DcomLaunch,ddpvssvc,Dhcp,Dnscache,DPS,EventLog,EventSystem,FontCache,gpsvc,IKEEXT,LSM,mpssvc,NlaSvc,nsi,Power,ProfSvc,RpcEptMapper,RpcSs,SamSs,Schedule,SENS,ShellHWDetection,sppsvc,SysMain,SystemEventsBroker,Themes,TrkWks,UserManager,UsoSvc,Wcmsvc,wfcs,WinDefend,Winmgmt,WSearch"
set "DEMAND=AppIDSvc,Appinfo,AppReadiness,AppXSvc,AxInstSV,BITS,camsvc,cbdhsvc,ClipSVC,COMSysApp,ddpsvc,defragsvc,DeviceInstall,DevicesFlowUserSvc,DevQueryBroker,DmEnrollmentSvc,dot3svc,DsmSvc,DsSvc,Eaphost,EFS,embeddedmode,EntAppSvc,fdPHost,FDResPub,FontCache3.0.0.0,GraphicsPerfSvc,hidserv,InstallService,jhi_service,KeyIso,KPSSVC,KtmRm,LanmanServer,LanmanWorkstation,LicenseManager,lltdsvc,LMS,MSDTC,msiserver,Netman,netprofm,NetSetupSvc,NgcCtnrSvc,NgcSvc,PerfHost,pla,PlugPlay,PolicyAgent,QWAVE,RSoPProv,sacsvr,seclogon,SecurityHealthService,Sense,smphost,SSDPSRV,SstpSvc,StateRepository,StorSvc,svsvc,swprv,TieringEngineService,TimeBrokerSvc,TokenBroker,TrustedInstaller,upnphost,VaultSvc,vds,VSS,WaaSMedicSvc,WalletService,WarpJITSvc,WdiServiceHost,WdiSystemHost,WdNisSvc,Wecsvc,WEPHOSTSVC,wercplsupport,wmiApSrv,WPDBusEnum,WpnUserService,wuauserv,ClickToRunSvc,MBAMScheduler,MBAMService,PaceLicenseDServices,SentinelKeysServer,SentinelProtectionServer,SentinelSecurityRuntime,"Tib Mounter Service""
set "DISABLED=AJRouter,ALG,AppMgmt,AppVClient,BTAGService,BthAvctpSvc,bthserv,CaptureService,CDPSvc,CDPUserSvc,CertPropSvc,ConsentUxUserSvc,CscService,DeviceAssociationService,DevicePickerUserSvc,diagnosticshub.standardcollector.service,DiagTrack,dmwappushservice,DoSvc,FrameServer,HvHost,icssvc,iphlpsvc,isaHelperSvc,lfsvc,lmhosts,MapsBroker,MSiSCSI,NcaSvc,NcbService,Netlogon,NetTcpPortSharing,PcaSvc,PhoneSvc,PimIndexMaintenanceSvc,PrintNotify,PrintWorkflowUserSvc,PushToInstall,RasAuto,RasMan,RemoteAccess,RemoteRegistry,RmSvc,RpcLocator,SCardSvr,ScDeviceEnum,SCPolicySvc,SEMgrSvc,SensorDataService,SensorService,SensrSvc,SessionEnv,SgrmBroker,SharedAccess,shpamsvc,SNMPTRAP,Spooler,ssh-agent,stisvc,TabletInputService,tapisrv,TermService,tzautoupdate,UALSVC,UevAgentService,UmRdpService,UnistoreSvc,UserDataSvc,vmicguestinterface,vmicheartbeat,vmickvpexchange,vmicrdv,vmicshutdown,vmictimesync,vmicvmsession,vmicvss,W32Time,WbioSrvc,WebClient,WerSvc,WiaRpc,WinHttpAutoProxySvc,WinRM,wisvc,wlidsvc,WpnService,AcronisActiveProtectionService,AcrSch2Svc,afcdpsrv,"AMD External Events Utility","Acronis VSS Provider",AcronisAgent,ARSM,IAStorDataMgrSvc,"Intel^(R^) Capability Licensing Service TCP IP Interface","Intel^(R^) Security Assist",mmsminisrv,MMS,mobile_backup_server,mobile_backup_status_server,LanmanWorkstation,ose64,syncagentsrv"
goto :Start_Svc_Optimization

:Start_Svc_Optimization
:: Optimize Services
	for %%g in (%AUTO%) do reg query HKLM\SYSTEM\ControlSet001\Services\%%g /v Start 1>NUL 2>NUL && reg add HKLM\SYSTEM\ControlSet001\Services\%%g /v Start /t REG_DWORD /d 2 /f >NUL 2>&1
	for %%g in (%DEMAND%) do reg query HKLM\SYSTEM\ControlSet001\Services\%%g /v Start 1>NUL 2>NUL && reg add HKLM\SYSTEM\ControlSet001\Services\%%g /v Start /t REG_DWORD /d 3 /f >NUL 2>&1
	for %%g in (%DISABLED%) do reg query HKLM\SYSTEM\ControlSet001\Services\%%g /v Start 1>NUL 2>NUL && reg add HKLM\SYSTEM\ControlSet001\Services\%%g /v Start /t REG_DWORD /d 4 /f >NUL 2>&1
	for %%g in (%AUTO%) do sc config %%g start= AUTO >NUL 2>&1
	for %%g in (%DEMAND%) do sc config %%g start= DEMAND >NUL 2>&1
	for %%g in (%DISABLED%) do sc config %%g start= DISABLED >NUL 2>&1

	if "%WLan_Service%" == "Missing" ( goto :Services_Optimization_Success)
	if "%WLan_Service%" == "Enabled" (
		sc config "WlanSvc" start= AUTO >NUL 2>&1
		goto :Services_Optimization_Success
	)
	if "%WLan_Service%" == "Disabled" (
		sc config "WlanSvc" start= DISABLED >NUL 2>&1
		goto :Services_Optimization_Success
	)
:Services_Optimization_Success
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
	<nul set /p dummyName=Backing up optimized services start state and creating restore script...
	cd /d "%TEMP%\SettingsBackup\Services Backup"
:: Get Date and Time
	for /f "tokens=1, 2, 3, 4 delims=-/. " %%j in ('Date /T') do set "NEWFILENAME=Optimized_services_saved_on_%%j-%%k-%%l_at_%%m"
	for /f "tokens=1, 2 delims=: " %%j in ('TIME /T') do set "NEWFILENAME=%NEWFILENAME%%%jh%%k.bat"
:: Get Services Name
	sc query type= service state= all | findstr /r /c:"SERVICE_NAME:">tmpsrv.txt
:: Rename
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "SERVICE_NAME: " "" /m /f "%TEMP%\SettingsBackup\Services Backup\tmpsrv.txt" /o -
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)$" "$1" /m /f "%TEMP%\SettingsBackup\Services Backup\tmpsrv.txt" /o -
:: Create Restore Script
		@echo @echo off>"%NEWFILENAME%"
		@echo %%windir%%^\system32\reg.exe query "HKU\S-1-5-19" 1^>NUL 2^>NUL ^|^| goto :NOADMIN>>"%NEWFILENAME%"
		@echo(>>"%NEWFILENAME%"
		@echo echo ^^]0;Import optimized services start state, saved at %TIME% on %DATE%^>>"%NEWFILENAME%"
		@echo ^<nul set /p dummyName=^^[1APress any key to start...>>"%NEWFILENAME%"
		@echo pause ^>NUL>>"%NEWFILENAME%"
		@echo cls>>"%NEWFILENAME%"
		@echo(>>"%NEWFILENAME%"
		for /f "delims=" %%j in (tmpsrv.txt) do @( sc qc "%%j" | findstr START_TYPE >tmpstype.txt && for /f "tokens=4 delims=:_ " %%s in (tmpstype.txt) do @echo sc config "%%j" start= %%s>>"%NEWFILENAME%")
		@echo echo:>>"%NEWFILENAME%"
		@echo(>>"%NEWFILENAME%"
		@echo ^<nul set /p dummyName=Done. Press any key to exit...>>"%NEWFILENAME%"
		@echo pause ^>NUL>>"%NEWFILENAME%"
		@echo exit /b>>"%NEWFILENAME%"
		@echo(>>"%NEWFILENAME%"
		@echo :NOADMIN>>"%NEWFILENAME%"
		@echo echo You must have administrator rights to run this script.>>"%NEWFILENAME%"
		@echo ^<nul set /p dummyName=Press any key to exit...>>"%NEWFILENAME%"
		@echo pause ^>NUL>>"%NEWFILENAME%"
		@echo goto :eof>>"%NEWFILENAME%"
:: Delete temp files
	del "tmpsrv.txt" "tmpstype.txt" /f /s /q >NUL 2>&1
:: Inform user
	echo [92mDone.[97m
	echo [93mOptimized services start state saved as "%NEWFILENAME%".[97m
	echo:
	goto :eof

::============================================================================================================
:Indexing_Options
::============================================================================================================
	echo %Shell_Title2%
	cls
	call :Color_title
	echo:
	echo:
:IndexingOptions_FULL
	if not "%FullMode%" == "Unlocked" (
		echo 1. Set custom locations& echo:
		echo 2. Add Windows start menus only& echo:
		echo 3. Remove all locations from indexing options& echo:
		echo 4. Default indexing options settings& echo: & echo:
		choice /c 12340 /n /m "Select your option, or 0 to cancel and return to previous menu: "
		if errorlevel 5 ( set "Clean=Clean_is_OFF" & goto :Index_Task_Clean)
		if errorlevel 4 ( set "Style=default" & goto :ScopeTask)
		if errorlevel 3 ( set "Style=reset" & goto :ScopeTask)
		if errorlevel 2 ( set "Style=startmenus" & goto :ScopeTask)
		if errorlevel 1 ( set "Style=custom" & goto :PathSelection)
		goto :eof
	) else (
		<nul set /p dummyName=Select option:
:Browser_Canceled
		echo:
		echo 1. Set custom locations
		echo 2. Add Windows start menus only
		echo 3. Remove all locations from indexing options
		echo 4. Default indexing options settings
		<nul set /p dummyName=0. Cancel[5A[5C
		choice /c 12340 /n /m "" >NUL 2>&1
	)
	if errorlevel 5 (
		echo 0
		echo [14D[4B[31m0. Cancel[97m
		echo:
		set "Clean=Clean_is_OFF"
		goto :Index_Task_Clean
	)
	if errorlevel 4 (
		echo 8
		echo [14D[3B[92m4. Default indexing options settings[97m
		echo 0. Cancel
		echo:
		set "Style=default"
		goto :ScopeTask
	)
	if errorlevel 3 (
		echo 3
		echo [14D[2B[92m3. Remove all locations from indexing options[97m
		echo 4. Default indexing options settings
		echo 0. Cancel
		echo:
		set "Style=reset"
		goto :ScopeTask
	)
	if errorlevel 2 (
		echo 2
		echo [14D[1B[92m2. Add Windows start menus only[97m
		echo 3. Remove all locations from indexing options
		echo 4. Default indexing options settings
		echo 0. Cancel
		echo:
		set "Style=startmenus"
		goto :ScopeTask
	)
	if errorlevel 1 (
		echo 1
		echo [92m1. Set custom locations[97m
		echo 2. Add Windows start menus only
		echo 3. Remove all locations from indexing options
		echo 4. Default indexing options settings
		echo 0. Cancel
		echo:
		set "Style=custom"
		goto :PathSelection
	)
	goto :eof

:PathSelection
	setlocal EnableDelayedExpansion
	call "%Tmp_Folder%Files\Scripts\IndexingOptions\Browser.bat"

	if "%Index%" == "0" (
		if not "%IndexedFolder%" == "" (
			if not "%FullMode%" == "Unlocked" (
				cls
				call :Color_title2
			)
			echo You selected "%IndexedFolder%"
			goto :SelectMorePaths
		)
	)

	if %Index% GTR 0 (
		if not "!Index2_%Index%!" == "" (
			echo You selected "!Index2_%Index%!"
			goto :SelectMorePaths
		)
	)
	set "Index=0"
	set "IndexedFolder="
	if not "%FullMode%" == "Unlocked" ( goto :Indexing_Options) else (
		<nul set /p dummyName=[7ASelect option:[2X[?25h
		goto :Browser_Canceled
	)

:SelectMorePaths
	<nul set /p dummyName=Do you want to add another path to indexed locations? [Y/N]
	choice /C:YN /M "" >NUL 2>&1
	if errorlevel 2 ( echo No& goto :PathResult)
	set /a "Index+=1"
	goto :PathSelection

:PathResult
	echo:
	if "%Index%" == "0" (
		echo Indexed location is "%IndexedFolder%"
		goto :SetCount
	)
	echo Indexed locations are
	echo "%IndexedFolder%"
:SetCount
	set /a "Count=%Index%"

:ResultLoop
	if "%Count%" == "0" ( goto :ScopeTask)
	set "Index2=!Index2_%Count%!"
	echo "%Index2%"
	set /a "Count-=1"
	goto :ResultLoop

:ScopeTask
	if "%Style%" == "custom" ( echo:) else (
		if not "%FullMode%" == "Unlocked" ( cls & call :Color_title2)
	)
:Indexing_Options_FastMode
	mkdir "%Tmp_Index_Folder%" >NUL 2>&1
	set "Clean=Clean_is_ON"
	<nul set /p dummyName=Setting indexing options...
:: Get SID
	for /f "tokens=1,2 delims==" %%s IN ('wmic path win32_useraccount where name^='%username%' get sid /value ^| find /i "SID"') do set "SID=%%t"

:: Make PS Script
	@echo $host.ui.RawUI.WindowTitle = "Optimize Next Gen v3.8.5 | Powershell Script">>%scriptname%
	@echo Add-Type -path "%Tmp_Folder%Files\Utilities\Microsoft.Search.Interop.dll">>%scriptname%
	@echo $sm = New-Object Microsoft.Search.Interop.CSearchManagerClass>>%scriptname%
	@echo $catalog = $sm.GetCatalog^("SystemIndex"^)>>%scriptname%
	@echo $crawlman = $catalog.GetCrawlScopeManager^(^)>>%scriptname%
	@echo $crawlman.RevertToDefaultScopes^(^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	if "%Style%" == "default" ( goto :MakeDefault)
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\ProgramData\Microsoft\Windows\Start Menu\*"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\Local\Temp\*"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\*"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.RemoveDefaultScopeRule^("iehistory://{%SID%}"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	if "%Style%" == "default" ( goto :MakeDefault)
	if "%Style%" == "reset" ( goto :Finish_Ps)
	if "%Style%" == "startmenus" ( goto :AddStartMenus)
	if "%Style%" == "custom" ( goto :SetCustomPaths)
	:MakeDefault
	@echo $crawlman.AddUserScopeRule^("file:///C:\Users\*",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.AddUserScopeRule^("file:///C:\ProgramData\Microsoft\Windows\Start Menu\*",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.AddUserScopeRule^("iehistory://{%SID%}",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	goto :Reindex
	:AddStartMenus
	@echo $crawlman.AddUserScopeRule^("file:///%ProgramData%\Microsoft\Windows\Start Menu\Programs\*",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	@echo $crawlman.AddUserScopeRule^("file:///%AppData%\Microsoft\Windows\Start Menu\Programs\*",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	goto :Finish_Ps
	:SetCustomPaths
	@echo $crawlman.AddUserScopeRule^("file:///%IndexedFolder%\*",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	:MorePathsLoop
	if "%Index%" == "0" ( goto :Finish_Ps)
	set "Index2=!Index2_%Index%!"
	@echo $crawlman.AddUserScopeRule^("file:///%Index2%\*",$true,$false,$null^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	set /a "Index-=1"
	goto :MorePathsLoop
	:Finish_Ps
	@echo $crawlman.RemoveDefaultScopeRule^("file:///%UserProfile%\Favorites\*"^)>>%scriptname%
	@echo $crawlman.SaveAll^(^)>>%scriptname%
	:Reindex
	@echo $Catalog.Reindex^(^)>>%scriptname%
	@echo Remove-Item "%lock%">>%scriptname%
:: Execute Task
	@echo Locked>"%lock%"
	PowerShell -NoProfile -ExecutionPolicy Unrestricted -File "%scriptname%" -force >NUL 2>&1
	:Wait
	if exist "%lock%" goto :Wait

:Index_Task_Clean
	if "%Clean%" == "Clean_is_OFF" (
		if not "%FullMode%" == "Unlocked" (
			cls
			call :Color_title
		)
		echo [?25l[93mNo indexing location has been set.[97m
		goto :eof
	)
	echo [?25l[92mDone.[97m[?25h
	echo [93mIndexing options setting task as completed successfully.[97m
	if not "%FastMode%" == "Unlocked" (
		mkdir "%launchpath%Backup\Scripts (Restore or Apply again)\Indexing Options\" >NUL 2>&1
		findstr /R /V /C:"Remove-Item" "%scriptname%"> "%Tmp_Index_Folder%\SearchScopeTask2.ps1"
		move /y	"%Tmp_Index_Folder%\SearchScopeTask2.ps1" "%launchpath%Backup\Scripts (Restore or Apply again)\Indexing Options\SearchScopeTask.ps1" >NUL 2>&1
	)
:CleanMore
	if not exist "%scriptname%" ( goto :CleanMore2) else (
		del "%scriptname%" /f /s /q >NUL 2>&1
		goto :CleanMore
	)
:CleanMore2
	if not exist "%Tmp_Index_Folder%\" ( goto :eof) else (
		rmdir "%Tmp_Index_Folder%\" /s /q >NUL 2>&1
		goto :CleanMore2
	)

::============================================================================================================
:Miscellaneous
::============================================================================================================
::Fix EventLog Cosmetic Errors
	wevtutil sl "Microsoft-Windows-DeviceSetupManager/Admin" /e:false /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /v "EnableLevel" /t REG_DWORD /d "0" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-User Device Registration/Admin" /v "OwningPublisher" /t REG_SZ /d "{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /f >NUL 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-User Device Registration/Admin" /v "Enabled" /t REG_DWORD /d "0" /f >NUL 2>&1
:: Disabling Application Compatibility telemetry
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\AIT" /v "AITEnable" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry" /v "TaskEnableRun" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling CEIP
	reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling remote Scripted Diagnostics Provider query
	reg add "HKLM\Software\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "EnableQueryRemoteServer" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" /v "DisableQueryRemoteServer" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling remote Scheduled Diagnostics execution
	reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling auto-Recommended-Updates install
	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v "IncludeRecommendedUpdates" /t REG_DWORD /d "0" /f >nul 2>&1
:: Disabling auto-reboot after update install
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling Peernet
	reg add "HKLM\Software\Policies\Microsoft\Peernet" /v "Disabled" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\BITS" /v "DisablePeerCachingClient" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\Software\Policies\Microsoft\Windows\BITS" /v "DisablePeerCachingServer" /t REG_DWORD /d "1" /f >nul 2>&1
:: Disabling telemetry uploading
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul 2>&1
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
:: Patching Explorer leaks
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "AllowOnlineTips" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d "0" /f >nul 2>&1
:: Clearing unique ad-tracking ID token
	reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Id" /t REG_SZ /d "null" /f >nul 2>&1
:: Configuring SmartScreen control permissions
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
	echo [92mDone.[97m
goto :eof

::============================================================================================================
:Save_All_Settings
::============================================================================================================
	<nul set /p dummyName=Saving all settings...
:: Update or Rename choice, then save
	cd /d "%Tmp_Folder%"
	robocopy "%TEMP%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S >NUL 2>&1
	echo [93mSettings successfully saved.[97m& echo:
:: Ask if user want to archive
	<nul set /p dummyName=Do you want to "zip" saved setttings and scripts? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& ( goto :eof)
	if errorlevel 1 echo [92mYes[97m& ( goto :Archive)

::============================================================================================================
:Archive
::============================================================================================================
:: Check 7z first (fastest)
	if exist "%ProgramFiles%\7-Zip\7z.exe" (
	"%ProgramFiles%\7-Zip\7z.exe" a "%launchpath%Backup.zip" "%TEMP%\SettingsBackup\*" -r -y >NUL 2>&1
	goto :Archiving_Success
	)

:WinRAR
:: xcopy workaround for winrar adding parent folders to archive when specifying path as argument
	if exist "%programFiles%\WinRAR\WinRAR.exe" (
		xcopy "%TEMP%\SettingsBackup" "%Tmp_Folder%SettingsBackup" /e /h /k /i /y >NUL 2>&1
		cd /d "%Tmp_Folder%SettingsBackup\"
		"%programFiles%\WinRAR\WinRAR.exe" a "%launchpath%Backup.zip" -ibck -r -u -y >NUL 2>&1
		cd /d "%Tmp_Folder%" & rmdir "%Tmp_Folder%SettingsBackup" /s /q >NUL 2>&1
		goto :Archiving_Success
	)

:PS
:: Last chance (slowest)
	PowerShell -NoProfile -ExecutionPolicy Bypass "Compress-Archive -Path "$env:TEMP\SettingsBackup\*" -CompressionLevel Fastest -DestinationPath "$env:%launchpath%Backup.zip" -Update" 1>NUL 2>NUL && (
		goto :Archiving_Success
	) || (
		echo [31mArchiving failed.[97m
		goto :eof
	)

:Archiving_Success
	echo [93mSettings successfully zipped.[97m
	rmdir "%launchpath%Backup" /s /q >NUL 2>&1
	goto :eof

::============================================================================================================
:Cleaning
::============================================================================================================
:: Clean empty devices in device manager
	%Tmp_Folder%Files\Utilities\DeviceCleanupCmd.exe * -s -n >NUL 2>&1

:: Clear System EventViewer Logs
	wevtutil.exe cl "System" >NUL 2>&1

:Cleaning_Temp_Folder
	cd /d "%TEMP%"
	if not exist "%TEMP%\SettingsBackup" ( goto :eof) else (
		cd /d "%TEMP%\SettingsBackup"
		for /f "delims=" %%i in ('dir /b') do (
			rmdir "%%i" /s /q >NUL 2>&1
		) || (
			del "%%i" /f /s /q >NUL 2>&1
		)
		cd /d "%TEMP%"
		rmdir "SettingsBackup" /s /q >NUL 2>&1
		goto :Cleaning
	)

::============================================================================================================
:: Close And Restart Countdown Thingy
::============================================================================================================
:Restart_Warning
	echo:
	echo All tasks have completed.
	echo You will need to restart your PC to finish optimizing your system.
	goto :Restart_Question

:Restart_Information
	echo:
	echo You might have to restart your computer for all settings to be effective.
	goto :Restart_Question

:Restart_Question
	set "FullMode=Locked"
	<nul set /p dummyName=Do you want to restart the PC now? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mNo[97m& echo: & ( goto :RETURN_TO_MAIN_MENU)
	if errorlevel 1 echo [92mYes[97m& echo: & ( goto :Restart_Computer)

:Save_Before_End
	robocopy "%TEMP%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S >NUL 2>&1
	goto :Cleaning

:RETURN_TO_MAIN_MENU
	<nul set /p dummyName=Press any key to return to main menu...
	pause >NUL 2>&1
	set "FastMode=Locked"
	set "FullMode=Locked"
	cls & goto :START

:RETURN_TO_OPT_MENU
	<nul set /p dummyName=Press any key to return to Optimization menu...
	pause >NUL 2>&1
	cls & goto :Optimize_MENU

:RETURN__TO_REST_MENU
	<nul set /p dummyName=Press any key to return to Restore menu...
	pause >NUL 2>&1
	cls & goto :Restore_MENU

:Restart_Computer
	if "%OfflineMode%" == "Unlocked" ( goto :TmpFolder_Remove)
	if "%SecretMode%" == "Unlocked" (
		if "%RestartWindow%" == "Show" (
			call "%Tmp_Folder%Files\Utilities\conSize.bat" 150 10 150 9999
			echo %Shell_Title%
			cls
			call :Color_title2
			set "Timer=20"
			goto :Restart_Task
		) else (
			set "RestartWindow=Show"
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:Show "%~dpnx0" && exit /b
		)
	) else ( set "Timer=10")
	echo: [?25l
:Restart_Task
	setlocal EnableDelayedExpansion
	cd /d "%Tmp_Folder%"
	echo X>Lock.tmp
	@echo @echo off >"%Tmp_Folder%Lock.bat"
	@echo :loop_1 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) >>"%Tmp_Folder%Lock.bat"
	@echo "%Tmp_Folder%Files\Utilities\GetKey.exe" /N >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 48 ^( @echo X ^>"%%Tmp_Folder%%Lock2.tmp" ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo if %%errorlevel%% equ 0 ^( goto :loop_1 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :loop_2 >>"%Tmp_Folder%Lock.bat"
	@echo if not exist "%Tmp_Folder%Lock.tmp" ^( goto :finish ^) else ^( del "%Tmp_Folder%Lock.tmp" /s /q ^>NUL ^&^& goto :loop_2 ^) >>"%Tmp_Folder%Lock.bat"
	@echo :finish >>"%Tmp_Folder%Lock.bat"
	@echo ^(goto^) 2^>nul ^& del "%%~f0" >>"%Tmp_Folder%Lock.bat"
	if "%SecretMode%" == "Unlocked" ( echo All tasks have completed.& echo:)
	echo [1BPress any key to cancel and return to start menu, or 0 to exit.[2A[?25l
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
	for /l %%n in (%Timer% -1 1) do (
		dir * /s/b | findstr /c:Lock.tmp > nul && (
			if %%n GEQ 10 (
				if not "%SecretMode%" == "Unlocked" (
					<nul set /p "=Restarting in %%n seconds...!CR!"
				) else (
					<nul set /p "=Your system will restart in %%n seconds to finish optimization.!CR!"
				)
			)
			if %%n LEQ 9 (
				if not "%SecretMode%" == "Unlocked" (
					<nul set /p "=Restarting in %%n seconds... !CR!"
				) else (
					<nul set /p "=Your system will restart in %%n seconds to finish optimization. !CR!"
				)
			)
			if %%n EQU 0 ( goto :Final_Stuff)
			ping -n 2 localhost > nul
		) || (
			cls
			if exist "%Tmp_Folder%Lock2.tmp" (
				call :Lock2_Delete_Loop
				if not "%FullMode%" == "Unlocked" ( call :Settings_Check)
				goto :TmpFolder_Remove
			)
			call "%Tmp_Folder%Files\Utilities\conSize.bat" 150 45 150 9999
			goto :Optimize_MENU
		)
	)

:Final_Stuff
	call :Lock1_Delete_Loop
	cd /d "%TEMP%"
	if not "%FullMode%" == "Unlocked" ( call :Settings_Check && call :Cleaning)
	if "%Win_Edition%" == "Windows Server 2019" (
		reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\CapabilityIndex\Kernel.Soft.Reboot" | findstr /I /C:Microsoft-Windows-CoreSystem-SoftReboot-FoD-Package >NUL && (
			"C:\Windows\System32\cmd.exe" /c shutdown.exe /r /soft /t 0
			goto :TmpFolder_Remove
		)
	)
	"C:\Windows\System32\cmd.exe" /c shutdown.exe /r /f /t 00
	goto :TmpFolder_Remove

::============================================================================================================
:: CleaningLoops
::============================================================================================================
:Lock1_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock.tmp" (
			goto :eof
		) else (
			del "%Tmp_Folder%Lock.tmp" /f /s /q >NUL 2>&1
			goto :Lock2_Delete_Loop
		)
	)

:Lock2_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock2.tmp" (
			goto :eof
		) else (
			del "%Tmp_Folder%Lock2.tmp" /f /s /q >NUL 2>&1
			goto :Lock2_Delete_Loop
		)
	)

:Settings_Check
	cd /d "%TEMP%"
	if not exist "%TEMP%\SettingsBackup\" ( goto :eof) else (
		rmdir "%TEMP%\SettingsBackup" >NUL 2>&1
		goto :Settings_Check
	)
	goto :eof

:TmpFolder_Remove
	cd /d "%TEMP%"
	if not exist "%Tmp_Folder%" ( goto :eof) else (
		rmdir "%Tmp_Folder%" /s /q >NUL 2>&1
		goto :TmpFolder_Remove
	)

:TmpFolder_Check
	cd /d "%TEMP%"
	for /f "delims=" %%a in ('dir /b /ad ^| findstr /i /r "Optimize_NextGen_[0-9]*.tmp"') do (
		rmdir "%%a" /s /q >NUL 2>&1
	) || (
		goto :eof
	)
	goto :eof

::============================================================================================================
:Remove_Tweaks
::============================================================================================================
	echo Removing privacy settings tweaks...
	<nul set /p dummyName=%BS%  -Preferences added to Group Policy in 'Custom Policies': 
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
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /f >NUL 2>&1
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
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "1" /f >NUL 2>&1
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
:: Allow StorageSense
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense" /v "AllowStorageSenseGlobal" /f >NUL 2>&1
:: By default displays shutdown button on logon
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "shutdownwithoutlogon" /f >NUL 2>&1
:: Check Windows edition before adding Shutdown Event Tracker value and do not display Server Manager at logon.
	if "%Win_Edition%" == "Windows Server 2019" ( goto :Windows_Server_Policies_Remove) else ( goto :Power_Remove_Next)
:Windows_Server_Policies_Remove
:: Display Shutdown Event Tracker (Windows Server)
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v "ShutDownReasonOn" /f >NUL 2>&1
:: Display Manage Your Server page at logon (Windows Server)
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\MYS" /v "DisableShowAtLogon" /f >NUL 2>&1
:Power_Remove_Next
:: Power saving settings
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" /f >NUL 2>&1
:: Button settings
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280" /f >NUL 2>&1
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB" /f >NUL 2>&1
:: Domain password policies
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
:: MenuShowDelay default delay value
	reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f >NUL 2>&1
:: Max 15 items allowed to Open with
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "MultipleInvokePromptMinimum" /f >NUL 2>&1
:: Add "-shortcut" to shortcut name at creation
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /f >NUL 2>&1
:: Show advertising banner in Snipping Tool
	reg delete "HKCU\Software\Microsoft\Windows\TabletPC\Snipping Tool" /v "IsScreenSketchBannerExpanded" /f >NUL 2>&1
:: Default icons cache size
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /f >NUL 2>&1
:: Requires ALT+CTRL+DEL at logon screen (Windows Server)
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /f >NUL 2>&1
:: Allow creation and logon of Microsoft Account
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoConnectedUser" /t REG_DWORD /d "0" /f >NUL 2>&1
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
	goto :eof

:GPO_Redundant_Settings
	echo [93mNote:[97m Some important registry settings are redundantly included as Group Policy settings.
	echo If you launched full/fast optimization or Group Policy single task before, the tweaks you just removed are still stored as GPO.
	echo It means that tweaks are removed, but a future "GpUpdate" command would re-add them.
	echo In this case, it's better to launch Group Policy task again with these tweaks removed, or to reset Group Policy totally.
	echo:
	<nul set /p dummyName=Do you want to set Group Policy again with the registry tweaks removed (1)? Reset Group Policy totally (2)? or leave it like this (3)? [1/2/3]
	choice /c 123 >NUL 2>&1
	if errorlevel 3 ( echo 3& echo:& goto :eof)
	if errorlevel 2 ( echo 2& echo:& goto :RTASK_2notitle)
	if errorlevel 1 ( echo 1& echo:& goto :Delete_GPO_Redundant_Settings)

:Delete_GPO_Redundant_Settings
	del "%windir%\system32\GroupPolicy\User\registry.pol" /f /s /q >NUL 2>&1
	del "%windir%\system32\GroupPolicy\Machine\registry.pol" /f /s /q >NUL 2>&1
	mkdir "%TEMP%\GPO_Restore\GroupPolicy\User" >NUL 2>&1
	mkdir "%TEMP%\GPO_Restore\GroupPolicy\Machine" >NUL 2>&1
	"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\User_MDL.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\User\registry.pol" >NUL 2>&1
	if exist "C:\Windows\PolicyDefinitions\firefox.admx" ( goto :LGPO_Restore_Firefox) else ( goto :LGPO_Restore_No_Firefox)

:LGPO_Restore_Firefox
	if not "%Win_Edition%" == "Windows Server 2019" (
		"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\LTSC_Machine.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	) else (
		"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\Server_Machine.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	)
	goto :LGPO_Restore_END

:LGPO_Restore_No_Firefox
	if not "%Win_Edition%" == "Windows Server 2019" (
		"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\LTSC_Machine.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	) else (
		"%Tmp_Folder%Files\GroupPolicy\LGPO\LGPO.exe" /r "%Tmp_Folder%Files\GroupPolicy\LGPO_Restore\Server_Machine.txt" /w "%TEMP%\GPO_Restore\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	)

:LGPO_Restore_END
	robocopy "%TEMP%\GPO_Restore\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >NUL 2>&1
	if exist "%TEMP%\GPO_Restore" rmdir "%TEMP%\GPO_Restore" /s /q >NUL 2>&1
	<nul set /p dummyName=Updating policy...
	GPUpdate /Force >NUL 2>&1
	echo [93mPolicy update has completed successfully.[97m
	echo:
	goto :eof

::============================================================================================================
:Custom_Policies_Preferences_Remove
::============================================================================================================
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
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /f >NUL 2>&1
	goto :eof

::============================================================================================================
:Restore_GPO
::============================================================================================================
:: Remove folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
	<nul set /p dummyName=Saving current policy files...
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak" (
		copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak" "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" >NUL 2>&1
		copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak" "%windir%\system32\GroupPolicy\User\registry.bak_bak" >NUL 2>&1
	)
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >NUL 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >NUL 2>&1
	echo [92mDone.[97m& echo:
	<nul set /p dummyName=Restoring Group Policy from backup...
	if exist "%launchpath%Backup\GroupPolicy Backup\Current GPO\GroupPolicy" (
		robocopy "%launchpath%Backup\GroupPolicy Backup\Current GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >NUL 2>&1
		cd /d "%windir%\system32\GroupPolicy\Machine" & del "registry.bak_bak" /f /s /q >NUL 2>&1
		cd /d "%windir%\system32\GroupPolicy\User" & del "registry.bak_bak" /f /s /q >NUL 2>&1
		echo [92mDone.[97m
		echo [93mGroup Policy settings restored from backup folder.[97m& echo:
		goto :eof
	)
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" (
		copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" "%windir%\system32\GroupPolicy\Machine\registry.pol" >NUL 2>&1
		copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak_bak" "%windir%\system32\GroupPolicy\User\registry.pol" >NUL 2>&1
		cd /d "%windir%\system32\GroupPolicy\Machine" & del "registry.bak_bak" /f /s /q >NUL 2>&1
		cd /d "%windir%\system32\GroupPolicy\User" & del "registry.bak_bak" /f /s /q >NUL 2>&1
		echo [92mDone.[97m
		echo [93mGroup Policy settings restored from registry.bak files.[97m& echo:
		goto :eof
	)
	echo [31mGroup Policy backup not found.[97m
	echo [93mRestore operation failed.[97m
	cd /d "%windir%\system32\GroupPolicy\Machine" & del "registry.bak" /s /q >NUL 2>&1
	cd /d "%windir%\system32\GroupPolicy\User" & del "registry.bak" /s /q >NUL 2>&1
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	echo:
	<nul set /p dummyName=Would you like to reset Group Policy instead? [Y/N]
	choice /c YN >NUL 2>&1
	if errorlevel 2 echo [31mNo[97m& echo: & ( goto :RETURN_TO_MAIN_MENU)
	if errorlevel 1 echo [92mYes[97m& (
		echo:
		goto :RTASK_2notitle
	)

::============================================================================================================
:Restore_Services
::============================================================================================================
	<nul set /p dummyName=Restoring services start state using NSudo, choosing oldest file in backup folder...
	if exist "%launchpath%Backup\Services Backup" ( goto :Restore_Services_Backup) else (
		echo [31mServices backup not found.[97m
		echo [93mRestore operation failed.[97m
		echo:
		goto :eof
	)

:Restore_Services_Backup
:: Set dynamic file which will have pause skipped
	set "DynScriptName=%Temp%\NoPause.bat"
:: Order by date to select oldest backup and then save it as dynamic file without pause
	for /f "delims=" %%a in ( 'dir /b /a-d /tw /od "%launchpath%Backup\Services Backup\*.bat"') do (
		findstr /i /v "pause" "%launchpath%Backup\Services Backup\%%a">"%DynScriptName%"& goto :Restore_Services_Backup_Action
	)

:Restore_Services_Backup_Action
:: Run dynamic script with NSudo
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -wait "%DynScriptName%"
	echo [92mDone.[97m
	if exist "%DynScriptName%" del /f /s /q "%DynScriptName%" >NUL 2>&1
:: Inform user
	for /f "delims=" %%a in ( 'dir /b /a-d /tw /od "%launchpath%Backup\Services Backup\*.bat"') do (
		echo [93m"%%a" successfully restored.[97m& echo: & goto :eof
	)

::============================================================================================================
:NOADMIN
::============================================================================================================
	echo [97mYou must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof

::============================================================================================================
:NSudo_Tasks
::============================================================================================================
	if "%PowerSchemeCreation%" == "PowerSchemeCreation_is_on" ( goto :GUID_Trick) else ( goto :Svc_Optimization)
	goto :eof
