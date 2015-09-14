@echo OFF 
set BASEDIR=C:\TEST
set DRIVELETTERS=E F G H I J K L M N O P Q R s T U V W x Y Z

REM CLS

REM THIS IS THE DIR and FILE TO CHECK FOR IF EXISTS
ECHO Setting FILENAME,SOURCEDIR,DESTDIR,DESTFILE

set SOURCEDIR=1Tech
set DESTDIR=C:\ProgramData\Imagine
set FILENAME=client_settings.json
REM Full path to the copied file
set DESTFILE=%DESTDIR%\%FILENAME%

REM full path for the file to copy - not known yet
set FILETOCOPY=

for %%. in (%DRIVELETTERS%) do @call :READDRIVE %%.
echo About to Copy %FILETOCOPY% to %DESTFILE%
goto :CHECKFILE
goto :EOF

:READDRIVE
REM Check if FILETOCOPY already determined
if NOT "%FILETOCOPY%" equ "" goto :EOF
set DRIVELETTER=%1

net use | findstr /ic:"%DRIVELETTER%:" > NUL
if ERRORLEVEL 1 @echo Drive letter %DRIVELETTER%: is not mapped to any share && goto :EOF
echo Probing if exist %DRIVELETTER%:\%SOURCEDIR%
if EXIST "%DRIVELETTER%:\%SOURCEDIR%" call :FOUNDIT %DRIVELETTER%

goto :EOF

:FOUNDIT

set DRIVELETTER=%1
echo Found the data on drive %DRIVELETTER%:
set FILETOCOPY=%DRIVELETTER%:\%SOURCEDIR%\%FILENAME%

goto :EOF


REM File and DIR Exist so let us know then end
:CHECKFILE
if EXIST %DESTFILE% GOTO FILEALREADYEXISTS

REM Check if directory exists
if NOT EXIST %DESTDIR% GOTO MAKEDIR
REM Dir Exists so copy the file
goto COPYTHEFILE

:MAKEDIR
ECHO.
ECHO Creating Destination Directory
ECHO.
mkdir %DESTDIR%
GOTO COPYTHEFILE

:COPYTHEFILE
COPY /B %FILETOCOPY% %DESTDIR%
ECHO.
ECHO Copying JSON file to destination folder
ECHO.
GOTO CHECKFILESTUFF

:CHECKFILESTUFF
ECHO.
ECHO Checking if file copied properly
ECHO.
IF EXIST %DESTFILE% GOTO GOODEND
GOTO BADEND

:BADEND
ECHO.
ECHO Could Not Create File.
ECHO.
GOTO REALEND

:FILEALREADYEXISTS
ECHO.
ECHO File Already Exists. Exiting.
ECHO.
GOTO GOODEND

:GOODEND
ECHO.
ECHO Success.
ECHO.
GOTO REALEND

:REALEND
pause














Is this something you can do?



Go to the proposal. 	7:40 AM EDT