@echo OFF 
setlocal
PATH=%PATH%;c:\Windows\Microsoft.NET\Framework\v4.0.30319
PATH=%PATH%;C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
call mstest.exe /testcontainer:Sample\bin\Debug\Sample.dll