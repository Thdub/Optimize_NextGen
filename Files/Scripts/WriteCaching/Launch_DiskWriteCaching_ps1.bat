@echo off
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :NOADMIN
cd /d "%~dp0"
PowerShell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass ".\DiskWriteCaching.ps1 -Disks (1..10) -WriteCache $true -Servers $env:COMPUTERNAME"
echo:
<nul set /p DummyName=Press any key to exit...
pause >nul
exit /b
:NOADMIN
echo [97mYou must have administrator rights to run this script.
<nul set /p DummyName=Press any key to exit...
pause >nul
goto :eof