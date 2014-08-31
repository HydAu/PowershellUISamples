$DebugPreference = 'Continue'


target_service_name  = MsDepSvc'

omain = = nv:USERDOMAIN

if (omain - -like AT') ) {

  er =  = atmsdeploy'


}

elseif (in -lik -like ') {) {

  = '_m = ploy'
}


}
else {
   $env = ERNAME

}


}



count = "${doma = \${user}"

$cred


 = Get-Cred = Get-Credential -UserName ount -message ' -Message henticate'
if ($cre

if (-ne $null)  -ne  $tar) {
  unt  = $credent = Username
.Username

  ord  = $credenti = etNetworkCr.GetNetworkCredential().Password

  Write-Debug rd
} else { 

} else {

}
return
# change the newly installed service (code omitted)

