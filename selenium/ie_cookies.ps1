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
  [switch]$browser
)
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}
$shared_assemblies = @(
  "WebDriver.dll",
  "WebDriver.Support.dll",
  "Selenium.WebDriverBackedSelenium.dll",
  'nunit.core.dll',
  'nunit.framework.dll'

)

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

<# 
pushd C:\tools 
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>

$verificationErrors = New-Object System.Text.StringBuilder
$baseURL = "http://www.wikipedia.org"
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node_ie.cmd"
    Start-Sleep -Seconds 10
  }

  # The script works fine with Chrome or Firefox 31, but not IE 11.
  # the exception specifically when attempting to mess with cookies
  # Exception calling "ExecuteScript" with "1" argument(s): "Unable to get browser
  # is known since Nov 2013 
  # https://code.google.com/p/selenium/issues/detail?id=6511  
  # The bad news is that cookie manipulation is broken. Badly. If you attempt to set or retrieve cookies, there's a chance that you'll end up with the "Unable to get browser" error encountered before. At the moment, there is no workaround for that. Matt, looking at the log you posted earlier, it looks like you were doing some cookie manipulation before you got into the bad state."
  # $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()

  $capability.setCapability([OpenQA.Selenium.Remote.CapabilityType.ForSeleniumServer]::ENSURING_CLEAN_SESSION, $true)  

  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}



$selenium.Navigate().GoToUrl($baseURL)
$selenium.Navigate().Refresh()


<#

# http://www.milincorporated.com/a2_cookies.html
 pushd "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Cookies"
 pushd "${env:USERPROFILE}\AppData\Roaming\Microsoft\Windows\Cookies\Low\"
NOTE: Recent Files in the latter directory  are present even before the browser is open first time after the cold boot.
# Session cookies ?
 pushd "${env:USERPROFILE}\Local Settings\Temporary Internet Files\Content.IE5"
#>
# http://stackoverflow.com/questions/7413966/delete-cookies-in-webdriver 
<#
$target_server = '...'
function clear_cookies{

$command = 'C:\Windows\System32\rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 2'
[void](invoke-expression -command $command  )
} 

$remote_run_step = invoke-command -computer $target_server -ScriptBlock ${function:clear_cookies}
# note one may try to do the same using java runtime:
http://girixh.blogspot.com/2013/10/how-to-clear-cookies-from-internet.html
try {
  Runtime.getRuntime().exec("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2");
 } catch (IOException e) {
  // TODO Auto-generated catch block
  e.printStackTrace();
#>
<#

DesiredCapabilities caps = DesiredCapabilities.internetExplorer(); 
caps.setCapability(CapabilityType.ForSeleniumServer.ENSURING_CLEAN_SESSION, true); 
WebDriver driver = new InternetExplorerDriver(caps);

Once initialized, you can use:

driver.manage().deleteAllCookies()


# note this is a very very old post:
# http://stackoverflow.com/questions/595228/how-can-i-delete-all-cookies-with-javascript
# http://stackoverflow.com/questions/2144386/javascript-delete-cookie
#>


$script = @"

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}

function eraseCookie(name) {
    createCookie(name,"",-1);
}

// finally invoke 

var cookies = document.cookie.split(";");
for (var i = 0; i < cookies.length; i++) {
  eraseCookie(cookies[i].split("=")[0]);
}
"@
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeScript($script);

try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}


<#
# The following registry key describes the state of the 'Delete Browsing history on exit' checkbox 

pushd 'HKCU:'
cd '/Software/Microsoft/Internet Explorer/Privacy'
get-itemproperty -name 'ClearBrowsingHistoryOnExit' -path 'HKCU:/Software/Microsoft/Internet Explorer/Privacy'
set-itemproperty -name 'ClearBrowsingHistoryOnExit' -path 'HKCU:/Software/Microsoft/Internet Explorer/Privacy' -value '1'
popd

#>
