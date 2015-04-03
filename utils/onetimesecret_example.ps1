#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


param(
  [switch]$use_proxy,
  [string]$recipient = 'kouzmine_serguei@yahoo.com',
  [string]$passphrase = 'test',
  [string]$username = 'kouzmine_serguei@yahoo.com',
  [string]$get_service_url = 'https://onetimesecret.com/api/v1/status',
  [string]$post_service_url = 'https://onetimesecret.com/api/v1/share',
  [string]$secret = 'This is a test.',
  [string]$apitoken = 'b6804cf818a151f47b1b53687ac8540172dbfb0a'
)
function GET_request {
  param(
    [string]$username,
    [string]$password = '',
    [string]$service_url = '',
    [string]$default_proxy_config_url = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script',
    [bool]$use_proxy
  )

  if ($use_proxy) {

    # Use current user NTLM credentials do deal with corporate firewall
    $proxy_config_url = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer

    if ($proxy_address -eq $null) {
      $proxy_config_url = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
    }

    if ($proxy_address -eq $null) {
      # write a hard coded proxy address here 
      $proxy_config_url = $default_proxy_config_url
    }

    $proxy = New-Object System.Net.WebProxy
    $proxy.Address = $proxy_config_url
    $proxy.useDefaultCredentials = $true

  }

  [system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($service_url)
  try {
    [string]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding('ASCII').GetBytes(($username + ':' + $password)))
    # Write-Debug $encoded
    $request.Headers.Add('Authorization','Basic ' + $encoded)
  } catch [argumentexception]{

  }

  if ($use_proxy) {
    Write-Host ('Use Proxy: "{0}"' -f $proxy.Address)
    $request.proxy = $proxy
    $request.useDefaultCredentials = $true
  }


  Write-Host ('Open {0}' -f $service_url)

  for ($i = 0; $i -ne $max_retries; $i++) {

    Write-Debug ('Try {0}' -f $i)


    try {
      $response = $request.GetResponse()
    } catch [System.Net.WebException]{
      $response = $_.Exception.Response
    }

    # this is a test
    $expected_status = 200


    $int_status = [int]$response.StatusCode
    $time_stamp = (Get-Date -Format 'yyyy/MM/dd hh:mm')
    $status = $response.StatusCode # not casting

    Write-Host "$time_stamp`t$url`t$int_status`t$status"
    $sleep_interval = 10
    if ($int_status -ne $expected_status) {
      Write-Host 'Unexpected http status detected. sleep and retry.'
      Start-Sleep -Seconds $sleep_interval
      # sleep and retry
    } else {
      break
    }
  }

  $time_stamp = $null
  if ($int_status -ne $expected_status) {
    Write-Debug ('Unexpected http status: {0} ' -f $int_status)
  }
 
  $response_text = ( New-Object System.IO.StreamReader ($response.GetResponseStream())).ReadToEnd()

  Write-Debug $response_text

  $response_json = ConvertFrom-Json -InputObject $response_text
  $request = $null
  return $response_json

}


function POST_request {
  param(
    [string]$username,
    [string]$password = '',
    [string]$service_url = '',
    [string]$postdata,
    [string]$default_proxy_config_url = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script',
    [bool]$use_proxy
  )

  if ($use_proxy) {

    # Use current user NTLM credentials do deal with corporate firewall
    $proxy_config_url = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer

    if ($proxy_address -eq $null) {
      $proxy_config_url = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
    }

    if ($proxy_address -eq $null) {
      # write a hard coded proxy address here 
      $proxy_config_url = $default_proxy_config_url
    }

    $proxy = New-Object System.Net.WebProxy
    $proxy.Address = $proxy_config_url
    $proxy.useDefaultCredentials = $true

  }

  [system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($service_url)
  try {
    [string]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding('ASCII').GetBytes(($username + ':' + $password)))
    # Write-Debug $encoded
    $request.Headers.Add('Authorization','Basic ' + $encoded)
  } catch [argumentexception]{

  }

  if ($use_proxy) {
    Write-Host ('Use Proxy: "{0}"' -f $proxy.Address)
    $request.proxy = $proxy
    $request.useDefaultCredentials = $true
  }

  # [string] $postData = 'secret="This is a test."'
   if ($postdata -eq $null) {
     $postdata = ''
   }
  [byte[]] $byteArray = [System.Text.Encoding]::GetEncoding('ASCII').GetBytes($postData) 
  $request.Method = "POST"
  $request.ContentLength = $byteArray.Length  
  $request.ContentType = "application/x-www-form-urlencoded"
  [System.IO.Stream] $dataStream = $request.GetRequestStream()
  $dataStream.Write($byteArray, 0, $byteArray.Length)
  $dataStream.Close()
  Write-Host ('Open {0}' -f $service_url)

  for ($i = 0; $i -ne $max_retries; $i++) {

    Write-Debug ('Try {0}' -f $i)

    try {
      $response = $request.GetResponse()
    } catch [System.Net.WebException]{
      write-debug $_.Exception.Response
	  return  
    }

    $expected_status = 200

    $int_status = [int]$response.StatusCode
    $time_stamp = (Get-Date -Format 'yyyy/MM/dd hh:mm')
    $status = $response.StatusCode

    Write-Host "$time_stamp`t$url`t$int_status`t$status"
    $sleep_interval = 10
    if ($int_status -ne $expected_status) {
      Write-Host 'Unexpected http status detected. sleep and retry.'
      Start-Sleep -Seconds $sleep_interval
      # sleep and retry
    } else {
      break
    }
  }

  $time_stamp = $null
  if ($int_status -ne $expected_status) {
    Write-Debug ('Unexpected http status: {0} ' -f $int_status)
  }

  $response_text = ( New-Object System.IO.StreamReader ( $response.GetResponseStream())  ).ReadToEnd()
  $response_json = ConvertFrom-Json -InputObject $response_text

  return $response_json

}

# https://onetimesecret.com/docs/api/secrets

write-host 'Check current status of the system.'
[bool]$use_proxy = ([bool]$PSBoundParameters['use_proxy'].IsPresent)
Write-Host "GET_request -username $username -apitoken $apitoken -service_url $get_service_url -use_proxy $use_proxy"
$status_result = GET_request -username $username -password  $apitoken -service_url $get_service_url -use_proxy $use_proxy
write-host  ('status = {0}' -f $status_result.status )

[int]$ttl = 120
write-host 'Store a secret value with recipient, passphrase and secret.'
$recipient =  [System.Web.HttpUtility]::UrlEncode($recipient) 
[string] $postData = @"
ttl=${ttl}
secret=${secret}
recipient=${recipient}
passphrase=${passphrase}
"@
$postData  = ( $postData  -split "`r`n" ) -join '&'

Write-Host "POST_request -username $username -apitoken $apitoken -service_url $post_service_url -postData $postData -use_proxy $use_proxy"
$secret_store_result = POST_request -username $username -password $apitoken -service_url $post_service_url -postData $postData -use_proxy $use_proxy
write-output $secret_store_result | format-list 

# NOTE: Not receiving a friendly email containing the secret link.

write-host 'Retreive a list of recent metadata.'
$list_url = 'https://onetimesecret.com/api/v1/private/recent'
[string] $postData = ''
Write-Host "POST_request -username $username -apitoken $apitoken -service_url  $list_url  -postData '' -use_proxy $use_proxy"
$list_result = POST_request -username $username -password $apitoken -service_url $list_url -use_proxy $use_proxy -postData '' 
write-output $list_result

# NOTE: Oops! Apologies dear citizen! You have been rate limited. 