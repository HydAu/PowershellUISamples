@echo OFF

REM The script wrapper and the inner script have to have a matching value of the ExecutionPolicy they 'require'
REM instead of writing a TARGET_EXECUTIONPOLICY parameter into the inline script 
REM is pass it to the script as a parameter


set TARGET_EXECUTIONPOLICY=ByPass
set TARGET_EXECUTIONPOLICY=Restricted
set TARGET_EXECUTIONPOLICY=AllSigned
set TARGET_EXECUTIONPOLICY=RemoteSigned
set TARGET_EXECUTIONPOLICY=Unrestricted

echo Changing Powershell Script execution Policy 
call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Param([string] $targetExecutionPolicy) Set-ExecutionPolicy $TargetExecutionPolicy; write-output (get-ExecutionPolicy -list )}" -targetExecutionPolicy %TARGET_EXECUTIONPOLICY%
echo Enabling Powershell Remoting 
call C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Enable-PSRemoting -Force } "


goto :EOF 
