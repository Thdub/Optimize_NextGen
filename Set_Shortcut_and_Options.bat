@echo off

setlocal enabledelayedexpansion

:: VARIABLES
	set "ShortcutScriptPath=%TEMP%\Set_Shortcut.ps1"
	set "WorkDir=%~dp0"
	set "WorkDir=%WorkDir:~0,-1%"
	set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass"
	set "colors=blue=[94m,green=[92m,red=[31m,yellow=[93m,white=[97m
	set "%colors:,=" & set "%"
	
:: TITLE AND TEXT
	echo ***********************************************************************
	echo Customize your Mode ^(%yellow%/mode%white%^) and Switches ^(%yellow%-option%white%^) for Optimize NextGen
	echo ***********************************************************************
	echo First set your mode:
	echo:
	echo %yellow%Full Mode%white% goes through all optimization tasks and interactively offers choices.
	echo %yellow%Fast Mode%white% runs with pre-set options. By default, it shows a warning at the beginning and a restart prompt at the end.
	echo %yellow%Offline Mode%white% runs with the same pre-set options, but runs hidden and will exit directly at the end, requiring no user input at all.
	echo %yellow%Custom Mode%white% runs with the options you choose only.
	echo:
	echo You can change %yellow%Fast mode%white% and %yellow%Offline mode%white% default settings by adding arguments when launching Optimize NextGen.
	echo The %yellow%/mode%white% swith position is mandatory, unlike the %yellow%-option%white% arguments.
	echo:
	echo This script simplifies the process: It creates the shortcut pointing to Optimize NextGen, with the arguments related to the options you choose.
	echo Type Optimize_NextGen_MDL.exe /? to launch Help and learn more about default settings and all the options you can set.
	echo:

:: MODE
	choice /c 1234 /M "Choose your mode: Full Mode (1), Fast Mode (2), Offline Mode (3) or Custom Mode (4)"
	if errorlevel 4 ( set "mode_switch=/custom" &set "warn_switch=-nowarn" &echo: &goto :backup_serv_sw )
	if errorlevel 3 ( set "mode_switch=/offline" & goto :Set_Options_Choice )
	if errorlevel 2 ( set "mode_switch=/fast" & goto :Set_Options_Choice )
	if errorlevel 1 ( set "mode_switch=/full" & goto :Set_Arguments )

:Set_Options_Choice
	echo:
 	choice /c YN /M "Do you want to set options"
	if errorlevel 2 ( goto :Set_Arguments )
	if errorlevel 1 (
		if "%mode_switch%"=="/fast" ( echo: & goto :warn_sw )
		if "%mode_switch%"=="/offline" ( echo: & goto :backup_serv_sw )
	)

:: OPTIONS
:: Warning
:warn_sw
	choice /c YN /M "Show warning"
	if errorlevel 2 ( set "warn_switch=-nowarn" & goto :backup_serv_sw )
	if errorlevel 1 ( set "warn_switch=" & goto :backup_serv_sw )
:: Backups
:backup_serv_sw
	choice /c YN /M "Backup services startup configuration before running"
	if errorlevel 2 ( set "backup_serv_switch=" & goto backup_gp_sw )
	if errorlevel 1 ( set "backup_serv_switch=-backupserv" & goto backup_gp_sw )
:backup_gp_sw
	choice /c YN /M "Backup Group Policy settings before running"
	if errorlevel 2 ( set "backup_gp_switch=" & goto :gp_sw )
	if errorlevel 1 ( set "backup_gp_switch=-backupgp" & goto :gp_sw )
:: Group policy
:gp_sw
	choice /c YN /M "Run Group Policy task"
	if errorlevel 2 ( set "gp_switch=-nogp" & goto :priv_sw )
	if errorlevel 1 ( set "gp_switch=" & goto :resetgp_sw )
:resetgp_sw
	choice /c YN /M "-Reset group policy security settings"
	if errorlevel 2 ( set "gps_switch=-noresetgps" & goto :custompol_sw )
	if errorlevel 1 ( set "gps_switch=" & goto :custompol_sw )
:custompol_sw
	choice /c YN /M "-Import Custom Policy Template"
	if errorlevel 2 ( set "importcp_switch=-noimportcp" & goto :importfp_sw )
	if errorlevel 1 ( set "importcp_switch=" & goto :importfp_sw )
:importfp_sw
	choice /c YN /M "-Import Firefox Policy Template and Group Policy settings"
	if errorlevel 2 ( set "importfp_switch=-noimportfp" & goto :priv_sw )
	if errorlevel 1 ( set "importfp_switch=" & goto :priv_sw )
:: Privacy
:priv_sw
	choice /c YN /M "Run Privacy task"
	if errorlevel 2 ( set "priv_switch=-nopriv" & goto :perf_sw )
	if errorlevel 1 ( set "priv_switch=" & goto :perf_sw )
:: Performances
:perf_sw
	choice /c YN /M "Run Performance task"
	if errorlevel 2 ( set "perf_switch=-noperf" & goto :store_sw )
	if errorlevel 1 ( set "perf_switch=" & goto :ss_sw )
:ss_sw
	choice /c YN /M "-Deactivate Selective Suspend for USB devices and Network adapters"
	if errorlevel 2 ( set "ss_switch=-noss" & goto :wc_sw )
	if errorlevel 1 ( set "ss_switch=" & goto :wc_sw )
:wc_sw
	choice /c YN /M "-Enable Write Caching on all disks"
	if errorlevel 2 ( set "wc_switch=-nowc" & goto :mm_sw )
	if errorlevel 1 ( set "wc_switch=" & goto :mm_sw )
:mm_sw
	for /f "tokens=1* delims==" %%A in ('wmic os get Caption /value') do ( for /f "tokens=*" %%S in ("%%B") do ( if "%%A"=="Caption" set "OS_Name=%%S" ))
	if "%OS_Name%"=="Microsoft Windows Server 2019 Datacenter" ( goto :set_mm_sw ) else ( goto :store_sw )
	if "%OS_Name%"=="Microsoft Windows Server 2019 Essentials" ( goto :set_mm_sw ) else ( goto :store_sw )
	if "%OS_Name%"=="Microsoft Windows Server 2019 Standard" ( goto :set_mm_sw ) else ( goto :store_sw )
:set_mm_sw
	choice /c YN /M "-Process memory settings"
	if errorlevel 2 ( set "mm_switch=-nomm" & goto :store_sw )
	if errorlevel 1 ( set "mm_switch=" & goto :store_sw )
:: Store
:store_sw
	if "%priv_switch%"=="-nopriv" ( if "%perf_switch%"=="-noperf" ( if "%gp_switch%"=="-nogp" ( goto :serv_sw )))
	choice /c YN /M "Using Microsoft Store"
	if errorlevel 2 ( set "store_switch=" & goto :games_sw )
	if errorlevel 1 ( set "store_switch=-store" & goto :games_sw )
:: Games
:games_sw
	choice /c YN /M "Playing games"
	if errorlevel 2 ( set "games_switch=" & goto :gex_sw )
	if errorlevel 1 ( set "games_switch=-games" & goto :serv_sw )
:: Game explorer
:gex_sw
	choice /c YN /M "Deactivate Game Explorer"
	if errorlevel 2 ( set "gex_switch=" & goto :serv_sw )
	if errorlevel 1 ( set "gex_switch=-gex" & goto :serv_sw )
:: Services
:serv_sw
	choice /c YN /M "Run services optimization"
	if errorlevel 2 ( set "serv_switch=-noserv" & goto :idx_sw )
	if errorlevel 1 ( set "serv_switch=" & goto :enablewl_sw )
:enablewl_sw
	choice /c ED /M "-Enable or Disable Wireless Lan service"
	if errorlevel 2 ( set "enablewl_switch=" & goto :enablefps_sw )
	if errorlevel 1 ( set "enablewl_switch=-enablewl" & goto :enablefps_sw )
:enablefps_sw
	choice /c ED /M "-Enable or Disable File and Printer Sharing"
	if errorlevel 2 ( set "enablefps_switch=" & goto :idx_sw )
	if errorlevel 1 ( set "enablefps_switch=-enablefps" & goto :idx_sw )
:: Indexing options
:idx_sw
	choice /c YN /M "Run Indexing Options task"
	if errorlevel 2 ( set "idx_switch=-bypassidx" & goto :netapps_sw )
	if errorlevel 1 ( goto :set_idx_sw )
:set_idx_sw
	choice /c 123 /M "-Indexing locations: Start menus(1), default windows locations (2), no folder indexed (3)"
	if errorlevel 3 ( set "idx_switch=-resetidx" & goto :netapps_sw )
	if errorlevel 2 ( set "idx_switch=-defaultidx" & goto :netapps_sw )
	if errorlevel 1 ( set "idx_switch=" & goto :netapps_sw )
:: .NET web apps
:netapps_sw
	choice /c YN /M ".NET Framework web applications performance tuning"
	if errorlevel 2 ( set "netapps_switch=" & goto :evlog_sw )
	if errorlevel 1 ( set "netapps_switch=-netapps" & goto :evlog_sw )
:: Clear event log
:evlog_sw
	choice /c YN /M "Clear Event Viewer logs"
	if errorlevel 2 ( set "evlog_switch=" & goto :trim_sw )
	if errorlevel 1 ( set "evlog_switch=-evlog" & goto :trim_sw )
:: Trim ssd
:trim_sw
	choice /c YN /M "Send TRIM request to system SSD (Optimize)"
	if errorlevel 2 ( set "trim_switch=" & goto :norestart_sw )
	if errorlevel 1 ( set "trim_switch=-trim" & goto :norestart_sw )
:: Exit or restart
:norestart_sw
if "%mode_switch%"=="/offline" ( goto :Set_Arguments )
	choice /c 12 /M "Show restart prompt at the end or exit directly"
	if errorlevel 2 set "norestart_switch=-norestart" & goto :Set_Arguments )
	if errorlevel 1 set "norestart_switch=" & goto :Set_Arguments )

:Set_Arguments
	set "Shorcut_Description=Optimize NextGen in"
	set "Link_Name=%~dp0Optimize Nextgen - "
	set "Source_Exe=%~dp0Optimize_NextGen_VE.exe"
	if "%mode_switch%"=="/full" ( set "Arguments=/full" & goto :Create_Powershell_Script )
	set "Arguments_pool_1=%mode_switch% %warn_switch% %backup_serv_switch% %backup_gp_switch% %gp_switch% %gps_switch% %importcp_switch% %importfp_switch%"
	set "Arguments_pool_2=%priv_switch% %perf_switch% %ss_switch% %wc_switch% %mm_switch% %store_switch% %games_switch% %serv_switch% %enablewl_switch% %enablefps_switch%"
	set "Arguments_pool_3=%idx_switch% %netapps_switch% %gex_switch% %evlog_switch% %trim_switch% %norestart_switch%"
	set "Arguments=%Arguments_pool_1% %Arguments_pool_2% %Arguments_pool_3%"
	set "Arguments=%Arguments: =%"
	set "Arguments=%Arguments:-= -%"

:Create_Powershell_Script
	@echo param ^( [string]$SourceExe, [string]$ArgumentsToSourceExe, [string]$Destination, [string]$WorkDirectory, [string]$Description, [string]$Icon ^)> "%ShortcutScriptPath%"
	@echo $WshShell = New-Object -comObject WScript.Shell>> "%ShortcutScriptPath%"
	@echo $Shortcut = $WshShell.CreateShortcut^($Destination^)>> "%ShortcutScriptPath%"
	@echo $Shortcut.TargetPath = $SourceExe>> "%ShortcutScriptPath%"
	@echo $Shortcut.Arguments = $ArgumentsToSourceExe>> "%ShortcutScriptPath%"
	@echo $Shortcut.WorkingDirectory = $WorkDirectory>> "%ShortcutScriptPath%"
	@echo $Shortcut.Description = $Description>> "%ShortcutScriptPath%"
	@echo $Shortcut.IconLocation = $Icon>> "%ShortcutScriptPath%"
	@echo $Shortcut.Save^(^)>> "%ShortcutScriptPath%"
	@echo $bytes = [System.IO.File]::ReadAllBytes^("$Destination"^)>> "%ShortcutScriptPath%"
	@echo $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 ^(0x15^) bit 6 ^(0x20^) ON>> "%ShortcutScriptPath%"
	@echo [System.IO.File]::WriteAllBytes^("$Destination", $bytes^)>> "%ShortcutScriptPath%"

:: Set additional names
	if "%mode_switch%"=="/full" ( set "Link_Name=%Link_Name%Full" & set "Shorcut_Description=%Shorcut_Description% full mode" & goto :Create_Shortcut )
	if "%mode_switch%"=="/custom" ( set "Link_Name=%Link_Name%Custom" & set "Shorcut_Description=%Shorcut_Description% custom mode" & goto :Create_Shortcut )
	if "%Arguments%"==%mode_switch% (
		if "%mode_switch%"=="/fast" ( set "Link_Name=%Link_Name%Fast" & set "Shorcut_Description=%Shorcut_Description% fast mode" )
		if "%mode_switch%"=="/offline" ( set "Link_Name=%Link_Name%Offline" & set "Shorcut_Description=%Shorcut_Description% offline mode" )	
	) else (
		if "%mode_switch%"=="/fast" ( set "Link_Name=%Link_Name%Fast with options" & set "Shorcut_Description=%Shorcut_Description% fast mode with switches" )
		if "%mode_switch%"=="/offline" ( set "Link_Name=%Link_Name%Offline with options" & set "Shorcut_Description=%Shorcut_Description% offline mode with switches" )
	)

:Create_Shortcut
	%PScommand% -file "%ShortcutScriptPath%" "%Source_Exe%" "!Arguments!" "%Link_Name%.lnk" "%WorkDir%" "%Shorcut_Description%" "%Source_Exe%"
	echo:
	<nul set /p DummyName=Done, closing in an instant...

:: Delete PS script
	del %ShortcutScriptPath% /f /s /q >nul 2>&1
	timeout /t 30 >nul 2>&1
	exit /b
