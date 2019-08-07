::::::::::::::::::::::::::::::::::::::::::::
::        Optimize NextGen v4.1           ::
:: Written by Th.Dub @ResonantStep - 2019 ::
::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal DisableDelayedExpansion

REM Check rights
C:\Windows\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :No_Admin
C:\Windows\system32\whoami.exe /USER | find /i "S-1-5-18" 1>nul && goto :NSudo_Tasks

REM Second run, go directly to Start menu
	if "%Run%"=="Second" (
	REM Clean RarSFX artefacts
		if "%launcher%"=="exe" (
			for /f "delims=" %%a in ('dir /b /ad ^| findstr /i /r "RarSFX[0-9]*"') do ( rmdir "%%a" /s /q >nul 2>&1 )
		)
	REM Resize window keeping buffer size
		"%Tmp_Folder%Files\Utilities\consolesize.exe" 153 50 153 9999
		goto :START
	)

REM Run not defined, very first start
	if "%Run%"=="" (
		set "Run=First"
		set "launchpath=%~x1"
	)

REM Set folders
	set "Script_Folder=%~dp0"
	set "NextGen_UserName=%username%"
	if not defined NextGen_UserName (goto :Error_No_User) else if exist "%systemdrive%\Users\%NextGen_UserName%\AppData\Local\Temp\" (
		set "Tmp_Folder=%systemdrive%\Users\%NextGen_UserName%\AppData\Local\Temp\Optimize_NextGen_%random%.tmp\" & set "User_Tmp_Folder=%systemdrive%\Users\%NextGen_UserName%\AppData\Local\Temp"
	)

REM Check if robocopy exists
	if not exist "%systemroot%\system32\robocopy.exe" goto :Error_No_Robocopy
REM Clean tasks and folders artefacts
	taskkill /f /IM "robocopy.exe" >nul 2>&1
	taskkill /f /IM "choice.exe" >nul 2>&1
	cd /d "%User_Tmp_Folder%"
	for /f "tokens=*" %%a in ('dir /b /ad ^| findstr /i /r "Optimize_NextGen_[0-9]*.tmp"') do ( rmdir "%%a" /s /q >nul 2>&1 )

REM Set launch paths for sfx.exe or script.Bat
	if "%launchpath%"==".exe" (
		cd /d "%~dp0"
		set "launchpath=%~dp1"
		set "launcher=exe"
		set "Run_With_Arg=%~2"
	) else (
		set "launchpath=%~dp0"
		set "launcher=bat"
		set "Run_With_Arg=%~1"
	)

REM Copy all files to temp folder
	robocopy /MIR "%Script_Folder%\" "%Tmp_Folder%\" >nul 2>&1

::============================================================================================================
:: Set Variables
::============================================================================================================
REM Set arguments
	set /a paramcount=1
:paramloop1
	set "FastMode_Switch_%paramcount%=%~1"
	if defined FastMode_Switch_%paramcount% ( set /a paramcount+=1&shift&goto :paramloop1 )
	set /a paramcount -=1

REM Set arguments pool
	set "Fast_Mode_Switches_Pool_1=%FastMode_Switch_2% %FastMode_Switch_3% %FastMode_Switch_4% %FastMode_Switch_5% %FastMode_Switch_6% %FastMode_Switch_7% %FastMode_Switch_8%"
	set "Fast_Mode_Switches_Pool_2=%FastMode_Switch_9% %FastMode_Switch_10% %FastMode_Switch_11% %FastMode_Switch_12% %FastMode_Switch_13% %FastMode_Switch_14% %FastMode_Switch_15%"
	set "Fast_Mode_Switches_Pool_3=%FastMode_Switch_16% %FastMode_Switch_17% %FastMode_Switch_18% %FastMode_Switch_19% %FastMode_Switch_20% %FastMode_Switch_21% %FastMode_Switch_22%"
REM For later...
REM	set "Fast_Mode_Switches_Pool_4=%FastMode_Switch_23% %FastMode_Switch_24% %FastMode_Switch_25% %FastMode_Switch_26% %FastMode_Switch_27% %FastMode_Switch_28% %FastMode_Switch_29%"
	set "Fast_Mode_Switches_Pool_MAIN=%Fast_Mode_Switches_Pool_1% %Fast_Mode_Switches_Pool_2% %Fast_Mode_Switches_Pool_3%"

REM Set modes from arguments used
	set "Mode_Title=" & set "FullMode=" & set "OfflineMode=" & set "FastMode="
	if "%Run_With_Arg%"=="/fast" ( set "FastMode=Unlocked" & set "Mode_Title= Fast Mode" & set "Fast_Mode_Switches_Pool_MAIN=%Fast_Mode_Switches_Pool_MAIN:/fast=%" )
	if "%Run_With_Arg%"=="/full" ( set "FullMode=Unlocked" & set "Mode_Title= Full Mode" & set "Fast_Mode_Switches_Pool_MAIN=%Fast_Mode_Switches_Pool_MAIN:/full=%" )
	if "%Run_With_Arg%"=="/offline" ( set "FastMode=Unlocked" & set "OfflineMode=Unlocked" & set "Fast_Mode_Switches_Pool_MAIN=%Fast_Mode_Switches_Pool_MAIN:/offline=%" )
	if "%Run_With_Arg%"=="/custom" ( set "FastMode=Unlocked" & set "CustomMode=Unlocked" & set "Fast_Mode_Switches_Pool_MAIN=%Fast_Mode_Switches_Pool_MAIN:/custom=%" )

REM Set script name and version, saves me some edits
	cd /d "%Tmp_Folder%"
	for %%a in (*.bat) do ( set "Script_User=%%~na" & set "Script_Version=%%~na" )
	set "Script_User=%Script_User:~21%"
	set "Script_Version=%Script_Version:~17,4%"

REM Values
	set "Idx_Tmp_Folder=%User_Tmp_Folder%\Indexing_Options_%random%.tmp"
	set "Idx_lock=%Idx_Tmp_Folder%\wait%random%.lock"
	set "Idx_scriptname=%Idx_Tmp_Folder%\SearchScopeTask.ps1"
	set "SPACE50=                                                  "
	set "STAR46=**********************************************"
	set "windir=C:\Windows"
	set "PScommand=%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass"
	set "colors=blue=[94m,green=[92m,red=[31m,yellow=[93m,white=[97m
	set "%colors:,=" & set "%"
	set "hide_cursor=[?25l"
	set "show_cursor=[?25h"
	set "yes=[?25l[92mYes[97m"
	set "no=[?25l[31mNo[97m"
	set "abort=[?25l[31mAborted[97m"
	set "done=[?25l[92mDone.[97m"

REM TitleBar
	set "Shell_Title=%white%]0;Optimize NextGen %Script_Version%%Mode_Title%%white%"
	set "Shell_Title2=%white%]0;Indexing Options%white%"

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
		if "%OS_Name%"=="Microsoft Windows Server 2019 Datacenter" ( set "Win_Edition=Windows Server 2019" & set "Win_Edition_Title=%OS_Name:~0,29%" & goto :First_Run )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Standard" ( set "Win_Edition=Windows Server 2019" & set "Win_Edition_Title=%OS_Name:~0,29%" & goto :First_Run )
		if "%OS_Name%"=="Microsoft Windows Server 2019 Essentials" ( set "Win_Edition=Windows Server 2019" & set "Win_Edition_Title=%OS_Name:~0,29%" & goto :First_Run )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise LTSC" ( set "Win_Edition=Windows 10 LTSC" & set "Win_Edition_Title=Microsoft Windows 10 LTSC" & goto :First_Run )
		if "%OS_Name%"=="Microsoft Windows 10 Enterprise N LTSC" ( set "Win_Edition=Windows 10 LTSC" & set "Win_Edition_Title=Microsoft Windows 10 LTSC" & goto :First_Run )
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
:First_Run
::============================================================================================================
REM Launch script from temp folder and exit this one
	if "%Run%"=="First" (
		set "Run=Second"
		if "%OfflineMode%"=="Unlocked" (
			"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -ShowWindowMode:hide "%Tmp_Folder%Optimize_NextGen_%Script_Version%%Script_User%.bat" && exit /b
		) else (
			if "%launcher%"=="exe" ( "%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole "%Tmp_Folder%Optimize_NextGen_%Script_Version%%Script_User%.bat" && exit /b )
			if "%launcher%"=="bat" ( "%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P "%Tmp_Folder%Optimize_NextGen_%Script_Version%%Script_User%.bat" && exit /b )
	))

::============================================================================================================
:START
::============================================================================================================
REM Go to temp and remove backup folder
	cd /d "%User_Tmp_Folder%"
	if exist "%User_Tmp_Folder%\SettingsBackup" ( rmdir "SettingsBackup" /s /q >nul 2>&1 )
REM Display title in titlebar
	echo %hide_cursor%%Shell_Title%
	cls
	if "%FullMode%"=="Unlocked" ( goto :Full_Mode_Main_Task )
	if "%FastMode%"=="Unlocked" ( goto :Fast_Mode_Main_Task )
	if "%Run_With_Arg%"=="/?" ( set "Help_Style=Main" & call :Help_Menu & goto :START )
	call :Modes_Locker
	call :Color_title
	echo: & echo:
	echo 1. Optimize& echo:
	echo 2. Restore& echo:
	echo H. Help& echo:
	<nul set /p DummyName=Select your option, or 0 to exit: %show_cursor%
	choice /c 12H0 >nul 2>&1
	if errorlevel 4 ( echo %hide_cursor%0& cls & goto :TmpFolder_Remove )
	if errorlevel 3 ( echo %hide_cursor%H& set "Run_With_Arg=/?" & set "Help_Style=Start" & cls & call :Help_Menu & goto :START )
	if errorlevel 2 ( echo %hide_cursor%2& cls & goto :Restore_MENU )
	if errorlevel 1 ( echo %hide_cursor%1& cls & goto :Optimize_MENU )

::============================================================================================================
:Optimize_MENU
::============================================================================================================
	call :Modes_Locker
	echo %hide_cursor%%Shell_Title%
	cls
	call :Color_title
	echo: & echo:
	echo 1. Apply FULL optimization ^(interactive script^)& echo:
	echo 2. Fast mode: FULL optimization without prompts and backups& echo:
	echo 3. Privacy task only& echo:
	echo 4. Performances optimization task only& echo:
	echo 5. Group Policy task only& echo:
	if "%Win_Regular_Edition%"=="Windows 10" ( echo %red%6. Services optimization task only%white% ^(LTSC and Windows Server only^)& echo:) else ( echo 6. Services optimization task only& echo:)
	echo S. Disable %blue%S%white%cheduled Tasks only& echo:
	echo T. Apply Registry %blue%T%white%weaks only ^(privacy + performances tweaks^)& echo:
	echo P. Apply %blue%P%white%ower Management settings only& echo:
	echo U. Enable %blue%U%white%ltimate Performance Power Scheme ^(and create with Default GUID if it doesn't exist^)& echo:
	echo W. Enable %blue%W%white%rite Caching on all disks& echo:
	if not "%Win_Edition%"=="Windows Server 2019" ( echo %red%M. Optimize Memory Settings%white% ^(Windows Server only^)& echo:) else ( echo M. Optimize %blue%M%white%emory Settings for Windows Server& echo:)
	echo I. Set %blue%I%white%ndexing Options& echo:
	echo 0. %blue%O%white%ptimize System SSD ^(Send TRIM Request^)& echo:
	echo G. Deactivate %blue%G%white%ame Explorer& echo:
	echo E. Clear %blue%E%white%vent Viewer Logs& echo:
	echo B. %blue%B%white%ackup Services and/or Group Policy setting& echo:
	echo N. .%blue%N%white%ET Framework web applications performance tuning& echo:
	echo R. Go to %blue%R%white%estore Menu& echo:
	echo H. %blue%H%white%elp Menu& echo:
	echo 0. Exit& echo:

	<nul set /p DummyName=Select your option, or 0 to exit: %show_cursor%
	choice /c 123456STPUWMIOGEBNRH0 >nul 2>&1

		if errorlevel 21 ( echo %hide_cursor%0& cls & goto :TmpFolder_Remove )
		if errorlevel 20 ( echo %hide_cursor%H& set "Run_With_Arg=/?" & set "Help_Style=Optimize" & cls & call :Help_Menu & goto :Optimize_MENU )
		if errorlevel 19 ( echo %hide_cursor%R& cls & goto :Restore_MENU )
		if errorlevel 18 ( echo %hide_cursor%N& cls & goto :TASK_N )
		if errorlevel 17 ( echo %hide_cursor%B& cls & goto :Backup_Menu_Task )
		if errorlevel 16 ( echo %hide_cursor%E& cls & goto :TASK_E )
		if errorlevel 15 ( echo %hide_cursor%G& cls & goto :TASK_G )
		if errorlevel 14 ( echo %hide_cursor%O& cls & goto :TASK_O )
		if errorlevel 13 ( echo %hide_cursor%I& cls & goto :TASK_I )
		if errorlevel 12 ( echo %hide_cursor%M& cls & goto :TASK_M )
		if errorlevel 11 ( echo %hide_cursor%W& cls & goto :TASK_W )
		if errorlevel 10 ( echo %hide_cursor%U& cls & goto :TASK_U )
		if errorlevel 9 ( echo %hide_cursor%P& cls & goto :TASK_P )
		if errorlevel 8 ( echo %hide_cursor%T& cls & goto :TASK_T )
		if errorlevel 7 ( echo %hide_cursor%S& cls & goto :TASK_S )
		if errorlevel 6 ( echo %hide_cursor%6& cls & goto :Services_Optimization_Main_Task )
		if errorlevel 5 ( echo %hide_cursor%5& cls & goto :Group_Policy_Main_Task )
		if errorlevel 4 ( echo %hide_cursor%4& cls & goto :Performances_Optimization_Main_Task )
		if errorlevel 3 ( echo %hide_cursor%3& cls & goto :Privacy_Main_Task )
		if errorlevel 2 ( echo %hide_cursor%2& set "Mode_Title= Fast Mode" & cls & goto :Fast_Mode_Main_Task )
		if errorlevel 1 ( echo %hide_cursor%1& set "Mode_Title= Full Mode" & cls & goto :Full_Mode_Main_Task )

::============================================================================================================
:: OPTIMIZE MENU Tasks
::============================================================================================================
:Full_Mode_Main_Task
	set "FullMode=Unlocked"
	set "Shell_Title=%white%]0;Optimize NextGen %Script_Version%%Mode_Title%%white%"
	if not "%Run_With_Arg%"=="/full" ( echo %Shell_Title%& cls )
	call :Color_title2
	call :Backup_Services1
	call :Backup_GPO
	call :Reset_GPO
	call :MStore_Modes_Locker
	if not "%Win_Edition%"=="Windows Server 2019" ( call :WStore_Check )
	call :Privacy_Opt_Txt
	call :Telemetry_Settings
	call :Scheduled_Tasks_Settings
	call :Privacy_Settings
	echo %yellow%Privacy settings task has completed successfully.%white%& echo:
	call :Perf_Opt_Txt
	call :Enable_Ultimate_Performance
	call :Performances_Settings
	call :Power_Settings
	call :Selective_Suspend
	call :WriteCaching
	call :MMAgent
	echo %yellow%Performances optimization task has completed successfully.%white%& echo:
	call :Group_Policy_Task
	call :Save_Scripts_Txt
	call :Save_PS_Scripts
	call :Tweak_PS_Scripts_Logs
	call :Save_Registry_Scripts
	call :Save_Scheduled_Tasks_Scripts
	call :Save_GPO_Scripts
	call :Save_Services_Scripts
	call :Save_Scripts_Success
	call :Services_Optimization
	call :Indexing_Options
	call :Net_Web_Apps
	call :EventLog_Cosmetics
	call :Game_Explorer
	call :TRIM_Request
	call :Save_All_Settings
	call :Cleaning
	if not "%Win_Edition%"=="Windows Server 2019" ( call :MStore_Modes_Locker )
	goto :Restart_Warning


:Fast_Mode_Main_Task
	set "FastMode=Unlocked"
	set "Shell_Title=%white%]0;Optimize NextGen %Script_Version%%Mode_Title%%white%"
	if not "%Run_With_Arg%"=="/fast" ( echo %hide_cursor%%Shell_Title%& cls )
REM Set variables
	set "Style=startmenus"
	set "Reset_GPO_Security=Reset_GPO_Security"
	set "Custom_Policy=Imported"
	set "Firefox_Policy=Imported"
	set "WLan_Service=Disable_WLan_Service"
	set "File_and_Printer_Sharing=Disable_File_and_Printer_Sharing"
	call :MStore_Modes_Locker
	if "%Fast_Mode_Switches_Pool_MAIN%"=="                    " ( set "Fast_Mode_Switches_Pool_MAIN=%Fast_Mode_Switches_Pool_MAIN: =%" )
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" (
		for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do (
			if "%%a"=="-noresetgps" ( set "Reset_GPO_Security=No_Reset_GPO_Security" )
			if "%%a"=="-noimportcp" ( set "Custom_Policy=Not_Imported" )
			if "%%a"=="-noimportfp" ( set "Firefox_Policy=Not_Imported" )
			if "%%a"=="-enablewl" ( set "WLan_Service=Enable_WLan_Service" )
			if "%%a"=="-enablefps" ( set "File_and_Printer_Sharing=Enable_File_and_Printer_Sharing" )
			if "%%a"=="-defaultidx" ( set "Style=default" )
			if "%%a"=="-resetidx" ( set "Style=reset" )
			if not "%Win_Edition%"=="Windows Server 2019" (
				if "%%a"=="-store" ( set "Win_Store=Store_ON" )
				if "%%a"=="-games" ( set "Win_Games=Games_ON" )
			)
	))

REM Offline mode jump
	if "%OfflineMode%"=="Unlocked" ( goto :Fast_Mode_Task_Start )

REM Custom mode string replacement
	set "Argument_Line=%Fast_Mode_Switches_Pool_MAIN%"
	if "%CustomMode%"=="Unlocked" (
		setlocal EnableDelayedExpansion
		set "Argument_Line=!Argument_Line! -nogp -nopriv -noperf -noserv -bypassidx"
		for %%a in (!Argument_Line!) do (
			if "%%a"=="-gp" ( set "Argument_Line=!Argument_Line:-nogp=! -noimportcp -noresetgps -noimportfp" &set "Argument_Line=!Argument_Line:-gp=!" )
			if "%%a"=="-resetgps" ( set "Argument_Line=!Argument_Line:-noresetgps=!" & set "Argument_Line=!Argument_Line:-resetgps=!" )
			if "%%a"=="-importcp" ( set "Argument_Line=!Argument_Line:-noimportcp=!" & set "Argument_Line=!Argument_Line:-importcp=!" )
			if "%%a"=="-importfp" ( set "Argument_Line=!Argument_Line:-noimportfp=!" & set "Argument_Line=!Argument_Line:-importfp=!" )
			if "%%a"=="-priv" ( set "Argument_Line=!Argument_Line:-nopriv=!" & set "Argument_Line=!Argument_Line:-priv=!" )
			if "%%a"=="-perf" ( set "Argument_Line=!Argument_Line:-noperf=! -noss -nowc -nomm" & set "Argument_Line=!Argument_Line:-perf=!" )
			if "%%a"=="-ss" ( set "Argument_Line=!Argument_Line:-noss=!" & set "Argument_Line=!Argument_Line:-ss=!" )
			if "%%a"=="-wc" ( set "Argument_Line=!Argument_Line:-nowc=!" & set "Argument_Line=!Argument_Line:-wc=!" )
			if "%%a"=="-mm" ( set "Argument_Line=!Argument_Line:-nomm=!" & set "Argument_Line=!Argument_Line:-mm=!" )
			if "%%a"=="-serv" ( set "Argument_Line=!Argument_Line:-noserv=!" & set "Argument_Line=!Argument_Line:-serv=!" )
			if "%%a"=="-startmenusidx" ( set "Argument_Line=!Argument_Line:-bypassidx=!" & set "Argument_Line=!Argument_Line:-startmenusidx=!" )
			if "%%a"=="-defaultidx" ( set "Argument_Line=!Argument_Line:-bypassidx=!" )
			if "%%a"=="-resetidx" ( set "Argument_Line=!Argument_Line:-bypassidx=!" )
		)
		set "Argument_Line=!Argument_Line: =!"
		if not "!Argument_Line!"=="" ( set "Argument_Line=!Argument_Line:-= -!" & set "Fast_Mode_Switches_Pool_MAIN=!Argument_Line!") else ( set "Fast_Mode_Switches_Pool_MAIN=" )
		setlocal DisableDelayedExpansion
		goto :Fast_Mode_Task_Start
	)

REM Warning message
		if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-nowarn" ( goto :Fast_Mode_Task_Start )))
		REM Resize window keeping buffer size
		"%Tmp_Folder%Files\Utilities\consolesize.exe" 153 59 153 9999
		call :Help_Menu

:Fast_Mode_Task_Start
	call :Color_title2
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-backupserv" ( call :Backup_Services_Fast_Task )))
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-backupgp" ( call :Backup_GPO_Fast_Task )))
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-nogp" ( goto :Fast_Mode_Privacy_Task )))
	call :Reset_GPO
:Fast_Mode_Privacy_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-nopriv" ( goto :Fast_Mode_Performance_Task )))
	call :Privacy_Opt_Txt
	call :Telemetry_Settings
	call :Scheduled_Tasks_Settings
	call :Privacy_Settings
	echo %yellow%Privacy settings task has completed successfully.%white%& echo:
:Fast_Mode_Performance_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-noperf" ( goto :Fast_Mode_GroupPolicy_Task )))
	call :Perf_Opt_Txt
	call :Enable_Ultimate_Performance
	call :Performances_Settings
	call :Power_Settings
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-noss" ( goto :Fast_Mode_WriteCaching_Task )))
	call :Selective_Suspend
:Fast_Mode_WriteCaching_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-nowc" ( goto :Fast_Mode_MMAgent_Task )))
	call :WriteCaching
:Fast_Mode_MMAgent_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-nomm" ( goto :Fast_Mode_Performance_Task_Success )))
	call :MMAgent
:Fast_Mode_Performance_Task_Success
	echo %yellow%Performances optimization task has completed successfully.%white%& echo:
:Fast_Mode_GroupPolicy_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-nogp" ( goto :Fast_Mode_Services_Task )))
	call :Group_Policy_Task
:Fast_Mode_Services_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-noserv" ( goto :Fast_Mode_Indexing_Options_Task )))
	call :Services_Optimization
:Fast_Mode_Indexing_Options_Task
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-bypassidx" ( call :Reset_Indexing_Options_Task_Variable & goto :Fast_Mode_Net_Apps )))
	call :Indexing_Options_Task
:Fast_Mode_Net_Apps
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-netapps" ( call :Net_Web_Apps )))
:Fast_Mode_EventLog_Cosmetics
	call :EventLog_Cosmetics
REM Game Explorer deactivation
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-gex" ( call :Game_Explorer )))
REM Event Viewer logs clearing
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-evlog" ( call :Clear_EventViewer_Logs )))
REM Trim request
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" ( for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-trim" (
		<nul set /p DummyName=Sending TRIM request to system SSD...%show_cursor%& call :TRIM_Command )))
REM Clean
	call :Cleaning
REM Close
	if not "%Fast_Mode_Switches_Pool_MAIN%"=="" (
		if not "%OfflineMode%"=="Unlocked" (
			for %%a in (%Fast_Mode_Switches_Pool_MAIN%) do ( if "%%a"=="-norestart" (
			<nul set /p DummyName=All Tasks have completed, closing in a moment...%show_cursor%
			timeout /t 3 /nobreak >nul 2>&1
			goto :TmpFolder_Remove
	))))
	if not "%Win_Edition%"=="Windows Server 2019" ( if not "%OfflineMode%"=="Unlocked" ( call :MStore_Modes_Locker ))
REM Go to restart prompt or exit and clean all files in temp folder
	if not "%OfflineMode%"=="Unlocked" ( goto :Restart_Warning ) else ( goto :TmpFolder_Remove )


::3
:Privacy_Main_Task
	call :Color_title2
	call :MStore_Modes_Locker
	if not "%Win_Edition%"=="Windows Server 2019" ( call :WStore_Check )
	call :Privacy_Opt_Txt
	call :Telemetry_Settings
	call :Scheduled_Tasks_Settings
	call :Privacy_Settings
	echo %yellow%Privacy settings task has completed successfully.%white%& echo:
	call :Save_Scripts_Txt
	call :Save_Registry_Scripts
	call :Save_Scheduled_Tasks_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	if not "%Win_Edition%"=="Windows Server 2019" ( call :MStore_Modes_Locker )
	goto :Return_To_Main_Menu

::4
:Performances_Optimization_Main_Task
	call :Color_title2
	call :Perf_Opt_Txt
	call :Enable_Ultimate_Performance
	call :Performances_Settings
	call :Power_Settings
	call :Selective_Suspend
	call :WriteCaching
	call :MMAgent
	echo %yellow%Performances optimization task has completed successfully.%white%& echo:
	call :TRIM_Request
	<nul set /p DummyName=Saving scripts and logs...
	call :Save_PS_Scripts
	call :Tweak_PS_Scripts_Logs
	call :Save_Registry_Scripts
	call :Save_Files_Success
	call :Save_Before_End
	goto :Return_To_Main_Menu

::5
:Group_Policy_Main_Task
	call :Color_title2
	call :Backup_GPO
	call :Reset_GPO
	call :MStore_Modes_Locker
	if not "%Win_Edition%"=="Windows Server 2019" ( call :WStore_Check )
	call :Group_Policy_Task
	<nul set /p DummyName=Saving Group Policy backups, settings files and scripts...
	call :Save_GPO_Scripts
	call :Save_Files_Success
	call :Save_Before_End
	if not "%Win_Edition%"=="Windows Server 2019" ( call :MStore_Modes_Locker )
	goto :Return_To_Main_Menu

::6
:Services_Optimization_Main_Task
	call :Color_title2
	if "%Win_Regular_Edition%"=="Windows 10" ( echo Services Optimization is not available ^(yet^) on %Win_Edition%.& goto :Return_To_Optimize_Menu )
	call :Backup_Services1
	call :Services_Optimization
	<nul set /p DummyName=Saving scripts and services startup configuration backups...
	call :Save_Services_Scripts
	call :Save_Files_Success
	call :Save_Before_End
	goto :Return_To_Main_Menu

::7
:TASK_S
	call :Color_title2
	<nul set /p DummyName=Disabling scheduled tasks...%show_cursor%
	call :Scheduled_Tasks_Settings_Single
	echo:
	<nul set /p DummyName=Saving Scheduled Tasks script...
	call :Save_Scheduled_Tasks_Scripts
	echo %hide_cursor%%yellow%Script successfully saved.%white%& echo:
	call :Save_Before_End
	goto :Return_To_Main_Menu

::8
:TASK_T
	call :Color_title2
	call :MStore_Modes_Locker
	if not "%Win_Edition%"=="Windows Server 2019" ( call :WStore_Check )
	call :Privacy_Opt_Txt
	call :Telemetry_Settings
	call :Privacy_Settings
	echo %yellow%Privacy registry settings task has completed successfully.%white%& echo:
	call :Perf_Opt_Txt
	call :Performances_Settings
	call :Power_Settings
	echo %yellow%Performances registry settings task has completed successfully.%white%& echo:
	call :Save_Scripts_Txt
	call :Save_Registry_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	if not "%Win_Edition%"=="Windows Server 2019" ( call :MStore_Modes_Locker )
	goto :Return_To_Main_Menu

::9
:TASK_P
	call :Color_title2
	echo Applying Power Management settings...%show_cursor%
	call :Enable_Ultimate_Performance
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\3C0BC021-C8A8-4E07-A973-6B14CBCB2B7E" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280" /v "ACSettingIndex" /t REG_DWORD /d "3" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" /v "ACSettingIndex" /t REG_DWORD /d "1" /f >nul 2>&1
	call :Power_Settings
	call :Selective_Suspend
	echo %Shell_Title%[1A
	echo %yellow%Power Management settings optimization task has completed successfully.%white%& echo:
	<nul set /p DummyName=Saving Power Management scripts and logs...
	robocopy /MIR "%Tmp_Folder%Files\Scripts\PowerManagement" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement" >nul 2>&1
	cd /d "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement"
	call :Tweak_PSscripts
	call :Tweak_PS_Scripts_Logs
	call :Save_Files_Success
	call :Save_Before_End
	echo You will need to restart your PC to finish optimizing your system.
	goto :Restart_Question

::10
:TASK_U
	call :Color_title2
	<nul set /p DummyName=Enabling Ultimate Performance PowerScheme...%show_cursor%
	call :Enable_Ultimate_Performance_START
	echo:
	goto :Return_To_Main_Menu

::11
:TASK_W
	set "WC_SingleTask=WC_SingleTask_ON"
	call :Color_title2
	call :WriteCaching
	set "WC_SingleTask=WC_SingleTask_OFF"
	echo:
	<nul set /p DummyName=Saving Write Caching script and log...
	robocopy /MIR "%Tmp_Folder%Files\Scripts\WriteCaching" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching" >nul 2>&1
	cd /d "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching"
	call :Tweak_PSscripts
	echo %hide_cursor%%yellow%Files successfully saved.%white%
	call :Save_Before_End
	goto :Restart_Information

::12
:TASK_M
	call :Color_title2
	if not "%Win_Edition%"=="Windows Server 2019" ( echo This settings can only be applied on Windows Server.& goto :Return_To_Optimize_Menu )
	<nul set /p DummyName=Enabling MemoryCompression and PageCombining...%show_cursor%
	call :Memory_Settings_Enable
	echo:
	goto :Return_To_Main_Menu

::13
:TASK_I
	echo %Shell_Title2%& cls
	call :Color_title2
	echo: & echo:
	call :Indexing_Options_Start
	goto :Return_To_Main_Menu

::14
:TASK_O
	call :Color_title2
	<nul set /p DummyName=Sending TRIM request to system SSD...%show_cursor%
	call :TRIM_Command
	goto :Return_To_Main_Menu

::15
:TASK_G
	call :Color_title2
	call :Game_Explorer
	goto :Return_To_Main_Menu

::16
:TASK_E
	call :Color_title2
	call :Clear_EventViewer_Logs
	goto :Return_To_Main_Menu

::17
:Backup_Menu_Task
	call :Color_title2
	set "Backup_Menu_Task=Unlocked"
	<nul set /p DummyName=Do you want to backup services startup configuration? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %hide_cursor%%no%& echo: & goto :Group_Policy_Backup_Question )
	if errorlevel 1 ( echo %hide_cursor%%yes%& call :Backup_Services1 )
:Group_Policy_Backup_Question
	<nul set /p DummyName=Do you want to backup Group Policy settings? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %hide_cursor%%no%& echo: & goto :Save_Backups_Made )
	if errorlevel 1 ( echo %hide_cursor%%yes%& call :Backup_GPO )
:Save_Backups_Made
	robocopy "%User_Tmp_Folder%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S /MT:128 >nul 2>&1
	call :Cleaning
	set "Backup_Menu_Task=Undefined"
	goto :Return_To_Main_Menu

:Backup_Services_Fast_Task
	call :Backup_Services1
	robocopy "%User_Tmp_Folder%\SettingsBackup\Services Backup" "%launchpath%Backup\Services Backup" *.* /is /it /S /MT:128 >nul 2>&1
	goto :eof

:Backup_GPO_Fast_Task
	call :Backup_GPO
	robocopy "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup" "%launchpath%Backup\GroupPolicy Backup" *.* /is /it /S /MT:128 >nul 2>&1
	goto :eof

::18
:TASK_N
	call :Color_title2
	call :Net_Web_Apps
	goto :Return_To_Main_Menu

::============================================================================================================
:Restore_MENU
::============================================================================================================
	call :Modes_Locker
	echo %hide_cursor%%Shell_Title%
	cls
	call :Color_title
	echo: & echo:
	echo 1. Remove Registry Tweaks& echo:
	echo 2. Reset Group Policy& echo:
	echo 3. Restore Group Policy from backup& echo:
	echo 4. Restore services startup configuration from backup& echo:
	if not "%Win_Edition%"=="Windows Server 2019" ( echo %red%5. Restore Default Memory Settings%white% ^(Windows Server only^)& echo:) else ( echo 5. Restore Default Memory Settings& echo:)
	echo 6. Restore Windows default indexed locations.& echo:
	echo G. Reactivate %blue%G%white%ame Explorer& echo:
	echo N. Remove or restore .%blue%N%white%ET Framework web applications performance tuning tweaks& echo:
	echo O. Go to %blue%O%white%ptimize Menu& echo:
	echo H. %blue%H%white%elp Menu& echo:
	echo 0. Exit& echo:

	<nul set /p DummyName=Select your option, or 0 to exit: %show_cursor%
	choice /c 123456GNOH0 >nul 2>&1
		if errorlevel 11 ( echo %hide_cursor%0& cls & goto :TmpFolder_Remove )
		if errorlevel 10 ( echo %hide_cursor%H& set "Run_With_Arg=/?" & set "Help_Style=Restore" & cls & call :Help_Menu & goto :Restore_MENU )
		if errorlevel 9 ( echo %hide_cursor%O& cls & goto :Optimize_MENU )
		if errorlevel 8 ( echo %hide_cursor%N& cls & goto :RTASK_N )
		if errorlevel 7 ( echo %hide_cursor%G& cls & goto :RTASK_G )
		if errorlevel 6 ( echo %hide_cursor%6& cls & goto :RTASK_6 )
		if errorlevel 5 ( echo %hide_cursor%5& cls & goto :RTASK_5 )
		if errorlevel 4 ( echo %hide_cursor%4& cls & goto :RTASK_4 )
		if errorlevel 3 ( echo %hide_cursor%3& cls & goto :RTASK_3 )
		if errorlevel 2 ( echo %hide_cursor%2& cls & goto :RTASK_2 )
		if errorlevel 1 ( echo %hide_cursor%1& cls & goto :RTASK_1 )

::============================================================================================================
:: RESTORE Menu Tasks
::============================================================================================================
:RTASK_1
	call :Color_title2
	call :Remove_Tweaks
	call :Save_Registry_Scripts
	call :Save_Scripts_Success
	call :Save_Before_End
	goto :Return_To_Main_Menu

:RTASK_2
	call :Color_title2
:RTASK_2_no_Color_Title
	set "Restore_GPO_Task=Unlocked"
	call :Backup_GPO
	call :Reset_Group_Policy_Preferences
	call :Reset_GPO
	call :GP_Update
	call :Save_Before_End
	echo %white%Your Group Policy settings have been reset.
	set "Restore_GPO_Task=Undefined"
	goto :Restart_Information

:RTASK_3
	set "Restore_GPO_Task=Unlocked"
	call :Color_title2
	call :Reset_Group_Policy_Preferences
	call :Restore_GPO
	call :GP_Update
	echo %white%Your Group Policy settings have been restored.
	set "Restore_GPO_Task=Undefined"
	goto :Restart_Information

:RTASK_4
	call :Color_title2
	call :Restore_Services
	goto :Return_To_Main_Menu

:RTASK_5
	if not "%Win_Edition%"=="Windows Server 2019" (
		echo This settings can only be applied on Windows Server.& echo:
		<nul set /p DummyName=Press any key to return to Restore menu...%show_cursor%
		pause >nul
		goto :Restore_MENU
	)
	call :Color_title2
	<nul set /p DummyName=Disabling MemoryCompression and PageCombining...%show_cursor%
	call :Memory_Settings_Disable
	echo:
	goto :Return_To_Main_Menu

:RTASK_6
	call :Color_title2
	set "Style=default"
	call :Indexing_Options_Task
	goto :Return_To_Main_Menu

:RTASK_G
	call :Color_title2
	call :Game_Explorer_Restore
	goto :Return_To_Main_Menu

:RTASK_N
	call :Color_title2
	call :Net_Web_Apps_Restore
	goto :Return_To_Main_Menu

::============================================================================================================
:Color_title
::============================================================================================================
	if "%Win_Edition%"=="Windows Server 2019" ( echo %SPACE50%%white%%STAR46%****)
	if "%Win_Edition%"=="Windows 10 LTSC" ( echo %SPACE50%%white%%STAR46%)
	if "%Win_Edition%"=="Windows 10 Education" ( echo %SPACE50%%white%%STAR46%**********)
	if "%Win_Edition%"=="Windows 10 Enterprise" ( echo %SPACE50%%white%%STAR46%***********)
	if "%Win_Edition%"=="Windows 10 Pro" ( echo %SPACE50%%white%%STAR46%****)
	if "%Win_Edition%"=="Windows 10" ( echo %SPACE50%%white%%STAR46%)
	if "%Win_Regular_Edition%"=="Windows 10" ( echo %SPACE50%Optimize NextGen LITE for %Win_Edition_Title%) else ( echo %SPACE50%Optimize NextGen for %Win_Edition_Title%)
	if "%Win_Edition%"=="Windows Server 2019" ( echo %SPACE50%%STAR46%****)
	if "%Win_Edition%"=="Windows 10 LTSC" ( echo %SPACE50%%STAR46%)
	if "%Win_Edition%"=="Windows 10 Education" ( echo %SPACE50%%STAR46%**********)
	if "%Win_Edition%"=="Windows 10 Enterprise" ( echo %SPACE50%%STAR46%***********)
	if "%Win_Edition%"=="Windows 10 Pro" ( echo %SPACE50%%STAR46%****)
	if "%Win_Edition%"=="Windows 10" ( echo %SPACE50%%STAR46%)
	goto :Jump_Line_and_EOF

::============================================================================================================
:Color_title2
::============================================================================================================
	if "%Win_Edition%"=="Windows Server 2019" ( echo %SPACE50%%yellow%%STAR46%****)
	if "%Win_Edition%"=="Windows 10 LTSC" ( echo %SPACE50%%yellow%%STAR46%)
	if "%Win_Edition%"=="Windows 10 Education" ( echo %SPACE50%%yellow%%STAR46%**********)
	if "%Win_Edition%"=="Windows 10 Enterprise" ( echo %SPACE50%%yellow%%STAR46%***********)
	if "%Win_Edition%"=="Windows 10 Pro" ( echo %SPACE50%%yellow%%STAR46%****)
	if "%Win_Edition%"=="Windows 10" ( echo %SPACE50%%yellow%%STAR46%)
	if "%Win_Regular_Edition%"=="Windows 10" ( echo %SPACE50%Optimize NextGen LITE for %Win_Edition_Title%) else ( echo %SPACE50%Optimize NextGen for %Win_Edition_Title%)
	if "%Win_Edition%"=="Windows Server 2019" ( echo %SPACE50%%STAR46%****%white%)
	if "%Win_Edition%"=="Windows 10 LTSC" ( echo %SPACE50%%STAR46%%white%)
	if "%Win_Edition%"=="Windows 10 Education" ( echo %SPACE50%%STAR46%**********%white%)
	if "%Win_Edition%"=="Windows 10 Enterprise" ( echo %SPACE50%%STAR46%***********%white%)
	if "%Win_Edition%"=="Windows 10 Pro" ( echo %SPACE50%%STAR46%****%white%)
	if "%Win_Edition%"=="Windows 10" ( echo %SPACE50%%STAR46%%white%)
	goto :Jump_Line_and_EOF

::============================================================================================================
:Backup_Services1
::============================================================================================================
	<nul set /p DummyName=Backing up current services startup configuration...%show_cursor%
	cd /d "%Tmp_Folder%Files\Scripts\Services"
REM Create lock file
	echo >lock.tmp
REM Backup services through vbs script, getting services count argument from it
	for /f "delims=" %%i in ('cscript //nologo "%Tmp_Folder%Files\Scripts\Services\Cur_services_startup_config_backup.vbs" "iSvc_Cnt"') do Set "iSvc_Cnt=%%i"
	echo:
	<nul set /p DummyName=%iSvc_Cnt%
:Wait_for_lock_Cur
	if exist "lock.tmp" goto :Wait_for_lock_Cur
	for /r %%a in (*.reg) do ( set "Cur_Service_Backup_Path=%%~dpna" & set "Cur_Service_Backup_Name=%%~na" )
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)( start=.*)$" "$1$3$4" /m /f "%Cur_Service_Backup_Path%.bat" /o - >nul 2>&1
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(HKEY_LOCAL_MACHINE.*)_(.*)\d(.*)$" "$1$3" /m /f "%Cur_Service_Backup_Path%.reg" /o - >nul 2>&1
 	robocopy "%Tmp_Folder%Files\Scripts\Services" "%User_Tmp_Folder%\SettingsBackup\Services Backup" *.reg *.bat /Mov /is /it /S /xf "Services Optimization.bat" >nul 2>&1
	echo %hide_cursor%[1A[9D%green%Done.%white%[1B
	echo %yellow%Default services startup configuration saved as "%Cur_Service_Backup_Name%".%white%
	goto :Jump_Line_and_EOF

::============================================================================================================
:Backup_GPO
::============================================================================================================
	cd /d "%User_Tmp_Folder%"
	<nul set /p DummyName=Backing up current Group Policy...%show_cursor%
REM Create folders
	mkdir "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Current GPO" >nul 2>&1
	mkdir "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Local Policy Export" >nul 2>&1
REM Remove folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
REM Copy policy files
	robocopy "%windir%\system32\GroupPolicy" "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Current GPO\GroupPolicy" *.pol /is /it /S >nul 2>&1
REM Export GPO with LGPO
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /b "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Local Policy Export" /n "Local Policy Backup" /q >nul 2>&1
REM Export Group Policy Security settings
	mkdir "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Security settings" >nul 2>&1
	if exist "%launchpath%Backup\GroupPolicy Backup\Security settings\securityconfig.cfg" (
		move /y "%launchpath%Backup\GroupPolicy Backup\Security settings\securityconfig.cfg" "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Security settings\securityconfig.bak" >nul 2>&1 )
	secedit /export /cfg "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Security settings\securityconfig.cfg" >nul 2>&1
REM Force rename policy files to .bak as an additional safety measure
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >nul 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >nul 2>&1
	echo %done%
	goto :Jump_Line_and_EOF

::============================================================================================================
:Reset_GPO
::============================================================================================================
	<nul set /p DummyName=Resetting Group Policy...%show_cursor%
	del /F /Q /S "%windir%\system32\GroupPolicy\User\registry.pol" >nul 2>&1
	del /F /Q /S "%windir%\system32\GroupPolicy\Machine\registry.pol" >nul 2>&1
	echo %done%
	if not "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=Do you want to reset your Group Policy Security settings as well? [Y/N]%show_cursor%
		choice /c YN >nul 2>&1
		if errorlevel 2 ( echo %abort%& goto :Reset_GPO_Security_Task_Variable )
		if errorlevel 1 ( echo %yes%%show_cursor%& goto :Reset_GPO_Task )
	)
	if "%Reset_GPO_Security%"=="Reset_GPO_Security" ( echo Resetting Group Policy Security settings...%show_cursor%) else ( goto :Reset_GPO_Security_Task_Variable )
:Reset_GPO_Task
	if not exist "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Security settings" ( mkdir "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Security settings" >nul 2>&1 )
	cd /d "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Security settings"
REM Full GPO reset
	secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb
	if "%Reset_GPO_Security%"=="Reset_GPO_Security" ( echo %hide_cursor%[4A[43C%yellow%The task has completed.%white%& echo: [140X& goto :eof )
	echo %hide_cursor%[3A%yellow%The task has completed.%white%

:Reset_GPO_Security_Task_Variable
	set "Reset_GPO_Security=Not_Defined"
	echo: [140X
	goto :eof

::============================================================================================================
:: Privacy Task
::============================================================================================================
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

:Scheduled_Tasks_Settings
	<nul set /p DummyName=[2X[2C-Disabling scheduled tasks...%show_cursor%
:Scheduled_Tasks_Settings_Single
REM Microsoft tasks
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
	schtasks /Change /TN "Microsoft\Windows\Media Center\OCURActivate" /Disable >nul 2>&1
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
	if not "%Win_Games%"=="Games_ON" (
		schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable >nul 2>&1
		schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable >nul 2>&1
	)
	schtasks /Change /TN "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRep" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepCR3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
	schtasks /Change /TN "\OneDrive Standalone Update Task-%User_SID%" /Disable >nul 2>&1
REM Office tasks
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
REM Finally delete bad tasks
	schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >nul 2>&1
	schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" >nul 2>&1
	schtasks /Delete /F /TN "Microsoft\Windows\Application Experience\AitAgent" >nul 2>&1
	schtasks /Delete /F /TN "Microsoft\Windows\PerfTrack\BackgroundConfigSurveyor" >nul 2>&1
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
:: Performances
::============================================================================================================
:Enable_Ultimate_Performance
	<nul set /p DummyName=[2C-Enabling Ultimate Performance PowerScheme...%show_cursor%
:Enable_Ultimate_Performance_START
	set "PowerSchemeCreation="
	powercfg /S e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
	if errorlevel 1 ( goto :Create_PwrScheme ) else ( goto :Ultimate_Performance_Success )

:Create_PwrScheme
	powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
	for /f "tokens=4" %%f in ('powercfg -list ^| findstr /c:"Ultimate Performance"') do set "GUID=%%f"
	powercfg /S %GUID% >nul 2>&1
	set "PowerSchemeCreation=PowerSchemeCreation_ON"
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -ShowWindowMode:Hide -wait "%~dpnx0"&& ( goto :Enable_Ultimate_Performance_START )

:GUID_Trick
REM Ultimate Performance Registry
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "Description" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-18,Provides ultimate performance on higher end PCs." /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61" /v "FriendlyName" /t REG_EXPAND_SZ /d "@%%SystemRoot%%\system32\powrprof.dll,-19,Ultimate Performance" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "ACSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet001\Control\Power\User\Default\PowerSchemes\e9a42b02-d5df-448d-aa00-03f14749eb61\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v "DCSettingIndex" /t REG_DWORD /d "0" /f >nul 2>&1
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

REM Delete GUID
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\%GUID%" /f >nul 2>&1
	exit /b

:Ultimate_Performance_Success
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
REM Prefetch parameters (note: Outdated. EnableSuperfetch and EnablePrefetcher values have been removed since before v1809 and values get automatically deleted anyway)
REM	reg add "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f >nul 2>&1
REM	reg add "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f >nul 2>&1
REM	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /f >nul 2>&1
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
REM Disable scheduled defragmentation
	schtasks /Change /TN "Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
REM Disable System Restore Scheduled Task
	schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Disable >nul 2>&1
REM Me only
	schtasks /Delete /F /TN "Microsoft\Windows\SystemRestore\SR" >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\SystemRestore" /f >nul 2>&1
	takeown /f "C:\Windows\System32\Tasks\Microsoft\Windows\SystemRestore" /r /d y >nul 2>&1
	icacls "C:\Windows\System32\Tasks\Microsoft\Windows\SystemRestore" /grant Administrators:F /t /q >nul 2>&1
	rd /s /q "C:\Windows\System32\Tasks\Microsoft\Windows\SystemRestore" >nul 2>&1
REM Me only
  REM Fix keyboard regional settings (beware, settings for en-US language and French keyboard)
  REM	reg add "HKCU\Control Panel\Desktop\MuiCached" /v "MachinePreferredUILanguages" /t REG_MULTI_SZ /d "en-US" /f >nul 2>&1
  REM	reg add "HKCU\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
  REM	reg add "HKCU\Keyboard Layout\Substitutes" /v "00000409" /t REG_SZ /d "0000040c" /f >nul 2>&1
  REM	reg add "HKU\.DEFAULT\Control Panel\Desktop\MuiCached" /v "MachinePreferredUILanguages" /t REG_MULTI_SZ /d "en-US" /f >nul 2>&1
  REM	reg add "HKU\.DEFAULT\Keyboard Layout\Preload" /v "1" /t REG_SZ /d "00000409" /f >nul 2>&1
  REM	reg add "HKU\.DEFAULT\Keyboard Layout\Substitutes" /v "00000409" /t REG_SZ /d "0000040c" /f >nul 2>&1
REM Kill CreateExplorerShellUnelevatedTask (preventive)
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
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
:Selective_Suspend
::============================================================================================================
	echo   -Selective Suspend:
REM Disable "allow the computer to turn off this device to save power" for HID Devices under PowerManagement tab in Device Manager
	<nul set /p DummyName=[5C-Disabling "Allow the computer to turn off this device to save power" for HID Devices under Power Management tab in Device Manager...%show_cursor%
	setlocal EnableExtensions DisableDelayedExpansion
	set "DetectionCount=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "SelectiveSuspendOn" /t REG_DWORD') do call :ProcessLine "%%i"
	if not %DetectionCount% == 0 ( endlocal & goto :SelectiveSuspend_part2 )

:ProcessLine
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%"=="HKEY_" set "RegistryKey=%~1" & goto :eof
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
	if "%RegistryLine:~0,5%"=="HKEY_" set "RegistryKey=%~1" & goto :eof
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
	if "%RegistryLine:~0,5%"=="HKEY_" set "RegistryKey=%~1" & goto :eof
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
	if "%RegistryLine:~0,5%"=="HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "SelectiveSuspendEnabled" /t REG_BINARY /d "00" /f >nul 2>&1
	set /A Detection4_Count+=1
	goto :eof

:SelectiveSuspend_part5
	setlocal EnableExtensions DisableDelayedExpansion
	set "Detection5_Count=0"
	for /f "delims=" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /v "DeviceSelectiveSuspended" /t REG_DWORD') do call :ProcessLine5 "%%i"
	if not %Detection5_Count% == 0 ( echo %done%& endlocal & goto :SelectiveSuspend_Scripts )

:ProcessLine5
	set "RegistryLine=%~1"
	if "%RegistryLine:~0,5%"=="HKEY_" set "RegistryKey=%~1" & goto :eof
	reg add "%RegistryKey%" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f >nul 2>&1
	set /A Detection5_Count+=1
	goto :eof

:SelectiveSuspend_Scripts
REM Disable "allow the computer to turn off this device to save power" for USBHub under PowerManagement tab in Device Manager
	cd /d "%Tmp_Folder%Files\Scripts\PowerManagement"
	<nul set /p DummyName=[5C-Disabling "Allow the computer to turn off this device to save power" for USB Hubs under Power Management tab in Device Manager...%show_cursor%
	%PScommand% ".\PowerManagementUSB.ps1 -Script_Version '%Script_Version%%Mode_Title%'" >nul 2>&1
	echo %done%
	echo %Shell_Title%[1A

REM Disable "allow the computer to turn off this device to save power" for Network Adapters under PowerManagement tab in Device Manager
	echo %hide_cursor%[5C-Disabling "Allow the computer to turn off this device to save power" for Network Adapters under Power Management tab in Device Manager...
	%PScommand% ".\PowerManagementNIC.ps1 -Script_Version '%Script_Version%%Mode_Title%'"
	echo      %done% Please %yellow%reboot%white% the machine for the changes to take effect.
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:WriteCaching
::============================================================================================================
	cd /d "%Tmp_Folder%Files\Scripts\WriteCaching"
	if not "%WC_SingleTask%"=="WC_SingleTask_ON" (
		<nul set /p DummyName=[2C-Enabling Write Caching on all disks...%show_cursor%
		%PScommand% ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME -Script_Version '%Script_Version%%Mode_Title%'" >nul 2>&1
		echo %done%
	) else (
		echo Enabling Write Caching on all disks...%show_cursor%
		%PScommand% ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME -Script_Version '%Script_Version%'"
		echo %hide_cursor%[11A[12C%green%Done.%white%[11B
	)
	cd /d "%User_Tmp_Folder%"
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:MMAgent
::============================================================================================================
	if not "%Win_Edition%"=="Windows Server 2019" ( goto :eof )
	<nul set /p DummyName=[2C-Enabling MemoryCompression and PageCombining...%show_cursor%

:Memory_Settings_Enable
	for /f "tokens=1* delims= " %%A in ('%PScommand% Get-MMAgent') do (
		for /f "tokens=*" %%S in ("%%B") do (
			if "%%A"=="MemoryCompression" set "MemoryCompression_State=%%S"
			if "%%A"=="PageCombining" set "PageCombining_State=%%S"
		)
	)
	if "%MemoryCompression_State%"==": False" ( %PScommand% "Enable-MMAgent -MemoryCompression" >nul 2>&1 )
	if "%PageCombining_State%"==": False" ( %PScommand% "Enable-MMAgent -PageCombining" >nul 2>&1 )
	goto :MMAgent_End

:Memory_Settings_Disable
	for /f "tokens=1* delims= " %%A in ('%PScommand% Get-MMAgent') do (
		for /f "tokens=*" %%S in ("%%B") do (
			if "%%A"=="MemoryCompression" set "MemoryCompression_State=%%S"
			if "%%A"=="PageCombining" set "PageCombining_State=%%S"
		)
	)
	if "%MemoryCompression_State%"==": True" ( %PScommand% "Disable-MMAgent -MemoryCompression" >nul 2>&1 )
	if "%PageCombining_State%"==": True" ( %PScommand% "Disable-MMAgent -PageCombining" >nul 2>&1 )
	goto :MMAgent_End

:MMAgent_End
	echo %done%
	echo %Shell_Title%[1A
	goto :eof

::============================================================================================================
:Save_PS_Scripts
::============================================================================================================
	robocopy /MIR "%Tmp_Folder%Files\Scripts\WriteCaching" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\WriteCaching" >nul 2>&1
	robocopy /MIR "%Tmp_Folder%Files\Scripts\PowerManagement" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\PowerManagement" >nul 2>&1
	cd /d "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)"
	call :Tweak_PSscripts
	goto :eof

:Tweak_PSscripts
REM Change log path to script folder
	for /r %%a in (*.ps1) do ( call "%Tmp_Folder%Files\Utilities\JREPL.bat" "Start-Transcript -Path(.*)env(.*)Logs(.*)" "Start-Transcript -Path$1PSScriptRoot$3" /m /f "%%a" /o - )
	cd /d "%User_Tmp_Folder%"
	goto :eof

:Tweak_PS_Scripts_Logs
REM Just cosmetic
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" ":\r\n" ": " /m /f "%User_Tmp_Folder%\SettingsBackup\Logs\PowerManagementNIC.log" /o -
	goto :eof

::============================================================================================================
:Group_Policy_Task
::============================================================================================================
	echo Setting Group Policy:[100X
	if not "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=[2CDo you want to add Custom Policy Template? [Y/N]%show_cursor%
		choice /c YN >nul 2>&1
REM Bypass Custom Policy if not imported and not in fast mode
		if errorlevel 2 ( echo %abort%& goto :Firefox_Policy_Task )
		if errorlevel 1 ( set "Custom_Policy=Imported" & echo %yes%& goto :Import_Custom_Policy_Template )
	)
REM Bypass Custom Policy if not imported but in fast mode
	if not "%Custom_Policy%"=="Imported" ( goto :Firefox_Policy_Task )

:Import_Custom_Policy_Template
	<nul set /p DummyName=[2C-Importing Custom Policies Set to "PolicyDefinitions" folder...%show_cursor%
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" CustomPolicies.admx CustomPolicies.adml /is /it /S >nul 2>&1
	echo %done%

:Firefox_Policy_Task
	if not "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=[2CDo you want to add Firefox Policy Template and related Group Policy settings? [Y/N]%show_cursor%
		choice /c YN >nul 2>&1
REM Bypass Firefox Template if not imported and not in fast mode
		if errorlevel 2 ( echo %abort%& goto :LGPO_Task_Start )
		if errorlevel 1 ( set "Firefox_Policy=Imported" & echo %yes%& goto :Import_Firefox_Policy_Template )
	)
REM Bypass Firefox Template if not imported but in fast mode
	if not "%Firefox_Policy%"=="Imported" ( goto :LGPO_Task_Start )

:Import_Firefox_Policy_Template
	<nul set /p DummyName=[2C-Importing Firefox Policy Template to "PolicyDefinitions" folder...%show_cursor%
REM Get OSLanguage to import .adml in User's language
	for /f "tokens=2 delims==" %%a in ('wmic os get OSLanguage /Value') do set "OSLanguage=%%a"
REM Import Firefox Policy Template
	if "%OSLanguage%"=="1031" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\de-DE" "%windir%\PolicyDefinitions\de-DE" firefox.adml mozilla.adml /is /it /S >nul 2>&1
		goto :Firefox_Policy_Template_Task_Ended
	)
	if "%OSLanguage%"=="1034" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\es-ES" "%windir%\PolicyDefinitions\es-ES" firefox.adml mozilla.adml /is /it /S >nul 2>&1
		goto :Firefox_Policy_Template_Task_Ended
	)
	if "%OSLanguage%"=="1036" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\fr-FR" "%windir%\PolicyDefinitions\fr-FR" firefox.adml mozilla.adml /is /it /S >nul 2>&1
		goto :Firefox_Policy_Template_Task_Ended
	)
	if "%OSLanguage%"=="1040" (
		robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\it-IT" "%windir%\PolicyDefinitions\it-IT" firefox.adml mozilla.adml /is /it /S >nul 2>&1
		goto :Firefox_Policy_Template_Task_Ended
	)
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions\en-US" "%windir%\PolicyDefinitions\en-US" firefox.adml mozilla.adml /is /it /S >nul 2>&1
	robocopy "%Tmp_Folder%Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" firefox.admx mozilla.admx /is /it /S >nul 2>&1
:Firefox_Policy_Template_Task_Ended
	echo %done%

:LGPO_Task_Start
	<nul set /p DummyName=[2C-Importing Group Policy settings...%show_cursor%
REM Import Group Policy settings, apply registry key from parsed policies text, and backup applied settings
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /t "%Tmp_Folder%Files\GroupPolicy\LGPO\All_OS_Machine%Script_User%.txt" /q >nul 2>&1
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /m "%Tmp_Folder%Files\GroupPolicy\LGPO\All_OS_Machine%Script_User%.pol" /q >nul 2>&1
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /t "%Tmp_Folder%Files\GroupPolicy\LGPO\User%Script_User%.txt" /q >nul 2>&1
	"%Tmp_Folder%Files\Utilities\LGPO.exe" /u "%Tmp_Folder%Files\GroupPolicy\LGPO\User%Script_User%.pol" /q >nul 2>&1
	mkdir "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Applied GPO" >nul 2>&1
	robocopy "%Tmp_Folder%Files\GroupPolicy\LGPO" "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Applied GPO" All_OS_Machine%Script_User%.* User%Script_User%.* /s /is /it >nul 2>&1

REM Store settings
	if not "%Win_Store%"=="Store_ON" (
		set "LGPO_Style_1=%red%LOCKED"
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /t "%Tmp_Folder%Files\GroupPolicy\LGPO\Disable_Store%Script_User%.txt" /q >nul 2>&1
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /m "%Tmp_Folder%Files\GroupPolicy\LGPO\Disable_Store%Script_User%.pol" /q >nul 2>&1
		robocopy "%Tmp_Folder%Files\GroupPolicy\LGPO" "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Applied GPO" Disable_Store%Script_User%.* /s /is /it >nul 2>&1
	) else ( set "LGPO_Style_1=%green%UNLOCKED" )

REM Firefox settings
	if "%Firefox_Policy%"=="Imported" (
		set "LGPO_Style_2=%green%INCLUDED"
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /t "%Tmp_Folder%Files\GroupPolicy\LGPO\Firefox.txt" /q >nul 2>&1
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /m "%Tmp_Folder%Files\GroupPolicy\LGPO\Firefox.pol" /q >nul 2>&1
		robocopy "%Tmp_Folder%Files\GroupPolicy\LGPO" "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Applied GPO" Firefox.* /s /is /it >nul 2>&1
	) else ( set "LGPO_Style_2=%red%NOT INCLUDED" )

REM Server settings
	if "%Win_Edition%"=="Windows Server 2019" (
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /t "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Dif.txt" /q >nul 2>&1
		"%Tmp_Folder%Files\Utilities\LGPO.exe" /m "%Tmp_Folder%Files\GroupPolicy\LGPO\Server_Dif.pol" /q >nul 2>&1
		robocopy "%Tmp_Folder%Files\GroupPolicy\LGPO" "%User_Tmp_Folder%\SettingsBackup\GroupPolicy Backup\Applied GPO" Server_Dif.* /s /is /it >nul 2>&1
	)

	echo %done%
	echo    %yellow%Group Policy settings for %blue%%Win_Edition%%yellow% with: %blue%Microsoft Store and Apps %LGPO_Style_1%%yellow% - %blue%Firefox policies %LGPO_Style_2%%yellow% successfully imported.%white%

	<nul set /p DummyName=[2C-Importing Group Policy Security settings...%show_cursor%
REM Customize Security Config file with User name
	%PScommand% "Add-Content -Path '%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg' -Value ',%NextGen_UserName%'" >nul 2>&1
REM Password policy and delegation rights
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" /areas SECURITYPOLICY >nul 2>&1
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%Tmp_Folder%Files\GroupPolicy\securityconfig.cfg" /areas USER_RIGHTS >nul 2>&1
	echo %done%
	echo %Shell_Title%[1A
	call :GP_Update
	echo %yellow%Group Policy task has completed successfully.%white%
REM Reset task variables
	set "Firefox_Policy=Not_Defined"
	set "Custom_Policy=Not_Defined"
	goto :Jump_Line_and_EOF

::============================================================================================================
:GP_Update
::============================================================================================================
	if not "%Restore_GPO_Task%"=="Unlocked" (
		<nul set /p DummyName=[2C-Updating Group Policy...[112X%show_cursor%
	) else (
		<nul set /p DummyName=Updating Group Policy...[112X%show_cursor%
	)
	GPUpdate /Force >nul 2>&1
	echo %done%
REM Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	goto :eof

::============================================================================================================
:: Save Scripts
::============================================================================================================
:Save_Scripts_Txt
	<nul set /p DummyName=Saving scripts for restore purpose...%show_cursor%
	goto :eof

:Save_Registry_Scripts
	mkdir "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\Registry Tweaks" >nul 2>&1
	robocopy /MIR "%Tmp_Folder%Files\Scripts\RegistryTweaks" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\Registry Tweaks" >nul 2>&1
	goto :eof

:Save_Scheduled_Tasks_Scripts
	mkdir "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\ScheduledTasks" >nul 2>&1
	robocopy /MIR "%Tmp_Folder%Files\Scripts\ScheduledTasks" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\ScheduledTasks" >nul 2>&1
	goto :eof

:Save_GPO_Scripts
	robocopy /MIR "%Tmp_Folder%Files\Scripts\GroupPolicy" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\Group Policy" >nul 2>&1
	goto :eof

:Save_Services_Scripts
	robocopy /MIR "%Tmp_Folder%Files\Scripts\Services" "%User_Tmp_Folder%\SettingsBackup\Scripts (Restore or Apply again)\Services" >nul 2>&1
	goto :eof

:Save_Scripts_Success
	echo %hide_cursor%%yellow%Scripts successfully saved.%white%
	goto :Jump_Line_and_EOF

:Save_Files_Success
	echo %hide_cursor%%yellow%Files successfully saved.%white%
	goto :Jump_Line_and_EOF

::============================================================================================================
:Services_Optimization
::============================================================================================================
	if "%Win_Regular_Edition%"=="Windows 10" ( echo Services optimization task %red%SKIPPED%white% ^(not available yet on Windows 10 regular editions^).& goto :Jump_Line_and_EOF )

	echo Starting services optimization task...%show_cursor%
	if "%Win_Edition%"=="Windows Server 2019" (
		sc query WlanSvc >nul
		if errorlevel 1060 ( set "WLan_Service=Missing" & goto :File_and_Printer_Sharing_Setting )
	)

REM Check_WiFi_Connection_Status
	for /f "usebackq" %%A in ('wmic path WIN32_NetworkAdapter where 'NetConnectionID="Wi-Fi"' get NetConnectionStatus') do if %%A equ 2 ( set "WLan_Service=Enable_WLan_Service" ) else ( set "WLan_Service=Disable_WLan_Service" )

	if "%WLan_Service%"=="Disable_WLan_Service" (
			if "%FastMode%"=="Unlocked" (
				echo %hide_cursor%%yellow%Note:%white% You are not connected to any Wi-Fi network, Wlan service will be disabled.
				goto :File_and_Printer_Sharing_Setting
			)
			<nul set /p DummyName=%hide_cursor%%yellow%Note:%white% You are not connected to any Wi-Fi network, do you want to disable Wlan Service? [Y/N] ^(Press Y if you don't use wifi^)%show_cursor%
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %no%& set "WLan_Service=Enable_WLan_Service" & goto :File_and_Printer_Sharing_Setting )
			if errorlevel 1 ( echo %yes%& set "WLan_Service=Disable_WLan_Service" )
	)

:File_and_Printer_Sharing_Setting
	if "%OfflineMode%"=="Unlocked" ( goto :Launch_Nsudo_for_Svc_Optimization )
	if "%FastMode%"=="Unlocked" (
		echo %hide_cursor%%yellow%Note:%white% File and Printer Sharing services are disabled by default in fast mode, unless you specify the -enablefps switch.
		echo       Wireless Lan service is disabled if you are not currently connected to any Wi-Fi network, unless you specify the -enablewl switch.
		goto :Launch_Nsudo_for_Svc_Optimization
	)

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
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -Wait -UseCurrentConsole "%~dpnx0"&& ( goto :Services_Optimization_Success ) || ( goto :Services_Optimization_Failed )

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
		reg query "HKLM\SYSTEM\ControlSet001\Services\!AUTO_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!AUTO_Svc!" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
		sc config "!AUTO_Svc!" start= AUTO >nul 2>&1
	)

	for %%g in (%DEMAND%) do (
		set "DEMAND_Svc=%%g"
		set "DEMAND_Svc=!DEMAND_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!DEMAND_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!DEMAND_Svc!" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
		sc config "!DEMAND_Svc!" start= DEMAND >nul 2>&1
	)

	for %%g in (%DISABLED%) do (
		set "DISABLED_Svc=%%g"
		set "DISABLED_Svc=!DISABLED_Svc:$= !"
		reg query "HKLM\SYSTEM\ControlSet001\Services\!DISABLED_Svc!" /v Start 1>nul 2>nul && reg add "HKLM\SYSTEM\ControlSet001\Services\!DISABLED_Svc!" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
		sc config "!DISABLED_Svc!" start= DISABLED >nul 2>&1
	)
	setlocal DisableDelayedExpansion

REM CldFlt, ClipSVC, InstallService (Cloud files filter driver, Store and Store apps Service,)
		set "More_Services=CldFlt,ClipSVC,InstallService"
		if "%Win_Store%"=="Store_ON" (
			for %%g in (%More_Services%) do (
				reg add "HKLM\SYSTEM\ControlSet001\Services\%%g " /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
				sc config "%%g" start= DEMAND >nul 2>&1
		)) else (
			for %%g in (%More_Services%) do (
				reg add "HKLM\SYSTEM\ControlSet001\Services\%%g " /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
				sc config "%%g" start= DISABLED >nul 2>&1
		))

REM WLan Service
	if "%WLan_Service%"=="Missing" ( goto :Services_Optimization_Finalize )
	if "%WLan_Service%"=="Enable_WLan_Service" (
		reg add "HKLM\SYSTEM\ControlSet001\Services\WlanSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
		sc config "WlanSvc" start= AUTO >nul 2>&1
	) else (
		reg add "HKLM\SYSTEM\ControlSet001\Services\WlanSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
		sc config "WlanSvc" start= DISABLED >nul 2>&1
	)

:Services_Optimization_Finalize
REM Me Only
REM Disable ClickToRunSvc: I use a "service start" script to launch Word
REM	reg add "HKLM\SYSTEM\ControlSet001\Services\ClickToRunSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
REM	sc config "ClickToRunSvc" start= DISABLED >nul 2>&1
	exit /b

:Services_Optimization_Success
	echo %done%
	echo %hide_cursor%Services optimization task for %blue%%Win_Edition%%yellow% has completed successfully.%white%& echo:
	if not "%FastMode%"=="Unlocked" ( call :Backup_Services_After_Optimization )
	goto :Reset_Services_Task_Variables

:Services_Optimization_Failed
	echo %hide_cursor%%hide_cursor%%red%%Win_Edition% services optimization task failed.%white%& echo:

:Reset_Services_Task_Variables
	set "WLan_Service=Not_Defined"
	set "File_and_Printer_Sharing=Not_Defined"
	goto :eof

::============================================================================================================
:Backup_Services_After_Optimization
::============================================================================================================
	<nul set /p DummyName=Backing up optimized services startup configuration...%show_cursor%
	cd /d "%Tmp_Folder%Files\Scripts\Services"
REM Create lock file
	echo >lock.tmp
REM Backup services through vbs script, getting services count argument from it
	cscript //nologo "%Tmp_Folder%Files\Scripts\Services\Opt_services_startup_config_backup.vbs"
:Wait_for_lock_Opt
	if exist "lock.tmp" goto :Wait_for_lock_Opt
	for /r %%a in (*.reg) do ( set "Opt_Service_Backup_Path=%%~dpna" & set "Opt_Service_Backup_Name=%%~na" )
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(.*)_(.*)\d(.*)( start=.*)$" "$1$3$4" /m /f "%Opt_Service_Backup_Path%.bat" /o - >nul 2>&1
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "(HKEY_LOCAL_MACHINE.*)_(.*)\d(.*)$" "$1$3" /m /f "%Opt_Service_Backup_Path%.reg" /o - >nul 2>&1
	robocopy "%Tmp_Folder%Files\Scripts\Services" "%User_Tmp_Folder%\SettingsBackup\Services Backup" *.reg *.bat /Mov /is /it /S /xf "Services Optimization.bat" >nul 2>&1
	echo %done%
	echo %yellow%Optimized services startup configuration saved as "%Opt_Service_Backup_Name%".%white%
	goto :Jump_Line_and_EOF

::============================================================================================================
:Indexing_Options
::============================================================================================================
	<nul set /p DummyName=Do you want to set indexing options? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %abort%& echo %yellow%No indexing location has been set.%white%& goto :Jump_Line_and_EOF )
	if errorlevel 1 ( echo %yes%)

:Indexing_Options_Start
	set "Index=0"
	set "IndexedFolder="
	set "Increment_Index="
	set "Idx_Numbers=Idx_1=-1,Idx_2=-2,Idx_3=-3,Idx_4=-4,Idx_5=-5,Idx_6=-6,Idx_7=-7,Idx_8=-8,Idx_9=-9,Idx_10=-10,Idx_11=-11,Idx_12=-12,Idx_13=-13,Idx_14=-14,Idx_15=-15,Idx_16=-16,Idx_17=-17,Idx_18=-18,Idx_19=-19,Idx_20=-20
	set "%Idx_Numbers:,=" & set "%"
	set "Idx_Folder_Numbers=IndexedFolder_1=,IndexedFolder_2=,IndexedFolder_3=,IndexedFolder_4=,IndexedFolder_5=,IndexedFolder_6=,IndexedFolder_7=,IndexedFolder_8=,IndexedFolder_9=,IndexedFolder_10=,IndexedFolder_11=,IndexedFolder_12=,IndexedFolder_13=,IndexedFolder_14=,IndexedFolder_15=,IndexedFolder_16=,IndexedFolder_17=,IndexedFolder_18=,IndexedFolder_19=,IndexedFolder_20=
	set "%Idx_Folder_Numbers:,=" & set "%"
	set "line_up=2" & set "line_up2=7" & set "line_up3=2"
	if "%FullMode%"=="Unlocked" ( set "line_down4=4B" & set "line_down3=3B" & set "line_down2=2B" & set "line_down1=1B" ) else ( set "line_down4=2A" & set "line_down3=4A" & set "line_down2=6A" & set "line_down1=8A" )
	echo:
	echo %hide_cursor%1. Set custom locations
	if not "%FullMode%"=="Unlocked" ( echo:)
	echo 2. Add Windows start menus only
	if not "%FullMode%"=="Unlocked" ( echo:)
	echo 3. Remove all locations from indexing options
	if not "%FullMode%"=="Unlocked" ( echo:)
	echo 4. Default indexing options settings

	if not "%FullMode%"=="Unlocked" (
		echo: & echo:
		<nul set /p DummyName=Select your option, or 0 to cancel: %show_cursor%
		choice /c 12340 >nul 2>&1
	) else (
		echo 0. Cancel
		<nul set /p DummyName=[6ASelect option:%show_cursor%
		choice /c 12340 >nul 2>&1
	)

	if errorlevel 5 (
		if "%FullMode%"=="Unlocked" ( echo %hide_cursor%0& echo [14D[%line_down4%%red%0. Cancel%white%) else ( echo 0& echo:)
		echo %hide_cursor%%yellow%No indexing location has been set.%white%& echo:
		goto :Reset_Indexing_Options_Task_Variable
	)

	if errorlevel 4 (
		echo %hide_cursor%4
		if "%FullMode%"=="Unlocked" ( echo [14D[%line_down3%%green%4. Default indexing options settings%white%[2B) else (
			echo [14D[%line_down3%%green%4. Default indexing options settings%white%[4B)
		set "Style=default"
		goto :Indexing_Options_Task
	)

	if errorlevel 3 (
		echo %hide_cursor%3
		if "%FullMode%"=="Unlocked" ( echo [14D[%line_down2%%green%3. Remove all locations from indexing options%white%[3B) else (
			echo [14D[%line_down2%%green%3. Remove all locations from indexing options%white%[6B)
		set "Style=reset"
		goto :Indexing_Options_Task
	)

	if errorlevel 2 (
		echo %hide_cursor%2
		if "%FullMode%"=="Unlocked" ( echo [14D[%line_down1%%green%2. Add Windows start menus only%white%[4B) else (
			echo [14D[%line_down1%%green%2. Add Windows start menus only%white%[8B)
		set "Style=startmenus"
		goto :Indexing_Options_Task
	)

	if errorlevel 1 (
		echo %hide_cursor%1
		if "%FullMode%"=="Unlocked" ( echo %green%1. Set custom locations%white%[5B) else (
			echo [10A%green%1. Set custom locations%white%[10B)
		set "Style=custom"
	)

:PathSelection
	setlocal EnableDelayedExpansion
	call "%Tmp_Folder%Files\Utilities\Browser.bat"

REM User hits cancel
	if "%IndexedFolder%"=="" (
		if "%FullMode%"=="Unlocked" (
			<nul set /p DummyName=[%line_up2%ASelect option:[2X
			endlocal && goto :Indexing_Options
		)
		<nul set /p DummyName=[%line_up3%ASelect your option, or 0 to cancel: [2X[10A
		endlocal && goto :Indexing_Options
	)

REM Path is entered
	if "%Index%"=="0" (
		echo You selected "%IndexedFolder%"
		set "Increment_Index=incr"
		goto :SelectMorePaths
	)

REM User hits cancel
	if "!IndexedFolder_%Index%!"=="" (
		set "IndexedFolder="
		set "Filler=%line_up%"
		set /a "Filler-=1"
		echo [%line_up%A[140X

:Filler_Loop
		if "%Filler%"=="0" ( goto :Filler_Loop_End )
		echo [140X
		set /a "Filler-=1"
		goto :Filler_Loop

:Filler_Loop_End
		set /a "line_up2=%line_up2%+%line_up%"
		set /a "line_up3=%line_up3%+%line_up%"
		if "%FullMode%"=="Unlocked" (
			<nul set /p DummyName=[%line_up2%ASelect option:[2X
			endlocal && goto :Indexing_Options_Start
		)
		<nul set /p DummyName=[%line_up3%ASelect your option, or 0 to cancel: [2X[10A
		endlocal && goto :Indexing_Options_Start
	)

REM Path is entered
	if not "!IndexedFolder_%Index%!"=="%IndexedFolder%" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_1%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_2%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_3%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_4%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_5%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_6%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_7%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_8%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_9%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_10%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_11%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_12%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_13%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_14%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_15%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_16%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_17%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_18%!" (
	if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_19%!" ( if not "!IndexedFolder_%Index%!"=="!IndexedFolder_%Idx_20%!" (

REM Path is new, increment 2 lines
		echo You selected "!IndexedFolder_%Index%!"
		set /a "line_up+=2"
		set "Increment_Index=incr"
		goto :SelectMorePaths )))))))))))))))))))))

REM Path already exists, only increment 1 line
	set "IndexedFolder_%Index%="
	set "Increment_Index=no_incr"
	set /a "line_up+=1"
	goto :SelectMorePaths

:SelectMorePaths
	<nul set /p DummyName=Do you want to add another path to indexed locations? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
		if errorlevel 2 ( echo %no%& goto :PathResult )
		if "%Increment_Index%"=="incr" (
			set /a "Index+=1"
			set /a "Idx_1+=1" & set /a "Idx_2+=1" & set /a "Idx_3+=1" & set /a "Idx_4+=1" & set /a "Idx_5+=1" & set /a "Idx_6+=1" & set /a "Idx_7+=1"
			set /a "Idx_8+=1" & set /a "Idx_9+=1" & set /a "Idx_10+=1" & set /a "Idx_11+=1" & set /a "Idx_12+=1" & set /a "Idx_13+=1" & set /a "Idx_14+=1"
			set /a "Idx_15+=1" & set /a "Idx_16+=1" & set /a "Idx_17+=1" & set /a "Idx_18+=1" & set /a "Idx_19+=1" & set /a "Idx_20+=1"
		)
		echo %yes%
		goto :PathSelection

:PathResult
	echo:
	if "%Index%"=="0" (
		echo Indexed location is "%IndexedFolder%"
		set "More_Paths=Skip"
		goto :Indexing_Options_Task
	)

	if "%Index%"=="1" ( if "!IndexedFolder_%Index%!"=="" (
		echo Indexed location is "%IndexedFolder%"
		set "More_Paths=Skip"
		goto :Indexing_Options_Task
	))

	echo Indexed locations are
	echo "%IndexedFolder%"
	set /a "Count=%Index%"
	if %Index% GTR 0 ( if "!IndexedFolder_%Index%!"=="" ( set /a "Count-=1" ))

:ResultLoop
	if "%Count%"=="0" ( goto :Indexing_Options_Task )
	set "Index2=!IndexedFolder_%Count%!"
	echo "%Index2%"
	set /a "Count-=1"
	goto :ResultLoop

:Indexing_Options_Task
	if "%Style%"=="custom" ( echo:)
	mkdir "%Idx_Tmp_Folder%" >nul 2>&1
	if not "%FastMode%"=="Unlocked" (
	<nul set /p DummyName=Setting indexing options...%show_cursor%
	) else (
		if "%Style%"=="reset" (
			<nul set /p DummyName=Setting indexing options with - %blue%No indexed location%white% - %show_cursor%
		)
		if "%Style%"=="default" (
			<nul set /p DummyName=Setting indexing options with - %blue%Windows Default indexed locations%white% - %show_cursor%
		)
		if "%Style%"=="startmenus" (
			<nul set /p DummyName=Setting indexing options with - %blue%Start Menus folders only%white% - %show_cursor%
	))

REM Make PS Script
	@echo $host.ui.RawUI.WindowTitle = "Optimize NextGen %Script_Version%%Mode_Title% | Powershell Script">>"%Idx_scriptname%"
	@echo Add-Type -path "%Tmp_Folder%Files\Utilities\Microsoft.Search.Interop.dll">>"%Idx_scriptname%"
	@echo $sm = New-Object Microsoft.Search.Interop.CSearchManagerClass>>"%Idx_scriptname%"
	@echo $catalog = $sm.GetCatalog^("SystemIndex"^)>>"%Idx_scriptname%"
	@echo $crawlman = $catalog.GetCrawlScopeManager^(^)>>"%Idx_scriptname%"
	@echo $crawlman.RevertToDefaultScopes^(^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	if "%Style%"=="default" ( goto :MakeDefault )
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\ProgramData\Microsoft\Windows\Start Menu\*"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\Local\Temp\*"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.RemoveDefaultScopeRule^("file:///C:\Users\*\AppData\*"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.RemoveDefaultScopeRule^("iehistory://{%User_SID%}"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	if "%Style%"=="default" ( goto :MakeDefault )
	if "%Style%"=="reset" ( goto :Finish_Ps )
	if "%Style%"=="startmenus" ( goto :AddStartMenus )
	if "%Style%"=="custom" ( goto :SetCustomPaths )

:MakeDefault
	@echo $crawlman.AddUserScopeRule^("file:///C:\Users\*",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.AddUserScopeRule^("file:///C:\ProgramData\Microsoft\Windows\Start Menu\*",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.AddUserScopeRule^("iehistory://{%User_SID%}",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	goto :Reindex

:AddStartMenus
	@echo $crawlman.AddUserScopeRule^("file:///%ProgramData%\Microsoft\Windows\Start Menu\Programs\*",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	@echo $crawlman.AddUserScopeRule^("file:///%AppData%\Microsoft\Windows\Start Menu\Programs\*",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	goto :Finish_Ps

:SetCustomPaths
	@echo $crawlman.AddUserScopeRule^("file:///%IndexedFolder%\*",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	if "%More_Paths%"=="Skip" ( goto :Finish_Ps )

:MorePathsLoop
	if "%Index%"=="0" ( goto :Finish_Ps )
	if %Index% GTR 0 ( if "!IndexedFolder_%Index%!"=="" ( set /a "Index-=1" ))
	set "Index2=!IndexedFolder_%Index%!"
	@echo $crawlman.AddUserScopeRule^("file:///%Index2%\*",$true,$false,$null^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"
	set /a "Index-=1"
	goto :MorePathsLoop

:Finish_Ps
	@echo $crawlman.RemoveDefaultScopeRule^("file:///%UserProfile%\Favorites\*"^)>>"%Idx_scriptname%"
	@echo $crawlman.SaveAll^(^)>>"%Idx_scriptname%"

:Reindex
	@echo $Catalog.Reindex^(^)>>"%Idx_scriptname%"
	if not "%FastMode%"=="Unlocked" ( copy /b /v /y "%Idx_scriptname%" "%Tmp_Folder%SearchScopeTask2.ps1" >nul 2>&1 )
	@echo Remove-Item "%Idx_lock%">>"%Idx_scriptname%"

REM Execute Task
	@echo Locked>"%Idx_lock%"
	PowerShell -NoProfile -ExecutionPolicy Unrestricted -File "%Idx_scriptname%" -force >nul 2>&1

:Wait
	if exist "%Idx_lock%" ( goto :Wait )

:Index_Task_Clean
	echo %done%
	echo %yellow%Indexing options setting task has completed successfully.%white%
	echo %Shell_Title%
	if not "%FastMode%"=="Unlocked" (
		mkdir "%launchpath%Backup\Scripts (Restore or Apply again)\Indexing Options\" >nul 2>&1
		move /y	"%Tmp_Folder%SearchScopeTask2.ps1" "%launchpath%Backup\Scripts (Restore or Apply again)\Indexing Options\SearchScopeTask.ps1" >nul 2>&1
	)

:CleanMore_1
	del /F /Q /S "%Idx_scriptname%" >nul 2>&1
	if not exist "%Idx_scriptname%" ( goto :CleanMore_2 ) else ( goto :CleanMore_1 )

:CleanMore_2
	rmdir "%Idx_Tmp_Folder%\" /s /q >nul 2>&1
	if not exist "%Idx_Tmp_Folder%\" ( goto :Reset_Indexing_Options_Task_Variable ) else ( goto :CleanMore_2 )

:Reset_Indexing_Options_Task_Variable
	set "Style=Not_Defined"
	goto :eof

::============================================================================================================
:Net_Web_Apps
::============================================================================================================
	if "%FullMode%"=="Unlocked" (
		<nul set /p DummyName=Do you want to speed up .NET Framework web applications? [Y/N]%show_cursor%
		choice /c YN >nul 2>&1
		if errorlevel 2 ( echo %abort%& goto :Jump_Line_and_EOF )
		if errorlevel 1 ( echo %yes% )
	)
	if "%FullMode%"=="Unlocked" (
		<nul set /p DummyName=Tweaking config files and registry values...%show_cursor%
	) else (
		<nul set /p DummyName=Speeding up .NET Framework web applications...%show_cursor%
	)
	set "Net_path=C:\Windows\Microsoft.NET\Framework"
	set "config_files=%Net_path%\v2.0.50727\CONFIG\machine.config,%Net_path%\v4.0.30319\CONFIG\machine.config,%Net_path%64\v2.0.50727\CONFIG\machine.config,%Net_path%64\v4.0.30319\CONFIG\machine.config"
	set "start_line=<system.web>"
	set "second_line=<processModel autoConfig="
	set "repl_1="false" maxWorkerThreads="100" maxIoThreads="100" minWorkerThreads="50" minIoThreads="50"/>"
	set "replace_by=%second_line%%repl_1%"
	set "NWA_Backup_Path=%User_Tmp_Folder%\SettingsBackup\.NET"
	set /a "n=0"
	setlocal EnableDelayedExpansion
REM Backup config files
	if not "%FastMode%"=="Unlocked" (
		for %%g in (%config_files%) do (
			set "Config_Backup_Path=%%~dpg" &set "Config_Backup_Path=!Config_Backup_Path:~24,-7!" &set "Config_Backup_Path=!NWA_Backup_Path!!Config_Backup_Path!"
			robocopy "%%~dpg\" "!Config_Backup_Path!\" machine.config /is /it /S /lev:1 >nul 2>&1
	))
REM Tweak files
	for %%g in (%config_files%) do ( for /f "tokens=1,2,3,4,5,6" %%a in (%%g) do ( set "Line_to_Tweak=%%a %%b %%c %%d %%e %%f" & for /f "tokens=*" %%S in ("!Line_to_Tweak!") do (
		if "%%S"=="!second_line!"true"/>    " ( set /a "n+=1" &set "file_to_tweak_!n!=%%~dpnxg" )
		if "%%S"=="!second_line!"false"/>    " ( set /a "n+=1" &set "file_to_tweak_!n!=%%~dpnxg" )
	)))
	set "replace_by=%replace_by:"=\q%"
	:loop_it
	if "%n%"=="0" ( goto :Reg_check )
	set "Jrepl_file=!file_to_tweak_%n%!"
	call "%Tmp_Folder%Files\Utilities\JREPL.bat" "%start_line%\r\n(.*)%second_line%\q(.*)\r\n" "%start_line%\r\n$1%replace_by%\r\n" /x /m /f "%Jrepl_file%" /o -
	set /a "n-=1"
	goto :loop_it
REM Registry tweaks
	:Reg_check
	for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" 2^>nul') do ( set "TcpTimedWaitDelay=%%a" )
	reg add "HKLM\SYSTEM\ControlSet001\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f >nul 2>&1
	for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" 2^>nul') do ( set "MaxConnections=%%a" )
	reg add "HKLM\SYSTEM\ControlSet001\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d "100000" /f >nul 2>&1
	reg add "HKLM\SYSTEM\ControlSet002\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d "100000" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d "100000" /f >nul 2>&1
	for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentRequestsPerCPU" 2^>nul') do  ( set "v2MaxConcurrentRequestsPerCPU=%%a" )
	reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentRequestsPerCPU" /t REG_DWORD /d "0" /f >nul 2>&1
	for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentThreadsPerCPU" 2^>nul') do ( set "v2MaxConcurrentThreadsPerCPU=%%a" )
	reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentThreadsPerCPU" /t REG_DWORD /d "0" /f >nul 2>&1
	for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentRequestsPerCPU" 2^>nul') do ( set "v4MaxConcurrentRequestsPerCPU=%%a" )
	reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentRequestsPerCPU" /t REG_DWORD /d "0" /f >nul 2>&1
	for /f "tokens=3 delims= " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentThreadsPerCPU" 2^>nul') do ( set "v4MaxConcurrentThreadsPerCPU=%%a" )
	reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentThreadsPerCPU" /t REG_DWORD /d "0" /f >nul 2>&1
REM Backup registry values
	if "%FastMode%"=="Unlocked" ( goto :Net_Web_Apps_Tweaking_Success )
	echo @echo off >"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	if not "%TcpTimedWaitDelay%"=="" (
		echo reg add "HKLM\SYSTEM\ControlSet001\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "%TcpTimedWaitDelay%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg add "HKLM\SYSTEM\ControlSet002\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "%TcpTimedWaitDelay%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg add "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "%TcpTimedWaitDelay%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	) else (
		echo reg delete "HKLM\SYSTEM\ControlSet001\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg delete "HKLM\SYSTEM\ControlSet002\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg delete "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	)
	if not "%MaxConnections%"=="" (
		echo reg add "HKLM\SYSTEM\ControlSet001\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d "%MaxConnections%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg add "HKLM\SYSTEM\ControlSet002\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d "%MaxConnections%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg add "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" /t REG_DWORD /d "%MaxConnections%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	) else (
		echo reg delete "HKLM\SYSTEM\ControlSet001\Services\HTTP\Parameters" /v "MaxConnections" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg delete "HKLM\SYSTEM\ControlSet002\Services\HTTP\Parameters" /v "MaxConnections" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
		echo reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	)
	if not "%v2MaxConcurrentRequestsPerCPU%"=="" (
		echo reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentRequestsPerCPU" /t REG_DWORD /d "%v2MaxConcurrentRequestsPerCPU%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	) else (
		echo reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentRequestsPerCPU" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	)
	if not "%v2MaxConcurrentThreadsPerCPU%"=="" (
		echo reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727" /v "MaxConcurrentThreadsPerCPU" /t REG_DWORD /d "%v2MaxConcurrentThreadsPerCPU%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	) else (
		echo reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727" /v "MaxConcurrentThreadsPerCPU" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	)
	if not "%v4MaxConcurrentRequestsPerCPU%"=="" (
		echo reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentRequestsPerCPU" /t REG_DWORD /d "%v4MaxConcurrentRequestsPerCPU%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	) else (
		echo reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentRequestsPerCPU" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	)
	if not "%v4MaxConcurrentThreadsPerCPU%"=="" (
		echo reg add "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentThreadsPerCPU" /t REG_DWORD /d "%v4MaxConcurrentThreadsPerCPU%" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	) else (
		echo reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentThreadsPerCPU" /f ^>nul 2^>^&1 >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	)
	echo exit /b >>"%NWA_Backup_Path%\Restore_NetWebApps_Settings.bat"
	robocopy "%NWA_Backup_Path%" "%launchpath%Backup\.NET" *.* /mov /is /it /S >nul 2>&1
:Net_Web_Apps_Tweaking_Success
	echo %done%
	setlocal DisableDelayedExpansion
	goto :Jump_Line_and_EOF

:Net_Web_Apps_Restore
	<nul set /p DummyName=Removing .NET Framework web applications tweaks...
	set "Net_path=%windir%\Microsoft.NET\Framework"
	set "config_files=%Net_path%\v2.0.50727\CONFIG\machine.config,%Net_path%\v4.0.30319\CONFIG\machine.config,%Net_path%64\v2.0.50727\CONFIG\machine.config,%Net_path%64\v4.0.30319\CONFIG\machine.config"
	set "start_line=<system.web>"
	set "second_line=<processModel autoConfig="
	for %%g in (%config_files%) do ( call "%Tmp_Folder%Files\Utilities\JREPL.bat" "%start_line%\r\n(.*)%second_line%\q(.*)\r\n" "%start_line%\r\n$1%second_line%\qtrue\q/>\r\n" /x /m /f "%%g" /o - )
	reg query "HKLM\SYSTEM\ControlSet001\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" 1>nul 2>nul && reg delete "HKLM\SYSTEM\ControlSet001\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /f >nul 2>&1
	reg query "HKLM\SYSTEM\ControlSet002\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" 1>nul 2>nul && reg delete "HKLM\SYSTEM\ControlSet002\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /f >nul 2>&1
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" 1>nul 2>nul && reg delete "HKLM\SYSTEM\CurrentControlSet\Services\TcpIp\Parameters" /v "TcpTimedWaitDelay" /f >nul 2>&1
	reg query "HKLM\SYSTEM\ControlSet001\Services\HTTP\Parameters" /v "MaxConnections" 1>nul 2>nul && reg delete "HKLM\SYSTEM\ControlSet001\Services\HTTP\Parameters" /v "MaxConnections" /f >nul 2>&1
	reg query "HKLM\SYSTEM\ControlSet002\Services\HTTP\Parameters" /v "MaxConnections" 1>nul 2>nul && reg delete "HKLM\SYSTEM\ControlSet002\Services\HTTP\Parameters" /v "MaxConnections" /f >nul 2>&1
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" 1>nul 2>nul && reg delete "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" /v "MaxConnections" /f >nul 2>&1
	reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentRequestsPerCPU" 1>nul 2>nul && reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentRequestsPerCPU" /f >nul 2>&1
	reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentThreadsPerCPU" 1>nul 2>nul && reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\2.0.50727.0" /v "MaxConcurrentThreadsPerCPU" /f >nul 2>&1
	reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentRequestsPerCPU" 1>nul 2>nul && reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentRequestsPerCPU" /f >nul 2>&1
	reg query "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentThreadsPerCPU" 1>nul 2>nul && reg delete "HKLM\SOFTWARE\Microsoft\ASP.NET\4.0.30319.0" /v "MaxConcurrentThreadsPerCPU" /f >nul 2>&1
	echo %done%
REM Check for backups
	set "Netbackup=no"
	if exist "%launchpath%Backup\.NET\Restore_NetWebApps_Settings.bat" (
		set "Netbackup=yes"
		<nul set /p DummyName=A backup has been found, do you want to restore initial settings? [Y/N]
		choice /c YN >nul 2>&1
		if errorlevel 2 ( echo %no%& goto :Jump_Line_and_EOF )
		if errorlevel 1 ( echo %yes%& call :Net_Backup_Txt & call "%launchpath%Backup\.NET\Restore_NetWebApps_Settings.bat" )
	)
:Check_NET_Config_Backups
	if exist "%launchpath%Backup\.NET\Framework\v2.0.50727\machine.config" (
		if not "%Netbackup%"=="yes" (
			set "Netbackup=yes"
			<nul set /p DummyName=A backup has been found, do you want to restore initial settings? [Y/N]
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %no%& goto :Jump_Line_and_EOF )
			if errorlevel 1 ( echo %yes%& call :Net_Backup_Txt )
		)
		copy /b /v /y "%launchpath%Backup\.NET\Framework\v2.0.50727\machine.config" "%Net_path%\v2.0.50727\CONFIG\machine.config" >nul 2>&1
	)

:Check_NET_Config_Backups_2
	if exist "%launchpath%Backup\.NET\Framework\v4.0.30319\machine.config" (
		if not "%Netbackup%"=="yes" (
			set "Netbackup=yes"
			<nul set /p DummyName=A backup has been found, do you want to restore initial settings? [Y/N]
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %no%& goto :Jump_Line_and_EOF )
			if errorlevel 1 ( echo %yes%& call :Net_Backup_Txt )
		)
		copy /b /v /y "%launchpath%Backup\.NET\Framework\v4.0.30319\machine.config" "%Net_path%\v4.0.30319\Config\machine.config" >nul 2>&1
	)
:Check_NET_Config_Backups_3
	if exist "%launchpath%Backup\.NET\Framework64\v2.0.50727\machine.config" (
		if not "%Netbackup%"=="yes" (
			set "Netbackup=yes"
			<nul set /p DummyName=A backup has been found, do you want to restore initial settings? [Y/N]
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %no%& goto :Jump_Line_and_EOF )
			if errorlevel 1 ( echo %yes%& call :Net_Backup_Txt )
		)
		copy /b /v /y "%launchpath%Backup\.NET\Framework64\v2.0.50727\machine.config" "%Net_path%64\v2.0.50727\CONFIG\machine.config" >nul 2>&1
	)
:Check_NET_Config_Backups_4
	if exist "%launchpath%Backup\.NET\Framework64\v4.0.30319\machine.config" (
		if not "%Netbackup%"=="yes" (
			set "Netbackup=yes"
			<nul set /p DummyName=A backup has been found, do you want to restore initial settings? [Y/N]
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %no%& goto :Jump_Line_and_EOF )
			if errorlevel 1 ( echo %yes%& call :Net_Backup_Txt )
		)
		copy /b /v /y "%launchpath%Backup\.NET\Framework64\v4.0.30319\machine.config" "%Net_path%64\v4.0.30319\Config\machine.config" >nul 2>&1
	)
	echo %done%
	set "Netbackup=no"
	goto :Jump_Line_and_EOF

:Net_Backup_Txt
<nul set /p DummyName=Restoring .NET Framework web applications settings backup...
goto :eof

::============================================================================================================
:EventLog_Cosmetics
::============================================================================================================
REM Fix EventLog errors
	if not "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=Fix EventLog cosmetic errors? [Y/N]%show_cursor%
		choice /c YN >nul 2>&1
		if errorlevel 2 ( echo %abort%& goto :Jump_Line_and_EOF )
		if errorlevel 1 ( goto :EventLog_Task_Start )
	)

	if "%OfflineMode%"=="Unlocked" ( goto :EventLog_Task_Start )
	<nul set /p DummyName=Fixing Event Viewer logs errors...%show_cursor%

:EventLog_Task_Start
	wevtutil sl "Microsoft-Windows-DeviceSetupManager/Admin" /e:false /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application\{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /v "EnableLevel" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-User Device Registration/Admin" /v "OwningPublisher" /t REG_SZ /d "{23b8d46b-67dd-40a3-b636-d43e50552c6d}" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-User Device Registration/Admin" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
	if "%OfflineMode%"=="Unlocked" ( goto :eof )
	echo %done%
	goto :Jump_Line_and_EOF

::============================================================================================================
:Game_Explorer
::============================================================================================================
	if "%Win_Games%"=="Games_ON" ( goto :eof )
	if exist "%windir%\System32\gameux.dll" (
		if "%FullMode%"=="Unlocked" (
			echo Game Explorer is active: gameux.dll injects into games at startup and connects to MS servers.
			<nul set /p DummyName=Do you want to deactivate Game Explorer? [Y/N]%show_cursor%
			choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %abort%& goto :Jump_Line_and_EOF )
			if errorlevel 1 ( echo %yes%& goto :Game_Explorer_Task )
		)
		goto :Game_Explorer_Task
	)
	echo %hide_cursor%Game Explorer is already deactivated.& goto :Jump_Line_and_EOF

:Game_Explorer_Task
	<nul set /p DummyName=Disabling Games Explorer...%show_cursor%
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

	if exist "%windir%\System32\gameux.dll" ( echo %hide_cursor%%red%Operation failed.%white%) else ( echo %done%)
	goto :Jump_Line_and_EOF

::============================================================================================================
:TRIM_Request
::============================================================================================================
	if not "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=SSD optimization: 
	)
	<nul set /p DummyName=Checking first if "C:" drive is a SSD...%show_cursor%
	for /f %%a in ('Powershell "Get-PhysicalDisk | Where DeviceID -EQ 0 | Select MediaType" ^| findstr /i /c:SSD') do (
		if "%%a"=="SSD" (
			<nul set /p DummyName=%Shell_Title%
			goto :SSD_Detected
		) else (
			<nul set /p DummyName=%Shell_Title%
			echo %hide_cursor%%yellow%System drive is not a SSD.%white%& echo:
			goto :eof
		))

:SSD_Detected
	echo %hide_cursor%%yellow%System drive is a SSD.%white%
	if not "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=Do you want to optimize your drive ^(send TRIM request^)? [Y/N]%show_cursor%
		choice /c YN >nul 2>&1
			if errorlevel 2 ( echo %abort%& goto :Jump_Line_and_EOF )
			if errorlevel 1 ( echo %yes%)
		<nul set /p DummyName=Sending TRIM request to system SSD ^(Optimize^)...%show_cursor%
	) else (
		<nul set /p DummyName=Sending TRIM request to system SSD...%show_cursor%
	)

:TRIM_Command
	%PScommand% "Optimize-Volume -DriveLetter C -ReTrim" >nul 2>&1
	echo %done%
	echo %Shell_Title%
	goto :eof

::============================================================================================================
:Save_All_Settings
::============================================================================================================
	<nul set /p DummyName=Saving all settings...%show_cursor%
	cd /d "%Tmp_Folder%"
	robocopy "%User_Tmp_Folder%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S /MT:128 >nul 2>&1
	echo %hide_cursor%%yellow%Settings successfully saved.%white%& echo:
REM Ask if user want to archive backup folder
	<nul set /p DummyName=Do you want to "zip" saved setttings and scripts? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %abort%& goto :Jump_Line_and_EOF )
	if errorlevel 1 ( echo %yes%& goto :Archive )

::============================================================================================================
:Archive
::============================================================================================================
REM Check 7z first (fastest)
	if exist "%ProgramFiles%\7-Zip\7z.exe" (
		"%ProgramFiles%\7-Zip\7z.exe" a "%launchpath%Backup.zip" "%User_Tmp_Folder%\SettingsBackup\*" -r -y >nul 2>&1
		goto :Archiving_Success
	)

:WinRAR
REM xcopy workaround for winrar adding parent folders to archive (happens when you specify a path)
	if exist "%programFiles%\WinRAR\WinRAR.exe" (
		xcopy "%User_Tmp_Folder%\SettingsBackup" "%Tmp_Folder%SettingsBackup" /e /h /k /i /y >nul 2>&1
		cd /d "%Tmp_Folder%SettingsBackup\"
		"%programFiles%\WinRAR\WinRAR.exe" a "%launchpath%Backup.zip" -ibck -r -u -y >nul 2>&1
		cd /d "%Tmp_Folder%" & rmdir "%Tmp_Folder%SettingsBackup" /s /q >nul 2>&1
		goto :Archiving_Success
	)

:PS
REM Last chance (slowest)
	%PScommand% "Compress-Archive -Path "$env:TEMP\SettingsBackup\*" -CompressionLevel Fastest -DestinationPath "$env:%launchpath%Backup.zip" -Update" 1>nul 2>nul && (
		goto :Archiving_Success
	) || (
		echo %hide_cursor%%red%Archiving failed.%white%& echo:
		goto :eof
	)

:Archiving_Success
	echo %hide_cursor%%yellow%Settings successfully zipped.%white%& echo:
	rmdir "%launchpath%Backup" /s /q >nul 2>&1
	goto :eof

::============================================================================================================
:Cleaning
::============================================================================================================
REM Clean empty devices in Device Manager
	%Tmp_Folder%Files\Utilities\DeviceCleanupCmd.exe * -s -n >nul 2>&1

REM Clear System Event Viewer logs
	wevtutil.exe cl "System" >nul 2>&1

:Cleaning_Temp_Folder
	cd /d "%User_Tmp_Folder%"
	if not exist "%User_Tmp_Folder%\SettingsBackup" ( goto :eof ) else (
		cd /d "%User_Tmp_Folder%\SettingsBackup"
		for /f "delims=" %%i in ('dir /b') do ( rmdir "%%i" /s /q >nul 2>&1 ) || ( del /F /Q /S "%%i" >nul 2>&1 )
		cd /d "%User_Tmp_Folder%"
		rmdir "SettingsBackup" /s /q >nul 2>&1
		goto :Cleaning
	)

::============================================================================================================
:: Close And Restart Countdown Thingy
::============================================================================================================
:Restart_Warning
	echo %hide_cursor%All tasks have completed.
	echo You will need to restart your PC to finish optimizing your system.
	goto :Restart_Question

:Restart_Information
	echo:
	echo %hide_cursor%You might have to restart your computer for all settings to be effective.
	goto :Restart_Question

:Restart_Question
	<nul set /p DummyName=Do you want to restart the PC now? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %no%& echo: & goto :Return_To_Main_Menu )
	if errorlevel 1 ( echo %yes%& echo: & goto :Restart_Computer )

:Save_Before_End
	robocopy "%User_Tmp_Folder%\SettingsBackup" "%launchpath%Backup" *.* /is /it /S /MT:128 >nul 2>&1
	goto :Cleaning

:Return_To_Main_Menu
	cd /d "%Tmp_Folder%"
REM Create Lock file
	echo >Lock.tmp
REM Create script that will be launched simultaneously to release prompt when Lock file is deleted
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
REM Prompt and get pressed key
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	<nul set /p DummyName=Press any key to return to Start menu, or 0 to exit...%show_cursor%

:Return_To_Main_Menu_Prompt_CheckLoop
	if exist "%Tmp_Folder%Lock.tmp" ( goto :Return_To_Main_Menu_Prompt_CheckLoop )
	if exist "%Tmp_Folder%Lock_ZERO.tmp" (
		call :Lock_ZERO_Delete_Loop
		cls & goto :TmpFolder_Remove
	)
	call :Modes_Locker
	goto :START

:Return_To_Optimize_Menu
	echo:
	<nul set /p DummyName=Press any key to return to Optimization menu...%show_cursor%
	pause >nul
	goto :Optimize_MENU

:Restart_Computer
	set "Timer=12"
	echo:
	cd /d "%Tmp_Folder%"
REM Create Lock file
	echo >Lock.tmp
REM Create script that will be launched simultaneously to release prompt when Lock file is deleted
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
REM Prompt and get pressed key
	if not "%OfflineMode%"=="Unlocked" (
		echo %hide_cursor%Press %yellow%ENTER%white% to reboot now, %yellow%0%white% to cancel and exit, or any other key to cancel and return to Start menu.[2A ) else (
		echo %hide_cursor%All tasks have completed.& echo: & echo Press %yellow%ENTER%white% to reboot now, %yellow%0%white% to cancel and exit, or any other key to cancel and go to Start menu.[2A
	)
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"

REM Countdown
	setlocal EnableDelayedExpansion
	for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
	for /l %%n in (%Timer% -1 1) do (
		dir * /s/b | findstr /c:Lock.tmp > nul && (
			if %%n GEQ 10 (
				if not "%OfflineMode%"=="Unlocked" (
					<nul set /p "=Restarting in %%n seconds...!CR!" ) else (
						<nul set /p "=Your system will restart in %%n seconds to finish optimization.!CR!" ))
			if %%n LEQ 9 (
				if not "%OfflineMode%"=="Unlocked" (
					<nul set /p "=Restarting in %%n seconds... !CR!" ) else (
						<nul set /p "=Your system will restart in %%n seconds to finish optimization. !CR!" ))
			if %%n EQU 0 ( goto :Final_Stuff )
			ping -n 2 localhost > nul
		) || (
			if exist "%Tmp_Folder%Lock_ENTER.tmp" (
				call :Lock_ENTER_Delete_Loop
				goto :Final_Stuff
			)
			if exist "%Tmp_Folder%Lock_ZERO.tmp" (
				call :Lock_ZERO_Delete_Loop
				if not "%FullMode%"=="Unlocked" ( call :Settings_Check )
				goto :TmpFolder_Remove
			)
			if "%OfflineMode%"=="Unlocked" ( call :conSize 151 48 151 9999 )
			call :Modes_Locker
			goto :START
	))

:Final_Stuff
	call :Lock1_Delete_Loop
	cd /d "%User_Tmp_Folder%"
	if not "%FullMode%"=="Unlocked" ( call :Settings_Check && call :Cleaning )
	if "%Win_Edition%"=="Windows Server 2019" (
		reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\CapabilityIndex\Kernel.Soft.Reboot" | findstr /I /C:Microsoft-Windows-CoreSystem-SoftReboot-FoD-Package >nul && (
			"%windir%\System32\cmd.exe" /c shutdown.exe /r /soft /t 0
			goto :TmpFolder_Remove
	))
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
			goto :Lock_ZERO_Delete_Loop
	))

:Lock_ZERO_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock_ZERO.tmp" ( goto :eof ) else (
			del /F /Q /S "%Tmp_Folder%Lock_ZERO.tmp" >nul 2>&1
			goto :Lock_ZERO_Delete_Loop
	))

:Lock_ENTER_Delete_Loop
	if exist "%Tmp_Folder%" (
		cd /d "%Tmp_Folder%"
		if not exist "%Tmp_Folder%Lock_ENTER.tmp" ( goto :eof ) else (
			del /F /Q /S "%Tmp_Folder%Lock_ENTER.tmp" >nul 2>&1
			goto :Lock_ENTER_Delete_Loop
	))

:Settings_Check
	cd /d "%User_Tmp_Folder%"
	if not exist "%User_Tmp_Folder%\SettingsBackup\" ( goto :eof ) else (
		rmdir "%User_Tmp_Folder%\SettingsBackup" >nul 2>&1
		goto :Settings_Check
	)

:TmpFolder_Remove
	cd /d "%User_Tmp_Folder%"
	if not exist "%Tmp_Folder%" ( goto :eof ) else (
		rmdir "%Tmp_Folder%" /s /q >nul 2>&1
		goto :TmpFolder_Remove
	)

::============================================================================================================
:Remove_Tweaks
::============================================================================================================
REM PRIVACY TWEAKS
	<nul set /p DummyName=Removing privacy tweaks...%show_cursor%
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
REM Prefetch parameters (note: Outdated. EnableSuperfetch and EnablePrefetcher values have been removed since before v1809 and values get automatically deleted anyway)
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
REM Enable scheduled defragmentation
	schtasks /Change /TN "Microsoft\Windows\Defrag\ScheduledDefrag" /Enable >nul 2>&1
REM Enable System Restore Scheduled Task
	schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Enable >nul 2>&1
REM Kill CreateExplorerShellUnelevatedTask again (preventive)
	schtasks /Delete /F /TN "CreateExplorerShellUnelevatedTask" >nul 2>&1
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
	goto :Jump_Line_and_EOF

::============================================================================================================
:Reset_Group_Policy_Preferences
::============================================================================================================
REM Computer Policy (5 values, 9 lines)
	reg delete "HKLM\SOFTWARE\Microsoft\OneDrive" /v "PreventNetworkTrafficPreUserSignIn" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\wcmsvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider" /v "Domain Accounts" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v "EnableWsd" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\ControlSet002\Services\Tcpip\Parameters" /v "EnableWsd" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /f >nul 2>&1
REM User Policy (23 Preferences for 24 lines: counting 2 for VOIP lock screen notifications, but only one for Cortana notifications since we delete parent key deleting the 2 values)
	reg delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Messaging" /v "CloudServiceSyncEnabled" /f >nul 2>&1
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
REM Remove folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
	<nul set /p DummyName=Saving current policy files...%show_cursor%
REM in case .bak already exist rename it to .bak_bak
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak" (
		copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak" "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" >nul 2>&1
		copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak" "%windir%\system32\GroupPolicy\User\registry.bak_bak" >nul 2>&1
	)
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >nul 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >nul 2>&1
	echo %done%
	echo:
	<nul set /p DummyName=Restoring Group Policy from backup...%show_cursor%
	if exist "%launchpath%Backup\GroupPolicy Backup\Current GPO\GroupPolicy" (
		robocopy "%launchpath%Backup\GroupPolicy Backup\Current GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\Machine" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\User" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		echo %done%
		echo %yellow%Group Policy settings restored from backup folder.%white%& echo:
		goto :eof
	)
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" (
		copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" "%windir%\system32\GroupPolicy\Machine\registry.pol" >nul 2>&1
		copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak_bak" "%windir%\system32\GroupPolicy\User\registry.pol" >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\Machine" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		cd /d "%windir%\system32\GroupPolicy\User" & del /F /Q /S "registry.bak_bak" >nul 2>&1
		echo %done%
		echo %yellow%Group Policy settings restored from registry.bak files.%white%& echo:
		goto :eof
	)
	echo %hide_cursor%%red%Group Policy backup not found.%white%
	echo %hide_cursor%%yellow%Restore operation failed.%white%
	cd /d "%windir%\system32\GroupPolicy\Machine" & del /F /Q /S "registry.bak" >nul 2>&1
	cd /d "%windir%\system32\GroupPolicy\User" & del /F /Q /S "registry.bak" >nul 2>&1
REM Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	echo:
	<nul set /p DummyName=Would you like to reset Group Policy instead? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %no%& echo: & goto :Return_To_Main_Menu )
	if errorlevel 1 ( echo %yes%& echo: & goto :RTASK_2_no_Color_Title )

::============================================================================================================
:Restore_Services
::============================================================================================================
	<nul set /p DummyName=Restoring initial services startup configuration...%show_cursor%
	if exist "%launchpath%Backup\Services Backup" ( goto :Restore_Services_CheckforFile ) else ( goto :Restore_Services_Fail )

:Restore_Services_CheckforFile
	cd /d "%launchpath%Backup\Services Backup"
	for /f %%i in ('dir /b /s "*.bat" 2^>nul ^| find /i "Current"') do ( set "Services_Backup_Exists=%%i" )
	if not "%Services_Backup_Exists%"=="" ( goto :Restore_Services_Backup ) else ( goto :Restore_Services_Fail )

:Restore_Services_Backup
REM Set dynamic file which will have pause skipped
	echo %hide_cursor%%yellow%Services startup configuration backup found.%white%
	<nul set /p DummyName=Finding oldest file in backup folder, and restoring startup configuration with NSudo...%show_cursor%
	set "DynScriptName=%User_Tmp_Folder%\NoPause.bat"
REM Order by date to select oldest backup and then save it as dynamic file without pause
	for /f "delims=" %%a in ( 'dir /b /a-d /tw /od "%launchpath%Backup\Services Backup\*.bat" 2^>nul ^| find /i "Current"') do (
		set "Services_Configuration_to_Backup=%%~na"
		findstr /i /v "pause" "%launchpath%Backup\Services Backup\%%a">"%DynScriptName%"
		goto :Restore_Services_Backup_Action
	)

:Restore_Services_Backup_Action
REM Run dynamic script with NSudo
	if exist "%launchpath%Backup\Services Backup\%Services_Configuration_to_Backup%.reg" ( "%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -wait -UseCurrentConsole -ShowWindowMode:Show reg import "%launchpath%Backup\Services Backup\%Services_Configuration_to_Backup%.reg" >nul 2>&1 )
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -wait -ShowWindowMode:Hide "%DynScriptName%"
	echo %done%
	if exist "%DynScriptName%" ( del /F /Q /S "%DynScriptName%" >nul 2>&1 )
REM Inform user
	echo %yellow%"%Services_Configuration_to_Backup%" successfully restored.%white%& set "Services_Backup_Exists=" & goto :Jump_Line_and_EOF )

:Restore_Services_Fail
	echo %hide_cursor%%red%Services backup not found.%white%
	echo %yellow%Restore operation failed.%white%
	goto :Jump_Line_and_EOF

::============================================================================================================
:Clear_EventViewer_Logs
::============================================================================================================
	echo Clearing Event Viewer logs...%hide_cursor%
REM Backup events access rights
	for /f "tokens=2 delims= " %%a in ('wevtutil gl "Microsoft-Windows-LiveId/Operational" ^| find /i "Access:"') do ( set "ev_log1_access=%%a" )
	for /f "tokens=2 delims= " %%a in ('wevtutil gl "Microsoft-Windows-LiveId/Analytic" ^| find /i "Access:"') do ( set "ev_log2_access=%%a" )
	for /f "tokens=2 delims= " %%a in ('wevtutil gl "Microsoft-Windows-USBVideo/Analytic" ^| find /i "Access:"') do ( set "ev_log3_access=%%a" )
	for /f "tokens=2 delims= " %%a in ('wevtutil gl "Microsoft-Windows-USBVideo/Analytic" ^| find /i "enabled:"') do ( set "ev_log3_enabled=%%a" )
	for /f "tokens=2 delims= " %%a in ('wevtutil gl "Microsoft-Windows-USBVideo/Analytic" ^| find /i "retention:"') do ( set "ev_log3_retention=%%a" )
	for /f "tokens=2 delims= " %%a in ('wevtutil gl "Microsoft-Windows-USBVideo/Analytic" ^| find /i "maxsize:"') do ( set "ev_log3_maxsize=%%a" )

REM Change events access rights
	wevtutil sl "Microsoft-Windows-LiveId/Operational" /ca:O:BAG:SYD:(A;;0x1;;;SY)(A;;0x5;;;BA)(A;;0x1;;;LA)
	wevtutil sl "Microsoft-Windows-LiveId/Analytic" /ca:O:BAG:SYD:(A;;0x1;;;SY)(A;;0x5;;;BA)(A;;0x1;;;LA)
	wevtutil sl "Microsoft-Windows-USBVideo/Analytic" /enabled:false
	wevtutil sl "Microsoft-Windows-USBVideo/Analytic" /ca:O:BAG:SYD:(A;;0x1;;;SY)(A;;0x5;;;BA)(A;;0x1;;;LA)

REM Enumerate events
	for /f "tokens=*" %%G in ('wevtutil.exe el') do ( call :Clear_Event_Viewer_Logs_Task "%%G" )

REM Restore events access rights
	wevtutil sl "Microsoft-Windows-LiveId/Operational" /ca:%ev_log1_access%
	wevtutil sl "Microsoft-Windows-LiveId/Analytic" /ca:%ev_log2_access%
	wevtutil sl "Microsoft-Windows-USBVideo/Analytic" /ca:%ev_log3_access%
	wevtutil sl "Microsoft-Windows-USBVideo/Analytic" /enabled:%ev_log3_enabled% /quiet:true /retention:%ev_log3_retention% /maxsize:%ev_log3_maxsize%
	if "%FastMode%"=="Unlocked" ( echo [1A[29C%done%) else ( echo:)
	echo %yellow%Event logs have been cleared.%white%[100X
	goto :Jump_Line_and_EOF

:Clear_Event_Viewer_Logs_Task
	if not "%FastMode%"=="Unlocked" ( echo Clearing %1) else ( echo %hide_cursor%Clearing %1[100X[1A)
	wevtutil.exe cl %1
	goto :eof

::============================================================================================================
:Help_Menu
::============================================================================================================
	cd /d "%Tmp_Folder%"

REM Create Lock file
	echo >Lock.tmp
REM Create script that will be launched simultaneously to release prompt when Lock file is deleted
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

REM My ugly Help menu
	if "%FastMode%"=="Unlocked" (
		echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
		echo %SPACE50%::                FAST MODE                ::
		echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
		echo:
		echo In fast mode no backup is made, and there are no options/choices offered like in full mode.
		echo Default settings are geared towards maximum performances.
		echo:
		echo You can change default settings launching the script with %yellow%/fast%white% switch and adding %yellow%-option%white% arguments behind.
		echo Note the %yellow%/mode%white% switch position is mandatory, unlike the %yellow%-option%white% arguments.
		echo:
		echo Fast mode defaults:
		goto :Help_Fast_Mode_Defaults_Menu
	)
	if "%Run_With_Arg%"=="/?" ( set "Shell_Title=%white%]0;Optimize NextGen %Script_Version% Help%white%" )
	if "%Run_With_Arg%"=="/?" ( echo %hide_cursor%%Shell_Title%&cls )
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
	echo %SPACE50%::    Optimize NextGen %Script_Version% - HELP MENU    ::
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
	echo:
	echo                                OS performances optimization for Windows Server 2019, Windows 10 LTSC and Windows 10.
	echo:
	echo Optimize NextGen is primarily designed for individual workstations with a heavy workload, such as professional audio or 3D applications. In short,
	echo systems used mainly for one task. It aims to optimize performances by disabling unnecessary functions and maximizing privacy, while emphasizing
	echo Group Policy settings whenever possible, for tweak reversibility and to keep "update resistant" settings (unlike registry tweaks that are overwritten).
	echo:
	echo Nothing gets broken and everything is fully reversible, either from main script or with backed up files and scripts.
	echo Script was made primarily for Windows Server 2019 and Windows 10 LTSC: Services optimization for other editions is not yet available.
	echo:& echo:
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
	echo %SPACE50%::                  MODES                  ::
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
	echo:
	echo You can launch Optimize NextGen in 4 different modes from Command Prompt or using a shortcut previously created.
	echo:
	echo  -%yellow%Full mode%white% goes through every optimization tasks and is fully interactive, allowing you to choose between different options.
	echo   It will backup your services startup configuration and your Group Policy settings before running optimizations.
	echo   This mode is ideal if you run the script for the first time, as it allows you to restore initial values later if needed.
	echo   Add %yellow%/full%white% switch to launch script in this mode, or choose option %yellow%1%white% from the %yellow%Optimize menu%white%.
	echo:
	echo  -%yellow%Fast mode%white% goes through most optimization tasks with pre-set options. It doesn't require user input else an initial warning and a final restart promt.
	echo   Fast mode default settings are geared towards maximum performances. You can change them though, see below.
	echo   Add %yellow%/fast%white% switch to launch script in this mode, or choose option %yellow%2%white% from the %yellow%Optimize menu%white%.
	echo:
	echo  -%yellow%Offline mode%white% is similar to fast mode, but runs totally hidden and will exit directly at the end, instead of displaying a restart prompt.
	echo   This mode is only available using the %yellow%/offline%white% switch. Ideal for offline scenarios like deployment task or initial OS configuration.
	echo:
	echo  -%yellow%Custom mode%white% is "inverted" fast mode: It runs only with the options you set. It doesn't require user input else a restart prompt at the end.
	echo   This mode is only available using the %yellow%/custom%white% switch. You can use the provided shortcut script to set the options easily.
	echo:
	echo %yellow%Note:%white% You can change %yellow%Fast mode%white%, %yellow%Offline mode%white% and %yellow%Custom mode%white% default settings by adding %yellow%-option%white% arguments after the %yellow%/mode%white% switch.
	echo       The %yellow%/mode%white% switch position is mandatory, unlike the %yellow%-option%white% arguments.
	echo       Read "FAST MODE DEFAULT SETTINGS" chapter below for more informations about the options you can set and their argument.
	echo:& echo:
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
	echo %SPACE50%::         MENUS AND SINGLE TASKS          ::
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::
	echo:
	echo Besides full mode (option %yellow%1%white%) and fast mode (option %yellow%2%white%), you can launch single optimization tasks and even sub-parts from the %yellow%Optimize menu%white%.
	echo You can also restore single parts from the %yellow%Restore menu%white%: to "default value" for registry tweaks, to "initial state" for Group Policy and services
	echo startup configuration.
	echo:& echo:
		if not "%Help_Style%"=="Optimize" ( if not "%Help_Style%"=="Restore" (
		<nul set /p DummyName=Press any key to keep reading...%show_cursor%
		pause >nul 2>&1
	))
	"%Tmp_Folder%Files\Utilities\consolesize.exe" 153 53 153 9999
	echo %hide_cursor%[2A
	echo 1. Optimize Menu
	echo [150X
	echo Optimizations are divided in 4 main tasks/parts:
	echo:
	echo  -%yellow%Privacy%white% task ^(option %yellow%3%white%^) includes:
	echo   Telemetry killing task, Scheduled tasks disabling, and Registry Tweaks sub-parts.
	echo   Registry and telemetry are small sections, as most of the settings are made through Group Policy.
	echo   If Microsoft Store installation is detected, script will ask you if you want to apply Microsoft Store and Store Apps blocking tweaks (%yellow%Y%white%/%yellow%N%white%).
	echo   Press %yellow%N%white% ^(No^) if you use Microsoft Store. This option is not available on Windows Server where Store and Store Apps will be locked by default.
	echo   If you chose not to apply Store tweaks, it will then ask you the same about game-related tweaks. Press %yellow%N%white% ^(No^) again if you use Windows Games features.
	echo:
	echo  -%yellow%Performance%white% task ^(option %yellow%4%white%^) includes:
	echo   -Performances registry tweaks: Small section again, performances settings are mostly managed through Group Policy.
	echo   -Power Management optimization: Disable every "Selective Suspend" setting, and set Ultimate Performances Power Scheme.
	echo   -Memory settings: Enable memory compression and PageCombining ^(option only available on windows Server, not needed on Windows 10^).
	echo   -Disks Write Caching configuration: Enable write caching on all drives at once, instead setting it one by one using Device Manager.
	echo   Some of these parts are very useful for "initial setup" configuration in my opinion.
	echo   Otherwise, you have to do it manually via Control Panel and/or Device Manager. Now you can do it all by script.
	echo   Press %yellow%P%white% for Power Management task, %yellow%W%white% for Write Caching task, %yellow%M%white% for Memory settings task.
	echo:
	echo  -%yellow%Group Policy%white% task ^(option %yellow%5%white%^) is the MOST important part in Optimize NextGen.
	echo   I've spent lots of time collecting infos - these include NSA recommended settings ^(no joke^) - and tweaking it,
	echo   in the aim to get a fully hardened configuration and a greatly performing system at the same time.
	echo   Before running the task, a backup is performed allowing you to restore your initial Group Policy settings if needed.
	echo   It optionally includes a custom Policy Template, official Firefox Policy Template, and their related settings.
	echo   It has also been customized for Microsoft Store users: If Store is installed, script will ask you if you want to block Store and Store Apps ^(%yellow%Y%white%/%yellow%N%white%^).
	echo   If you chose to bypass Store tweaks, it will then ask you the same about game-related tweaks. Press %yellow%N%white% ^(No^) again if you use Windows Games features.
	echo   Note that Windows Defender is NOT disabled: Only reports, telemetry leaks and network inspection are.
	echo   The reason is that a lot of people are using it, while some use no antivirus at all and others 3rd party solution.
	echo   Besides that, you can easily disable it yourself, it's well documented. I prefered to focus on important less well known settings and tweaks.
	echo   Disabling Windows Defender would give you a substantial performances boost. But if you use a 3rd party solution, know that Defender has much
	echo   less influence on system performances, like most "native" solutions, and has been proven to be among the best in "detection rate".
	echo:
	echo  -%yellow%Services optimization%white% ^(option %yellow%6%white%^) has been tested thoroughly.
	echo   Some services are kept enabled ON PURPOSE because disabling them breaks Settings App, Immersive Control Panel crashing right away:
	echo   Disabling DevicesFlowUserSvc breaks Devices Settings, disabling WpnUserService breaks Focus and Assist Settings.
	echo   While disabling cbdhsvc disables clipboard history, you can not drag and drop copied text and images anymore.
	echo   Search service is NOT disabled, for the exact same reason than Windows Defender: Everyone is using a different solution.
	echo   Disabling search is well documented and very easy to do if you need to, but it won't give you any big performance improvement.
	echo   I personally set indexing locations to start menus folders, and set some related tweaks like not indexing external drives, encrypted folders etc.
	echo   If you disable Search features, I recommend to set indexed locations to "none" before. Check below for more infos about Indexing Options ^(%yellow%I%white%^) part.
	echo   Script will backup your services startup configuration before and after optimization, so you can revert at any time to the initial state,
	echo   or apply optimized services startup configuration again.
	echo   Unlike other similar solutions and scripts, this script will also rename Windows services with random numbers ^(ex: UserDataSvc_9eedb^),
	echo   and handles perfectly services with a space in their name, which is frequent for 3rd party applications.
	echo   It will backup startup configuration as .reg file and .bat script, .reg adding the ability to backup "delayed start" value.
	echo   If you are not connected to any Wi-Fi network, script will ask if you want to enable or disable Wlan service ^(%yellow%E%white%/%yellow%D%white%^).
	echo   Script will also ask if you want to enable or disable File and Printer Sharing ^(%yellow%E%white%/%yellow%D%white%^).
	echo   I recommend to disable it, but you could enable in the case you use network printer or other computers on home network.
	echo   Script uses NSudo to launch optimization with Trusted Installer rights, allowing FULL optimization including services with "access denied".
	echo:& echo:
	if not "%Help_Style%"=="Restore"	(
		<nul set /p DummyName=Press any key to keep reading...%show_cursor%
		pause >nul 2>&1
	)
	echo:
	echo %hide_cursor%[3A
	echo Get more optimizations:&echo:[100X
	echo  -Additionaly, press %yellow%T%white% to process registry tweaks only.
	echo   Note that Registry settings task includes both Privacy AND Performances registry tweaks, these are small sections and judged useless to separate.
	echo:
	echo  -Press %yellow%U%white% to enable, or create Ultimate Performance Power Scheme:
	echo   There is a annoying bug in Windows 10, if you ever set another Power Scheme, Ultimate Performance one disappears.
	echo   You can re-create it by using some commands as documented on the web, but it creates the Power Scheme with a new GUID,
	echo   bloating little by little your registry, if you are to repeat the operation.
	echo   This script creates the Power Scheme with the default GUID, as on a new OS installation and as it should.
	echo:
	echo  -Press %yellow%I%white% to set default indexed locations the easy way, instead of going through Control Panel.
	echo   You could consider it as a "front GUI" for Indexing Options Control Panel.
	echo   %yellow%Set Indexing Locations%white% (%yellow%I%white%) has 4 sub-menus:
	echo   -Custom locations: A convenient browser which allows to quickly set your desired indexed paths.
	echo   -Start menus only: The only paths you should really index in my opinion. Quick setting option.
	echo   -No indexed locations: Deletes all indexed folder ^(even "secretly" indexed ones^). Quick setting option.
	echo   -Default indexed locations: It will restore default Windows indexed locations, including the ones with your User SID. Quick setting option.
	echo:
	echo   This part is also useful for initial setup configuration, check below for %yellow%/offline%white% mode %yellow%-switches%white% and how to set different indexing options.
	echo   Note: If you disable Wsearch service, I recommend to also set default indexed locations to none.
	echo:
	echo  -Press %yellow%N%white% for .NET Framework web applications performance tuning.
	echo   To support high levels of concurrency when using web applications, some tuning is required. After a quick backup,
	echo   script will set config files and registry values as adviced here http://docs.frozenmountain.com/websync4/index.html#class=websync-performance-tuning
	echo:
	echo  -There are a few more menus and options, enough self-explanative, that I let you discover...
	echo:& echo:
	if not "%Help_Style%"=="Restore" (
		<nul set /p DummyName=Press any key to keep reading...%show_cursor%
		pause >nul 2>&1
	)
	"%Tmp_Folder%Files\Utilities\consolesize.exe" 153 34 153 9999
	echo %hide_cursor%[1A
	echo 2. Restore Menu[100X
	echo:
	echo Restore menu options are pretty self-explanative, so I don't need to go very much in details.
	echo:
	echo  -%yellow%Remove Registry Tweaks%white% (option %yellow%1%white%): It will restore privacy AND performances registry values to Windows default value.
	echo:
	echo  -%yellow%Reset Group Policy%white% (option %yellow%2%white%): It will reset your Group Policy settings and related registry values.
	echo   It will also reset Preferences set by the Group Policy task.
	echo   For the info: unlike True Policies, Preferences are Group Policy settings that are not located in a "/policies" registry key.
	echo   And unlike True Policies, their set value ^(enabled/disabled^) stays after you set the policy to "Not configured": the value doesn't reset.
	echo   The script will take care of that and reset those values. It also offers the option to reset Group Policy security settings.
	echo:
	echo  -%yellow%Restore Group Policy from backup%white% (option %yellow%3%white%): Use this option to restore your Group Policy settings to their initial values.
	echo   It will first go through the "Reset Group Policy" task above, and similarly propose to reset Group Policy security settings.
	echo   Then it will look for a backup of your Group Policy settings, first in the "Backup" folder next to the script, and if it doesn't find any,
	echo   it will restore registry.bak files saved previously in your "Windows\System32\GroupPolicy" directory.
	echo:
	echo  -%yellow%Restore services startup configuration from backup%white% (option %yellow%4%white%): Use this option to restore your services startup configuration to its initial state.
	echo   Script will search - and restore - oldest backup found in "Backup" folder located next to the script.
	echo   Note that it will only restore "current policy" backup ^(made before services optimization^) and not "optimized policy" backup, even if older.
	echo:
	echo  -%yellow%Restore default memory settings%white% (option %yellow%5%white%): This option is only available on Windows Server, and not needed on Windows 10.
	echo   It will disable Memory Compression and PageCombining, which are Windows Server default value. Use Get-MMAgent Powershell commandlet to find out.
	echo:
	echo  -%yellow%Restore Windows default indexed locations%white% (Option %yellow%6%white%): It will restore Windows default indexed paths, including the tricky ones depending on your SID.
	echo:
	echo  -%yellow%Reactivate Game Explorer%white% (Option %yellow%G%white%): Renames back gameux.bak to gameux.dll, if you deactivated Game Explorer previously.
	echo   If ever the file is broken or deleted, it can also restore it and its hardlink from WinSxs folder.
	echo:
	echo  -%yellow%Remove or restore .NET Framework web applications performance tuning tweaks%white% (Option %yellow%N%white%): It will reset .NET Framework tuning tweaks to default.
	echo   If a backup is detected in "Backup" folder, it will ask you if you want to restore initial values.
	echo:& echo:
	<nul set /p DummyName=Press any key to keep reading and learn more about default settings and the arguments you can set...%show_cursor%
	pause >nul 2>&1
	"%Tmp_Folder%Files\Utilities\consolesize.exe" 153 50 153 9999
	echo %hide_cursor%[1A
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::::[100X
	echo %SPACE50%::      DEFAULT SETTINGS AND ARGUMENTS       ::
	echo %SPACE50%:::::::::::::::::::::::::::::::::::::::::::::::
	echo:
:Help_Fast_Mode_Defaults_Menu
	echo  -In Fast mode an initial warning is displayed. Add %yellow%-nowarn%white% to disable it and go directly to optimization process.
	echo  -Group Policy security settings are reset. This is recommended to reset Group Policy properly, but the command takes a few seconds to complete.
	echo   Add %yellow%-noresetgps%white% to bypass secedit command.
	echo  -Custom Policy Template is imported. I recommend it, especially if you use Group Policy editor, but you can specify %yellow%-noimportcp%white% to avoid it.
	echo  -Firefox Policy Template is imported. Specify %yellow%-noimportfp%white% to avoid it if you don't use Firefox or don't need its GPO template.
	echo  -File and Printer Sharing services are disabled. Specify %yellow%-enablefps%white% to enable.
	echo  -Wireless Lan service will be automatically disabled if you are not currently connected to any Wi-Fi Network, unless you add the %yellow%-enablewl%white% switch.
	echo  -Indexed locations are set to "Start Menus", meaning only those 2 folders will be indexed.
	echo   Specify %yellow%-defaultidx%white% to set Windows default indexed locations, %yellow%-resetidx%white% to remove every indexed folder, or %yellow%-bypassidx%white% to bypass that task.
	echo  -Microsoft Store and Store apps are disabled. If you use Store and/or Microsoft account, you shouldn't. Specify %yellow%-store%white% to unlock it, though.
	echo  -Games tweaks are set. If you ever need Windows games features, specify %yellow%-games%white% to enable them.
	echo  -After its execution the script will advice to restart and ask if you want to reboot, return to main menu, or exit.
	echo   Specify %yellow%-norestart%white% to exit directly without showing that prompt, but note that some options need a restart for the changes to take effect.
	echo:
	echo Add some tasks:
	echo  -Game Explorer deactivation is bypassed, unless you specify %yellow%-gex%white%.
	echo  -Trim command is bypassed, you don't need to trim your SSD that often. Specify %yellow%-trim%white% to execute, for an "initial setup" configuration for example.
	echo  -You can also clear Event Viewer logs, adding %yellow%-evlog%white% to your command.
	echo  -Add %yellow%-netapps%white% to speed up .NET Framework web applications.
	echo:
	echo Bypass some tasks:
	echo  -Add %yellow%-nogp%white% to bypass Group Policy task.
	echo  -Add %yellow%-nopriv%white% to bypass whole privacy task.
	echo  -Add %yellow%-noperf%white% to bypass whole performance task.
	echo  -Add %yellow%-noss%white% to bypass Selective Suspend task, %yellow%-nowc%white% to bypass Write Caching task, %yellow%-nomm%white% to bypass Memory task.
	echo  -Add %yellow%-noserv%white% to bypass services optimization task.
	echo  -As mentioned above, use %yellow%-bypassidx%white% to bypass indexing options task, and %yellow%-nowarn%white% to bypass fast mode initial warning.
	echo:
	echo You can use as many arguments as you like. Note that depending on your system or the options chosen, some of them will be inactive ^(read below^).
	if not "%FastMode%"=="Unlocked" ( echo: )
	echo Examples: Optimize_NextGen.exe /fast -nowarn -noresetgps -evlog -nowc -norestart
	echo           Optimize_NextGen_%Script_Version%_MDL.bat /offline -nopriv -noperf -resetidx -noimportfp
	echo:
	echo Inactive arguments:
	echo  -Wireless Lan service is not installed by default on Windows Server ^(but you can of course enable it^).
	echo   If you are using Windows Server and Wlan AutoConfig service is detected as missing %yellow%-enablwl%white% argument is obviously inactive.
	echo  -Store and Games are not available on Windows Server. If you are using Windows Server, %yellow%-store%white% and %yellow%-games%white% switches won't do anything.
	echo  -Services optimization is only available on LTSC editions for now ^(Windows Server 2019 and Windows 10 LTSC^).
	echo   If you are using a "non LTSC" edition, %yellow%-enablewl%white% and %yellow%-enablefps%white% arguments will have no influence since services optimization task will be bypassed.
	echo  -If you add the %yellow%-noperf%white% argument, it will bypass the whole performances optimization task, which means that %yellow%-noss%white%, %yellow%-nowc%white% or %yellow%-nomm%white% are useless.
	if "%FastMode%"=="Unlocked" ( goto :Final_Notes )
	echo  -Offline mode runs totally hidden and will exit right after execution, meaning that %yellow%-nowarn%white% and %yellow%-norestart%white% arguments are useless in offline mode.
	echo   In other words, launching the script using %yellow%/offline%white% is similar to %yellow%/fast -nowarn -norestart%white%, except the fact offline mode runs totally hidden.
	echo  -In Custom mode there is no initial warning, meaning the %yellow%-nowarn%white% argument is also useless.
	echo:& echo:
	<nul set /p DummyName=Press any key to keep reading...%show_cursor%
	pause >nul 2>&1
	echo:
	echo %hide_cursor%[2ACustom mode differences:[100X
	echo   Fast mode and offline mode share the same arguments, but custom mode needs a few different arguments.[100X
	echo   Instead of BYPASSING tasks, you need to ENABLE them. Simply use "inverted" bypass arguments, as opposed to the above ones used to bypass tasks.
	echo:
	echo   Use %yellow%-gp%white% to run Group Policy task.
	echo   If you enabled Group Policy task with the %yellow%-gp%white% switch:
	echo     Add %yellow%-resetgps%white% to reset Group Policy security settings.
	echo     Add %yellow%-importcp%white% to import custom Group Policy Template.
	echo     Add %yellow%-importfp%white% to import Firefox Policy Template.
	echo   Use %yellow%-priv%white% to enable privacy task.
	echo   Use %yellow%-perf%white% to enable performance task.
	echo   If you enabled performances optimization task with the %yellow%-perf%white% switch:
	echo     Add %yellow%-ss%white% to run Selective Suspend task and disable selective suspend for USB devices and Network adapters.
	echo     Add %yellow%-wc%white% to run Write Caching task and enable Write Caching on all drives.
	echo     Add %yellow%-mm%white% to run Memory Settings task on Windows Server.
	echo   If you want to set indexed locations:
	echo     Use %yellow%-startmenusidx%white% to set start menus as indexed location.
	echo     Use %yellow%-resetidx%white% to remove every indexed location.
	echo     Or use %yellow%-defaultidx%white% to set Windows default indexed locations.
	echo   The remaining arguments are the same as in fast and offline mode:
	echo     Use %yellow%-trim%white% to trim your SSD.
	echo     Use %yellow%-gex%white% to disable Game Explorer.
	echo     Use %yellow%-evlog%white% do clear Event Viewer logs.
	echo     Use %yellow%-netapps%white% to run .Net Framework web application performances tuning.
	echo     Use %yellow%-norestart%white% to exit at the end instead of displaying the restart prompt.
:Final_Notes
	echo:
	echo Final notes:
	echo  -Even if you choose not to import Custom Policy Template using the %yellow%-noimportcp%white% switch, related privacy policies are set.
	echo   I recommend to import the template though, to be able to use those settings directly from GPedit.msc later.
	echo  -Launch script with %yellow%/?%white% switch to see full help, or Press %yellow%H%white% in one of the menus.
	echo  -A shortcut creation script is provided together with Optimize NextGen, allowing you to create shortcuts with the chosen options.
	if not "%FastMode%"=="Unlocked" ( echo   Have a look at it and see how it is easy.)
	echo:& echo:

REM Prompt and get key
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:P -UseCurrentConsole -ShowWindowMode:Show "%Tmp_Folder%Lock.bat"
	if "%Run_With_Arg%"=="/?" ( set "Run_With_Arg=Undefined" )

REM Message displayed
	if "%Help_Style%"=="Main" (
		<nul set /p DummyName=Press any key to start, or 0 to exit.%show_cursor%
	)
	if "%Help_Style%"=="Optimize" (
		<nul set /p DummyName=Press any key to return to return to Optimize menu, or 0 to exit.%show_cursor%
	)
	if "%Help_Style%"=="Restore" (
		<nul set /p DummyName=Press any key to return to return to Restore menu, or 0 to exit.%show_cursor%
	)
	if "%Help_Style%"=="Start" (
		<nul set /p DummyName=Press any key to return to return to Start menu, or 0 to exit.%show_cursor%
	)
	if "%FastMode%"=="Unlocked" (
		<nul set /p DummyName=Press any key to proceed, or 0 to return to Optimize menu.%show_cursor%
	)
REM Reset help style
	set "Help_Style=Undefined"

:Disclaimer_Lock_CheckLoop
	if exist "%Tmp_Folder%Lock.tmp" ( goto :Disclaimer_Lock_CheckLoop )
	if exist "%Tmp_Folder%Lock_ZERO.tmp" (
		call :Lock_ZERO_Delete_Loop
		if "%FastMode%"=="Unlocked" ( echo %hide_cursor%0& call :Resize_Window & goto :Optimize_MENU ) else ( goto :TmpFolder_Remove )
	)
	echo %hide_cursor%[1d[1G
	call :Resize_Window
	cls & goto :eof

:Resize_Window
	"%Tmp_Folder%Files\Utilities\consolesize.exe" 153 50 153 9999
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
	if errorlevel 2 ( echo %no%& set "Win_Store=Store_ON" & goto :WGames_Ask )
	if errorlevel 1 ( echo %yes%& set "Win_Store=Store_OFF" & goto :Jump_Line_and_EOF )

:WGames_Ask
	<nul set /p DummyName=Do you want to apply game related tweaks? [Y/N] (Press No if you play games)%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %no%& set "Win_Games=Games_ON" & goto :Jump_Line_and_EOF )
	if errorlevel 1 ( echo %yes%& set "Win_Games=Games_OFF" & goto :Jump_Line_and_EOF )

::============================================================================================================
:Game_Explorer_Restore
::============================================================================================================
	if exist "%windir%\System32\gameux.dll" ( echo %hide_cursor%Game Explorer is already active.& echo: && goto :eof )
	<nul set /p =Enabling Games Explorer...%show_cursor%
	if exist "%windir%\System32\gameux.dll.bak" ( ren "%windir%\System32\gameux.dll.bak" "gameux.dll" >nul 2>&1 )
	if exist "%windir%\System32\GameUXLegacyGDFs.dll.bak" ( ren "%windir%\System32\GameUXLegacyGDFs.dll.bak" "GameUXLegacyGDFs.dll" >nul 2>&1 )
	if exist "%windir%\SysWOW64\gameux.dll.bak" ( ren "%windir%\SysWOW64\gameux.dll.bak" "gameux.dll" >nul 2>&1 )
	if exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" ( ren "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" "GameUXLegacyGDFs.dll" >nul 2>&1 )
	if not exist "%windir%\System32\gameux.dll" ( echo %hide_cursor%%red%Operation failed.%white%& goto :Game_Explorer_Hard_Restore ) else ( echo %done%& goto :Jump_Line_and_EOF )

:Game_Explorer_Hard_Restore
REM In case anything goes wrong
	set "Restore_GameExplorer=Restore_GameExplorer_ON"
	<nul set /p =Restoring Game Explorer from WinSxs folder...%show_cursor%
	if exist "%windir%\System32\gameux.dll.bak" ( del /F /Q /S "%windir%\System32\gameux.dll.bak" >nul 2>&1 )
	if exist "%windir%\System32\GameUXLegacyGDFs.dll.bak" ( del /F /Q /S "%windir%\System32\GameUXLegacyGDFs.dll.bak" >nul 2>&1 )
	if exist "%windir%\SysWOW64\gameux.dll.bak" ( del /F /Q /S "%windir%\SysWOW64\gameux.dll.bak" >nul 2>&1 )
	if exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" ( del /F /Q /S "%windir%\SysWOW64\GameUXLegacyGDFs.dll.bak" >nul 2>&1 )

REM Launch NSudo to get permissions on WinSxs folder
	"%Tmp_Folder%Files\Utilities\NSudoC.exe" -U:T -P:E -Wait -UseCurrentConsole "%~dpnx0"&& ( goto :eof )

:Game_Explorer_Hard_Restore_Task
	cd /d "%windir%\WinSxS"
REM gameux 64bit
	for /f %%i in ('dir /b /s "gameux.dll" 2^>nul ^| find /i "amd64_"') do ( set "gameux_64=%%i" )
	if not "%gameux_64%"=="" ( if not exist "%windir%\System32\gameux.dll" ( mklink /H "%windir%\System32\gameux.dll" "%gameux_64%" >nul 2>&1 ))
REM gameux 32bit
	for /f %%j in ('dir /b /s "gameux.dll" 2^>nul ^| find /i "wow64_"') do ( set "gameux_32=%%j" )
	if not "%gameux_32%"=="" ( if not exist "%windir%\SysWOW64\gameux.dll" ( mklink /H "%windir%\SysWOW64\gameux.dll" "%gameux_32%" >nul 2>&1 ))
REM GameUXLegacyGDFs 64bit
	for /f %%k in ('dir /b /s "GameUXLegacyGDFs.dll" 2^>nul ^| find /i "amd64_"') do ( set "gameuxL_64=%%k" )
	if not "%gameuxL_64%"==""	( if not exist "%windir%\System32\GameUXLegacyGDFs.dll" ( mklink /H "%windir%\System32\GameUXLegacyGDFs.dll" "%gameuxL_64%" >nul 2>&1 ))
REM GameUXLegacyGDFs 32bit
	for /f %%l in ('dir /b /s "GameUXLegacyGDFs.dll" 2^>nul ^| find /i "wow64_"') do ( set "gameuxL_32=%%l" )
	if not "%gameuxL_32%"==""	( if not exist "%windir%\SysWOW64\GameUXLegacyGDFs.dll" ( mklink /H "%windir%\SysWOW64\GameUXLegacyGDFs.dll" "%gameuxL_32%" >nul 2>&1 ))
REM Check for file
	if not exist "%windir%\System32\gameux.dll" ( echo %hide_cursor%%red%Operation failed.%white% ) else ( echo %hide_cursor%%green%Operation was successful.%white% )
REM Reset task variable
	set "Restore_GameExplorer=Restore_GameExplorer_OFF"
	cd /d "%Tmp_Folder%"
	echo:
	exit /b

::============================================================================================================
:Modes_Locker
::============================================================================================================
	endlocal
	set "FastMode=Locked"
	set "FullMode=Locked"
	set "OfflineMode=Locked"
	set "CustomMode=Locked"
	set "Fast_Mode_Switches_Pool_MAIN="
	if not "%Win_Regular_Edition%"=="Windows 10" (
		set "Shell_Title=%white%]0;Optimize NextGen %Script_Version%%white%"
	) else (
		set "Shell_Title=%white%]0;Optimize NextGen %Script_Version% LITE%white%"
	)
	goto :eof

:MStore_Modes_Locker
	set "Win_Store=Store_OFF"
	set "Win_Games=Games_OFF"
	goto :eof

::============================================================================================================
:Privacy_Opt_Txt
::============================================================================================================
	echo Optimizing privacy:%show_cursor%[100X& goto :eof

::============================================================================================================
:Perf_Opt_Txt
::============================================================================================================
	echo Optimizing performances:%show_cursor%[100X& goto :eof

::============================================================================================================
:Jump_Line_and_EOF
::============================================================================================================
	echo:
	goto :eof

::============================================================================================================
:NSudo_Tasks
::============================================================================================================
	if "%PowerSchemeCreation%"=="PowerSchemeCreation_ON" ( goto :GUID_Trick )
	if "%Restore_GameExplorer%"=="Restore_GameExplorer_ON" ( goto :Game_Explorer_Hard_Restore_Task )
	goto :Services_Optimization_Task

::============================================================================================================
:LITE_Notice
::============================================================================================================
	set "Shell_Title=%white%]0;Optimize NextGen %Script_Version% LITE%white%"
	echo %hide_cursor%%white%Optimize NextGen was primarily made for LTSC and Windows Server,
	echo and won't ^(yet^) process services optimization in %Win_Edition%.& echo:
	echo It will fully support all Windows 10 editions soon.
	<nul set /p DummyName=Going to main menu in a few seconds...%show_cursor%
	timeout /t 8 /nobreak >nul 2>&1
	goto :eof

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

:Error_Frankenbuild
	echo %white%Frankenbuilds are not accepted.
	goto :Exit_on_Error

:Error_No_Robocopy
	echo Robocopy.exe doesn't exist, the script can not continue.
	goto :Exit_on_Error

:Error_No_User
	echo We could not find your User profile, the script can not continue.
	goto :Exit_on_Error

:Error_Edition_Not_Found
	echo We could not find your Windows Edition, the script can not continue.
	goto :Exit_on_Error

:Exit_on_Error
	<nul set /p DummyName=Press any key to exit...%show_cursor%
	pause >nul
	exit /b
