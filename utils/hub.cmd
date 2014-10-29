@echo OFF
pushd %~dp0
set SELENIUM_HOME=%CD:\=/%
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

REM java %LAUNCHER_OPTS% -jar selenium-server-standalone-%APP_VERSION%.jar ^
REM      %SERVLET_OPTS% ^
REM Be ready to load additional jars through CLASSPATH

java %LAUNCHER_OPTS% ^
     -classpath %SELENIUM_HOME%/selenium-server-standalone-%APP_VERSION%.jar ^
     org.openqa.grid.selenium.GridLauncher ^
     -port %HTTP_PORT% ^
     -role hub ^
     -ensureCleanSession true ^
     -trustAllSSLCertificates true ^
     -maxSession 20 ^
     -newSessionWaitTimeout 600000^

REM Keep the Blank line above intact
goto :EOF

REM http://www.deepshiftlabs.com/sel_blog/?p=2155&&lang=en-us
REM http://grokbase.com/t/gg/webdriver/1282vm4ej0/how-to-set-the-command-line-switches-for-iedriverserver-exe-when-running-it-along-with-grid-node 
