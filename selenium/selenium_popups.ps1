
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
  # "Selenium.WebDriverBackedSelenium.dll",
  # TODO - resolve dependencies
  'nunit.core.dll',
  'nunit.framework.dll'

)
<#

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\WebDriver.dll' 
or one of its dependencies. This assembly is built by a runtime newer than the currently loaded runtime and cannot be loaded.

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\nunit.framework.dll' or one of its dependencies. 
Operation is not supported. (Exception from HRESULT: 0x80131515) 

use fixw2k3.ps1

Add-Type : Unable to load one or more of the requested types. Retrieve the LoaderExceptions property for more information.
#>

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { 
 if ($host.Version.Major -gt 2){
   Unblock-File -Path $_;
 }
 write-output $_
 Add-Type -Path $_ 
start-sleep 10
 }
popd

<# 
pushd C:\tools 
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>

$verificationErrors = New-Object System.Text.StringBuilder
# use Default Web Site to host the page. Enable Directory Browsing.
$baseURL = "http://localhost/jOrgChart-master2/example.html"
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
#  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
#  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()

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

$selenium.Navigate().GoToUrl("file:///C:/developer/sergueik/powershell_ui_samples/selenium/popup.html" )
$selenium.Navigate().Refresh()
$selenium.Manage().Window.Maximize()

start-sleep 3

[OpenQA.Selenium.Remote.RemoteWebElement]$button = $selenium.findElement([OpenQA.Selenium.By]::xpath("//input[@type='button']"))

$button.click()
# http://www.programcreek.com/java-api-examples/index.php?api=org.openqa.selenium.Alert
# NOTE: do not explicitly declare the type here
# [OpenQA.Selenium.Remote.RemoteAlert]
$alert = $selenium.switchTo().alert()

write-output $alert.Text
$alert.accept()

# Works on FF, Chrome, IE 8 - 11
# http://seleniumeasy.com/selenium-tutorials/how-to-handle-javascript-alerts-confirmation-prompts
# e.g. need to be able to copy a url from a dialog box pop up and paste it into a new browser window

Start-Sleep 3


try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}




