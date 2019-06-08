@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>NUL 2>NUL || goto :NOADMIN
:: Set window Title
	echo ]0;Reset Group Policy Settings
:: Start when you're ready.
	<nul set /p dummyName=[1A[97mPress any key to start...
	@pause >NUL 2>&1
:: Start process
	cls
	<nul set /p dummyName=Backing up current Group Policy...
:: Change folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
:: Rename .pol files to .bak
	move /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >NUL 2>&1
	move /y "%windir%\system32\GroupPolicy\User\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >NUL 2>&1
	echo [92mDone.[97m
:: Group Policy Security Settings choice
	<nul set /p dummyName=Do you want to reset your Group Policy Security Settings as well? [Y/N]
	choice /C:YN /M "Do you want to reset" >NUL 2>&1
	if errorlevel 2 echo [31mAborted[97m& echo: & goto :GP_Update
:: Reset Group Policy Security Settings
	echo [92mYes[97m
	mkdir "%~dp0..\..\..\OptimizeNextGen_Settings_Backup\GroupPolicy Backup\Security Settings" >NUL 2>&1
	cd /d "%TEMP%\SettingsBackup\GroupPolicy Backup\Security Settings"
	secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb
	echo [3A[93mThe task has completed.[97m
	echo: [140X
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
	echo [93mGroup Policy has been reset.
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
