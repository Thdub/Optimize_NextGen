'Windows Services startup configuration.

Option Explicit
If WScript.Arguments.length = 0 Then
   Dim objShell : Set objShell = CreateObject("Shell.Application")
   objShell.ShellExecute "wscript.exe", Chr(34) & _
   WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
Else
   Dim WshShell, objFSO, strNow, intServiceType, intStartupType, strDisplayName, iSvcCnt
   Dim sREGFile, sBATFile, r, b, strComputer, objWMIService, colListOfServices, objService
   Set WshShell = CreateObject("Wscript.Shell")
   Set objFSO = Wscript.CreateObject("Scripting.FilesystemObject")

Function LPad (str, pad, length)
    LPad = String(length - Len(str), pad) & str
End Function

   strNow = LPad(Day(Date), "0", 2) & "-" & LPad(Month(Date), "0", 2) & "-" & Year(Now) & "_" & "at" & "_" & LPad(Hour(Time), "0", 2) & "h" & LPad(Minute(Time), "0", 2)

   Dim objFile: Set objFile = objFSO.GetFile(WScript.ScriptFullName)
   sREGFile = objFSO.GetParentFolderName(objFile) & "\Optimized_services_saved_on_" & strNow & ".reg"
   sBATFile = objFSO.GetParentFolderName(objFile) & "\Optimized_services_saved_on_" & strNow & ".bat"

   Set r = objFSO.CreateTextFile (sREGFile, True)
   r.WriteLine "Windows Registry Editor Version 5.00"
   r.WriteBlankLines 1
   r.WriteLine ";Services Startup Configuration saved after optimization at " & Time & " on " & FormatDateTime(Now, vbShortDate)
   r.WriteBlankLines 1

   Set b = objFSO.CreateTextFile (sBATFile, True)
   b.WriteLine "@echo off"
   b.WriteLine "%windir%\system32\reg.exe query ""HKU\S-1-5-19"" 1>nul 2>nul || goto :NOADMIN"
   b.WriteBlankLines 1
   b.WriteLine "echo ]0;Import optimized services startup configuration, saved at " & Time & " on " & FormatDateTime(Now, vbShortDate) & ""
   b.WriteLine "<nul set /p DummyName=[1APress any key to start..."
   b.WriteLine "pause >nul"
   b.WriteLine "cls"
   b.WriteBlankLines 1

   strComputer = "."
   iSvcCnt=0
   Dim sStartState, sSvcName, sSkippedSvc

   Set objWMIService = GetObject("winmgmts:" _
   & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

   Set colListOfServices = objWMIService.ExecQuery _
   ("Select * from Win32_Service")

   For Each objService In colListOfServices
      iSvcCnt=iSvcCnt + 1
      r.WriteLine "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & trim(objService.Name) & "]"
      sStartState = lcase(objService.StartMode)
      sSvcName = objService.Name
      Select Case sStartState
         Case "boot"

         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000000"
         b.WriteLine "sc.exe config " & Chr(34) & sSvcName & Chr(34) & " start= boot"

         Case "system"
         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000001"
         b.WriteLine "sc.exe config " & Chr(34) & sSvcName & Chr(34) & " start= system"

         Case "auto"
         'Check if it's Automatic (Delayed start)
         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000002"
         If objService.DelayedAutoStart = True Then
            r.WriteLine chr(34) & "DelayedAutostart" & Chr(34) & "=dword:00000001"
            b.WriteLine "sc.exe config " & Chr(34) & sSvcName & Chr(34) & " start= delayed-auto"
         Else
            r.WriteLine chr(34) & "DelayedAutostart" & Chr(34) & "=-"
            b.WriteLine "sc.exe config " & Chr(34) & sSvcName & Chr(34) & " start= auto"
         End If

         Case "manual"

         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000003"
         b.WriteLine "sc.exe config " & Chr(34) & sSvcName & Chr(34) & " start= demand"

         Case "disabled"

         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000004"
         b.WriteLine "sc.exe config " & Chr(34) & sSvcName & Chr(34) & " start= disabled"

         Case "unknown"	sSkippedSvc = sSkippedSvc & ", " & sSvcName
         'Case Else
      End Select
      r.WriteBlankLines 1
   Next

   r.Close
   b.WriteLine "echo:"
   b.WriteBlankLines 1
   b.WriteLine "<nul set /p DummyName=Done. Press any key to exit..."
   b.WriteLine "pause >nul"
   b.WriteLine "exit /b"
   b.WriteBlankLines 1
   b.WriteLine ":NOADMIN"
   b.WriteLine "echo You must have administrator rights to run this script."
   b.WriteLine "<nul set /p DummyName=Press any key to exit..."
   b.WriteLine "pause >nul"
   b.WriteLine "goto :eof"
   b.Close

   If objFSO.FileExists("lock.tmp") Then
      objFSO.DeleteFile "lock.tmp"
   End If

   Set objFSO = Nothing
   Set WshShell = Nothing
End If