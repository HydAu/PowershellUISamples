<# 
"CheckedUnattendLaunchSetting"=dword:00000001

***** C:\B.TXT
"CheckedUnattendLaunchSetting"=dword:00000001

"DoNotOpenServerManagerAtLogon"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager]
"OemExtensionXmlFilePath"=hex(2):00
"DoNotOpenServerManagerAtLogon"=dword:00000000
"InitializationComplete"=dword:00000001
"MaximumRebootAttempts"=dword:00000002
"CurrentRebootAttempts"=dword:00000000
#>

$hive = 'HKLM:' # TODO  link to Google document
$path = '/SOFTWARE/Microsoft/ServerManager'
$name = 'DoNotOpenServerManagerAtLogon'

pushd $hive
cd $path
# [void](New-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -Value '1' -PropertyType DWORD)
[void](Set-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -Value '1' )
$result = (Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)).$name
Write-Output ('Changed setting {0} to {1}' -f ('{0}/{1}' -f $hive,$path),$result)
popd
