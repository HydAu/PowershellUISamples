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
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}

# http://poshcode.org/1942
function assert {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,ParameterSetName = 'Script',Mandatory = $true)]
    [scriptblock]$Script,
    [Parameter(Position = 0,ParameterSetName = 'Condition',Mandatory = $true)]
    [bool]$Condition,
    [Parameter(Position = 1,Mandatory = $true)]
    [string]$message)

  $message = "ASSERT FAILED: $message"
  if ($PSCmdlet.ParameterSetName -eq 'Script') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = & $Script
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }
  if ($PSCmdlet.ParameterSetName -eq 'Condition') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = $Condition
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }

  if (!$success) {
    throw $message
  }
}

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Selenium.WebDriverBackedSelenium.dll',
  'Moq.dll'
)
$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'
$env:SCREENSHOT_PATH = 'C:\developer\sergueik\powershell_ui_samples'


$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
$screenshot_path = $env:SCREENSHOT_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$phantomjs_executable_folder = 'C:\tools\phantomjs'

if ($PSBoundParameters['browser']) {

  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect('127.0.0.1',4444)
    $connection.Close()
  }
  catch {
    $selemium_driver_folder = 'c:\java\selenium'
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\hub.cmd"
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\node.cmd"
    Start-Sleep 10
  }

  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  $uri = [System.Uri]('http://104.131.159.44:4444/wd/hub')
  $driver = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
  $driver = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $driver.Capabilities.SetCapability('ssl-protocol','any');
  $driver.Capabilities.SetCapability('ignore-ssl-errors',$true);
  $driver.Capabilities.SetCapability("takesScreenshot",$false);
  $driver.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")

  # currently unused 
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder);

}
# http://selenium.googlecode.com/git/docs/api/dotnet/index.html
[void]$driver.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(10))
[string]$baseURL = $driver.Url = 'http://www.wikipedia.org';
$driver.Navigate().GoToUrl(('{0}/' -f $baseURL))
[OpenQA.Selenium.Remote.RemoteWebElement]$queryBox = $driver.FindElement([OpenQA.Selenium.By]::Id('searchInput'))

$queryBox.Clear()
$queryBox.SendKeys('Selenium')
$queryBox.SendKeys([OpenQA.Selenium.Keys]::ArrowDown)
$queryBox.Submit()
$driver.FindElement([OpenQA.Selenium.By]::LinkText('Selenium (software)')).Click()
$title = $driver.Title
# -browser "browserName=safari,version=6.1,platform=OSX,javascriptEnable=true"
assert -Script { ($title.IndexOf('Selenium (software)') -gt -1) } -Message $title
assert -Script { ($driver.SessionId -eq $null) } -Message 'non null session id'

<#
# Take screenshot identifying the browser
$driver.Navigate().GoToUrl("https://www.whatismybrowser.com/")
[OpenQA.Selenium.Screenshot]$screenshot = $driver.GetScreenshot()

$screenshot.SaveAsFile(('{0}\{1}' -f $screenshot_path, 'a.png' ), [System.Drawing.Imaging.ImageFormat]::Png)
#>
# Cleanup
try {
  $driver.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}
