@echo OFF
pushd %~dp0
set MONGO_HOME=%CD:\=/%
set HTTP_PORT=27017

call bin\mongod.exe --dbpath %CD%\data