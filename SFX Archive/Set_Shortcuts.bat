@echo off
set "ShortcutScriptPath=%TEMP%\Set_Shortcut.ps1"
set "WorkDir=%~dp0"
set "WorkDir=%WorkDir:~0,-1%"

@echo param ^( [string]$SourceExe, [string]$ArgumentsToSourceExe, [string]$Destination, [string]$WorkDirectory, [string]$Description, [string]$Icon ^) > "%ShortcutScriptPath%"
@echo $WshShell = New-Object -comObject WScript.Shell >> "%ShortcutScriptPath%"
@echo $Shortcut = $WshShell.CreateShortcut^($Destination^) >> "%ShortcutScriptPath%"
@echo $Shortcut.TargetPath = $SourceExe >> "%ShortcutScriptPath%"
@echo $Shortcut.Arguments = $ArgumentsToSourceExe >> "%ShortcutScriptPath%"
@echo $Shortcut.WorkingDirectory = $WorkDirectory >> "%ShortcutScriptPath%"
@echo $Shortcut.Description = $Description >> "%ShortcutScriptPath%"
@echo $Shortcut.IconLocation = $Icon >> "%ShortcutScriptPath%"
@echo $Shortcut.Save^(^) >> "%ShortcutScriptPath%"
@echo $bytes = [System.IO.File]::ReadAllBytes^("$Destination"^) >> "%ShortcutScriptPath%"
@echo $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 ^(0x15^) bit 6 ^(0x20^) ON >> "%ShortcutScriptPath%"
@echo [System.IO.File]::WriteAllBytes^("$Destination", $bytes^) >> "%ShortcutScriptPath%"

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%ShortcutScriptPath%" "%~dp0Optimize_NextGen_MDL.exe" /fast "%~dp0Optimize Nextgen - Fast.lnk" "%WorkDir%" "Optimize NextGen fast mode" "%~dp0Optimize_NextGen_MDL.exe"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%ShortcutScriptPath%" "%~dp0Optimize_NextGen_MDL.exe" /full "%~dp0Optimize Nextgen - Full.lnk" "%WorkDir%" "Optimize NextGen full mode" "%~dp0Optimize_NextGen_MDL.exe"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%ShortcutScriptPath%" "%~dp0Optimize_NextGen_MDL.exe" /offline "%~dp0Optimize Nextgen - Offline.lnk" "%WorkDir%" "Optimize NextGen offline mode" "%~dp0Optimize_NextGen_MDL.exe"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%ShortcutScriptPath%" "%~dp0Optimize_NextGen_MDL.exe" /secret "%~dp0Optimize Nextgen - Secret.lnk" "%WorkDir%" "Optimize NextGen secret mode" "%~dp0Optimize_NextGen_MDL.exe"

del %ShortcutScriptPath% /f /s /q >NUL 2>&1
exit /b