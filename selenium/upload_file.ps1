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
  [string]$browser
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
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)


$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)

$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\hub.cmd'
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\node.cmd'
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  # this example may not work with phantomjs 
  $phantomjs_executable_folder = "c:\tools\phantomjs"
  Write-Host 'Running on phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}

[void]$selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(60))

$base_url = 'http://www.freetranslation.com/'

<# 
has the following fragment:
<div class="gw-upload-action clearfix">
  <div id="upload-button" class="btn"><img class="gw-icon upload" alt="" src="http://d2yxcfsf8zdogl.cloudfront.net/home-php/assets/home/img/pixel.gif"/>
         Choose File(s)                        
        <div class="ajaxupload-wrapper" style="width: 300px; height: 50px;"><input class="ajaxupload-input" type="file" name="file" multiple=""/></div>
    </div>
</div>
#>
$text_file = ('{0}\{1}' -f (Get-ScriptDirectory),'testfile.txt')
Write-Output 'good morning driver' | Out-File -FilePath $text_file -Encoding ascii
$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()
$upload_element = $selenium.FindElement([OpenQA.Selenium.By]::ClassName('ajaxupload-input'))
$upload_element.SendKeys($text_file)
<#
Wait until the following element is present:
<a href="..." class="gw-download-link">
  <img class="gw-icon download" src="http://d2yxcfsf8zdogl.cloudfront.net/home-php/assets/home/img/pixel.gif"/>
  Download
</a>
#>

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 100

[OpenQA.Selenium.Remote.RemoteWebElement]$element1 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("gw-download-link")))

[OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector('img.gw-icon')))
$text_url = $element1.getAttribute('href')
# http://winsysadm.net/
# http://weblog.west-wind.com/posts/2007/May/21/Downloading-a-File-with-a-Save-As-Dialog-in-ASPNET
$result = Invoke-WebRequest -Uri $text_url
[NUnit.Framework.Assert]::IsTrue(($result.RawContent -match 'Bonjour pilote'))
try {
  $selenium.Quit()
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]
}

