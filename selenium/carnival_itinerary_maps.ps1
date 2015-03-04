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
  [int]$version,
  [switch]$pause

)
function extract_match {

  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)

  )
  write-Debug ('Extracting from {0}' -f $source )
  $local:results = { }
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  Write-Debug 'extract_match:'
  write-Debug $local:results
  $result_ref.Value = $local:results.Media
}


function custom_pause {

  param([bool]$fullstop)
  # Do not close Browser / Selenium when run from Powershell ISE

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }

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
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\hub.cmd"
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start /min cmd.exe /c c:\java\selenium\node.cmd"
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
  'Bermuda' = 'BM';
  'Europe' = 'E';
  'Hawaii' = 'H'
  'Mexico' = 'M'
  'Canada/New England' = 'NN'; 
  'Transatlantic' = 'ET'
  'Caribbean' = 'C';
}
$ports = @{
  'Miami, FL' = 'MIA';
  'Jacksonville, FL' = 'JAX';
  'Fort Lauderdale, FL' = 'FLL';
  'Seattle, WA' = 'SEA';
  'Los Angeles, CA' = 'LAX';
  'Barcelona, Spain' = 'BCN';
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
  Start-Sleep -Milliseconds 500

  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)

  $select_element.Click()
  $select_element = $null
  Start-Sleep -Milliseconds 500

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 150

  # TODO the css_selector needs refactoring

  $select_value_css_selector = ('div[class=option][data-param={0}] div.scrollable-content div.viewport div.overview ul li a' -f $select_name)
  $value_element = $null
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found...'
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }
  $wait = $null

  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  $value_element = $null

  $actions2 = $null
  Start-Sleep -Milliseconds 500



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
    Write-Output ('"{0}"' -f $option)
    $selecting_value = $choice_value_ref.Value[$option]
    Write-Output $selecting_value
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
  Start-Sleep -Milliseconds 500
  [NUnit.Framework.Assert]::IsTrue(($select_element.Text -match $label))

  Write-Output ('Clicking on ' + $select_element.Text)
  $select_element.Click()
  Start-Sleep -Milliseconds 500
  $select_element = $null



  $select_value_css_selector = ('div[class=option][data-param={0}] a[data-id={1}]' -f $select_name,$selecting_value)
  Write-Output ('Selecting CSS: "{0}"' -f $select_value_css_selector)

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))

  $wait.PollingInterval = 150

  $value_element = $null
  try {
    [OpenQA.Selenium.Remote.RemoteWebElement]$value_element = $wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($select_value_css_selector)))
    Write-Output 'Found value_element...'
    $value_element
    Write-Output ('Selected value: {0} / attribute "{1}"' -f $value_element.Text,$value_element.GetAttribute('data-id'))

  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $wait = $null
  Start-Sleep -Milliseconds 500
  [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
  $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$value_element).Click().Build().Perform()
  Start-Sleep -Milliseconds 500
  $wait = $null
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


}
function count_cruises {
  param(
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)
  )

  $css_selector1 = "li[class*=num-found] strong"

  [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
  $wait.PollingInterval = 500
  try {
    [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($css_selector1)))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  try {
    [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  } catch [exception]{
    Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
  }

  $element1 = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
  Write-Output ('Found ' + $element1.Text)
  $result_ref.Value = $element1.Text

}


# TODO :finish parameters
$fullstop = (($PSBoundParameters['pause']) -ne $null)

select_criteria -choice 'numGuests' -Value '"2"' -label 'TRAVELERS'
# select_criteria -choice 'dest' -label 'Sail To' -Option 'Mexico' -choice_value_ref ([ref]$destinations)
# select_criteria -choice 'port' -label 'Sail from' -Option 'Los Angeles, CA' -choice_value_ref ([ref]$ports)

# select_criteria -choice 'dest' -label 'Sail To' -Option 'Bahamas' -choice_value_ref ([ref]$destinations)
# select_criteria -choice 'port' -label 'Sail from' -Option 'Fort Lauderdale, FL' -choice_value_ref ([ref]$ports)

select_criteria -choice 'dest' -label 'Sail To' -Option 'Europe' -choice_value_ref ([ref]$destinations)
select_criteria -choice 'port' -label 'Sail from' -Option 'Barcelona, Spain' -choice_value_ref ([ref]$ports)

# find first avail
select_first_option -choice 'dat' -label 'Date'
search_cruises
Start-Sleep -Milliseconds 10000
$cruises_count_text = $null
count_cruises -result_ref ([ref]$cruises_count_text)
write-output $cruises_count_text
extract_match -Source $cruises_count_text -capturing_match_expression '\b(?<media>\d+)\b' -label 'media' -result_ref ([ref]$result)
Write-Output ('Found # itinearies: {0}' -f $result)
[NUnit.Framework.Assert]::IsTrue(($result -match '\d+'))

$select_choice = Get-Random -minimum 1 -maximum $result
write-output ("Will try {0}th" -f $select_choice)

$element5 = $null
$css_selector1 = 'div[class*=search-result] a.itin-select'
Write-Output $css_selector1
try {
  [void]$selenium.FindElement([OpenQA.Selenium.By]::CssSelector($css_selector1))
} catch [exception]{
  Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
}
$elements1 = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($css_selector1))
$learn_more_cnt = 0
$elements1 | ForEach-Object {
  $element3 = $_

  if (($element5 -eq $null)) {
    if ($element3.Text -match '\S') {

      if (-not ($element3.Text -match 'LEARN MORE')) {
        # $element3
        
        Write-Output ('Found: {0} count = {1}' -f $element3.Text,$learn_more_cnt)
        [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
        $actions.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Build().Perform()
        [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'color: yellow; border: 4px solid yellow;')
        Start-Sleep -Milliseconds 100
        [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$element3,'')
      }

      if ($element3.Text -match 'LEARN MORE') {
        Write-Output ('Found: {0} count = {1}' -f $element3.Text,$learn_more_cnt)
       $learn_more_cnt = $learn_more_cnt + 1

  if($learn_more_cnt -eq $select_choice) { 
    write-output 'Selecting this itinerary'

        Write-Output ('Saving  XPATH for {0} = "{1}" ' -f $element3.Text,$result)
        Write-Output ('Clicking on ' + $element3.Text)
        [OpenQA.Selenium.Interactions.Actions]$actions2 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
        $actions2.MoveToElement([OpenQA.Selenium.IWebElement]$element3).Click().Build().Perform()
        Start-Sleep -Milliseconds 3000
        [NUnit.Framework.StringAssert]::Contains('http://www.carnival.com/itinerary/',$selenium.url,{})
        Write-Output ("Redirected to url: `n`t'{0}'" -f $selenium.url )

        custom_pause -fullstop $fullstop

        # Click on Book Now

        $book_now_css_selector = 'li[class = action-col] a[class *=btn-red]'

        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($book_now_css_selector)))
        } catch [exception]{
          Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
        }

        $book_now_buttons = $selenium.FindElements([OpenQA.Selenium.By]::CssSelector($book_now_css_selector))
        $book_now_element = $null

        foreach ($element8 in $book_now_buttons) {
          if (!$book_now_element) {
            if ($element8.Text -match 'BOOK NOW') {
              Write-Output ('Selecting {0}' -f $element8.Text)
              $book_now_element = $element8
            }
          }
        }
        $element8 = $null
        [OpenQA.Selenium.Interactions.Actions]$actions4 = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

        [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$book_now_element,'color: yellow; border: 4px solid yellow;')
        Start-Sleep 3
        [OpenQA.Selenium.IJavaScriptExecutor]$selenium.ExecuteScript("arguments[0].setAttribute('style', arguments[1]);",$book_now_element,'')

        $actions4.MoveToElement([OpenQA.Selenium.IWebElement]$book_now_element).Build().Perform()

        Start-Sleep -Millisecond 1000
        Write-Output ('Click : "{0}"' -f $book_now_element.Text)
        $book_now_element.Click()
        Start-Sleep -Milliseconds 1000
        try {
          [NUnit.Framework.StringAssert]::Contains('http://www.carnival.com/BookingEngine/Stateroom',$selenium.url,{})
        } catch [exception]{
          write-output ("Unexpected redirect:`r`t{0}`rtAborting." -f $selenium.url )
          cleanup ([ref]$selenium)
          return
        }
        # Write-Output $selenium.url
        $view_itin_css_selector = 'span.viewitin'

        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($view_itin_css_selector)))
          #          Write-Output 'Found ...'
        } catch [exception]{
          Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
        }

        $view_itin_button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($view_itin_css_selector))
        Write-Output ('Clicked {0} ' -f $view_itin_button.Text)
        $view_itin_button.Click()
        Start-Sleep -Milliseconds 2000

        <#
        # TODO: role=presentation is not found
        $presentation_css_selector = 'a[role=presentation]'
        [OpenQA.Selenium.Support.UI.WebDriverWait]$wait44 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(3))
        $wait44.PollingInterval = 500

        try {
          [void]$wait44.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($presentation_css_selector)))
          $found_presentation = $true   
        } catch [exception]{
          Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
          $found_presentation = $false
        }
        if ($found_presentation) {
          $presentation_button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($presentation_css_selector))

          $presentation_button.Click()
          start-sleep -millisecond 1000
        }
        #>
        Write-Output 'trying page source'
        $page_source = (($selenium.PageSource) -join '')

        if ($page_source -match '/~/media/Images/Itineraries/Maps') {

           $result = $null
           extract_match -Source $page_source -capturing_match_expression '(?<media>/~/media/Images/Itineraries/Maps[^\"]+)' -label 'media' -result_ref ([ref]$result)
           Write-Output ('Found media images: {0}' -f $result)
        } else  { 
           Write-Output ('No media images found')
        }

        # TODO: inner-pages itinerary is not found
        <# 
        $inner_pages_itinerary_css_selector = 'div[class *= itinerary]'
        $inner_pages_itinerary_css_selector =  'form[action *="ItineraryLightbox.aspx"]'
        [OpenQA.Selenium.Support.UI.WebDriverWait]$wait55 = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(30))
        $wait55.PollingInterval = 500

        try {
          [void]$wait55.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($inner_pages_itinerary_css_selector)))
          $found_inner_pages_itinerary = $true   
        } catch [exception]{
          Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
          $found_inner_pages_itinerary = $false
        }
        if ($found_inner_pages_itinerary) {
          $inner_pages_itinerary_button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($inner_pages_itinerary_css_selector))

          $inner_pages_itinerary_button.GetAttribute("innerHTML")
          start-sleep -millisecond 1000
        }
        #>
        #       <!--Pre load map to allow lightbox to be properly sized-->
        #       <img style="display: none;" src="/~/media/Images/Itineraries/Maps/JAX-BAE-04gif.ashx" />


        # <img src="/~/media/Images/Itineraries/Maps/LAX-LAH-04gif.ashx" style="display: none;">
        $close_itin_css_selector = 'a[id = fancybox-close]'

        try {
          [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($close_itin_css_selector)))
        } catch [exception]{
          Write-Output ("Exception : {0} ...`n" -f (($_.Exception.Message) -split "`n")[0])
        }
        $close_itin_button = $selenium.FindElement([OpenQA.Selenium.By]::CssSelector($close_itin_css_selector))

        $close_itin_button.Click()
        # cannot LEARN_MORE in a loop 

        Start-Sleep -Milliseconds 100

        cleanup ([ref]$selenium)
        exit 0

      }
    }
  }
  }

}

custom_pause -fullstop $fullstop
# Do not close Browser / Selenium when run from Powershell ISE
if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}
