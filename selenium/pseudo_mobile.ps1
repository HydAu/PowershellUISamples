# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver
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

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'nunit.framework.dll'
)

$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://m.carnival.com/'
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
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
[void]$selenium.manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(10))

$selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 480; }
$selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
$window_position = $selenium.manage().Window.Position
$window_size = $selenium.manage().Window.Size
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()


  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $name = "ddlDestinations"
  $xpath = ('//select[@id="{0}"]' -f $name)

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $csspath = 'select#ddlDestinations > option.cclMobileOptionColor'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))

$text1 = 'Caribbean'
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($element)

$availableOptions = $select_element.Options
$index = 0
$max_count = 10
[bool]$found = $false
foreach ($item in $elements)
{
  if ($index -gt $max_count) {
    continue
  }
  if ($found) {
    continue
  }
  # $item
  if ($item.Text -eq $text1) {

    $found = $true

    $select_element.SelectByText($item.Text)
    $select_element.SelectByIndex($index)
    $select_element.SelectByValue($item.GetAttribute('value'))

    $result = $select_element.SelectedOption
    Write-Output $result.Text
    Write-Output $index

    [NUnit.Framework.Assert]::AreEqual($result.Text,$item.Text)
    # [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)


    $result.Click()
    Start-Sleep -Milliseconds 1000

    # NOTE: The [OpenQA.Selenium.Keys]::Enter,Space,Return do not work
    [void]$actions.SendKeys($item,[OpenQA.Selenium.Keys]::Enter)
    # Start-Sleep -Milliseconds 1000
    [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
    Start-Sleep -Milliseconds 1000
  }
  $index++
}


Start-Sleep -Milliseconds 1000

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $name = "ddlDates"
  $xpath = ('//select[@id="{0}"]' -f $name)

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()



  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'select#ddlDates > option.cclMobileOptionColor'

try {

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))

$text1 = 'Apr 2015'
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($element)

$availableOptions = $select_element.Options
$index = 0
$max_count = 10
[bool]$found = $false
foreach ($item in $elements)
{
  if ($index -gt $max_count) {
    continue
  }
  if ($found) {
    continue
  }
  # $item
  if ($item.Text -eq $text1) {

    $found = $true

    $select_element.SelectByText($item.Text)
    $select_element.SelectByIndex($index)
    $select_element.SelectByValue($item.GetAttribute('value'))

    $result = $select_element.SelectedOption
    Write-Output $result.Text
    Write-Output $index

    [NUnit.Framework.Assert]::AreEqual($result.Text,$item.Text)
    # [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $result.Click()
    Start-Sleep -Milliseconds 1000
    [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
  }
  $index++
}



#--- 

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $name = "ddlDestinations"
  $xpath = ('//select[@id="{0}"]' -f $name)

try {


  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}


[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'select#ddlDestinations > option.cclMobileOptionColor'


try {

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))
# write-output $element

$text1 = 'Caribbean'
[OpenQA.Selenium.Support.UI.SelectElement]$select_element = New-Object OpenQA.Selenium.Support.UI.SelectElement ($element)

$availableOptions = $select_element.Options
$index = 0
$max_count = 10
[bool]$found = $false
foreach ($item in $elements)
{
  if ($index -gt $max_count) {
    continue
  }
  if ($found) {
    continue
  }
  # $item
  if ($item.Text -eq $text1) {

    $found = $true

    $select_element.SelectByText($item.Text)
    $select_element.SelectByIndex($index)
    $select_element.SelectByValue($item.GetAttribute('value'))

    $result = $select_element.SelectedOption
    Write-Output $result.Text
    Write-Output $index

    [NUnit.Framework.Assert]::AreEqual($result.Text,$item.Text)
    # [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)


    $result.Click()
    Start-Sleep -Milliseconds 1000

    # NOTE: The [OpenQA.Selenium.Keys]::Enter,Space,Return do not work
    [void]$actions.SendKeys($item,[OpenQA.Selenium.Keys]::Enter)
    # Start-Sleep -Milliseconds 1000
    [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
    Start-Sleep -Milliseconds 1000
  }
  $index++
}



#--- 
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'div.traveler-counter > a.more'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$more_cnt = 3

for ($cnt = 0; $cnt -ne $more_cnt; $cnt++) {
  $element.Click()
}
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'div.traveler-counter > a.less'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$more_cnt = 3
for ($cnt = 0; $cnt -ne $more_cnt; $cnt++) {
  $element.Click()
  # Start-Sleep -Milliseconds 500

}


  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $csspath = 'div.find-cruise-submit > a'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$element.Click()

Start-Sleep -Milliseconds 1000

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $csspath = 'a.refineResultsButton'

try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$element.Click()

Start-Sleep -Milliseconds 1000
# 

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $csspath = "span.ui-btn-text"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))
# write-output $element

$text1 = 'Ship'

$index = 0
$max_count = 10
[bool]$found = $false
foreach ($item in $elements)
{

  if ($index -gt $max_count) {
    continue
  }
  if ($found) {
    continue
  }
  # $item
  if ($item.Text -eq $text1) {

    $found = $true
    $item
    [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $actions.MoveToElement([OpenQA.Selenium.IWebElement]$item).Click().Build().Perform()
  }
  $index++
}

# scroll away from tool bar
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript('scroll(0, 500)',$null)
Start-Sleep -Seconds 1



  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100
  $csspath = "div#shipCode > label.ships"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}

[OpenQA.Selenium.IWebElement[]]$elements = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($csspath))
# write-output $element


$text1 = 'Dream'

$index = 0
$max_count = 20
[bool]$found = $false
foreach ($item in $elements)
{


  if ($index -gt $max_count) {
    continue
  }
  if ($found -eq $true) {
    continue
  }

  if ($item.Text -match $text1) {

    [NUnit.Framework.Assert]::AreEqual($item.Text,'Carnival Dream')
    #    write-output $index 
    #    write-output '*'
    #    write-output $item.Text

    $found = $true
    [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
    $cbs = $item.FindElement([OpenQA.Selenium.By]::CssSelector("div.custom-checkbox"))

    $cbs.Click()
    [void]$actions.SendKeys($cbs,[OpenQA.Selenium.Keys]::SPACE)
    # $item | get-member

  }
  $index++
}



try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'a#filterResults'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$element.Click()


try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'div.sailing-dates'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
[NUnit.Framework.Assert]::AreEqual($element.Text,'Show Sailing Dates')


$element.Click()
# scroll away from tool bar
[void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript('scroll(0, 500)',$null)
Start-Sleep -Seconds 1

try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'i.fa-chevron-circle-right'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
$element.Click()


Start-Sleep -Milliseconds 1000


try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'a#btnContinue'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
Write-Output $element.Text
$element.Click()
# assert 
Start-Sleep -Milliseconds 1000
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'a#available'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
Write-Output $element.Text
$element.Click()
# assert 
Start-Sleep -Milliseconds 1000

try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'a#btnContinueFromRateOption'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
Write-Output $element.Text
$element.Click()
# assert 
Start-Sleep -Milliseconds 1000

try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'a#btnContinueStateRoom'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
Write-Output $element.Text
$element.Click()
# assert 
Start-Sleep -Milliseconds 1000
try {

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
  $wait.PollingInterval = 100

  $csspath = 'a#btnContinueYourStateRoom'

  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($csspath)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
}
[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($csspath))
Write-Output $element.Text
$element.Click()
# assert 

Start-Sleep -Milliseconds 10000


# Cleanup
cleanup ([ref]$selenium)

