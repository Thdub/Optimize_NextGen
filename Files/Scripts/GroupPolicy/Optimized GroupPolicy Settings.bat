@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN

:: Set Variables
	for /f "tokens=2 delims==" %%j in ('wmic os get Caption /value') do (
	set "Win_Edition=%%j"
	)
:: Find either LTSC or Server
	echo %Win_Edition% | findstr /i /c:"Enterprise S" >nul && (
	set "Win_Edition=Windows 10 LTSC"
	set "Win_Edition_Title=Microsoft Windows 10 LTSC"
	goto :START
	) || (
	goto :Find_Server_Edition
	)
:Find_Server_Edition
	echo %Win_Edition% | findstr /i /c:"Server" >nul && (
	set "Win_Edition=Windows Server 2019"
	set "Win_Edition_Title=Microsoft Windows Server 2019"
	goto :START
	) || (
	goto :PAUSE_BEFORE_EXIT
	)
:START
	for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%A

:: Set window Title
	echo ]0;Optimized Group Policy Settings for %Win_Edition_Title%
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to start...
	@pause >NUL 2>&1

:: Start process
	cls
	<nul set /p dummyName=Backing up current Group Policy...
:: Remove Temp Directory
	cd /d "%TEMP%"
	if exist "%TEMP%\SettingsBackup" rmdir "SettingsBackup" /s /q >NUL 2>&1
:: Change folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
:: Rename .pol files to .bak
	move /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >NUL 2>&1
	move /y "%windir%\system32\GroupPolicy\User\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >NUL 2>&1
:: Export Group Policy Security Settings
	mkdir "%~dp0..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Security Settings" >NUL 2>&1
	if exist "%~dp0..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" (
	move /y "%~dp0..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" "%~dp0..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Security Settings\securityconfig.bak" >NUL 2>&1
	)
	secedit /export /cfg "%~dp0..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Security Settings\securityconfig.cfg" >NUL 2>&1
	echo [92mDone.[97m
	echo:
:: Import custom policies set and firefox into policydefinitions, create files from parsed lgpo text and import new group policy
	echo Starting Group Policy task...
	<nul set /p dummyName=Do you want to add Firefox policies as well? [Y/N]
	choice /C:YN /M "Do you want to add" >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& ( goto :No_Firefox_Policy )
	if errorlevel 1 echo [92mYes[97m& ( goto :All_Policies )

:All_Policies
	<nul set /p dummyName=%BS%  -Importing Custom Policies Set and Firefox Policy Template to "PolicyDefinitions" folder: 
	robocopy "%~dp0..\..\..\Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" *.admx *.adml /is /it /S >NUL 2>&1
	echo [92mDone.[97m& ( goto :Start_LGPO )

:No_Firefox_Policy
	<nul set /p dummyName=%BS%  -Importing Custom Policies Set to "PolicyDefinitions" folder: 
	robocopy "%~dp0..\..\..\Files\GroupPolicy\PolicyDefinitions" "%windir%\PolicyDefinitions" CustomPolicies.admx CustomPolicies.adml /is /it /S >NUL 2>&1
	echo [92mDone.[97m& ( goto :Start_LGPO_No_Firefox )

:Start_LGPO
	<nul set /p dummyName=%BS%  -Creating registry.pol files from parsed LGPO text: 
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine" "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User" >NUL 2>&1
	"%~dp0..\..\..\Files\GroupPolicy\LGPO\LGPO.exe" /r "%~dp0..\..\..\Files\GroupPolicy\LGPO\User_VE.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User\registry.pol" >NUL 2>&1
:: Check Windows edition
	echo %Win_Edition% | findstr /i /c:"LTSC" >nul && (
	goto :LTSC_LGPO
	) || (
	goto :SERVER_LGPO
	)

:LTSC_LGPO
	"%~dp0..\..\..\Files\GroupPolicy\LGPO\LGPO.exe" /r "%~dp0..\..\..\Files\GroupPolicy\LGPO\LTSC_Machine.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:SERVER_LGPO
	"%~dp0..\..\..\Files\GroupPolicy\LGPO\LGPO.exe" /r "%~dp0..\..\..\Files\GroupPolicy\LGPO\Server_Machine.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:Start_LGPO_No_Firefox
	<nul set /p dummyName=%BS%  -Creating registry.pol files from parsed LGPO text: 
	mkdir "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine" "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User" >NUL 2>&1
	"%~dp0..\..\..\Files\GroupPolicy\LGPO\LGPO.exe" /r "%~dp0..\..\..\Files\GroupPolicy\LGPO\User_VE.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\User\registry.pol" >NUL 2>&1
:: Check Windows edition
	echo %Win_Edition% | findstr /i /c:"LTSC" >nul && (
	goto :LTSC_LGPO_No_Firefox
	) || (
	goto :SERVER_LGPO_No_Firefox
	)

:LTSC_LGPO_No_Firefox
	"%~dp0..\..\..\Files\GroupPolicy\LGPO\LGPO.exe" /r "%~dp0..\..\..\Files\GroupPolicy\LGPO\LTSC_Machine_NF.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:SERVER_LGPO_No_Firefox
	"%~dp0..\..\..\Files\GroupPolicy\LGPO\LGPO.exe" /r "%~dp0..\..\..\Files\GroupPolicy\LGPO\Server_Machine_NF.txt" /w "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	goto :LGPO_SUCCESS

:LGPO_SUCCESS
	echo [92mDone. [93m%Win_Edition% policy files successfully created.[97m
:: Import_New_GPO
	<nul set /p dummyName=%BS%  -Importing new Group Policy: 
	robocopy "%TEMP%\SettingsBackup\GroupPolicy Backup\New GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >NUL 2>&1
	echo [92mDone.[97m
	<nul set /p dummyName=%BS%  -Importing Group Policy Security Settings: 
:: Password policy
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%~dp0..\..\..\Files\GroupPolicy\securityconfig.cfg" /areas SECURITYPOLICY >NUL 2>&1
:: Delegation rights
	secedit /configure /db "%windir%\security\new.sdb" /cfg "%~dp0..\..\..\Files\GroupPolicy\securityconfig.cfg" /areas USER_RIGHTS >NUL 2>&1
	echo [92mDone.[97m
	echo [93mGroup Policy task has completed successfully.[97m
	echo:

:GPUpdate
	<nul set /p dummyName=Updating policy...[140X
	GPUpdate /Force /Target:Computer >NUL && echo:
	<nul set /p dummyName=[93mComputer Policy update has completed successfully.[1A[32D
	GPUpdate /Force /Target:User >NUL && echo: & echo:
	echo User Policy update has completed successfully.& echo:
	echo [4A[18C[92mDone.[97m[2B
	echo:
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	if exist "%TEMP%\SettingsBackup" rmdir "SettingsBackup" /s /q >NUL 2>&1
:: Inform user
	echo [93m%Win_Edition% Group Policy optimization task has completed successfully.
	echo [96mNote:[97m Old Group Policy files have been renamed as registry.bak.
	echo:
	echo You might have to restart your computer for all settings to be effective.
	<nul set /p dummyName=Do you want to restart the PC now? [Y/N]
	choice /C:YN /M "Do you want to restart" >NUL 2>&1
	if errorlevel 2 echo [31mNo[97m& echo: & goto :PAUSE_BEFORE_EXIT
	if errorlevel 1 goto :Restart_Computer
	echo:

:PAUSE_BEFORE_EXIT
	<nul set /p dummyName=Press any key to exit...
	pause >NUL 2>&1
	exit /b

:Restart_Computer
	echo: [?25l
	setlocal EnableDelayedExpansion
	for /F %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
	for /L %%n in (5 -1 1) do (
		<nul set /p "=Restarting in %%n seconds...!CR!"
		ping -n 2 localhost > nul
	)
	shutdown /r /f /t 00
	exit /b

:NOADMIN
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
