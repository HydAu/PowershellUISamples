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
  # in the current environment phantomejs is not installed 
  [string]$browser = 'firefox',
  [int]$version
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
# http://www.codeproject.com/Tips/816113/Console-Monitor
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Drawing.Imaging;
public class WindowHelper
{
    private Bitmap _bmp;
    private Graphics _graphics;
    private int _count = 0;
    private Font _font;

    private string _timeStamp;
    private string _browser;
    private string _srcImagePath;

    private string _dstImagePath;

    public string DstImagePath
    {
        get { return _dstImagePath; }
        set { _dstImagePath = value; }
    }

    public string TimeStamp
    {
        get { return _timeStamp; }
        set { _timeStamp = value; }
    }

    public string SrcImagePath
    {
        get { return _srcImagePath; }
        set { _srcImagePath = value; }
    }

    public string Browser
    {
        get { return _browser; }
        set { _browser = value; }
    }
    public int Count
    {
        get { return _count; }
        set { _count = value; }
    }
    public void Screenshot(bool Stamp = false)
    {
        _bmp = new Bitmap(Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);
        _graphics = Graphics.FromImage(_bmp);
        _graphics.CopyFromScreen(0, 0, 0, 0, _bmp.Size);
        if (Stamp)
        {
            StampScreenshot();
        }
        else
        {
            _bmp.Save(_dstImagePath, ImageFormat.Jpeg);
        }
        Dispose();
    }

    public void StampScreenshot()
    {
        string firstText = _timeStamp;
        string secondText = _browser;

        PointF firstLocation = new PointF(10f, 10f);
        PointF secondLocation = new PointF(10f, 55f);
        if (_bmp == null)
        {
            createFromFile();
        }
        _graphics = Graphics.FromImage(_bmp);
        _font = new Font("Arial", 40);
        _graphics.DrawString(firstText, _font, Brushes.Black, firstLocation);
        _graphics.DrawString(secondText, _font, Brushes.Blue, secondLocation);
        _bmp.Save(_dstImagePath, ImageFormat.Jpeg);
        Dispose();

    }
    public WindowHelper()
    {
    }

    public void Dispose()
    {
        _font.Dispose();
        _bmp.Dispose();
        _graphics.Dispose();

    }

    private void createFromFile()
    {
        try
        {
            _bmp = new Bitmap(_srcImagePath);
        }
        catch (Exception e)
        {
            throw e;
        }
        if (_bmp == null)
        {
            throw new Exception("failed to load image");
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'

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
  'WebDriver.dll',
  'WebDriver.Support.dll',
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

$baseURL = 'http://www.carnival.com'


$selenium.Navigate().GoToUrl($baseURL + "/")

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(360))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName("logo")))

$selenium.Title


$selenium.Manage().Window.Maximize()
<#
            $selenium.FindElement([OpenQA.Selenium.By]::Id("ccl_header_expand-login-link")).Click()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("username")).Clear()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("username")).SendKeys("xxxx")
            $selenium.FindElement([OpenQA.Selenium.By]::Id("password")).Clear()
            $selenium.FindElement([OpenQA.Selenium.By]::Id("password")).SendKeys("yyyy")

            $selenium.FindElement([OpenQA.Selenium.By]::Id("login")).Click()

#>


$value1 = 'numGuests'
$css_selector1 = ('a[data-param={0}]' -f $value1)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Travelers'))

Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
Start-Sleep -Milliseconds 300

$value2 = '"2"'
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150

$css_selector2 = ('div[class=option][data-param=numGuests] a[data-id={0}]' -f $value2)
try {
  [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
Write-Output ('Clicking on ' + $element2.Text)
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Click().Build().Perform()
Start-Sleep -Milliseconds 300

$value1 = 'dest'
$css_selector1 = ('a[data-param={0}]' -f $value1)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Sail To'))

Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
Start-Sleep -Milliseconds 300

$value2 = 'C'
$css_selector2 = ('a[data-id={0}]' -f $value2)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150

try { [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
Write-Output ('Clicking on ' + $element2.Text)
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()
$actions2.Click().Build().Perform()
Start-Sleep -Milliseconds 300

$has_port_selector = $true
$value1 = 'port'
$css_selector1 = ('a[data-param={0}]' -f $value1)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
} catch [exception]{
  #  this button is optional 
  $has_port_selector = $false
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
if ($has_port_selector) {
  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  [NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Sail from'))
  Write-Output ('Clicking on ' + $element1.Text)
  $element1.Click()
  Start-Sleep -Milliseconds 300


  $value2 = 'FLL'
  $css_selector2 = ('a[data-id={0}]' -f $value2)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
  Write-Output ('Clicking on ' + $element2.Text)
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()
  $actions2.Click().Build().Perform()
  Start-Sleep -Milliseconds 150
}

$value1 = 'dat'
$css_selector1 = ('a[data-param={0}]' -f $value1)

[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'Date'))

Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
Start-Sleep -Milliseconds 300


$value2 = '"022015"'
$css_selector2 = ('a[data-id={0}]' -f $value2)
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
$wait.PollingInterval = 150
try {
  [OpenQA.Selenium.Remote.RemoteWebElement]$element2 = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector2)))

} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$element2 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector2))
Write-Output ('Clicking on ' + $element2.Text)
[OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
$actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element2).Build().Perform()
$actions2.Click().Build().Perform()
Start-Sleep -Milliseconds 300


$css_selector1 = 'div.actions > a.search'
try {
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match 'SEARCH'))
Write-Output ('Clicking on ' + $element1.Text)
$element1.Click()
$element1 = $null
Start-Sleep 1

$css_selector1 = "li[class*=num-found] strong"
try {
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}

$element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
[NUnit.Framework.Assert]::IsTrue(($element1.Text -match '[123456789][1234567890]*'))
Write-Output ('Found ' + $element1.Text)
Write-Output 'Repeat 5 times.'

(1,2,3) | ForEach-Object {
  $cnt = 0
  $css_selector1 = "div[class*=search-result] a.itin-select"
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $elements1 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector1))
  $elements1 | ForEach-Object {

    $element3 = $_

    if (($element5 -eq $null)) {
      if ($element3.Text -match '\S') {
        if (-not ($element3.Text -match 'LEARN MORE')) {
          # $element3
          $cnt = $cnt + 1
          Write-Output ('Found: {0} {1}' -f $element3.Text,$cnt)
          [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
          $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
          [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'color: yellow; border: 4px solid yellow;')
          Start-Sleep -Milliseconds 140
          [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'')
        }
        # cannot LEAN_MORE in a loop 
      }
    }

  }
}

# get first element 
$elements1 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector1))
$elements1 | ForEach-Object {

  if (($element5 -eq $null)) {
    if ($element3.Text -match 'LEARN MORE') {
      # $element3


      Write-Output ('Clicking on ' + $element3.Text)
      [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
      $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Click().Build().Perform()
      Start-Sleep -Milliseconds 3000
      $selenium.Navigate().back()
    }
  }

}
try {
  [OpenQA.Selenium.Screenshot]$screenshot = $selenium.GetScreenshot()
  $guid = [guid]::NewGuid()
  $image_name = ($guid.ToString())
  [string]$image_path = ('{0}\{1}\{2}.{3}' -f (Get-ScriptDirectory),'temp',$image_name,'.jpg')

  [string]$stamped_image_path = ('{0}\{1}\{2}-stamped.{3}' -f (Get-ScriptDirectory),'temp',$image_name,'.jpg')
  $screenshot.SaveAsFile($image_path,[System.Drawing.Imaging.ImageFormat]::Jpeg)


  $owner = New-Object WindowHelper
  $owner.count = $iteration
  $owner.Browser = $browser
  $owner.SrcImagePath = $image_path
  $owner.TimeStamp = Get-Date
  $owner.DstImagePath = $stamped_image_path
  [boolean]$stamp = $false

  $owner.StampScreenshot()

} catch [exception]{
  Write-Output $_.Exception.Message
}

# Do not close Browser / Selenium when run from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  if ($PSBoundParameters['pause']) {
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }
  # Cleanup
  cleanup ([ref]$selenium)
}
