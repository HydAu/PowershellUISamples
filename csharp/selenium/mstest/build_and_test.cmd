PATH=%PATH%;c:\Windows\Microsoft.NET\Framework\v4.0.30319
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE

FOR /F "TOKENS=*" %%. in ('dir /b/ad "%USERNAME%_%COMPUTERNAME%*"') DO @echo %%. & start cmd /c rd /s/q "%%."
msbuild.exe mstest.sln /t:clean,build /p:Configuration=Debug /p:Platform="Any CPU"

rem goto :EOF
set CONSOLE_LOG=console.log
SET category=US

copy NUL %CONSOLE_LOG%  
echo >>%CONSOLE_LOG%  "Deleting the  results.trx"
del /q %CD%\results.%CATEGORY%.trx
del /q %CD%\results.trx
echo >>%CONSOLE_LOG% "start the test" 

mstest.exe /category:%CATEGORY% /testcontainer:Sample\bin\Debug\Sample.dll /resultsfile:%CD%\results.%CATEGORY%.trx
echo >>%CONSOLE_LOG% "finished the test"
GOTO :EOF

