@echo OFF 
set BASEDIR=C:\TEST
set DRIVELETTERS= ^
E ^
F ^
G ^
H ^
I ^
J ^
K ^
L ^
M ^
N ^
O ^
P ^
Q ^
R ^
s ^
T ^
U ^
V ^
W ^
x ^
Y ^
Z ^


REM Keep the above line blank

for %%. in (%DRIVELETTERS%) do @call :MAKDR %%.

subst
goto :EOF

:MAKDR
set DRIVELETTER=%1
echo Processing %DRIVELETTER%
if NOT EXIST %BASEDIR%\%DRIVELETTER% MKDIR %BASEDIR%\%DRIVELETTER%
pushd %BASEDIR%\%DRIVELETTER% 
echo Recycling %DRIVELETTER%:
SUBST %1: /D 
echo Assigning %DRIVELETTER%:
SUBST %DRIVELETTER%: %CD%  
POPD

goto :EOF
