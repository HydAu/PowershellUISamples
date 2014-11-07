@echo OFF
REM works
call mvn clean package 
set TARGET=%CD%\target
copy /y %USERPROFILE%\.m2\repository\org\seleniumhq\selenium\selenium-api\2.44.0\selenium-api-2.44.0.jar target > NUL
copy /y %USERPROFILE%\.m2\repository\org\json\json\20080701\json-20080701.jar target > NUL
copy /y %USERPROFILE%\.m2\repository\org\seleniumhq\selenium\selenium-chrome-driver\2.44.0\selenium-chrome-driver-2.44.0.jar  target > NUL
copy /y %USERPROFILE%\.m2\repository\org\seleniumhq\selenium\selenium-firefox-driver\2.44.0\selenium-firefox-driver-2.44.0.jar  target > NUL
copy /y %USERPROFILE%\.m2\repository\org\seleniumhq\selenium\selenium-java\2.44.0\selenium-java-2.44.0.jar  target > NUL
copy /y %USERPROFILE%\.m2\repository\org\seleniumhq\selenium\selenium-remote-driver\2.44.0\selenium-remote-driver-2.44.0.jar target > NUL


java -cp target\test-1.0-SNAPSHOT.jar;c:\java\selenium\selenium-server-standalone-2.44.0.jar;target\selenium-java-2.44.0.jar;target\selenium-firefox-driver-2.44.0.jar;target\selenium-api-2.41.0.jar;target\selenium-chrome-driver-2.44.0.jar;target\selenium-remote-driver-2.44.0.jar;target\\selenium-firefox-driver-2.44.0.jar;target\selenium-server-standalone-2.44.0.jar;target\json-20080701.jar com.mycompany.app.Test

goto :EOF


REM https://groups.google.com/forum/#!topic/selenium-users/i_xKZpLfuTk
