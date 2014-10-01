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
  elseif ($browser -match 'ie' ) {
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
<#
            $selenium.FindElement([OpenQA.Selenium.By]::Id("ccl_header_expand-login-link")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("username")).Clear()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("username")).SendKeys("xxxx")
            $selenium.FindElement([OpenQA.Selenium.By]::Id("password")).Clear()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("password")).SendKeys("yyyy")

            $selenium.FindElement([OpenQA.Selenium.By]::Id("login")).Click()

#>
#            $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("div.cruise-search-widget >div > div.container >ul >li >a[data-param=dest] > span")).Click()
            
  $value ='dest'
  $css_selector = ('a[data-param={0}]' -f $value)
  Write-Output $css_selector
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    Write-Output $_.Exception.Message
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue(($element.Text -match 'Select a destination'))
$element.Click()
start-sleep -seconds 3

# TODO carribbean

  $value ='C'
  $css_selector = ('a[data-id={0}]' -f $value)
  Write-Output $css_selector
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
    Write-Output $_.Exception.Message
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

    [NUnit.Framework.Assert]::IsTrue(($element.Text -match 'Caribbean'))
$element.Click()

start-sleep -seconds 3
<#
Exception calling "Click" with "0" argument(s): "unknown error: Element is not clickable at point (250, 525). Other element would receive the click: <div
#>
  $value ='dat'

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  [NUnit.Framework.Assert]::IsTrue(($element.Text -match 'Select a date'))
  $element.Click()
start-sleep -seconds 3

  $value ='numGuests'

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
    $element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
  [NUnit.Framework.Assert]::IsTrue(($element.Text -match 'How many travelers'))
  $element.Click()
start-sleep -seconds 3

# perform ??
<#
            $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("a[data-param=dest]")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::LinkText("Caribbean")).Click()
#            $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("div.cruise-search-widget >div > div.container >ul >li >a[data-param=dat] > span")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("a[data-param=dat]")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::LinkText("February 2015")).Click()
#            $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("div.cruise-search-widget >div > div.container >ul >li >a[data-param=numGuests] > span")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::CssSelector("a[data-param=numGuests]")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::LinkText("2 travelers")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::LinkText("Search")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::LinkText("Ocean View")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("cboxClose")).Click()
#            $selenium.FindElement([OpenQA.Selenium.By]::Id("ccl_header_expand-login-link")).Click()
#>
# Cleanup
try {
$selenium.Quit()
} catch [Exception] {
# Ignore errors if unable to close the browser
}
