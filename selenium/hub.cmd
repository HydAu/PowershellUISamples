@echo OFF
pushd %~dp0
set HTTP_PORT=4444
set HTTPS_PORT=-1
set APP_VERSION=2.42.2
set JAVA_HOME=c:\java\jdk1.6.0_45
set GROOVY_HOME=c:\java\groovy-2.3.2
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin
PATH=%PATH%;c:\Program Files\Mozilla Firefox
REM If 
REM Error occurred during initialization of VM
REM The size of the object heap + VM data exceeds the maximum representable size
REM Error occurred during initialization of VM
REM Could not reserve enough space for object heap
REM Could not create the Java virtual machine.
REM Then
REM This setting needs adjustment.
REM set LAUNCHER_OPTS=-XX:PermSize=512M -XX:MaxPermSize=1028M -Xmn128M -Xms512M -Xmx1024M
set LAUNCHER_OPTS=-XX:MaxPermSize=1028M -Xmn128M
rem java %LAUNCHER_OPTS% -jar selenium-server-standalone-%APP_VERSION%.jar -port %HTTP_PORT% -role hub
	java %LAUNCHER_OPTS% -jar selenium-server-standalone-%APP_VERSION%.jar -role hub


REM https://code.google.com/p/selenium/wiki/InternetExplorerDriver
rem http://seleniumonlinetrainingexpert.wordpress.com/2012/12/11/how-do-i-start-the-internet-explorer-webdriver-for-selenium/
goto :EOF 

REM 
REM pushd c:\Users\sergueik\AppData\Local\Mozilla Firefox
REM mklink /D c:\tools\firefox .
REM symbolic link created for c:\tools\firefox <<===>> .