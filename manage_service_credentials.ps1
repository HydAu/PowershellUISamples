$DebugPreference = 'Continue'

$target_service_name = 'MsDepSvc'
$domain = $env:USERDOMAIN 
if ($domain -like 'UAT') {
  $user = '_uatmsdeploy'
}
if ($domain -like 'PROD') {
  $user = '_msdeploy'
}


$target_account = "${domain}\${user}"
$credential = Get-Credential -username $target_account -message ( 'Enter password for {0}, please' -f $target_account   )
if ($credential -ne $null) { 
  $target_account  = $credential.Username
  $target_password  = $credential.GetNetworkCredential().Password
  write-Debug $target_password
} else { 

}
return
# change the newly installed service (code omitted)

