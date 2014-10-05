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

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)

$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

# Convertfrom-JSON applies To: Windows PowerShell 3.0 and above
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

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


[string]$baseURL = 'file:///C:/developer/sergueik/powershell_ui_samples/external/two_iframes_example.html'
$selenium.url = $baseURL = 'http://translation2.paralink.com/'
$selenium.Navigate().GoToUrl($baseURL)
[string]$xpath = "//frame[@id='topfr']"
$top_frame = $selenium.findElement([OpenQA.Selenium.By]::Xpath($xpath))
$frame_driver = $selenium.SwitchTo().Frame($top_frame)   
[NUnit.Framework.Assert]::AreEqual($frame_driver.url, 'http://translation2.paralink.com/newtop.asp',  $frame_driver.url)
write-debug '1'

[void]$selenium.SwitchTo().DefaultContent()

$xpath = "//frame[@id='botfr']"
$bot_frame = $selenium.findElement([OpenQA.Selenium.By]::Xpath($xpath))
$frame_driver = $selenium.SwitchTo().Frame($bot_frame)   

[NUnit.Framework.Assert]::AreEqual($frame_driver.url, 'http://translation2.paralink.com/newbot.asp',  $frame_driver.url)
write-debug '2'

[void]$selenium.SwitchTo().DefaultContent()

$driver = $selenium.SwitchTo().Frame(1)   
[NUnit.Framework.Assert]::AreEqual($frame_driver.url, 'http://translation2.paralink.com/newbot.asp',  $frame_driver.url)

[void]$selenium.SwitchTo().DefaultContent()
write-debug '3'
$driver = $selenium.SwitchTo().Frame(0)   
[NUnit.Framework.Assert]::AreEqual($frame_driver.url, 'http://translation2.paralink.com/newtop.asp',  $frame_driver.url)

[void]$selenium.SwitchTo().DefaultContent()
write-debug '4'

# [OpenQA.Selenium.IWebElement]$element = $driver.FindElement([OpenQA.Selenium.By]::ClassName('central-featured-logo'))
# [void]$selenium.SwitchOutOfIFrame()

try {
  $selenium.Quit()
} catch [exception]{
  # Write-Output $_.Exception.Message
  # Ignore errors if unable to close the browser
}
return
