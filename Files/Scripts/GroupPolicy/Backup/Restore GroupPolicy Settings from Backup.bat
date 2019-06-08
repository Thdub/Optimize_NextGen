@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN
:: Set window Title
	echo ]0;Restore Group Policy Settings from Backup
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to start...
	@pause >NUL 2>&1
:: Start process
	cls
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
	if exist "%~dp0..\..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Current GPO\GroupPolicy" (
	robocopy "%~dp0..\..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Current GPO\GroupPolicy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >NUL 2>&1
	cd /d "%windir%\system32\GroupPolicy\Machine" & del "registry.bak_bak" /s /q >NUL 2>&1
	cd /d "%windir%\system32\GroupPolicy\User" & del "registry.bak_bak" /s /q >NUL 2>&1
	echo [92mDone.[97m
	echo [93mGroup Policy settings restored from backup folder.[97m& echo:
	goto :GP_Update
	)
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" (
	copy /b /v /y "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" "%windir%\system32\GroupPolicy\Machine\registry.pol" >NUL 2>&1
	copy /b /v /y "%windir%\system32\GroupPolicy\User\registry.bak_bak" "%windir%\system32\GroupPolicy\User\registry.pol" >NUL 2>&1
	cd /d "%windir%\system32\GroupPolicy\Machine" & del "registry.bak_bak" /s /q >NUL 2>&1
	cd /d "%windir%\system32\GroupPolicy\User" & del "registry.bak_bak" /s /q >NUL 2>&1
	echo [92mDone.[97m
	echo Backup folder not found: [93mGroup Policy settings restored from registry.bak files.[97m& echo:
	goto :GP_Update
	)
	echo [91mGroup Policy backup not found.[97m
	echo [93mRestore operation failed.[97m
	cd /d "%windir%\system32\GroupPolicy\Machine" & del "registry.bak" /s /q >NUL 2>&1
	cd /d "%windir%\system32\GroupPolicy\User" & del "registry.bak" /s /q >NUL 2>&1
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	echo:
	<nul set /p dummyName=Would you like to reset GroupPolicy instead? [Y/N]
	choice /c YN /m "Would you like to reset" >NUL 2>&1
	if errorlevel 2 echo [91mNo[97m& echo: & ( goto :PAUSE_BEFORE_EXIT )
	if errorlevel 1 echo [92mYes[97m& (
	echo:
	echo Launching "Reset GroupPolicy.bat"
	cls
	call "%~dp0..\Reset GroupPolicy.bat"
	exit /b
	)
:GP_Update
	<nul set /p dummyName=Updating policy...[140X
	GPUpdate /Force /Target:Computer >NUL && echo:
	<nul set /p dummyName=[93mComputer Policy update has completed successfully.[1A[32D
	GPUpdate /Force /Target:User >NUL 2>&1 && echo: & echo:
	echo User Policy update has completed successfully.& echo:
	echo [4A[18C[92mDone.[97m[2B
	echo:
:: Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
:: Inform user
	echo [93mYour Group Policy settings have been restored.[97m
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
