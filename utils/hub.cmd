@echo OFF
pushd %~dp0
set HTTP_PORT=4444
set HTTPS_PORT=-1
set APP_VERSION=2.43.1
set JAVA_VERSION=1.7.0_55
REM 
set JAVA_HOME=c:\progra~1\java\jdk%JAVA_VERSION%
rem Need to keep 1.7 and 1.6 both installed
set GROOVY_HOME=c:\java\groovy-2.3.2
set HUB_URL=http://127.0.0.1:4444/grid/register
REM cannot use paths
set NODE_CONFIG=NODE_config_local.json
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin

REM Error occurred during initialization of VM
REM The size of the object heap + VM data exceeds the maximum representable size
REM Error occurred during initialization of VM
REM Could not reserve enough space for object heap
REM Could not create the Java virtual machine.
REM Then
REM This setting needs adjustment.
REM set LAUNCHER_OPTS=-XX:PermSize=512M -XX:MaxPermSize=1028M -Xmn128M -Xms512M -Xmx1024M
set LAUNCHER_OPTS=-XX:MaxPermSize=1028M -Xmn128M
set SERVLET_OPTS=
set SERVLET_JARS=

java %LAUNCHER_OPTS% -jar selenium-server-standalone-%APP_VERSION%.jar ^
     %SERVLET_OPTS% ^
     -role hub 



REM Blank line
goto :EOF 

REM https://code.google.com/p/selenium/wiki/InternetExplorerDriver
rem http://seleniumonlinetrainingexpert.wordpress.com/2012/12/11/how-do-i-start-the-internet-explorer-webdriver-for-selenium/
goto :EOF 

REM 
REM pushd c:\Users\sergueik\AppData\Local\Mozilla Firefox
REM mklink /D c:\tools\firefox .
REM symbolic link created for c:\tools\firefox <<===>> .
