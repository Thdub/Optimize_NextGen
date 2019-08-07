@echo off
C:\Windows\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :No_Admin
cd /d "%~dp0"
PowerShell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME"
echo:
<nul set /p DummyName=Press any key to exit...
pause >nul
exit /b
:No_Admin
echo You must have administrator rights to run this script.
<nul set /p DummyName=Press any key to exit...
pause >nul
goto :eof
