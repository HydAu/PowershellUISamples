@echo OFF
pushd %~dp0
set JAVA_HOME=c:\java\jdk1.6.0_45
set M2_HOME=c:\java\apache-maven-3.2.1
set M2=%M2_HOME%\bin
set MAVEN_OPTS=-Xms256m -Xmx512m
set GROOVY_HOME=c:\java\groovy-2.3.2
PATH=%JAVA_HOME%\bin;%PATH%;%GROOVY_HOME%\bin;%M2%

REM http://www.tutorialspoint.com/maven/maven_environment_setup.htm