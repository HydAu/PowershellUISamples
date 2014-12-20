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


# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver
param(
  [switch]$browser,  
  [switch]$pause

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

function set_timeouts {
  param(
    [System.Management.Automation.PSReference]$selenium_ref,
    [int]$explicit = 120,
    [int]$page_load = 600,
    [int]$script = 3000
  )

  [void]($selenium_ref.Value.Manage().Timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
  [void]($selenium_ref.Value.Manage().Timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))

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
$shared_assemblies | ForEach-Object { 
# Unblock-File -Path $_; 
Add-Type -Path $_ 
}
popd
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
$verificationErrors = New-Object System.Text.StringBuilder
$phantomjs_executable_folder = "C:\tools\phantomjs"
if ($PSBoundParameters["browser"]) {
  try {

    $connection.Connect("127.0.0.1",4444)
    $connection.Close()
  } catch {
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"
    Start-Sleep -Seconds 4
  }

[object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

[OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
[OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
$selected_profile_object.setPreference('general.useragent.override','Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16')
$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
[OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

# TODO: finish the syntax
# [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
[NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')

$DebugPreference = 'Continue'

} else {
  $selenium = New-Object OpenQA.Selenium.PhantomJS.PhantomJSDriver ($phantomjs_executable_folder)
  $selenium.Capabilities.SetCapability("ssl-protocol","any")
  $selenium.Capabilities.SetCapability("ignore-ssl-errors",$true)
  $selenium.Capabilities.SetCapability("takesScreenshot",$true)
  $selenium.Capabilities.SetCapability("userAgent","Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")
  $options = New-Object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path",$phantomjs_executable_folder)
}
[void]$selenium.manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(3000))


if ($host.Version.Major -le 2) {
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (480,600)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else { 
  $selenium.Manage().Window.Size = @{ 'Height' = 600; 'Width' = 480; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}

$window_position = $selenium.manage().Window.Position
$window_size = $selenium.manage().Window.Size


$base_url = 'http://www.carnival.com/'
$selenium.Navigate().GoToUrl($base_url)
# set_timeouts ([ref]$selenium)


$css_selector = 'select[data-param=dest] option[disabled][selected]'
write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Sail to')
 [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
 [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))


$css_selector = 'select[data-param=dest] option[value=C]'

write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('Caribbean', $element.Text  )
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

$css_selector_header = 'h2.c-cruise-search__header'
write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector_header )
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element_header = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector_header))
[NUnit.Framework.Assert]::AreEqual('FIND A CRUISE', $element_header.Text  )
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}


$css_selector = 'select[data-param=port] option[disabled][selected]'
write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Sail from')
# [NUnit.Framework.Assert]::AreEqual('Sail to', $element.Text  )
 [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
 [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
# $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

$css_selector = 'select[data-param=port] option[value=FLL]'

write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('Fort Lauderdale, FL', $element.Text  )
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}


$css_selector = 'select[data-param=numGuests] option[disabled][selected]'
write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Travelers')
 [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
 [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))




$css_selector = 'select[data-param=numGuests] option[value="2"]'

write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('2 travelers', $element.Text  )
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()


[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

$css_selector = 'select[data-param=dat] option[disabled][selected]'
write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))
[NUnit.Framework.Assert]::IsTrue($element.Text -match 'Date')
[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()


[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

$css_selector = 'select[data-param=dat] option[value="052015"]'

write-output ( 'Locating via CSS SELECTOR: "{0}"' -f $css_selector )

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
$wait.PollingInterval = 100
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}

[OpenQA.Selenium.IWebElement]$element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector))

[NUnit.Framework.Assert]::AreEqual('May 2015', $element.Text  )
 [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# [void]$actions.SendKeys($result,[System.Windows.Forms.SendKeys]::SendWait("{ENTER}"))
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element).Click().Build().Perform()


[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions.MoveToElement([OpenQA.Selenium.IWebElement]$element_header).Build().Perform()
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector($css_selector_header)))
} catch [exception]{
  Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,$_.Exception.Message )
}


if ($PSBoundParameters['pause']) {
  write-output 'pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}



Start-Sleep -Milliseconds 10000


# Cleanup
cleanup ([ref]$selenium)

