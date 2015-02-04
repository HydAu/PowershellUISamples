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
  # in the current environment phantomejs is not installed 
  [string]$browser = 'firefox',
  [switch]$pause

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
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$verificationErrors = New-Object System.Text.StringBuilder

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
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
    if ($version -ne $null -and $version -ne 0) {
      $capability.SetCapability("version",$version.ToString());
    }

  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Host 'Running on phantomjs'
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}



$baseURL = 'http://www.seabourn.com/'

$selenium.Navigate().GoToUrl($baseURL + "/")


[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(360))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("sbn-logo")))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element0 = $selenium.FindElement([OpenQA.Selenium.By]::ClassName("sbn-logo"))
Write-Output ('Logo: ' + $element0.GetAttribute('alt'))

[NUnit.Framework.Assert]::IsTrue(($selenium.Title -match 'Seabourn'))
Write-Output $selenium.Title


function hover_menus {
  param([string]$value0,
    [bool]$pause)
  if ($value0 -eq '' -or $value0 -eq $null) {
    return
  }
  $css_selector0 = ('a#{0}' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  Start-Sleep -Millisecond 50
  Write-Output ('Hovering over ' + $element0.GetAttribute('title'))
  $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Build().Perform()

  if ($pause) {
    Write-Output 'pause'
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Write-Output 'no pause'
    Start-Sleep -Millisecond 1000

  }
}

function click_menu {
  param(
    [string]$value0,
    [bool]$pause
  )
  if ($value0 -eq '' -or $value0 -eq $null) {
    return
  }
  $css_selector0 = ('a#{0}' -f $value0)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
  $wait.PollingInterval = 50

  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector0)))
  } catch [exception]{
    Write-Debug ("Exception : {0} ...`ncss_selector={1}" -f (($_.Exception.Message) -split "`n")[0],$css_selector0)
  }

  $element0 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector0))

  [OpenQA.Selenium.Interactions.Actions]$actions0 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

  Write-Output ('Clicking over ' + $element0.GetAttribute('title'))
  $actions0.MoveToElement([OpenQA.Selenium.IWebElement]$element0).Click().Build().Perform()
  Start-Sleep -Millisecond 50
  if ($pause) {
    Write-Output 'pause'
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Write-Output 'no pause'
    Start-Sleep -Millisecond 1000
  }

}
# Explore Cruise Ports 
# http://www.seabourn.com/luxury-cruise-destinations/Ports.action?WT.ac=pnav_planPorts 

$baseURL = 'http://www.seabourn.com/'
$selenium.Navigate().GoToUrl($baseURL + "/")
[bool]$pause = $false
if ($PSBoundParameters['pause']) {
  $pause = $true
} else {
  $pause = $false
}


#  hover_menus -value0 'pnav-planACruise' -pause $pause

click_menu -value0 'pnav-planACruise' -pause $pause
#  click_menu -value0 'pnav-planACruise' -pause $pause


$selenium.Quit()
