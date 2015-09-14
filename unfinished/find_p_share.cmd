
@echo OFF 
REM setup_p_share.cmd 
goto :TEST
net share SAMPLE_SHARE=C:\test\P
REM SAMPLE_SHARE was shared successfully.

net use P: \\%computername%\SAMPLE_SHARE
REM The command completed successfully.

net share OTHER_SHARE=C:\test\Q
REM OTHER_SHARE was shared successfully.

net use Q: \\%computername%\OTHER_SHARE
REM The command completed successfully.


:TEST
REM find_p_share.cmd
set SHARE_UNC_PATH_FRAGMENT=SAMPLE_SHARE
set ANSWER=%TEMP%\answer.txt
for /F "tokens=1,2,*" %%1 in ('net use ^| findstr /ic:"%SHARE_UNC_PATH_FRAGMENT%" ') do @echo set DRIVELETTER=%%2>%ANSWER%
type %ANSWER%
goto :EOF