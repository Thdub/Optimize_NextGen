@if (@X)==(@Y) @end /* Harmless hybrid line that begins a JScript comment
@goto :Batch

============= :Batch portion ===========
setlocal disableDelayedExpansion
del /f /s /q "%TEMP%\lock_process.tmp" >NUL 2>&1

:: Process Help
if .%2 equ . call :help "%~1" && exit /b 0 || call :exitErr "Insufficient arguments"

:: Define options
set ^"/options= /A: /APP: /B: /C: /D:":" /E: /EXC:"" /F:"" /H: /HON:"\x1B[7m" /HOFF:"\x1B[0m" /HU: /I:^
                /INC:"" /J: /JBEG:"" /JBEGLN:"" /JEND:"" /JENDLN:"" /JLIB:"" /JMATCH: /JMATCHQ: /JQ:^
                /K:"" /L: /M: /MATCH: /N:0 /O:"" /OFF:0 /P:"" /PFLAG:"g" /PREPL:"" /R:"" /RTN:"" /S:""^
                /T:"none" /TFLAG:"" /U: /UTF: /V: /VT: /X: /XBYTES: /XBYTESOFF: /XFILE: /XSEQ: /XREG:"" ^"
:: Set default option values
for %%O in (%/options%) do for /f "tokens=1,* delims=:" %%A in ("%%O") do set "%%A=%%~B"

:: Get options
:loop
if not "%~3"=="" (
  set "/test=%~3"
  setlocal enableDelayedExpansion
  if "!/test:~0,1!" neq "/" call :exitErr "Too many arguments"
  set "/test=!/options:*%~3:=! "
  if "!/test!"=="!/options! " (
      endlocal
      call :exitErr "Invalid option %~3"
  ) else if "!/test:~0,1!"==" " (
      endlocal
      set "%~3=1"
  ) else (
      endlocal
      set "%~3=%~4"
      shift /3
  )
  shift /3
  goto :loop
)

:: Validate options
if defined /M if defined /A if not defined /S                                      call :exitErr "/M cannot be used with /A without /S"
if "%/O%" equ "-" if not defined /F                                                call :exitErr "Output = - but Input file not specified"
if defined /F if defined /S                                                        call :exiterr "/S cannot be used with /F"
if defined /F for %%A in ("%/F%") do for %%B in ("%/O%") do if "%%~fA" equ "%%~fB" call :exitErr "Output file cannot match Input file"
if defined /RTN if defined /O                                                      call :exitErr "/O and /RTN are mutually exclusive"
if defined /RTN if defined /UTF                                                    call :exitErr "/UTF and /RTN are mutually exclusive"
if "%/EXC%%/INC%%/C%%/JBEGLN%%/JENDLN%" neq "" if "%/M%%/S%" neq ""                call :exitErr "/C, /JBEGLN, and /JENDLN cannot be used with /M or /S"
for /f "tokens=2" %%A in ("%/J% %/JQ% %/JMATCH% %/JMATCHQ% %/K% %/R% %/MATCH%") do call :exitErr "/J, /JQ, /JMATCH, /JMATCHQ, /MATCH, /K and /R are all mutually exclusive"
if "%/K%%/R%" neq "" if "%/A%%/M%%/S%%/T%" neq "none"                              call :exitErr "/K, /R cannot be used with /A, /M, /S or /T"
if defined /MATCH if "%/A%%/T%" neq "none"                                         call :exitErr "/MATCH cannot be used with /A or /T"
for /f delims^=giGI^ eol^= %%A in ("%/PFLAG%") do                                  call :exitErr "Invalid /PFLAG value"
if "%/OFF%" neq "0" if defined /PREPL                                              call :exitErr "/PREPL cannot be used with /OFF"
for /f "delims=| eol=| tokens=2*" %%A in ("%/APP%|%/O%x") do if %%A==- if .%%B neq . call :exitErr "/APP cannot be combined with /O - with CharSet"

:: Transform options
if "%/XREG%"=="." (set /XREG=%XREGEXP%)
if defined /X set "/XFILE=1" & set "/XSEQ=1"
if defined /MATCH set "/JMATCHQ=1"
if defined /JMATCHQ set "/JMATCH=1"
if defined /JMATCH set "/J=1"
if defined /JQ set "/J=1"
if "%/JMATCH%%/K%" equ "" set "/OFF=0"
if defined /UTF set "/UTF=//u" & set "/XFILE="
if not defined /T set "/L=1"
if "%/M%%/S%" neq "" set "/N=0"
if defined /HU (
  set "/H=1"
  set "/HON=\x1B[4m"
  set "/HOFF=\x1B[24m"
)
if defined /R set "/H="
if defined /RTN (
  setlocal enableDelayedExpansion
  for /f "eol=: delims=: tokens=1,2" %%A in ("!/RTN!") do (
    endlocal
    set "/RTN=%%A"
    set "/RTN_LINE=%%B"
  )
)

if defined /XBYTESOFF set "/XBYTES=" & goto :endXBytes
if defined /XBYTES set "/XBYTES=" & goto :createXBytes
for %%F in (
  "%ALLUSERSPROFILE%\JREPL\XBYTES.DAT"
  "%TEMP%\JREPL\XBYTES.DAT"
  "%TMP%\JREPL\XBYTES.DAT"
) do if "%%~zF" equ "256" set "/XBYTES=%%~fF" & goto :endXBytes

:createXBytes
:: Attempt to create XBYTES.DAT via CERTUTIL. If able to write to the JREPL
:: subdirectory, but unable to create correct file, then pass task to JScript.
for %%F in (
  "%ALLUSERSPROFILE%"
  "%TEMP%"
  "%TMP%"
) do if %%F neq "" for %%F in ("%%~F\JREPL\XBYTES.DAT") do (
  del %%F
  md "%%~dpF"
  (  >"%%~dpnF.HEX" (
    for %%A in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do for %%B in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do echo %%A%%B
  )) && (
    set "/XBYTES=%%~fF"
    certutil.exe -f -decodehex "%%~dpnF.HEX" "%%~fF"
    for %%G in (%%F) do if "%%~zG" neq "256" del %%F
    del "%%~dpnF.HEX"
    goto :endXBytes
  )
) >nul 2>nul
:endXBytes

set ^"/FIND=%1"
set ^"/REPL=%2"
call :GetScript /SCRIPT
set "/LOCK="

set "/FindReplVar="
if defined /UTF (
  set "/FindReplVar=1"
  set "/FIND2=%/FIND:"=%"
  set "/REPL2=%/REPL:"=%"
  set "/FIND=/FIND2"
  set "/REPL=/REPL2"
  goto :noLock
)
if defined /V if /i "%/T%" neq "FILE" set "/FindReplVar=1"
if defined /XFILE if /i "%/T%" neq "FILE" set "/FindReplVar=1"
if defined /RTN goto :lock
if not defined /XFILE goto :noLock
if defined /FindReplVar goto :lock
if not defined /JBEG if not defined /JBEGLN if not defined /JEND if not defined /JENDLN if not defined /INC if not defined /EXC if not defined /P if not defined /S goto :noLock

:lock
setlocal enableDelayedExpansion
set "/LOCK=jrepl.bat.!date:\=-!_!time::=.!_!random!.temp"
set "/LOCK=!/LOCK:/=-!"
for /f "delims=" %%F in ("!temp!\!/LOCK::=-!") do (
  endlocal
  set "/LOCK=%%~fF"
)
if defined /RTN (
  set "/CHCP="
  if not defined /XFILE for /f "tokens=2 delims=:." %%P in ('chcp') do (
    chcp 65001 >nul 2>nul && (
      set "/CHCP=%%P"
      chcp %%P >nul 2>nul
    )
  )
  if defined /CHCP (set "/O=%/LOCK%.RTN|utf-8|nb") else set "/O=%/LOCK%.RTN"
)
9>&2 2>nul (
  8>"%/LOCK%" (
    2>&9 (
      if defined /XFILE (
        setlocal enableDelayedExpansion
        if defined /S call :writeVar S
        if defined /V (
          if defined /FindReplVar (
            call :writeVar FIND
            call :writeVar REPL
          )
          if defined /JBEG   call :writeVar JBEG
          if defined /JBEGLN call :writeVar JBEGLN
          if defined /JEND   call :writeVar JEND
          if defined /JENDLN call :writeVar JENDLN
          if defined /INC    call :writeVar INC
          if defined /EXC    call :writeVar EXC
          if defined /P      call :writeVar P
        ) else (
          if defined /FindReplVar (
            (echo(!/FIND:^"=!) >"!/LOCK!.FIND"
            (echo(!/REPL:^"=!) >"!/LOCK!.REPL"
          )
          if defined /JBEG (echo(!/JBEG!) >"!/LOCK!.JBEG"
          if defined /JBEGLN (echo(!/JBEGLN!) >"!/LOCK!.JBEGLN"
          if defined /JEND (echo(!/JEND!) >"!/LOCK!.JEND"
          if defined /JENDLN (echo(!/JENDLN!) >"!/LOCK!.JENDLN"
          if defined /INC (echo(!/INC!) >"!/LOCK!.INC"
          if defined /EXC (echo(!/EXC!) >"!/LOCK!.EXC"
          if defined /P (echo(!/P!) >"!/LOCK!.P"
        )
        endlocal
      )
      call :execute
    )
  )
  if errorlevel 3 (del "%/LOCK%*"&exit /b 3)
  if errorlevel 1 (del "%/LOCK%*"&(call)) else del "%/LOCK%*"
  if "%/RTN%" equ "" exit /b
) || goto :lock

:writeVar
for /f delims^=^ eol^= %%A in ("!/%1!") do (echo(!%%A!) >"!/LOCK!.%1"
exit /b

:noLock
call :execute
exit /b %errorlevel%

:execute
cscript.exe //E:JScript //nologo %/UTF% "%/SCRIPT%" %/FIND% %/REPL%
if not defined /RTN exit /b %errorlevel%

::returnVar
if errorlevel 3 exit /b %errorlevel%
if defined /CHCP chcp 65001 >nul 2>nul
set "/ERR=%errorlevel%"
set "/NORMAL="
for /f "usebackq delims=" %%A in ("%/LOCK%.RTN") do (
  if not defined /NORMAL (
    set "/NORMAL=%%A"
  ) else set "/DELAYED=%%A"
)
chcp %/CHCP% >nul 2>nul
for /f %%2 in (
  'copy /z "%/SCRIPT%" nul' %= This generates CR =%
) do for %%1 in (^"^
%= This generates quoted LF =%
^") do for /f "tokens=1,2" %%3 in (^"%% "") do (
  (goto) 2>nul
  if "^!^" equ "^!" (
    set "%/RTN%=%/DELAYED:~1%"!
  ) else (
    set "%/RTN%=%/NORMAL:~1%"
  )
  if %/ERR% equ 0 (call ) else (call)
)

:GetScript
set "%1=%~f0"
exit /b

:help
setlocal
set "help=%~1"
setlocal enableDelayedExpansion
if "!help:~0,2!" neq "/?" exit /b 1
set "noMore=1"
set "help=!help:~2!"
if defined help if "!help:~0,1!" equ "?" (
  set "noMore="
  set "help=!help:~1!"
)
for /f "delims=" %%A in ("/!help!") do if /i "%%~pA" equ "\CharSet\" ( %= /?CHARSET/ =%
  echo(
  if defined noMore (
    for /f "delims=" %%F in ('reg query HKCR\MIME\Database\Charset /k /f "%%~nxA"') do echo %%~nF
  ) else (
    (cmd /c "for /f "delims=" %%F in ('reg query HKCR\MIME\Database\Charset /k /f "%%~nxA"') do @echo %%~nF") | more /e
  )
  exit /b 0
)
if defined help if "!help:~0,2!" equ "/?" set "help=help"
for /f "delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/ eol=a" %%A in ("!help!") do (
  echo(
  echo Invalid /? option
  exit /b 0
)
if /i "!help!" equ "regex" (
    explorer "https://msdn.microsoft.com/en-us/library/ae5bf541.aspx"
    exit /b 0
) else if /i "!help!" equ "replace" (
    explorer "https://msdn.microsoft.com/en-US/library/efy6s3e6.aspx"
    exit /b 0
) else if /i "!help!" equ "update" (
    explorer "http://www.dostips.com/forum/viewtopic.php?f=3&t=6044"
    exit /b 0
) else if /i "!help!" equ "charset" (
    explorer "https://msdn.microsoft.com/en-us/library/windows/desktop/dd317756.aspx"
    exit /b 0
) else if /i "!help!" equ "xregexp" (
    explorer "http:xregexp.com"
    exit /b 0
) else if "!help!" equ "" ( %= /? =%
    set "find=^:::(.*)"
    set "repl=$1"
    set ^"cmd="%~f0" find repl /v /a /f "%~f0"^"
) else if "!help:~0,1!" equ "/" (   %= /?/Option =%
    set "find=^:::(.*)"
    set "repl=$txt=$1"
    set "help=!help:/=\/!"
    set "inc=/^^::: {6}!help!(?= |$)/i/:/^^::: {6}\/(?^!!help:~2!(?= |$))|^^::\//i-1"
    set "help=!help:\/=/!"
    set ^"cmd=echo(^&call "%~f0" find repl /v /jmatchq /inc inc /f "%~f0"^|^|echo Help not found for option %help%^"
) else ( %= /?Topic =%
    set "find=^:::?(.*)"
    set "repl=$txt=$1"
    set "inc=/^^::\/!help:/=\/!$/i/+1:/^^::\//-1"
    set ^"cmd="%~f0" find repl /v /jmatchq /inc inc /f "%~f0"^|^|(echo(^&echo Help not found for topic %help%^)^"
)
if defined noMore (
  setlocal
  set "pathext=."
  call %cmd%
) else (%cmd%) | more /e
exit /b 0

:exitErr
>&2 (
  echo ERROR: %~1.
  echo   Use JREPL /? or JREPL /?? to get help.
  (goto) 2>nul
  exit /b 2
)

************* JScript portion **********/
var _g=new Object();
_g.loc='';
_g.objSh=WScript.CreateObject("WScript.Shell");
try {
  var env=_g.objSh.Environment("Process"),
      cnt,
      ln=0,
      skip=false,
      quit=false,
      fso,
      stdin=WScript.StdIn,
      stdout=WScript.Stdout,
      stderr=WScript.Stderr,
      output,
      input;
  if (env('/VT')!='') _g.objExec=_g.objSh.Exec("powershell.exe -nop -ep Bypass -c \"exit\"");
  _g.ForReading=1;
  _g.ForWriting=2;
  _g.ForAppending=8;
  _g.FileFormat = env('/UTF') ? -1 : 0;
  _g.TemporaryFolder=2;
  fso = new ActiveXObject("Scripting.FileSystemObject");
  _g.inFile=env('/F');
  _g.inFileA=_g.inFile.split('|');
  _g.outFile=env('/O');
  _g.outFileA=_g.outFile.split('|');
  if (_g.outFileA[0]=='-') {
    if (_g.outFileA[1]===undefined) {_g.outFileA[1]=_g.inFileA[1]; _g.outFileA[2]=_g.inFileA[2];}
    _g.outFile = _g.inFileA[0]+'.new'+(_g.outFileA[1]?'|'+_g.outFileA[1]:'')+(_g.outFileA[2]?'|'+_g.outFileA[2]:'');
    if (env('/APP')) fso.CopyFile( _g.inFileA[0], _g.inFileA[0]+'.new', true );
  }
  _g.tempFile='';
  _g.delim=env('/D');
  _g.term=env('/U')?'\n':'\r\n';

  _g.ADOStream = function( name, mode, format, noBom) {
    var that = this;
    var bomSize = 0;
    try {
      var stream = WScript.CreateObject("ADODB.Stream");
    } catch(ex) {
      throw new Error(215,'ADO unavailable');
    }
    try {
      stream.CharSet = format;
    } catch(ex) {
      throw new Error(215,'ADO character set "'+format+'" is invalid or unavailable');
    }
    stream.LineSeparator = (mode==_g.ForReading) ? 10 : -1;
    stream.Open();
    if (mode !== _g.ForReading && noBom) {
      stream.WriteText("");
      stream.Position = bomSize = stream.Size;
    }
    switch (mode) {
      case _g.ForReading:
        stream.LoadFromFile(name);
        break;
      case _g.ForAppending:
        stream.LoadFromFile(name);
        stream.Position = stream.Size;
      case _g.ForWriting:
        break;
      default:
        throw new Error(215, 'Invalid file mode');
    }
    this.AtEndOfStream = stream.EOS;

    this.ReadLine = function() {
      if (mode!=_g.ForReading) throw new Error(215, 'Bad file mode');
      var str = stream.ReadText(-2);
      that.AtEndOfStream = stream.EOS;
      return str.slice(-1)=='\r' ? str.slice(0,-1) : str;
    }

    this.Read = function(size) {
      if (mode!=_g.ForReading) throw new Error(215, 'Bad file mode');
      var str = stream.ReadText(size)
      that.AtEndOfStream = stream.EOS;
      return str;
    }

    this.SkipLine = function() {
      if (mode!=_g.ForReading) throw new Error(215, 'Bad file mode');
      stream.SkipLine();
      that.AtEndOfStream = stream.EOS;
    }

    this.Write = function(str) {
      if (mode==_g.ForReading) throw new Error(215, 'Bad file mode');
      stream.WriteText(str);
    }

    this.WriteLine = function(str) {
      if (mode==_g.ForReading) throw new Error(215, 'Bad file mode');
      stream.WriteText(str,1);
    }

    this.Close = function() {
      if (mode!==_g.ForReading){
        if (bomSize) {
          var noBomStream = WScript.CreateObject("ADODB.Stream");
          noBomStream.Type = 1;
          noBomStream.Mode = 3;
          noBomStream.Open();
          stream.Position = bomSize;
          stream.CopyTo(noBomStream);
          noBomStream.SaveToFile( name, 2 );
          noBomStream.Flush();
          noBomStream.Close();
          noBomStream = null;
        } else stream.SaveToFile( name, 2 );
      }
      stream.Close();
      stream=null;
    }
  }

  _g.openInput = function( fileName ) {
    var file;
    if (fileName) {
      file = fileName.split('|');
      if (file[1]) {
        file = new _g.ADOStream( file[0], _g.ForReading, file[1], file[2] );
        return file;
      }
      else return fso.OpenTextFile( fileName, _g.ForReading, false, _g.FileFormat );
    }
    else return stdin;
  }

  _g.charMap = new Object();
  _g.readVar = function( val, ref, ext ) {
    var input, buf=1024;
    if (!env('/XFILE') || !val) return (ref && val) ? env(val) : val;
    _g.loc=' reading '+env('/LOCK')+ext;
    input=fso.OpenTextFile( env('/LOCK')+ext, _g.ForReading );
    val='';
    while (!input.AtEndOfStream) {
      val+=input.Read(buf);
      buf*=2;
    }
    input.Close();
    _g.loc=''
    return val.slice(0,-2);
  }

  _g.xbytes = env('/XBYTES');
  if (_g.xbytes && !(fso.FileExists(_g.xbytes))) try {
    // Unable to create file with CERTUTIL, so now try with ADO
    var Stream=WScript.CreateObject('ADODB.Stream'),
        Node=WScript.CreateObject('Microsoft.XMLDOM').createElement('e');
    Node.dataType='bin.base64';
    Node.text='AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4v'
    + 'MDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5f'
    + 'YGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6P'
    + 'kJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/'
    + 'wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v'
    + '8PHy8/T19vf4+fr7/P3+/w==';
    Stream.Type=1;
    Stream.Open();
    Stream.Write(Node.nodeTypedValue);
    Stream.SaveToFile(_g.xbytes);
  } catch(e) {
    _g.xbytes = '';
  }
  var decode = _g.xbytes ?
    // Default dynamic character set decode() for v7.4 and beyond
    function(str, charSet, searchSwitch) {
      function u(codeUnit) {return '\\u'+lpad(codeUnit.toString(16),4,'0');}
      function xToUTF16(byte,charSet) {
        if (typeof _g.charMap[charSet]==='undefined') {
          if (charSet=='default' && _g.utf) {
            _g.charMap[charSet]=false
          } else {
            var stream = _g.openInput( _g.xbytes+(charSet=='default'?'':'|'+charSet) );
            try {
              _g.charMap[charSet] = stream.Read(256);
              stream.Close();
              if (_g.charMap[charSet].length!=256) _g.charMap[charSet]=false;
            } catch(e) {
              _g.charMap[charSet]=false;
            }
          }
        }
        return  u( _g.charMap[charSet] ? _g.charMap[charSet].charCodeAt(byte) : byte );
      }
      function xRange(min,max,charSet) {
        var str='', i;
        for (i=min; i<=max; i++ ) str+=xToUTF16(i,charSet);
        return str;
      }
      function uToUTF16(codePoint) {
        if (codePoint <= 0xFFFF) return u(codePoint);
        codePoint -= 0x10000;
        return u(0xD800|(codePoint>>10)) + u(0xDC00|(codePoint&1023));
      }
      if (charSet===undefined) charSet='default';
      if (charSet=='input') charSet = _g.inFileA[1] ? _g.inFileA[1] : 'default';
      if (charSet=='output') charSet = _g.outFileA[1] ? _g.outFileA[1] : 'default';
      return str.replace(
        /\\(?:\\|b|c|f|n|q|r|t|v|x([0-9a-fA-F]{2})|x\{([0-9a-fA-F]{2}),([^}]+)}|u[0-9a-fA-F]{4}|u\{([0-9a-fA-F]+)\}|x\{([0-9a-fA-F]{2})-([0-9a-fA-F]{2})(?:,([^}]+))?})/g,
        function($0,$1,$2,$3,$4,$5,$6,$7) {
          if ($0=='\\q') return '"';
          if ($0=='\\c') return '^';
          if ($1) $0=xToUTF16(parseInt($1,16),charSet);
          if ($2) $0=xToUTF16(parseInt($2,16),$3);
          if ($4) $0=uToUTF16(parseInt($4,16));
          if ($5) $0=xRange(parseInt($5,16),parseInt($6,16),($7?$7:charSet));
          return searchSwitch===false ? $0 : eval('"'+$0+'"');
        }
      );
    }
    : // Pre-v7.4 decode() that assumes Windows-1252, only used if XBYTES.DAT not available or disabled.
    function(str, ignore, searchSwitch) {
      function toUTF16(codePoint) {
        function u(codeUnit) {return '\\u'+lpad(codeUnit.toString(16),4,'0');}
        if (codePoint <= 0xFFFF) return u(codePoint);
        codePoint -= 0x10000;
        return u(0xD800|(codePoint>>10)) + u(0xDC00|(codePoint&1023));
      }
      str=str.replace(
        /\\(\\|b|c|f|n|q|r|t|v|x80|x82|x83|x84|x85|x86|x87|x88|x89|x8[aA]|x8[bB]|x8[cC]|x8[eE]|x91|x92|x93|x94|x95|x96|x97|x98|x99|x9[aA]|x9[bB]|x9[cC]|x9[dD]|x9[eE]|x9[fF]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|u\{([0-9a-fA-F]+)\}|x\{([0-9a-fA-F]{2}),[^}]+\})/g,
        function($0,$1,$2,$3) {
          if ($3) {
            $1='x'+$3;
            $0='\\'+$1;
          }
          switch ($1.toLowerCase()) {
            case 'q':   return '"';
            case 'c':   return '^';
            case 'x80': return '\u20AC';
            case 'x82': return '\u201A';
            case 'x83': return '\u0192';
            case 'x84': return '\u201E';
            case 'x85': return '\u2026';
            case 'x86': return '\u2020';
            case 'x87': return '\u2021';
            case 'x88': return '\u02C6';
            case 'x89': return '\u2030';
            case 'x8a': return '\u0160';
            case 'x8b': return '\u2039';
            case 'x8c': return '\u0152';
            case 'x8e': return '\u017D';
            case 'x91': return '\u2018';
            case 'x92': return '\u2019';
            case 'x93': return '\u201C';
            case 'x94': return '\u201D';
            case 'x95': return '\u2022';
            case 'x96': return '\u2013';
            case 'x97': return '\u2014';
            case 'x98': return '\u02DC';
            case 'x99': return '\u2122';
            case 'x9a': return '\u0161';
            case 'x9b': return '\u203A';
            case 'x9c': return '\u0153';
            case 'x9d': return '\u009D';
            case 'x9e': return '\u017E';
            case 'x9f': return '\u0178';
            default:    if ($2) $0=toUTF16(parseInt($2,16));
                        return searchSwitch===false ? $0 : eval('"'+$0+'"');
          }
        }
      );
      return str;
    }
  ;

  _g.getCount = function() {
    if (cnt>=0) return;
    cnt=0;
    if (_g.inFile=='') {
      _g.tempFile=fso.GetSpecialFolder(_g.TemporaryFolder).path+'\\'+fso.GetTempName();
      _g.inFile=_g.tempFile;
      var output=fso.OpenTextFile(_g.tempFile,_g.ForWriting,true,_g.FileFormat);
      while (!input.AtEndOfStream) {
        output.WriteLine(input.ReadLine());
        cnt++
      }
      output.Close();
    } else {
      while (!input.AtEndOfStream) {
        input.SkipLine();
        cnt++;
      }
      input.Close();
    }
    input = _g.openInput(_g.inFile);
  }

  _g.loc=' opening input file';
  input = _g.openInput(_g.inFile);
  _g.loc='';

  if (env('/C')) _g.getCount();

  openOutput( _g.outFile, env('/APP'), _g.FileFormat );

  if (env('/XREG')) {
    _g.loc=' while loading /XREG library';
    _g.libs=env('/XREG').split('/');
    for (_g.i=0; _g.i<_g.libs.length; _g.i++) {
      _g.lib=fso.OpenTextFile(_g.libs[_g.i],_g.ForReading);
      if (!_g.lib.AtEndOfStream) eval(_g.lib.ReadAll());
      _g.lib.Close();
    }
    _g.loc=' while initializing /XREG library';
    _g.newRegExp = function(pattern,flags){ return new XRegExp(pattern,flags); }
    XRegExp.install('natives');
    _g.loc='';
    _g.XRegExp = true;
  } else {
    _g.newRegExp = function(pattern,flags){ return new RegExp(pattern,flags); }  
    _g.XRegExp = false;
  }  

  if (env('/JLIB')) {
    _g.loc=' while loading /JLIB code';
    _g.libs=env('/JLIB').split('/');
    for (_g.i=0; _g.i<_g.libs.length; _g.i++) {
      _g.lib=fso.OpenTextFile(_g.libs[_g.i],_g.ForReading);
      if (!_g.lib.AtEndOfStream) eval(_g.lib.ReadAll());
      _g.lib.Close();
    }
    _g.loc='';
  }

  _g.loc=' in /JBEG code';
  eval( _g.readVar( env('/JBEG'), env('/V'), '.JBEG' ) );
  _g.loc='';

  _g.defineObjectInternal=function(){
    _g.loc=' while defining '+_g.defineObjectObj;
    eval(_g.defineObjectStr);
    _g.loc='';
  }
  _g.defineObject=function(str,obj) {
    _g.defineObjectStr=str;
    _g.defineObjectObj=obj;
    _g.defineObjectInternal();
  }

  _g.main=function() {
    _g.rtn=1;
    var args=WScript.Arguments;
    var search =  env('/FindReplVar') ? _g.readVar( args.Item(0), env('/V')||env('/UTF'), '.FIND' ) : args.Item(0);
    var replace = env('/FindReplVar') ? _g.readVar( args.Item(1), env('/V')||env('/UTF'), '.REPL' ) : args.Item(1);
    var hiLite=env('/H')!='';
    var hiLiteOn=eval('"'+env('/HON')+'"');
    var hiLiteOff=eval('"'+env('/HOFF')+'"');
    var multi=env('/M')!='';
    var literal=env('/L')!='';
    var alterations=env('/A')!='';
    var srcVar=env('/S');
    var jexpr=env('/J')!='';
    var jmatch=env('/JMATCH')!='';
    var jmatchq=env('/JMATCHQ')!='';
    var jquick=env('/JQ')!='';
    var translate=env('/T');
    var filter = _g.readVar( env('/P'), env('/V'), '.P' );
    var keep, reject, context, krfile=false;
    var rtnVar=env('/RTN');
    if (reject=env('/R')) {
      if (!/^\d+(:\d+)?(:FILE)?$/i.test(reject)) throw new Error(209, 'Invalid /R Context');
      context = reject.toUpperCase().split(':')
      krfile=(context[context.length-1]=='FILE');
      context[0]=Number(context[0]);
      context[1]=(context.length==1 || context[1]=='FILE')?context[0]:Number(context[1]);
    }
    if (keep=env('/K')) {
      if (!/^\d+(:\d+)?(:FILE)?$/i.test(keep)) throw new Error(208, 'Invalid /K Context');
      context = keep.toUpperCase().split(':')
      krfile=(context[context.length-1]=='FILE');
      context[0]=Number(context[0]);
      context[1]=(context.length==1 || context[1]=='FILE')?context[0]:Number(context[1]);
    }
    var options = (keep||reject)?"":"g";
    _g.begLn = _g.readVar( env('/JBEGLN'), env('/V'), '.JBEGLN' );
    _g.endLn = _g.readVar( env('/JENDLN'), env('/V'), '.JENDLN' );

    _g.incBlock = new Array();
    _g.excBlock = new Array();
    _g.incBlock.dynamic = false;
    _g.excBlock.dynamic = false;
    var blockMatch,
        blockSearch = /(?:(-?\d+)|(?:\/((?:\\\/|[^/])+)\/|'((?:''|[^'])+)')([ibe]*)(\/)?)([+-]\d+)?(:(?:(-?\d+)|(\+\d+)|(?:\/((?:\\\/|[^/])+)\/|'((?:''|[^'])+)')([ibe]*))([+-]\d+)?)?(?:,(?=.)|$)?|(.+)/g;
    /*                    1            2                   3               4       5     6         7    8       9            1                   1               1        1                         1
                                                                                                                             0                   1               2        3                         4
        line or range begin
          spec
            1 = line number
            2 = regex
              4 = i|b|e flags
              5 = singleton
            3 = string
              4 = i|b|e flags
              5 = singleton
          6 = offset
        7 = range end
          spec
            8 = line number
            9 = offset from range begin
            10 = regex
              12 = i|b|e flags
            11 = string
              12 = i|b|e flags
          13 = offset
        14 = error
    */
    _g.Block = function(match) {
      if (match[14]) throw new Error(210, 'Invalid block syntax');
      this.offset=match[6]?Number(match[6]):0;
      if (match[1]) {
        this.type='lineNum';
        if ((this.spec=Number(match[1])) < 0) _g.getCount();
        this.lineNum=this.spec+this.offset+(this.spec<0?cnt+1:0);
      } else {
        this.type='regex';
        this.spec=_g.newRegExp( (match[4].search('b')+1?'^':'') + (
            match[2] ? decode(match[2],'input',false) :
            decode(match[3].replace(/''/g,"'"),'input',true).replace(/([.^$*+?()[{\\|])/g,"\\$1")
          ) + (match[4].search('e')+1?'$':''),
          match[4].search('i')+1?'i':''
        );
        this.spec.singleton=match[5]?true:false;
        this.lineNum=void 0;
        if (this.offset<0) throw new Error(211, 'Regex/String offset cannot be negative');
      }
      if (match[7]) {
        this.endOffset=Number(match[13]);
        if (match[8]) {
          this.endType='lineNum';
          if ((this.endSpec=Number(match[8])) < 0) _g.getCount();
          this.endLineNum=this.endSpec+this.endOffset+(this.endSpec<0?cnt+1:0);
        } else if (match[9]) {
          this.endType='offset';
          this.endSpec=Number(match[9]);
          this.endLineNum=this.lineNum+this.endSpec+this.endOffset;
        } else {
          this.endType='regex';
          this.endSpec=_g.newRegExp( (match[12].search('b')+1?'^':'') + (
              match[10] ? decode(match[10],'input',false) :
              decode(match[11].replace(/''/g,"'"),'input',true).replace(/([.^$*+?()[{\\|])/g,"\\$1")
            ) + (match[12].search('e')+1?'$':''),
            match[12].search('i')+1?'i':''
          );
          this.endLineNum=void 0;
          if (this.endOffset<-1) throw new Error(212, 'End-range Regex/String offset cannot be less than -1');
        }
      } else {
         this.endType=void 0;
         this.endSpec=void 0;
         this.endLineNum=this.lineNum;
      }
    }
    _g.setBlocks = function(blocks,str) {
      if (blocks.dynamic==true) {
        for (var i=0; i<blocks.length; i++) {
          var block = blocks[i];
          if (ln>block.endLineNum && block.type=='regex' && !block.spec.singleton)
            block.lineNum=block.endLineNum=void 0;
          if (!block.lineNum && block.spec.test(str)) {
            block.lineNum = ln+block.offset;
            if (!block.endLineNum) {
              if (!block.endType)
                block.endLineNum=block.lineNum;
              else if (block.endType=='offset')
                block.endLineNum=block.lineNum+block.endSpec+block.endOffset;
            }
          }
          if (!block.endLineNum && ln>block.lineNum && block.endSpec.test(str))
            block.endLineNum = ln+block.endOffset;
        }
      }
    }
    var str = _g.readVar( env('/INC'), env('/V'), '.INC' );
    while ( (blockMatch=blockSearch.exec(str)) !== null ) {
      _g.loc=' while parsing /INC block['+_g.incBlock.length+']';
      var block = new _g.Block(blockMatch);
      _g.incBlock.dynamic=(_g.incBlock.dynamic || block.type=='regex' || block.endType=='regex');
      _g.incBlock.push(block);
    }
    str = _g.readVar( env('/EXC'), env('/V'), '.EXC' );
    while ( (blockMatch=blockSearch.exec(str)) !== null ) {
      _g.loc=' while parsing /EXC block['+_g.excBlock.length+']';
      var block = new _g.Block(blockMatch);
      _g.excBlock.dynamic=(_g.excBlock.dynamic || block.type=='regex' || block.endType=='regex');
      _g.excBlock.push(new _g.Block(blockMatch));
    }
    _g.loc='';

    if (multi) options+='m';
    if (env('/MATCH')) replace='$txt=$0';
    if (_g.begLn) _g.defineObject("_g.begLn=function($txt){_g.loc=' in /JBEGLN code';"+_g.begLn+";_g.loc='';return $txt;}",'/JBEGLN code');
    if (_g.endLn) _g.defineObject("_g.endLn=function($txt){_g.loc=' in /JENDLN code';"+_g.endLn+";_g.loc='';return $txt;}",'/JENDLN code');
    if (env('/I')) options+='i';

    var lnWidth=parseInt(env('/N'),10),
        offWidth=parseInt(env('/OFF'),10);
    if (lnWidth<0) lnWidth = 0;
    if (offWidth<0) offWidth = 0;
    _g.lnPrefix=lnWidth>0;
    _g.offPrefix=offWidth>0;
    var lnPad=lnWidth>0?'"'+(Array(lnWidth+1).join('0'))+'"':'',
        offPad=offWidth>0?'"'+(Array(offWidth+1).join('0'))+'"':'',
        xcnt=0, test,
        filterMatchOffset = offWidth>0&&filter!='' ? '+_g.filterMatchOffset' : '';

    function writeMatch(str,ln,lnPad,off,offPad) {
      return 'if('+str+'!==false){_g.rtn=0;output.Write('
           + (lnWidth==0 ? '' : 'lpad('+ln+','+lnPad+')+_g.delim+')
           + (offWidth==0 ? '' : 'lpad('+off+','+offPad+')+_g.delim+')
           + str+'+_g.term);}';
    }

    if (env('/VT')!='') while (_g.objExec.Status == 0) WScript.Sleep(50);

    if (translate=='none') {  // Normal
      if (hiLite && (keep||reject)) options+='g';
      if (krfile) { // Load KEEP or REJECT File
        _g.loc=' loading '+(keep?'/K':'/R')+' Search file';
        var f = _g.openInput(search);
        search='';
        while (!f.AtEndOfStream) {
          str=f.ReadLine();
          if (env('/XSEQ')) str=decode(str,'input',literal);
          if (literal) str=str.replace(/([.^$*+?()[{\\|])/g,"\\$1");
          if (env('/B')) str="^"+str;
          if (env('/E')) str=str+"$";
          search+=(search?'|':'')+str;
        }
        f.Close();
      } else { // Load Normal Search
        if (env('/XSEQ')) {
          if (!jexpr) replace=decode(replace,'output');
          search=decode(search,'input',literal);
        }
        if (literal) {
          search=search.replace(/([.^$*+?()[{\\|])/g,"\\$1");
          if (!jexpr) replace=replace.replace(/\$/g,"$$$$");
        }
        if (env('/B')) search="^"+search;
        if (env('/E')) search=search+"$";
        _g.loc=' in Search regular expression';
      }
      search=_g.newRegExp(search,options);
      _g.loc='';
      if (keep||reject){
        jquick=jexpr=(hiLite || filter!='');
        replace = jquick ? '$txt=$0;if(_g.matchOffset==null)_g.matchOffset=$off'+filterMatchOffset+';' : '$&';
      }
      if (jexpr) {
        _g.loc=' in Search regular expression';
        test=_g.newRegExp('.|'+search,options);
        _g.loc='';
        'x'.replace(test,function(){xcnt=arguments.length-2; return '';});
        _g.replFunc='_g.replFunc=function($0';
        for (var i=1; i<xcnt; i++) _g.replFunc+=',$'+i;
        _g.replFunc+=',$off,$src){_g.loc=" in Replace code";';
        if (jquick||jmatchq) {
          _g.replFunc+='var $txt;'+replace+';';
          if (hiLite) _g.replFunc+='$txt="'+hiLiteOn+'"+$txt+"'+hiLiteOff+'";';
          _g.replFunc+=
            jmatch ? writeMatch('$txt','ln',lnPad,'$off'+filterMatchOffset,offPad)+'_g.loc="";return $0;}'
                   : '_g.loc="";return $txt;}';
        } else {
          var jstr = 'eval(_g.replace)';
          if (hiLite) jstr = '"'+hiLiteOn+'"+'+jstr+'+"'+hiLiteOff+'"';
          _g.replFunc+=
            jmatch ? writeMatch(jstr,'ln',lnPad,'$off'+filterMatchOffset,offPad)+'_g.loc="";return $0;}'
                   : '_g.rtn2='+jstr+';_g.loc="";return _g.rtn2;}';
        }
        _g.defineObject(_g.replFunc,'/J or /JMATCH code');
        _g.replace = replace;
      } else {
        _g.replace = hiLite ? hiLiteOn + replace + hiLiteOff : replace;
      }
    } else {                         // /T
      if (translate.toLowerCase()=='file') {
        var f
        _g.loc=' loading /T Search file';
        f = _g.openInput(search);
        search=[];
        while (!f.AtEndOfStream) search[search.length]=f.ReadLine();
        f.Close();
        _g.loc=' loading /T Replace file';
        f = _g.openInput(replace);
        replace=[];
        while (!f.AtEndOfStream) replace[replace.length]=f.ReadLine();
        f.Close();
        _g.loc='';
      } else {
        if (translate.length>1) throw new Error(203, 'Invalid /T delimiter');
        if (translate.length==0 && env('/XSEQ')) {
          search=decode(search,'input',literal);
          replace=decode(replace,'output');
        }
        search=search.split(translate);
        var replace=replace.split(translate);
      }
      if (search.length>99 && !_g.XRegExp) throw new Error(202, '/T expression count exceeds 99');
      if (search.length!=replace.length) throw new Error(201, 'Mismatched search and replace /T expressions');
      var j=1;
      if (!jexpr) jquick=1;
      if (jquick) _g.replace='';
      else _g.replace=[];
      for (var i=0; i<search.length; i++) {
        if (env('/XSEQ')) search[i]=decode(search[i],'input',literal);
        if (literal) {
          search[i]=search[i].replace(/([.^$*+?()[{\\|])/g,"\\$1");
        } else {
          _g.loc=' in Search regular expression';
          test=_g.newRegExp('.|'+search[i],options+(_g.XRegExp?env('/TFLAG'):''));
          _g.loc='';
          'x'.replace(test,function(){xcnt=arguments.length-3;return '';});
        }
        if (j+xcnt>99 && !_g.XRegExp) throw new Error(202, '/T expressions + captured expressions exceeds 99');
        if (env('/B')) search[i]="^"+search[i];
        if (env('/E')) search[i]=search[i]+"$";
        if (_g.XRegExp) search[i]="?<T"+i+">"+search[i];
        if (jquick|jmatchq) {
          if (!jexpr) {
            replace[i]="'" + (env('/XSEQ')==''?replace[i]:decode(replace[i],'output')).replace(/[\\']/g,"\\$&") + "'";
            replace[i]=replace[i].replace(/\n/g, "\\n");
            replace[i]=replace[i].replace(/\r/g, "\\r");
            if (!literal) {
              if (_g.XRegExp) {
                replace[i]='$txt='+replace[i].replace(
                  /\$([$&`0]|\\'|\{0\}|(\d)(\d)?|\{((\d)(\d)?)\}|\{([^}]+)\})/g,
                  function($0,$1,$2,$3,$4,$5,$6,$7){
                    return ($1=="$") ? "$":
                           ($1=="&" || $1=="0" || $1=="{0}") ? "'+$0+'":
                           ($1=="`") ? "'+$src.substr(0,$off)+'":
                           ($1=="\\'") ? "'+$src.substr($off+$0.length)+'":
                           ($7) ? "'+$0."+$7+"+'":
                           (Number($1)-j<=xcnt && Number($1)>=j) ? "'+"+$0+"+'":
                           (Number($2)-j<=xcnt && Number($2)>=j) ? "'+$"+$2+"+'"+$3:
                           (Number($4)-j<=xcnt && Number($4)>=j) ? "'+$"+$4+"+'":
                           (Number($5)-j<=xcnt && Number($5)>=j) ? "'+$"+$5+"+'"+$6:
                           $0;
                  }
                );
              } else {
                replace[i]='$txt='+replace[i].replace(
                  /\$([$&`0]|\\'|(\d)(\d)?)/g,
                  function($0,$1,$2,$3){
                    return ($1=="$") ? "$":
                           ($1=="&") ? "'+$0+'":
                           ($1=="`") ? "'+$src.substr(0,$off)+'":
                           ($1=="\\'") ? "'+$src.substr($off+$0.length)+'":
                           (Number($1)-j<=xcnt && Number($1)>=j) ? "'+"+$0+"+'":
                           (Number($2)-j<=xcnt && Number($2)>=j) ? "'+$"+$2+"+'"+$3:
                           $0;
                  }
                );
              }
            } else replace[i]='$txt='+replace[i];
          }
          _g.replace+='if(arguments['+j+']!==undefined){'+replace[i]+';}';
        } else {
          _g.replace[j]=replace[i];
        }
        j+=xcnt+1;
      }
      search='('+search.join(')|(')+')';
      _g.loc=' in Search regular expression';
      search=_g.newRegExp( search, options+(_g.XRegExp?env('/TFLAG'):'') );
      _g.loc='';
      _g.replFunc='_g.replFunc=function($0';
      for (var i=1; i<j; i++) _g.replFunc+=',$'+i;
      _g.replFunc+=',$off,$src){_g.loc=" in Replace code";';
      if (jquick||jmatchq) {
        _g.replFunc+='var $txt;'+_g.replace;
        if (hiLite) _g.replFunc+='$txt="'+hiLiteOn+'"+$txt+"'+hiLiteOff+'";';
        _g.replFunc+=(
           jmatch ? writeMatch('$txt','ln',lnPad,'$off'+filterMatchOffset,offPad)+'_g.loc="";return $0;}'
                  : '_g.loc="";return $txt;}' );
      } else {
        var jstr = 'eval(_g.replace[_g.i])';
        if (hiLite) jstr = '"'+hiLiteOn+'"+'+jstr+'+"'+hiLiteOff+'"';
        _g.replFunc+='for(_g.i=1;_g.i<arguments.length-2;_g.i++)if(arguments[_g.i]!==undefined)'+ (
           jmatch ? writeMatch(jstr,'ln',lnPad,'$off'+filterMatchOffset,offPad)+'_g.loc="";return $0;}'
                  : '{_g.rtn2='+jstr+';_g.loc="";return _g.rtn2;}}' );
      }
      _g.defineObject(_g.replFunc,'/J or /JMATCH code');
      jexpr=true;
    }

    var str1, str2;
    var repl=jexpr?_g.replFunc:_g.replace;

    if (filter!='') {
      if (env('/PREPL')) {
        _g.defineObject(
          '_g.filterReplace=function(){ return '
            + env('/PREPL').replace(/\$(\d+)/g,'arguments[$1]')
            .replace(/{([^}]*)}/g,'($1).replace(_g.search,_g.filterReplace2)')
            +';}'
          ,'/PREPL'
        );
      } else if (offWidth>0) {
        _g.filterReplace=function(str) {
          _g.filterMatchOffset = arguments[arguments.length-2];
          return str.replace(_g.search,_g.filterReplace2);
        }
      } else {
        _g.filterReplace=function(str) {
          return str.replace(_g.search,_g.filterReplace2);
        }
      }
      _g.loc=' in /P FilterRegex';
      filter = _g.newRegExp( decode(filter,'input',false), env('/PFLAG').toLowerCase()+(env('/M')?'m':'') );
      _g.loc='';
      _g.search=search;
      search=filter;
      _g.filterReplace2=repl;
      repl=_g.filterReplace;
    }

    if (srcVar) {
      str1=_g.readVar( srcVar, srcVar, '.S' );
      str2=str1.replace(search,repl);
      if (str1!=str2) _g.rtn=0;
      if (!jmatch && (!alterations || str1!=str2)) output.Write(str2+(multi?'':_g.term));
    } else if (multi){
      var buf=1024;
      str1="";
      while (!input.AtEndOfStream) {
        str1+=input.Read(buf);
        buf*=2;
      }
      str2=str1.replace(search,repl);
      if (!jmatch) output.Write(str2);
      if (str1!=str2) _g.rtn=0;
    } else if (keep||reject){
      var match, arr, filterResult, post, pre=new Array();
      var cmd='while(!input.AtEndOfStream&&!quit){str1=input.ReadLine();';
      if ( _g.incBlock.length || _g.excBlock.length || lnWidth
           || _g.begLn || _g.endLn || env(env('/V')?env('/JEND'):'/JEND')
         ) cmd+='ln++;';
      if (_g.incBlock.dynamic) cmd+='_g.setBlocks(_g.incBlock,str1);';
      if (_g.excBlock.dynamic) cmd+='_g.setBlocks(_g.excBlock,str1);';
      if (_g.begLn) cmd+='str1=_g.begLn(str1);';
      if (jquick) cmd+='_g.matchOffset=null;';
      str1='';str2='if(';
      if (_g.incBlock.length) {str1+=str2+'inc()';str2='&&';}
      if (_g.excBlock.length) {str1+=str2+'!exc()';str2='&&';}
      if (_g.begLn||_g.endLn||jexpr||env(env('/V')?env('/JBEG'):'/JBEG')) {str1+=str2+'!skip';}
      if (str1) cmd+=str1+')';
      if (jquick) {
        cmd+='{str1=str1.replace(search,repl);match=_g.matchOffset!=null?!reject:reject;}';
      } else {
        cmd+='if ((arr=search.exec(str1))!==null){match=!reject;_g.matchOffset=arr.index}else match=reject;';
      }
      if (_g.endLn) cmd += 'str1=_g.endLn(str1);';
      cmd+='if (str1!==false && match) {_g.rtn=0;';
      if (context[0]) cmd+='while(pre.length){str2=pre.pop();'+writeMatch('str2','ln-pre.length-1',lnPad,'""',offWidth)+'}';
      cmd+=writeMatch('str1','ln',lnPad,'_g.matchOffset',offPad);
      if (context[1]) cmd+='post=context[1];}else if(post-->0){'+writeMatch('str1','ln',lnPad,'""',offWidth);
      if (context[0]) cmd+='}else{pre.unshift(str1);if(pre.length>context[0])pre.pop();';
      cmd+='}}';
      eval(cmd);
    } else {
      var cmd='while(!input.AtEndOfStream&&!quit){str2=str1=input.ReadLine();';
      if ( _g.incBlock.length || _g.excBlock.length || lnWidth
           || _g.begLn || _g.endLn|| jexpr || env(env('/V')?env('/JEND'):'/JEND')
         ) cmd+='ln++;';
      if (_g.incBlock.dynamic) cmd+='_g.setBlocks(_g.incBlock,str2);';
      if (_g.excBlock.dynamic) cmd+='_g.setBlocks(_g.excBlock,str2);';
      if (_g.begLn) cmd+='str2=_g.begLn(str2);';
      str1='';str2='if(';
      if (_g.incBlock.length) {str1+=str2+'inc()';str2='&&';}
      if (_g.excBlock.length) {str1+=str2+'!exc()';str2='&&';}
      if (_g.begLn||_g.endLn||jexpr||env(env('/V')?env('/JBEG'):'/JBEG')) {str1+=str2+'!skip';}
      if (str1) cmd+=str1+')';
      cmd+='str2=str2.replace(search,repl);';
      if (_g.endLn) cmd+='str2=_g.endLn(str2);';
      if (!jmatch) {
        str1='';str2='if(';
        if (_g.endLn||jexpr) {str1+=str2+'str2!==false';str2='&&';}
        if (alterations) {str1+=str2+'str1!=str2';}
        if (str1) cmd+=str1+')';
        cmd+='output.Write('+(lnWidth>0?'lpad(ln,'+lnPad+')+_g.delim+':'')+'str2+_g.term);';
        cmd+='if (str1!=str2) _g.rtn=0;';
      }
      cmd+='}'
      eval(cmd);
    }
  }

  _g.main();

  _g.loc=' in /JEND code';
  eval( _g.readVar( env('/JEND'), env('/V'), '.JEND' ) );
  _g.loc='';
  if (_g.inFile) input.Close();
  if (_g.outFile) output.Close();
  if (_g.outFileA[0]=='-') {
    fso.GetFile(_g.inFileA[0]).Delete();
    fso.GetFile(_g.inFileA[0]+'.new').Move(_g.inFileA[0]);
  }
  if (_g.tempFile) fso.GetFile(_g.tempFile).Delete();

  if (env('/RTN')) {
    _g.rtnVar = function() {
      var val, str1, str2, buf=1024, arr, n;
      input=_g.openInput(_g.outFile)
      val='';
      while (!input.AtEndOfStream) {
        val+=input.Read(buf);
        buf*=2;
      }
      input.Close();
      if (env('/RTN_LINE')&&(n=parseInt(env('/RTN_LINE')))) {
        arr=val.split(/\r?\n/);
        n = n>0 ? n-1 : arr.length+n;
        val = typeof arr[n]==='undefined' ? '' : arr[n];
      } else if ((env('/MATCH')||env('/JMATCH')||env('/JMATCHQ'))&&val.slice(-_g.term.length)===_g.term){
        val=val.slice(0,-_g.term.length);
      }
      output=null;
      openOutput(_g.outFile, "", 0 );
      str1='x'+val.replace(/%/g,'%3').replace(/\n/mg,'%~1').replace(/\r/mg,'%2').replace(/"/g,'%4');
      str2=str1.replace(/[!^]/g,'^$&');
      if (str2.length + env('/RTN').length > 8181) throw new Error(213, 'Result too long to fit within variable');
      if (str2.indexOf('\x00')>=0) throw new Error(214, 'Null bytes (0x00) cannot be returned in a variable');
      output.WriteLine(str1);
      output.WriteLine(str2);
      output.Close();
    }
    _g.rtnVar();
  }

  WScript.Quit(_g.rtn);
} catch(e) {
  WScript.Stderr.WriteLine("JScript runtime error"+_g.loc+": "+e.message);
  WScript.Quit(3);
}

function lpad( val, arg2, arg3 ) {
  var rtn=val.toString(), len, pad, cnt;
  if (typeof arg2 === "string") {
    pad = arg2;
    len = arg2.length;
  } else {
    len = arg2;
    pad = arg3 ? arg3 : '                                                  ';
    while (pad.length < len) pad+=pad;
  }
  return (rtn.length<len) ? pad.slice(0,len-rtn.length)+rtn : rtn;
}

function rpad( val, arg2, arg3 ) {
  var rtn=val.toString(), len, pad, cnt;
  if (typeof arg2 === "string") {
    pad = arg2;
    len = arg2.length;
  } else {
    len = arg2;
    pad = typeof arg3 === "string" ? arg3 : '                                                  ';
    while (pad.length < len) pad+=pad;
  }
  return (rtn.length<pad.length) ? rtn+pad.slice(rtn.length-len) : rtn;
}

function inc(n) {
  for (var i=n?n:0, end=n?n+1:_g.incBlock.length; i<end; i++) {
    var block = _g.incBlock[i];
    if (ln>=block.lineNum && ln<=(block.endLineNum?block.endLineNum:ln)) return true;
  }
  return (_g.incBlock.length==0);
}

function exc(n) {
  for (var i=n?n:0, end=n?n+1:_g.excBlock.length; i<end; i++) {
    var block = _g.excBlock[i];
    if (ln>=block.lineNum && ln<=(block.endLineNum?block.endLineNum:ln)) return true;
  }
  return false;
}

function openOutput( fileName, append, utf ) {
  _g.loc=' opening output file';
  if (output && output!==stdout) output.Close();
  if (fileName) {
    var file = fileName.split('|');
    if (file[1]) output=new _g.ADOStream( file[0], append?_g.ForAppending:_g.ForWriting, file[1], file[2] );
    else output=fso.OpenTextFile( fileName, append?_g.ForAppending:_g.ForWriting, true, utf?-1:0 );
  }
  else output=stdout;
  _g.loc='';
}
