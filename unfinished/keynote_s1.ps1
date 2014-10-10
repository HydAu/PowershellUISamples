param(
  [string]$browser,
  [int]$version,
  [string]$base_url = 'https://my.keynote.com/newmykeynote/logon.do',
  [string]$username,
  [string]$password
)

if ($base_url -eq '') {
  $base_url = $env:BASE_URL
}

if (($base_url -eq '') -or ($base_url -eq $null)) {
  Write-Error 'The required parameter is missing : BASE_URL'
  exit (1)
}

if ($username -eq '') {
  $username = $env:USERNAME
}

if (($username -eq '') -or ($username -eq $null)) {
  Write-Error 'The required parameter is missing : USERNAME'
  exit (1)
}

if ($password -eq '') {
  $password = $env:PASSWORD
}

if (($password -eq '') -or ($password -eq $null)) {
  Write-Error 'The required parameter is missing : PASSWORD'
  exit (1)
}


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

$verificationErrors = New-Object System.Text.StringBuilder


$hub_host = '127.0.0.1'
$hub_port = '4444'

$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c d:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c d:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Debug "Running on ${browser}"
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
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  Write-Debug 'Running on phantomjs'
  $phantomjs_executable_folder = 'C:\tools\phantomjs'
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability('ssl-protocol','any')
  $selenium.Capabilities.SetCapability('ignore-ssl-errors',$true)
  $selenium.Capabilities.SetCapability('takesScreenshot',$true)
  $selenium.Capabilities.SetCapability('userAgent','Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34')
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability('phantomjs.executable.path',$phantomjs_executable_folder)
}

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(120))
$selenium.Navigate().GoToUrl($base_url)
$selenium.Manage().Window.Maximize()

$value1 = 'un'
$css_selector1 = ('input#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))

[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('type') -match 'text'))
$element1.SendKeys($username)


$value1 = 'pw'
$css_selector1 = ('input#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('type') -match 'password'))
$element1.SendKeys($password)


$value1 = 'loginbtn'
$css_selector1 = ('input#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.GetAttribute('value') -match 'Sign In'))

# Write-Output ('Clicking on ' + $element1.GetAttribute('value'))
$element1.Click()

Start-Sleep 5

$value1 = 'graphsNavTab'
$css_selector1 = ('a#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Charts'))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element1).Build().Perform();


Start-Sleep 5

$value1 = 'graphsNavTab'
$css_selector1 = ('li#{0}' -f $value1)
try {
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))

$value2 = 'fa-bar-chart-o'
$css_selector2 = ('i."{0}"' -f $value1)
try {
  #  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  #  $wait.PollingInterval = 150
  #  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  #  $element2 = $element1.FindElements([OpenQA.Selenium.By]::TagName("ul"))
  #  $elements2 = $element1.FindElementByTagName("ul")
  $elements3 = $element1.FindElementsByCssSelector("ul > li > a")
  $element5 = $null

  $cnt = 0

  $elements3 | ForEach-Object { $element3 = $_
    # https://my.keynote.com/newmykeynote/graph.aspx?hist=0&vp=N&yud=1066435

    if (($element3.GetAttribute('href') -match 'graph.asp') -and ($element3.Text -match 'Analyze')) {
      $element5 = $element3
    }
    $cnt++
  }
  # debug 
  # $element5
  [NUnit.Framework.Assert]::IsTrue(($element5.Text -match 'Analyze'))

  [NUnit.Framework.Assert]::IsTrue(($element5.Displayed))
# write-host ('->{0}' -f  $element5.Displayed )
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'color: blue; border: 4px solid blue;')
Start-Sleep 1
[OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element5,'')


#   $element5| get-member

  $element5.SendKeys([OpenQA.Selenium.Keys]::RETURN)
start-sleep 10
#  $element5.Click()   #  - this does not work
  # brute-force. We are sucessfully authenticated 
# $graph_url = 'https://my.keynote.com/newmykeynote/graph.aspx'
# $graph_url = 'https://my.keynote.com/newmykeynote/graph.aspx?hist=0&vp=N&yud=66442'
# $selenium.Navigate().GoToUrl($graph_url)
  # select device 
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
start-sleep -seconds 3

try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
# quotes ?
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector('input[name=regexp]'))
#  $web_element = $selenium.FindElementsByCssSelector("input[name=regexp]")
} catch [exception]{
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))
write-output  $web_element.TagName
$web_element.SendKeys('CCL - Carnival.com')
$web_element.SendKeys([OpenQA.Selenium.Keys]::RETURN)
start-sleep -seconds 3

$web_element  | get-member
<#
try {
  [OpenQA.Selenium.IWebElement]$web_element = $null
  $web_element = $selenium.FindElement([OpenQA.Selenium.By]::Id('step4btn'))
} catch [exception]{
}
[NUnit.Framework.Assert]::IsTrue(($web_element -ne $null))

$web_element.Click()   #  - this does not work
#>

start-sleep -seconds 3
# Cleanup
try {
  $selenium.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}