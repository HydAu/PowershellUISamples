param (
[String]$username = 'egarcia',
[String]$url = 'https://haldev.service-now.com/api/now/table/change_request',
[switch]$use_proxy ,
[String]$password = 'passtest'
)

function log_message {
param(
    [Parameter(Position=0)]
    [string] $message ,
    [Parameter(Position=1)]
    [string] $logfile 
)
  write-output -InputObject $message 
  write-output -InputObject $message  | out-file -FilePath $logfile -Encoding ascii -Force -append
}


function page_content {
param (
[String]$username = 'sergueik',
[String]$url = '',
[string]$password = '',
[string]$use_proxy 
)

if ($url -eq $null -or $url -eq ''){ 
#  $url =  ('https://github.com/{0}' -f $username)
  $url =   'https://api.github.com/user'
}


$sleep_interval = 10
$max_retries  = 5
$build_status = 'test.properties'
# this is a test
$expected_status  = 200 


( $build_status ) | foreach-object {set-content -Path $_ -value ''}


$log_file  = 'healthcheck.txt' 


if ($PSBoundParameters['use_proxy']) {

# Use current user NTLM credentials do deal with corporate firewall
$proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer

if ($proxyAddr -eq $null ){
  $proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
}

if ($proxyAddr -eq $null){
  $proxyAddr = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
}

$proxy = new-object System.Net.WebProxy
$proxy.Address = $proxyAddr
write-host  ("Probing {0}" -f $proxy.Address )
$proxy.useDefaultCredentials = $true

}
<#
request.Credentials = new NetworkCredential(xxx,xxx);
CookieContainer myContainer = new CookieContainer();
request.CookieContainer = myContainer;
request.PreAuthenticate = true;

#>

[system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($url)
[String]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes(($username + ':' + $password)))
$request.Headers.Add("Authorization", "Basic " + $encoded)


 if ($PSBoundParameters['use_proxy']) {
write-host   ('Use Proxy:{0}'-f $proxy.Address )
$request.proxy = $proxy
$request.useDefaultCredentials = $true
}
# Note github returns a json result saying that it requires authentication 
# normally the server returns a "classic" 401 html page

write-host ('Open {0}' -f $url )

for ($i = 0 ; $i -ne $max_retries  ; $i ++ ) {

write-host  ('Try {0}' -f $i )


try {
    $response = $request.GetResponse()
} catch [System.Net.WebException] {
    $response = $_.Exception.Response
}

$int_status = [int]$response.StatusCode
$time_stamp =  ( Get-Date -format 'yyyy/MM/dd hh:mm' ) 
$status = $response.StatusCode # not casting

write-host "$time_stamp`t$url`t$int_status`t$status" 
# | Tee-Object  -FilePath $log_file  -append 
if ($int_status -ne $expected_status ) {
write-host 'Unexpected http status detected. sleep and retry.'

start-sleep -seconds $sleep_interval

# sleep and retry
} else { 
break
}
}

$time_stamp =  $null 
if ($int_status -ne $expected_status ) {
# write error status to a log file and exit
# 
write-host ('Unexpected http status detected. Error reported. {0}, {1} ' -f $int_status)
    log_message  'STEP_STATUS=ERROR' $build_status 
}

    $respstream = $response.GetResponseStream() 
       $stream_reader = new-object System.IO.StreamReader $respstream
       $result_page = $stream_reader.ReadToEnd()
       <#
       if ($result_page -match $confirm_page_text) {
         $found_expected_status =  $true
         if ($result_page.size -lt 100 )
         {
           $result_page_fragment= $result_page
         }
           write-host "Page Contents:`n${result_page_fragment}"
       } else {
         $found_expected_status =  $false
         $result_page = ''
       }
       #> 


write-debug $result_page

return $result_page

}


   [string]$use_proxy_arg = $null 
# TODO pass switches correctly
 if ($PSBoundParameters['use_proxy']) {
   $use_proxy_arg = @('-use_proxy',  $true) -join ' '
}
write-host "page_content -username $username -password $password -url $url $use_proxy_arg"
page_content -username $username -password $password -url $url $use_proxy_arg
# write-output ( page_content -username $username -password $password -url $url $use_proxy_arg)

