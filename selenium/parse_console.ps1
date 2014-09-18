#Copyright (c) 2014 Serguei Kouzmine
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
  [string] $debug = '' 
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}


$shared_assemblies = @(
  "HtmlAgilityPack.dll",
  "nunit.framework.dll"
)

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
popd


$url =  'http://localhost:4444/grid/console#' 

$sleep_interval = 30 
$max_retries  = 1
$build_log = 'test.properties'
$expected_http_status  = 200 

$proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
if ($proxyAddr -eq $null ){
  $proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
}

if ($proxyAddr -eq $null){
  $proxyAddr = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
}

$proxy = new-object System.Net.WebProxy
$proxy.Address = $proxyAddr
write-debug ('Probing {0}' -f $proxy.Address )
$proxy.useDefaultCredentials = $true

$req = [system.Net.WebRequest]::Create($url)
$req.proxy = $proxy
$req.useDefaultCredentials = $true

$req.PreAuthenticate = $true
$req.Headers.Add('UserAgent','Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/535.2')

$req.Credentials = new-object system.net.networkcredential($build_user, $build_password )
# $response = $webrequest.GetResponse()
[Io.StreamReader] $sr  =  $null
[int]$int = 0
for ($i = 0 ; $i -ne $max_retries  ; $i ++ ) {


try {
    $res = $req.GetResponse()
    $sr = [Io.StreamReader]($res.GetResponseStream()) 
# may fail!
# [xml]$xmlout = $sr.ReadToEnd()

} catch [System.Net.WebException] {
    $res = $_.Exception.Response
}
$int = [int]$res.StatusCode
$time_stamp =  ( Get-Date -format 'yyyy/MM/dd hh:mm' ) 
$status = $res.StatusCode
write-output "$time_stamp`t$url`t$int`t$status" 
if (($int -ne $expected_http_status ) -or ( $sr -eq $null )) {
start-sleep -seconds $sleep_interval
}
}
$time_stamp =  $null 
if ($int -ne $expected_http_status ) {
# write error status to a log file and exit
# 
    write-output 'Unexpected http status detected. Error reported.'
    log_message  'STEP_STATUS=ERROR' $build_status 
	exit 1 

}
[string]$source =$sr.ReadToEnd()
try{
# may fail!
[xml]$xmlout = $source 

} 
catch [Exception]  {
write-output 'ignoring the exception' 
# write-output $_.Exception.Message
<# Cannot convert value "<html><... </a></div></body></html>" to type "System.Xml.XmlDocument". 
Error: "The 'p' start tag on line 1 position 749 does not match the end tag of 'div'. Line 4, position 833." 
#>
}

[System.Net.WebUtility]::HtmlDecode($source) 
write-debug $source
[HtmlAgilityPack.HtmlDocument]$resultat  = new-Object HtmlAgilityPack.HtmlDocument
$resultat.LoadHtml($source) 
# http://www.codeproject.com/Tips/804660/How-to-Parse-Html-using-csharp
# http://htmlagilitypack.codeplex.com/downloads/get/437941

[HtmlAgilityPack.HtmlNodeCollection] $nodes = $resultat.DocumentNode.SelectNodes("//p[@class='proxyid']")
foreach ( $node in $nodes)
{
     write-output $node.InnerText   
     [HtmlAgilityPack.HtmlNodeCollection] $browsers = $node.ParentNode.SelectNodes("//div[@type='browsers']//img")

# [HtmlAgilityPack.HtmlNode] $node = $null
foreach ( $image in $browsers)
{

     write-output $image.Attributes["title"].Value
     write-output $image.Attributes["class"].Value

}

}

return

