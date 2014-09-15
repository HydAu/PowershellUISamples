@echo OFF
pushd %~dp0

set HUB_HOST=192.168.0.6
set HUB_HTTP_PORT=4444
set NODE_HTTP_PORT=5556
set APP_VERSION=2.42.2
set JDK_VERSION=1.6.0_45
set JAVA_HOME=c:\java\jdk%JDK_VERSION%
rem Need to keep 1.7 and 1.6 both installed
set GROOVY_HOME=c:\java\groovy-2.3.2
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin
PATH=%PATH%;c:\Program Files\Mozilla Firefox
REM This setting may need adjustment.
REM set LAUNCHER_OPTS=-XX:PermSize=512M -XX:MaxPermSize=1028M -Xmn128M -Xms512M -Xmx1024M
set LAUNCHER_OPTS=-XX:MaxPermSize=1028M -Xmn128M
java %LAUNCHER_OPTS% ^
-jar selenium-server-standalone-%APP_VERSION%.jar ^
-role node ^
-port %NODE_HTTP_PORT% ^
-hub http://%HUB_HOST%:%HUB_HTTP_PORT%/hub/register ^
-Dwebdriver.ie.driver=IEDriverServer.exe ^
-Dwebdriver.chrome.driver=chromedriver.exe ^
-nodeConfig node.json ^

# Double blank line
REM https://code.google.com/p/selenium/wiki/InternetExplorerDriver
rem http://seleniumonlinetrainingexpert.wordpress.com/2012/12/11/how-do-i-start-the-internet-explorer-webdriver-for-selenium/
goto :EOF 

REM NOTE: http://grokbase.com/t/gg/webdriver/1282vm4ej0/how-to-set-the-command-line-switches-for-iedriverserver-exe-when-running-it-along-with-grid-node 
