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
	set "User_Tmp_Folder=%systemdrive%\Users\%username%\AppData\Local\Temp"
	set "windir=C:\Windows"

:: Titlebar
	echo %hide_cursor%%white%]0;Restore Group Policy Settings from Backup& cls

:: Start when you're ready.
	<nul set /p dummyName=%white%Press any key to start...%show_cursor%
	pause >nul 2>&1
	cls

:: 1. Change folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"
	
:: 2. Backup choice
	<nul set /p dummyName=Do you want to backup your Group Policy settings before? [Y/N]%show_cursor%
	choice /C:YN >nul 2>&1
	if errorlevel 2 (
		echo %no%
		goto :Rename_GPO_Files
	)
	echo %yes%
	<nul set /p dummyName=Backing up current Group Policy settings...%show_cursor%
REM Create backup folders
	mkdir "%~dp0..\..\..\Backup\GroupPolicy Backup\Current GPO\%FolderDate%" >nul 2>&1
	mkdir "%~dp0..\..\..\Backup\GroupPolicy Backup\Local Policy Export" >nul 2>&1
REM Backup in date folder
	set "FolderDate=%Date:~0,2%-%Date:~3,2%-%Date:~6,4%"
	robocopy "%windir%\system32\GroupPolicy" "%~dp0..\..\..\Backup\GroupPolicy Backup\Current GPO\%FolderDate%\GroupPolicy" *.pol *.bak /is /it /S >nul 2>&1
REM LGPO full backup
	"%~dp0..\..\..\Files\Utilities\LGPO.exe" /b "%~dp0..\..\..\Backup\GroupPolicy Backup\Local Policy Export" /n "Local Policy Backup" /q >nul 2>&1
	echo %done%

:: 3. Remove Group Policy files
:Rename_GPO_Files
	<nul set /p dummyName=Renaming current Group Policy files...%show_cursor%
REM in case .bak already exists rename it to .bak_bak before
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak" ( move /y "%windir%\system32\GroupPolicy\Machine\registry.bak" "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" >nul 2>&1 )
	if exist "%windir%\system32\GroupPolicy\User\registry.bak" ( move /y "%windir%\system32\GroupPolicy\User\registry.bak" "%windir%\system32\GroupPolicy\User\registry.bak_bak" >nul 2>&1 )
	cd /d "%windir%\system32\GroupPolicy"
	for /r %%a in (*.pol) do ( move /y "%%a" "%%~dpna.bak" >nul 2>&1 )
	echo %done%& echo:

:: 4. Restore backup
REM Restore from backup folder
	<nul set /p dummyName=Restoring Group Policy from backup...
	if exist "%~dp0..\..\..\Backup\GroupPolicy Backup\Current GPO\Group Policy" (
		cd /d "%windir%\system32\GroupPolicy"
		robocopy "%~dp0..\..\..\Backup\GroupPolicy Backup\Current GPO\Group Policy" "%windir%\system32\GroupPolicy" *.pol /is /it /S >nul 2>&1
		for /r %%a in (*.bak_bak) do ( del /F /Q /S "%%a" >nul 2>&1 )
		echo %done%
		echo %yellow%Group Policy settings restored from backup folder.%white%& echo:
		goto :Task_Success
	)
REM Restore from .bak
	if exist "%windir%\system32\GroupPolicy\Machine\registry.bak_bak" (
		cd "%windir%\system32\GroupPolicy"
		for /r %%a in (*.bak_bak) do ( move /y "%%a" "%%~dpna.pol" >nul 2>&1 )
		echo %done%
		echo Backup folder not found: %yellow%Group Policy settings restored from registry.bak files.%white%& echo:
		goto :Task_Success
	)
REM Restore failed
	goto :Task_Failed

:: 5. Inform user
:Task_Failed
	echo %red%Group Policy backup not found.%white%
	echo %yellow%Restore operation failed.%white%& echo:
	cd "%windir%\system32\GroupPolicy"
	for /r %%a in (*.bak) do ( move /y "%%a" "%%~dpna.pol" >nul 2>&1 )
	for /r %%a in (*.bak_bak) do ( del /F /Q /S "%%a" >nul 2>&1 )
	<nul set /p dummyName=Would you like to reset GroupPolicy instead? [Y/N]%show_cursor%
	choice /c YN >nul 2>&1
	if errorlevel 2 ( echo %no%& echo: & call :GP_Update & goto :PAUSE_BEFORE_EXIT )
	if errorlevel 1 ( echo %yes%& call :Reset_GPO )
	exit /b
	)

:Task_Success
	call :GP_Update
	echo %yellow%Your Group Policy settings have been restored.
	echo Note:%white% Initial Group Policy files have been renamed from registry.pol to registry.bak
	echo:
	echo You might have to restart your computer for all settings to be effective.
	
:: 6. Restart choice
	<nul set /p dummyName=Do you want to restart the PC now? [Y/N]%show_cursor%
	choice /C:YN >nul 2>&1
	if errorlevel 2 ( echo %no%& echo: & goto :PAUSE_BEFORE_EXIT )
	if errorlevel 1 ( echo %yes%& goto :Restart_Computer )
	echo:

:PAUSE_BEFORE_EXIT
	<nul set /p dummyName=Press any key to exit...%show_cursor%
	pause >nul 2>&1
	exit /b

:Restart_Computer
	echo:
	setlocal EnableDelayedExpansion
	for /F %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
	for /L %%n in (6 -1 1) do (
		<nul set /p "=%hide_cursor%Restarting in %%n seconds...[3X!CR!"
		ping -n 2 localhost > nul
	)
	"%windir%\System32\cmd.exe" /c shutdown.exe /r /f /t 00
	exit /b

:GP_Update
	<nul set /p dummyName=Updating Group Policy...%show_cursor%[140X
	GPUpdate /Force >nul
	echo %done%
REM Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"
	echo:
	goto :eof

:Reset_GPO
:: Titlebar
	echo %hide_cursor%%white%]0;Reset Group Policy Settings& cls
REM Trick to call second batch at :Reset_GPO label, taking advantage of strange goto behavior and so not using call here.
	"%~dp0Reset Group Policy.bat"
	exit /b

:No_Admin
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
