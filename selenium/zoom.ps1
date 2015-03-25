#Copyright (c) 2015 Serguei Kouzmine
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
# http://techlearn.in/content/web-page-zoom-inout-using-selenium-webdriver
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

function highlight {

  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [System.Management.Automation.PSReference]$element_ref,
    [int]$delay = 300
  )

  # https://selenium.googlecode.com/git/docs/api/java/org/openqa/selenium/JavascriptExecutor.html
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'color: yellow; border: 4px solid yellow;')
  Start-Sleep -Millisecond $delay
  [OpenQA.Selenium.IJavaScriptExecutor]$selenium_ref.Value.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element_ref.Value,'')


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

$verificationErrors = New-Object System.Text.StringBuilder
$base_url = 'http://www.mozilla.org/en-US/'
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
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
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

$selenium.Navigate().GoToUrl($base_url)
Start-Sleep -Milliseconds 4000

[void]$selenium.manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(10))
# $selenium.Manage().Window.Size = new-Object System.Drawing.Size(600, 400)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$logo = $selenium.FindElementByXPath("//img[@alt='Mozilla']")
<#
cannot send keys to img node:
Exception calling "SendKeys" with "1" argument(s): 
"unknown error: cannot focus element
#>

$target_text_field = $selenium.FindElementByXPath("//input[contains(@type,'email') or contains(@type, 'text') ]")

highlight ([ref]$selenium) ([ref]$logo)
highlight ([ref]$selenium) ([ref]$target_text_field)

<#
# Some OpenQA.Selenium.Keys do not work with C# client ?
$target_text.SendKeys(([OpenQA.Selenium.Keys]::Control +  [OpenQA.Selenium.Keys]::Substract))
start-sleep -milliseconds 300
#>


Write-Output 'Zoom in'
# zoom in does not seem to work on Chrome or Firefox
(1,2,3,4,5) | ForEach-Object {
  try{
  # https://msdn.microsoft.com/en-us/library/system.windows.forms.sendkeys.send%28v=vs.110%29.aspx
  # + is a mnemonic for SHIFT
  # '^(+)' does not work
  #  "SendKeys string '^++' is not valid
  # OpenQA.Selenium.IKeyboard.SendKeys ? 
  [void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait("^+`0"))
  # [void]$actions.SendKeys($target_text_field,([OpenQA.Selenium.Keys]::Control +  [OpenQA.Selenium.Keys]::Add + [OpenQA.Selenium.Keys]::Null  ))
  # $target_text_field.SendKeys(([OpenQA.Selenium.Keys]::Control + [OpenQA.Selenium.Keys]::Add))
  # $selenium.Keyboard.SendKeys(([OpenQA.Selenium.Keys]::Control +  [OpenQA.Selenium.Keys]::Add + [OpenQA.Selenium.Keys]::Null  ))
  # $selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^+'))
  # $selenium.Keyboard.SendKeys([System.Windows.Forms.SendKeys]::SendWait('^(+)'))
  # key sequence to send must not be null
  # Parameter name: keySequence
  
  Start-Sleep -Milliseconds 500
  } catch [Exception] { 
write-output $_.Exception.Message
  }
}
[void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^0'))
Start-Sleep -Seconds 3
Write-Output 'Reload'

[void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^R'))
Start-Sleep -Seconds 3

Write-Output 'Zoom out'
(1,2,3) | ForEach-Object {
  [void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^-'))
  Start-Sleep -Milliseconds 500
}
Start-Sleep -Seconds 3
[void]$actions.SendKeys($target_text_field,[System.Windows.Forms.SendKeys]::SendWait('^0'))
Start-Sleep -Milliseconds 500


Write-Output 'zoom out'
(1,2,3) | ForEach-Object {
  [void]$actions.SendKeys($target_text,[System.Windows.Forms.SendKeys]::SendWait('^-'))
  Start-Sleep -Milliseconds 500
}
Start-Sleep -Seconds 3

# Cleanup
cleanup ([ref]$selenium)



