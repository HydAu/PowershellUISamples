@echo OFF
REM works
call mvn clean package install
set TARGET=%CD%\target

java -cp target\test-1.0-SNAPSHOT.jar;c:\java\selenium\selenium-server-standalone-2.44.0.jar;target\lib\*  com.mycompany.app.Test

goto :EOF


REM https://groups.google.com/forum/#!topic/selenium-users/i_xKZpLfuTk
