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
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.framework.dll'
)
# NOTE  a call to fix_w2k3.ps1 may be needed
$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { 
 if ($host.Version.Major -gt 2){
   Unblock-File -Path $_;
 }
 write-output $_
 Add-Type -Path $_ 
 }
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



$baseURL = "http://www.carnival.com"

$selenium.Navigate().GoToUrl($baseURL + "/")
$selenium.Manage().Window.Maximize()
<#
            $selenium.FindElement([OpenQA.Selenium.By]::Id("ccl_header_expand-login-link")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("username")).Clear()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("username")).SendKeys("xxxx")
            $selenium.FindElement([OpenQA.Selenium.By]::Id("password")).Clear()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("password")).SendKeys("yyyy")

            $selenium.FindElement([OpenQA.Selenium.By]::Id("login")).Click()

#>


$value1 = 'dest'
$css_selector1 = ('a[data-param={0}]' -f $value1)
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
##
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Select a destination' ))

Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
Start-Sleep 1

$value2 =  'C'
$css_selector2 = ('a[data-id={0}]' -f $value2)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
##
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
Write-Output ('Clicking on ' + $element2.Text)
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()
$actions2.Click().Build().Perform()
Start-Sleep 3


$value1 = 'dat'
$css_selector1 = ('a[data-param={0}]' -f $value1)
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
##
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Select a date'))

Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
Start-Sleep 1

$value2 =  '"022015"'
$css_selector2 = ('a[data-id={0}]' -f $value2)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
##
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
Write-Output ('Clicking on ' + $element2.Text)
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()
$actions2.Click().Build().Perform()
Start-Sleep 3

$value1 = 'numGuests'
$css_selector1 = ('a[data-param={0}]' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
##
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'How many travelers'))

Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
Start-Sleep 1

$value2 =  '"2"'
$css_selector2 = ('a[data-id={0}]' -f $value2)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
##
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
Write-Output ('Clicking on ' + $element2.Text)
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()
$actions2.Click().Build().Perform()
Start-Sleep 3

$css_selector1 = 'div.actions > a.search'
try {
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'SEARCH'))
Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()

Start-Sleep 30


# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
