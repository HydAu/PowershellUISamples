# http://techibee.com/sysadmins/disable-server-manager-startup-from-user-login-using-registry-and-group-policies/2076
$hive = 'HKLM:'
$path = '/SOFTWARE/Microsoft/ServerManager'
$name = 'DoNotOpenServerManagerAtLogon'

pushd $hive
cd $path

$old_setting_value = (Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)).$name

[void](Set-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -Value '1')


$new_setting_value = (Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)).$name

Write-Output ('Changed setting {0} from {1} to {2}' -f ('{0}/{1}' -f $hive,$path),$old_setting_value,$new_setting_value)
popd

$hive = 'HKCU:'

$path = 'Software\Microsoft\ServerManager'
$name  = 'CheckedUnattendLaunchSetting'

pushd $hive
$result = [bool](Test-Path -Path $path)
popd
if ($result) {
  Write-Output 'Deploying HKCU should be done via Group Policy preferences or logon scripts'

  $old_setting_value = (Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)).$name

  Write-Output ('Found setting {0} = {1}' -f ('{0}/{1}' -f $hive,$path),$old_setting_value)
  [void](Set-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path) -Value '0')


$new_setting_value = (Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)).$name

  Write-Output ('Changed setting {0} from {1} to {2}' -f ('{0}/{1}' -f $hive,$path),$old_setting_value,$new_setting_value)
} else {
  write-output 'There is no HKCU setting'
}
