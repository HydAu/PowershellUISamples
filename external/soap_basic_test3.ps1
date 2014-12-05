$newAcct = "${env:userdomain}\${env:username}"
$credential = Get-Credential -username $newAcct -message  ('Enter password for {0}, please' -f $newAcct   )
$newAcct  = $credential.Username 

$svc = New-WebServiceProxy –Uri 'http://www.webservicex.net/stockquote.asmx?WSDL' -Credential $credential

# http://stackoverflow.com/questions/4083379/compatibility-between-new-webserviceproxy-and-a-proxy-server
# Unfortunately, this cmdlet has no support for proxy credentials. You may want to try using the code posted here by Lee. http://www.leeholmes.com/blog/2007/02/28/calling-a-webservice-from-powershell/
