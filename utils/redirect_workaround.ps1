param(
  [string]$web_host = 'web31',
  [string]$app_virtual_path = 'BookedGuest'
)

function redirect_workaround {

  param(
    [string]$web_host = '',
    [string]$app_url = '',
    [string]$app_virtual_path = ''


  )

  if ($web_host -eq $null -or $web_host -eq '') {
    throw 'Web host cannot be null'

  }

  if (($app_virtual_path -ne '') -and ($app_virtual_path -ne '')) {
    $app_url = "http://${web_host}/${app_virtual_path}"
  }


  if ($app_url -eq $null -or $app_url -eq '') {
    throw 'Url cannot be null'
  }

  # workaround for 
  # The underlying connection was closed: Could not establish
  # trust relationship for the SSL/TLS secure channel.
  # error 
  # explained in 
  # http://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
  Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

  # $cert=New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("cert.crt")
  # Invoke-WebRequest -Uri https://IPADDRESS/resource -Credential $cred -certificate $cert -Body $json -ContentType application/json -Method POST


  $result = $null

  try {
    $result = (Invoke-WebRequest -MaximumRedirection 0 -Uri $app_url -ErrorAction 'SilentlyContinue')
    if ($result.StatusCode -eq '302' -or $result.StatusCode -eq '301') {
      $location = $result.headers.Location
      if ($location -match '^http') {
        # TODO capture the host
        $location = $location -replace 'secure.carnival.com',$web_host
      } else {
        $location = $location -replace '^/',''
        $location = ('http://{0}/{1}' -f $web_host,$location)
      }
      Write-Host ('Following {0} ' -f $location)

      $result = (Invoke-WebRequest -Uri $location -ErrorAction 'Stop')
    }
  } catch [exception]{}


  $result.Content.length

}

redirect_workaround -web_host $web_host -app_virtual_path $app_virtual_path
