REM This runs 
REM 
set FINAL_LOG_SHARE=c:\MSTEST_LOGS
PATH=%PATH%;c:\Windows\Microsoft.NET\Framework\v4.0.30319
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE


SET CONSOLE_LOG=console.log
SET CATEGORY=%1
IF "%CATEGORY%" == "" SET CATEGORY=US
copy NUL %CONSOLE_LOG%  
echo >>%CONSOLE_LOG%  "Delete old  results"

del /q %CD%\results.%CATEGORY%.trx
del /q %CD%\results.trx
REM Remove old result directories 
FOR /F "TOKENS=*" %%. in ('dir /b/ad "%USERNAME%_%COMPUTERNAME%*"') DO @echo %%. & start cmd /c rd /s/q "%%."

echo >>%CONSOLE_LOG% "start the test" 

mstest.exe /category:%CATEGORY% /testcontainer:Sample\bin\Debug\Sample.dll /resultsfile:%CD%\results.%CATEGORY%.trx
echo >>%CONSOLE_LOG% "Copy the results to %FINAL_LOG_SHARE%"
copy /y %CD%\results.%CATEGORY%.trx %FINAL_LOG_SHARE%

echo >>%CONSOLE_LOG% "Finished the test for %CATEGORY%"
GOTO :EOF

