Param (
[switch] $browser
)
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
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
"Selenium.WebDriverBackedSelenium.dll"
)

$env:SHARED_ASSEMBLIES_PATH = "c:\Users\sergueik\code\csharp\SharedAssemblies"

$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | foreach-object { Unblock-File -Path $_ ; Add-Type -Path $_ }
popd

<# 
pushd C:\tools 
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>

$verificationErrors = new-object System.Text.StringBuilder
$baseURL = "http://www.theautomatedtester.co.uk/demo1.html"
$phantomjs_executable_folder = "C:\tools\phantomjs"
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
$uri = [System.Uri]("http://127.0.0.1:4444/wd/hub")
$selenium = new-object OpenQA.Selenium.Remote.RemoteWebDriver($uri , $capability)
} else {
$selenium = new-object OpenQA.Selenium.PhantomJS.PhantomJSDriver($phantomjs_executable_folder)
$selenium.Capabilities.SetCapability("ssl-protocol", "any" )
$selenium.Capabilities.SetCapability("ignore-ssl-errors", $true)
$selenium.capabilities.SetCapability("takesScreenshot", $true )
$selenium.capabilities.SetCapability("userAgent", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
$options = new-object OpenQA.Selenium.PhantomJS.PhantomJSOptions
$options.AddAdditionalCapability("phantomjs.executable.path", $phantomjs_executable_folder)
}



$selenium.Navigate().GoToUrl($baseURL + "")
# https://groups.google.com/forum/?fromgroups#!topic/selenium-users/V1eoFUMEPqI
[OpenQA.Selenium.Interactions.Actions] $builder= new-object OpenQA.Selenium.Interactions.Actions($selenium);
# NOTE: failed in phantomjs
[OpenQA.Selenium.IWebElement] $canvas = $selenium.findElement([OpenQA.Selenium.By]::id("tutorial"));
$builder.build();
$builder.moveToElement($canvas, 100, 100)
$builder.clickAndHold()
$builder.moveByOffset(40, 60)
$builder.release();
$builder.perform();

start-sleep -seconds 10

try {
$selenium.Quit()
} catch [Exception] {
# Ignore errors if unable to close the browser
}
