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
  [string]$profile = 'Selenium'
)

function set_timeouts {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [int]$explicit = 10,
    [int]$page_load = 60,
    [int]$script = 30
  )

  [void]($selenium_ref.Value.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

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


try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect($hub_host,[int]$hub_port)
  $connection.Close()
} catch {
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\hub.cmd'
    Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList 'start cmd.exe /c c:\java\selenium\node.cmd'

#   Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"
  Start-Sleep -Seconds 5
}
if ($browser -ne $null -and $browser -ne '' -and $browser -match 'firefox') {


  [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager
  [OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles
  # assert $profiles.GetType() <-  FirefoxProfile[]
  $selected_profile_object = $null
  $profiles | ForEach-Object {
    $item = $_
    # TODO - find how to extract information about all profiles
    $item
  }
  # OpenQA.Selenium.Firefox.FirefoxBinary.StartProfile
  [string]$profilePath =  "c:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\nmkd7a04.Selenium" 
  [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = new-object OpenQA.Selenium.Firefox.FirefoxProfile($profilePath)
#  $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($selected_profile_object)
#
  $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver("C:\Program Files\Mozilla Firefox\firefox.exe", $null)
  # $selected_profile_object.setPreference("general.useragent.override", "Mozilla/5.0 (Windows NT 6.1; rv:15.0) Gecko/20100101 Firefox/15.0")
  # TODO:
  # .AcceptUntrustedCertificates
  # .AlwaysLoadNoFocusLibrary
  # .EnableNativeEvents
  # [void] SetPreference(string name, string value)
}

else {
  Write-Output 'This example only works with Firefox browser'
  exit 0
}


$base_url = 'http://www.wikipedia.org/'
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
$selenium

set_timeouts ([ref]$selenium)
# var hasJQueryLoaded = (bool) js.ExecuteScript("return (window.jQuery != null) && (jQuery.active === 0);");

[int]$timeout = 4000
# change $timeout to see if the WevDriver is waiting on page  sctript to execute

[string]$script = "window.setTimeout(function(){document.getElementById('searchInput').value = 'test'}, ${timeout});"

$start = (Get-Date -UFormat "%s")

try {
  [void]([OpenQA.Selenium.IJavaScriptExecutor]$selenium).executeAsyncScript($script);

} catch [OpenQA.Selenium.WebDriverTimeoutException]{
  # Ignore
  # Timed out waiting for async script result  (Firefox)
  # asynchronous script timeout: result was not received (Chrome)
  [NUnit.Framework.Assert]::IsTrue($_.Exception.Message -match '(?:Timed out waiting for async script result|asynchronous script timeout)')
}
catch [OpenQA.Selenium.NoSuchWindowException]{
  Write-Host $_.Exception.Message # Unable to get browser
  $_.Exception | Get-Member

}
$end = (Get-Date -UFormat "%s")
$elapsed = New-TimeSpan -Seconds ($end - $start)
Write-Output ('Elapsed time {0:00}:{1:00}:{2:00} ({3})' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,($end - $start))
# Start-Sleep 30
# Cleanup
cleanup ([ref]$selenium)




