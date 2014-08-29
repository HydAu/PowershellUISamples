Param (
[switch] $browser
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
$Invocation = (Get-Variable MyInvocation -Scope 1).Value
if ($Invocation.PSScriptRoot) {
  $Invocation.PSScriptRoot
}
Elseif ($Invocation.MyCommand.Path) {
  Split-Path $Invocation.MyCommand.Path
} else {
  $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
}
}

$shared_assemblies = @(
  "WebDriver.dll",
  "WebDriver.Support.dll",
  "Selenium.WebDriverBackedSelenium.dll",
  "nunit.framework.dll"
)

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | foreach-object { Unblock-File -Path $_ ; Add-Type -Path $_; write-debug ("Loaded {0} " -f $_) }
popd


if ($PSBoundParameters["browser"]) {
  try { 
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    start-process -filepath "C:\Windows\System32\cmd.exe" -argumentlist "start cmd.exe /c c:\java\selenium\hub.cmd"
    start-process -filepath "C:\Windows\System32\cmd.exe" -argumentlist "start cmd.exe /c c:\java\selenium\node.cmd"
    start-sleep -seconds 10
  }
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  $selenium = new-object OpenQA.Selenium.Remote.RemoteWebDriver([System.Uri]("http://127.0.0.1:4444/wd/hub"), $capability )
} else {
  $phantomjs_executable_folder = "C:\tools\phantomjs"
  $selenium = new-object OpenQA.Selenium.PhantomJS.PhantomJSDriver($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol", "any" )
  $selenium.Capabilities.SetCapability("ignore-ssl-errors", $true)
  $selenium.capabilities.SetCapability("takesScreenshot", $true )
  $selenium.capabilities.SetCapability("userAgent", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = new-object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path", $phantomjs_executable_folder)
}

  $verificationErrors = new-object System.Text.StringBuilder
  $baseURL = 'http://www.wikipedia.org'
  $selenium.Navigate().GoToUrl($baseURL)
  [OpenQA.Selenium.Interactions.Actions]  $actions = new-object OpenQA.Selenium.Interactions.Actions($selenium)  
  $element = $driver.FindElement([OpenQA.Selenium.By]::Id('searchInput'))

  $actions.MoveToElement( [OpenQA.Selenium.IWebElement]$element ).Build().Perform();
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = new-object OpenQA.Selenium.Support.UI.WebDriverWait($selenium, [System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 100
  [OpenQA.Selenium.Remote.RemoteWebElement]  $element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::Id("hplogo")))
  try {
    $selenium.Quit()
  }   catch [Exception] {
}
[NUnit.Framework.Assert]::AreEqual($verificationErrors.Length, 0)