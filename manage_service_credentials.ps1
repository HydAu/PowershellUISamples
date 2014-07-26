$DebugPreference = 'Continue'

$target_service_name = 'MsDepSvc'
$domain = $env:USERDOMAIN
if ($domain -like 'UAT') {
  $user = '_uatmsdeploy'
}
elseif ($domain -like 'PROD') {
  $user = '_msdeploy'
}
else { 
  $user = $env:USERNAME

}

$target_account = "${domain}\${user}"

$credential = Get-Credential -username $target_account -message 'Please authenticate'
if ($credential -ne $null) { 
  $target_account  = $credential.Username
  $target_password  = $credential.GetNetworkCredential().Password
  write-Debug $target_password
} else { 

}
return
# change the newly installed service (code omitted)

