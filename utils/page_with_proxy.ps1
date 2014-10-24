$sleep_interval = 30 
$max_retries  = 3
$build_status = 'test.properties'
# this is a test
$expected_status  = 200 

function log_message {
param(
    [Parameter(Position=0)]
    [string] $message ,
    [Parameter(Position=1)]
    [string] $logfile 
)

if ($SOLVED_UTF16_BUG -and $host.version.major -gt 2 ) {

  <# WARNING Tee-Object corrupts files with utf16
    PS D:\java\Jenkins\master\jobs\SQL_RUNNER_2\workspace> 
    Tee-Object  -FilePath 'test.properties' -append -InputObject 'hello world'
    hello world
    type 'test.properties' 
    h e l l o  w o r l d
  #>
  Tee-Object  -FilePath $logfile -Encoding ascii -append -InputObject $message
} else {
  # on certain machines
  # $host.version  = 2.0 
  # the tee-object does not support -append option.a
  write-output -InputObject $message 
  write-output -InputObject $message  | out-file -FilePath $logfile -Encoding ascii -Force -append
}
}

( $build_status ) | foreach-object {set-content -Path $_ -value ''}


$log_file  = 'healthcheck.txt' 
$url = "http://haldev.service-now.com/api/now/table/change_request"
$url =  "https://my.keynote.com/newmykeynote/scatterplotdrilldown.do?transid=1972395&agentid=40187&butd=561933119&profid=0&pageid=1"
$proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
if ($proxyAddr -eq $null ){
  $proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
}

if ($proxyAddr -eq $null){
  $proxyAddr = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
}

$proxy = new-object System.Net.WebProxy
$proxy.Address = $proxyAddr
write-debug ("Probing {0}" -f $proxy.Address )
$proxy.useDefaultCredentials = $true

$req = [system.Net.WebRequest]::Create($url)
$req.proxy = $proxy
$req.useDefaultCredentials = $true
for ($i = 0 ; $i -ne $max_retries  ; $i ++ ) {


try {
    $res = $req.GetResponse()
} catch [System.Net.WebException] {
    $res = $_.Exception.Response



}
$int = [int]$res.StatusCode
$time_stamp =  ( Get-Date -format 'yyyy/MM/dd hh:mm' ) 
$status = $res.StatusCode
write-output "$time_stamp`t$url`t$int`t$status"  | Tee-Object  -FilePath $log_file  -append 
start-sleep -seconds $sleep_interval
$time_stamp =  $null 
if ($int -ne $expected_status ) {
# write error status to a log file and exit
# 
    write-output 'Unexpected http status detected. Error reported.'
    log_message  'STEP_STATUS=ERROR' $build_status 
}

#---

    $respstream = $res.GetResponseStream() 
       $stream_reader = new-object System.IO.StreamReader $respstream
       $result_page = $stream_reader.ReadToEnd()
       if ($result_page -match $confirm_page_text) {
         $found_expected_status =  $true
         if ($result_page.size -lt 100 )
         {
           $result_page_fragment= $result_page
         }
           write-output "Page Contents:`n${result_page_fragment}"
       } else {
         $found_expected_status =  $false
         $result_page = ''
       }
#---
}


return
