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
  [string]$hub_host = '127.0.0.1',
  [string]$browser,
  [string]$version,
  [string]$profile='Selenium'
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
  # Ignore errors if unable to close the browser
  Write-Output (($_.Exception.Message) -split "`n")[0]

  }
}


$shared_assemblies = @(
  "WebDriver.dll",
  "WebDriver.Support.dll",
  'nunit.core.dll',
  'nunit.framework.dll'

)
<#

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\WebDriver.dll' 
or one of its dependencies. This assembly is built by a runtime newer than the currently loaded runtime and cannot be loaded.

Add-Type : Could not load file or assembly 
'file:///C:\developer\sergueik\csharp\SharedAssemblies\nunit.framework.dll' or one of its dependencies. 
Operation is not supported. (Exception from HRESULT: 0x80131515) 

use fixw2k3.ps1

Add-Type : Unable to load one or more of the requested types. Retrieve the LoaderExceptions property for more information.
#>

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

$verificationErrors = New-Object System.Text.StringBuilder

# use Default Web Site to host the page. Enable Directory Browsing.

$hub_port = '4444'
$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))

# we are loading a file - path varies
# remote node is linux, 

$base_url = 'file:///root/popup.html'
# local testing 
$base_url = 'file:///C:/developer/sergueik/powershell_ui_samples/selenium/popup.html'
if ($browser -ne $null -and $browser -ne '') {
  try {
    $connection = (New-Object Net.Sockets.TcpClient)
    $connection.Connect($hub_host,[int]$hub_port)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\node.cmd"
    Start-Sleep -Seconds 10
  }
  Write-Host "Running on ${browser}"
  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()


<#


 Directory of C:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\webwebweb.selenium\extensions

10/30/2014  01:09 PM         4,222,513 firebug@software.joehewitt.com.xpi
10/30/2014  01:08 PM           382,710 jid1-aPwS0JCl36iLkQ@jetpack.xpi
               2 File(s)      4,605,223 bytes

#>
[Object]$profile_manager = new-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

[OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles
$profiles.GetType()

$profiles | foreach-object {if ($_ -match $profile){
$selected_profile_object = new-object OpenQA.Selenium.Firefox.FirefoxProfile($_)
} } 
$selected_profile_object
$selected_profile_object.GetType()
$selected_profile_object | get-member
$selected_profile_object.ToString()
# [void] SetPreference(string name, string value)
# .AcceptUntrustedCertificates
# .AlwaysLoadNoFocusLibrary
# .EnableNativeEvents
# profile.setPreferences("foo.bar", 23);

  }

  else {
     write-output 'This example only works with Firefox'
     exit  0
  }
  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capability)
} else {
     write-output 'This example only works with Firefox'
     exit  0
}

$selenium.Navigate().GoToUrl( $base_url )
$selenium.Navigate().Refresh()
# $selenium.Manage().Window.Maximize()

start-sleep 3

$xpath = "//input[@type='button']"

[OpenQA.Selenium.Remote.RemoteWebElement]$button = $selenium.findElement([OpenQA.Selenium.By]::XPath($xpath ))

$button.click()
# http://www.programcreek.com/java-api-examples/index.php?api=org.openqa.selenium.Alert
# NOTE: do not explicitly declare the type here
# [OpenQA.Selenium.Remote.RemoteAlert]
$alert = $selenium.switchTo().alert()

write-output $alert.Text
$alert.accept()

# This works on FF, Chrome, IE 8 - 11
# http://seleniumeasy.com/selenium-tutorials/how-to-handle-javascript-alerts-confirmation-prompts
# e.g. need to be able to copy a url from a dialog box pop up and paste it into a new browser window

Start-Sleep 3

cleanup ([ref]$selenium)



