$target_service_name = 'MsDepSvc'
$domain = $env:USERDOMAIN 

if ($domain -like 'UAT') {
  $user = '_uatmsdeploy'
}
if ($domain -like 'PROD') {
  $user = '_msdeploy'
}

clear-host

$target_account = "${domain}\${user}"
$credential = Get-Credential -username $target_account -message 'Please authenticate' 
$target_account = $credential.Username 
$target_password = $credential.GetNetworkCredential().Password
$DebugPreference = 'Continue'

write-Debug $target_password
return
# change the newly installed service (code omitted)
