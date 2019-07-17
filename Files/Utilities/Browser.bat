@if (@CodeSection == @Batch) @then


@echo off
for /f "delims=" %%a in ('CScript //nologo //E:JScript "%~F0" "Select the folder or type the path you want to index, then click OK."') do (
	if %Index%==0 ( set "IndexedFolder=%%a" ) else ( set "IndexedFolder_%Index%=%%a" )
)
goto :eof

@end


var shl = new ActiveXObject("Shell.Application");
var folder = shl.BrowseForFolder(0, WScript.Arguments(0), 0x00000050,17);
WScript.Stdout.WriteLine(folder ? folder.self.path : "");