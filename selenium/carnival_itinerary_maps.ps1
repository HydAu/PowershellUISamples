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

$base_url = 'http://www.carnival.com'

$selenium.Navigate().GoToUrl($base_url + '/')

[void]$selenium.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds(100))
# protect from blank page
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150
[void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::ClassName('logo')))

Write-Output ('Started with {0}' -f $selenium.Title)


$selenium.Manage().Window.Maximize()

$destinations = @{
  'Alaska' = 'A';
  'Bahamas' = 'BH';
  'Bermuda' = 'E'
  'Europe' = 'BA'
  'Hawaii' = 'H'
  'Mexico' = 'M'
  'Transatlantic' = 'ET'
  'Caribbean' = 'C';
}
$ports = @{ 'Miami, FL' = 'MIA';
  'Jacksonville, FL' = 'JAX';
}




function select_first_option {
  param([string]$choice = $null,
    [string]$label = $null
  )

  $select_name = $choice

  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 200

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring
  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name,$selecting_value)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $value_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_value_css_selector))
  Write-Output ('Selecting value: {0} / attribute "{1}"' -f $value_element.Text, $value_element.GetAttribute('data-id'))
  # Write-Output ('Clicking on value : {0}  / {1}' -f $value_element.Text, $select_value_css_selector )
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  $value_element = $null
  $actions2 = $null
  Start-Sleep -Milliseconds 20000



}
function select_criteria {

  param([string]$choice = $null,
    [string]$label = $null,
    [string]$option = $null,
    [System.Management.Automation.PSReference]$choice_value_ref = ([ref]$null),
    [string]$value = $null # note formatting

  )

  $select_name = $choice

  if ($value) {
    $selecting_value = $value
  } else {
    $selecting_value = $choice_value_ref.Value[$option]
  }
  $select_css_selector = ('a[data-param={0}]' -f $select_name)
  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $select_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_css_selector))
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)
  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 200

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  $select_value_css_selector = ('div[class=option][data-param={0}] a[data-id={1}]' -f $select_name,$selecting_value)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null
  $value_element = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($select_value_css_selector))
  Write-Output ('Selecting value: {0}' -f $value_element.Text)
  # Write-Output ('Clicking on value : {0}  / {1}' -f $value_element.Text, $select_value_css_selector )
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  Start-Sleep -Milliseconds 200
  $actions2 = $null
  $value_element = $null

}

function search_cruises {
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


}
function count_cruises {
  $css_selector1 = "li[class*=num-found] strong"
  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  [NUnit.Framework.Assert]::IsTrue(($element1.Text -match '[1-9][0-9]*'))
  Write-Output ('Found ' + $element1.Text)


}

select_criteria -choice 'numGuests' -Value '"2"' -label 'TRAVELERS'
select_criteria -choice 'dest' -label 'Sail To' -Option 'Bahamas' -choice_value_ref ([ref]$destinations)
select_criteria -choice 'port' -label 'Sail from' -Option 'Jacksonville, FL' -choice_value_ref ([ref]$ports)
select_first_option -choice 'dat' -Value '"042015"' -label 'Date'
# select_criteria -choice 'dest' -Value 'C' -label 'Sail To' -option  'Caribbean' -choice_value_ref ([ref] $destinations)  
# select_criteria -choice 'port' -Value 'MIA' -label 'Sail from'
# need to find first avail
# select_criteria -choice 'dat' -Value '"042015"' -label 'Date'
#search_cruises
#count_cruises

if (-not ($host.Name -match 'ISE')) {
  if ($PSBoundParameters['pause']) {
    try {
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }
}

<#
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
        # cannot LEARN_MORE in a loop 
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


      Start-Sleep -Milliseconds 3000
      [string]$script = @"
function getPathTo(element) {
    if (element.id!=='')
        return '*[@id="'+element.id+'"]';
    if (element===document.body)
        return element.tagName;

    var ix= 0;
    var siblings= element.parentNode.childNodes;
    for (var i= 0; i<siblings.length; i++) {
        var sibling= siblings[i];
        if (sibling===element)
            return getPathTo(element.parentNode)+'/'+element.tagName+'['+(ix+1)+']';
        if (sibling.nodeType===1 && sibling.tagName===element.tagName)
            ix++;
    }
}
return getPathTo(arguments[0]);
"@
      $result = (([OpenQA.Selenium.IJavaScriptExecutor]$selenium).ExecuteScript($script,$element3,'')).ToString()

      Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element3.Text, $result )
      Write-Output ('Clicking on ' + $element3.Text)
      [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
      $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Click().Build().Perform()
      Start-Sleep -Milliseconds 3000
      $selenium.Navigate().back()
      Start-Sleep -Milliseconds 5000

      Write-Output ('Javascript-generated XPath = "{0}"' -f $result)


      [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(1))
      $wait.PollingInterval = 100
      $xpath = ('//{0}' -f $result)

      try {
        [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($xpath)))
      } catch [exception]{
        Write-Output ("Exception with {0}: {1} ...`n(ignored)" -f $id1,(($_.Exception.Message) -split "`n")[0])
      }

      [OpenQA.Selenium.IWebElement]$element4 = $selenium.FindElement([OpenQA.Selenium.By]::XPath($xpath))

          Write-Output ('Found: {0} {1}' -f $element4.Text,$cnt)
          [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
          $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element4).Build().Perform()
          [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'color: yellow; border: 4px solid yellow;')
          Start-Sleep -Milliseconds 3000
          [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element4,'')
          Start-Sleep -Milliseconds 3000

    }
  }

}
#>
<#
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
#>

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
