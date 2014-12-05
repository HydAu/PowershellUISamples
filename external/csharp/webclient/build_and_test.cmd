@echo OFF 
PATH=%PATH%;c:\Windows\Microsoft.NET\Framework\v4.0.30319
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE

FOR /F "TOKENS=*" %%. in ('dir /b/ad "%USERNAME%_%COMPUTERNAME%*"') DO @echo %%. & start cmd /c rd /s/q "%%."

SET CATEGORY=%1
for %%C in (1 2 3 ) do @copy /y  Sample\App%%C.config Sample\App.config   && call :DO_WORK First %CATEGORY% %%C
goto :EOF 

:DO_WORK

echo %*
SET IGNORED_ARG=%1
SET CATEGORY=%2
set BROWSER=%3

REM type Sample\App%BROWSER%.config
type Sample\App%BROWSER%.config
echo CATEGORY=%CATEGORY%
echo BROWSER=%BROWSER%

REM the dependency on App.config does not trigger
del /s/q Sample.dll
call msbuild.exe mstest.sln /t:clean  /p:Configuration=Debug /p:Platform="Any CPU"


call msbuild.exe mstest.sln /t:build /p:Configuration=Debug /p:Platform="Any CPU"
dir Sample\bin\Debug\Sample.dll
CHOICE /T 45 /C ync /CS /D y

GOTO :eof

set CONSOLE_LOG=console.log

copy NUL %CONSOLE_LOG%  
echo >>%CONSOLE_LOG%  "Deleting the  results.trx"
del /q %CD%\results.%CATEGORY%_%BROWSER%.trx
del /q %CD%\results.trx
echo >>%CONSOLE_LOG% "start the test" 

mstest.exe /CATEGORY:%CATEGORY% /testcontainer:Sample\bin\Debug\Sample.dll /resultsfile:%CD%\results.%CATEGORY%_%BROWSER%.trx
echo >>%CONSOLE_LOG% "finished the test"
CHOICE /T 1 /C ync /CS /D y
copy /y %CD%\results.%CATEGORY%_%BROWSER%.trx C:\mstest_logs
GOTO :EOF

