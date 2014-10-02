@echo OFF
pushd %~dp0

set NODE_HTTP_PORT=%1
set NODE_HOST=%2

if "%NODE_HTTP_PORT%" equ "" set NODE_HTTP_PORT=5555
if "%NODE_HOST%" equ "" set NODE_HOST=%COMPUTERNAME%

set HUB_HOST=127.0.0.1
set HUB_HTTP_PORT=4444

set HTTPS_PORT=-1
set APP_VERSION=2.43.1
set JAVA_VERSION=1.6.0_45
set JAVA_HOME=c:\progra~1\java\jdk%JAVA_VERSION%
set JAVA_HOME=c:\java\jdk%JAVA_VERSION%
rem Need to keep 1.7 and 1.6 both installed
set GROOVY_HOME=c:\java\groovy-2.3.2
set HUB_URL=http://127.0.0.1:4444/grid/register
REM cannot use paths
set NODE_CONFIG=NODE.json
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin

REM Browsers are installed in WOW6432
REM No
PATH=%PATH%;C:\Program Files (x86)\Google\Chrome\Application
PATH=%PATH%;C:\Program Files (x86)\Mozilla Firefox
PATH=%PATH%;C:\Program Files (x86)\Internet Explorer

where.exe firefox.exe
CHOICE /T 1 /C ync /CS /D y
where.exe chrome.exe
CHOICE /T 1 /C ync /CS /D y
where.exe iexplore.exe
CHOICE /T 1 /C ync /CS /D y

set LAUNCHER_OPTS=-XX:MaxPermSize=1028M -Xmn128M


java %LAUNCHER_OPTS% ^
-jar selenium-server-standalone-%APP_VERSION%.jar ^
-role node ^
-host %NODE_HOST% ^
-port %NODE_HTTP_PORT% ^
-hub http://%HUB_HOST%:%HUB_HTTP_PORT%/hub/register ^
-Dwebdriver.ie.driver=IEDriverServer.exe ^
-Dwebdriver.chrome.driver=chromedriver.exe ^
-nodeConfig %NODE_CONFIG%  ^
-browserTimeout 12000 -timeout 12000 ^

REM Blank line
goto :EOF

REM https://code.google.com/p/selenium/wiki/InternetExplorerDriver
rem http://seleniumonlinetrainingexpert.wordpress.com/2012/12/11/how-do-i-start-the-internet-explorer-webdriver-for-selenium/


REM NOTE: http://grokbase.com/t/gg/webdriver/1282vm4ej0/how-to-set-the-command-line-switches-for-iedriverserver-exe-when-running-it-along-with-grid-node 


