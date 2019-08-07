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
	set "Backup="

:: Titlebar
	echo %hide_cursor%%white%]0;Reset Group Policy Settings& cls

:: 1. Change folder attributes
	attrib -h -s "%windir%\system32\GroupPolicy"

:: 2. Backup choice
	<nul set /p dummyName=Do you want to backup your Group Policy settings before? [Y/N]%show_cursor%
	choice /C:YN >nul 2>&1
	if errorlevel 2 (
		echo %no%
		goto :Reset_GPO
	)
	echo %yes%&set "Backup=yes"
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
:Reset_GPO
	<nul set /p dummyName=Moving Group Policy files...%show_cursor%
	move /y "%windir%\system32\GroupPolicy\Machine\registry.pol" "%windir%\system32\GroupPolicy\Machine\registry.bak" >nul 2>&1
	move /y "%windir%\system32\GroupPolicy\User\registry.pol" "%windir%\system32\GroupPolicy\User\registry.bak" >nul 2>&1
	echo %done%& echo:

:: 4. Group Policy Security settings choice
	<nul set /p dummyName=Do you want to reset your Group Policy Security settings as well? [Y/N]%show_cursor%
	choice /C:YN >nul 2>&1
	if errorlevel 2 ( echo %no%& echo: & goto :GP_Update )
	if errorlevel 1 ( echo %yes% )
REM Reset Group Policy Security Settings
	cd /d "%User_Tmp_Folder%"
	secedit /configure /cfg "%windir%\inf\defltbase.inf" /db defltbase.sdb
	del /F /Q /S "defltbase.sdb" "defltbase.jfm" >nul 2>&1
	echo [3A%yellow%The task has completed.%white%
	echo: [140X

:: 5. Group Policy Update
:GP_Update
	<nul set /p dummyName=Updating Group Policy...%show_cursor%[140X
	GPUpdate /Force >nul 2>&1
	echo %done%
	echo:

:: 6. Restore folder attributes
	attrib +h +r +s "%windir%\system32\GroupPolicy"

:: 7. Inform user
	if "%backup%"=="yes" ( echo %yellow%Your Group Policy settings have been backed-up and reset.) else ( echo %yellow%Your Group Policy settings have been reset.)
	echo Note:%white% Initial Group Policy files have been renamed from registry.pol to registry.bak
	echo:
	echo You might have to restart your computer for all settings to be effective.
	
:: 8. Restart choice
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

:No_Admin
	echo You must have administrator rights to run this script.
	<nul set /p dummyName=Press any key to exit...
	pause >nul
	goto :eof
