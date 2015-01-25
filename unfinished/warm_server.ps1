param([string]$hostname,
  [string]$host_ip,
  [bool]$debug = $false
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

  # http://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
  # workaround for:
  # The underlying connection was closed: Could not establish
  # trust relationship for the SSL/TLS secure channel.
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

# main program
$target_host = ''
if ($host_ip -ne $null -and $host_ip -ne '') {
  $target_host = $host_ip
}

if ($target_host -eq $null -or $target_host -eq '') {
  return
}

# collection of URLs to "Prime"

$webpagelist = (
  "http://${host_ip}",
  "http://${host_ip}/#q=selenium,&spell=1",
  "http://${host_ip}/#q=Selenium+-+Google+Code",
  "http://${host_ip}/#q=Selenium+-+wikipedia"
)

# Introduced one short and one long response delay 
if ($debug -eq $true) {
  $mockup_delays = @{ "web30" = 100; "web23" = 30 }
} else {
  $mockup_delays = @{}
}
[bool]$use_redirect_workaround = $true

# uses global parameters
function download_content {

  if ($use_redirect_workaround) {
    try {
     [void]( redirect_workaround -web_host $target_host -app_url $app_url )
    } catch [exception]{
      Write-Output ("Exception `n{0}" -f (($_.Exception.Message) -split "`n")[0])
    }
  } else {
    [void](New-Object net.webclient).DownloadString($app_url)
  }

}

Write-Host ('Testing {0}' -f $hostname)

$WebpageList | ForEach-Object {

  $app_url = $_
  Write-Output ('Trying {0}' -f $app_url)

  if ($mockup_delays.containskey($hostname)) {
    $delay = $mockup_delays[$hostname]
    Write-Output ("Sleeping {0} seconds" -f $delay)
    Start-Sleep -Seconds $delay;
  }

  $warmup_response_time = [System.Math]::Round((Measure-Command ${function:download_content}).totalmilliseconds)

  Write-Output ("Opening page: {0} took {1} ms" -f $app_url,$warmup_response_time)

};



