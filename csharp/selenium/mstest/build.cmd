@echo OFF 
setlocal
PATH=%PATH%;c:\Windows\Microsoft.NET\Framework\v4.0.30319
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
PATH=%PATH%;D:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE


del /s/q Sample.dll
call msbuild.exe mstest.sln /t:clean  /p:Configuration=Debug /p:Platform="Any CPU"


call msbuild.exe mstest.sln /t:build /p:Configuration=Debug /p:Platform="Any CPU"
