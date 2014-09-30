param(
  [string]$browser
)


# http://www.codeproject.com/Tips/816113/Console-Monitor
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Drawing.Imaging;
public class WindowHelper
{
    private Bitmap bmp;
    private int _count = 0;

    private string _timeStamp;
    private string _browser;
    private string _imagePath;
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

    public string ImagePath
    {
        get { return _imagePath; }
        set { _imagePath = value; }
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
    public void Screenshot()
    {
        bmp = new Bitmap(Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);
        Graphics gr = Graphics.FromImage(bmp);
        gr.CopyFromScreen(0, 0, 0, 0, bmp.Size);
        StampScreenshot();

        string str = _dstImagePath;
        bmp.Save(str, ImageFormat.Jpeg);        
    }

    public void StampScreenshot()
    {
        string firstText = _timeStamp;
        string secondText = _browser;

        PointF firstLocation = new PointF(10f, 10f);
        PointF secondLocation = new PointF(10f, 55f);
        if (bmp == null)
        {
            bmp = createFromFile();
        }

        using (Graphics graphics = Graphics.FromImage(bmp))
        {
            using (Font arialFont = new Font("Arial", 40))
            {
                graphics.DrawString(firstText, arialFont, Brushes.DarkGray, firstLocation);
                graphics.DrawString(secondText, arialFont, Brushes.Aqua, secondLocation);
            }

        }
        //  bmp.Save(_imagePath, ImageFormat.Jpeg);
        string str = _dstImagePath;
        bmp.Save(str, ImageFormat.Jpeg);
        // graphics.Dispose();
        //bmp.UnlockBits();
    }
    public WindowHelper()
    {
    }


    private Bitmap createFromFile()
    {
        Bitmap bmp;
        bmp = new Bitmap(_imagePath);
        return bmp;
    }
}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'




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
function Assert {
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
  'ThoughtWorks.Selenium.Core.dll',
  'ThoughtWorks.Selenium.UnitTests.dll',
  'ThoughtWorks.Selenium.IntegrationTests.dll',
  'Moq.dll'
)
$env:SHARED_ASSEMBLIES_PATH = 'D:\java\teamcity\buildagent\SharedAssemblies'
$env:SHARED_ASSEMBLIES_PATH = 'C:\developer\sergueik\csharp\SharedAssemblies'
$env:SCREENSHOT_PATH = 'C:\Users\_AutomatedTest\Desktop\scripts'


$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
$screenshot_path = $env:SCREENSHOT_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$phantomjs_executable_folder = 'C:\tools\phantomjs'

if ($PSBoundParameters['browser']) {

  $selemium_driver_folder = 'c:\java\selenium'
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\hub.cmd"
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start cmd.exe /c ${selemium_driver_folder}\node.cmd"
  Start-Sleep 10
  # port probe omitted
  # also for grid testing 

  if ($browser -match 'firefox') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

  }
  elseif ($browser -match 'chrome') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
  }
  elseif ($browser -match 'ie') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
  }
  elseif ($browser -match 'safari') {
    $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Safari()
  }
  else {
    throw "unknown browser choice:${browser}"
  }
  $uri = [System.Uri]('http://127.0.0.1:4444/wd/hub')
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

$driver_capabilities = $driver.Capabilities
$driver_capabilities | Format-List



[string]$baseURL = $driver.Url = 'http://www4.uatcarnival.com/';
$driver.Navigate().GoToUrl(('{0}/' -f $baseURL))
$title = $driver.Title
Write-Output $title
assert -Script { ($title -ne $null) } -Message "title should not be blank"
assert -Script { ($title.IndexOf('Cruises | Carnival Cruise') -gt -1) } -Message $title
# start-sleep  -seconds 120

try {
  [OpenQA.Selenium.Screenshot]$screenshot = $driver.GetScreenshot()
  $guid = [guid]::NewGuid()
  $image_name = ($guid.ToString())
  [string]$image_path = ('{0}\{1}\{2}.{3}' -f (Get-ScriptDirectory),'temp',$image_name,'.jpg')
  $screenshot.SaveAsFile($image_path,[System.Drawing.Imaging.ImageFormat]::Jpeg)
  [string]$dest_image_path = ('{0}\{1}\{2}-new.{3}' -f (Get-ScriptDirectory),'screenshots',$image_name,'.jpg')
  $owner = New-Object WindowHelper
  $owner.count = $iteration
  $owner.Browser = ('{0} {1}' -f $driver_capabilities.BrowserName, $driver_capabilities.Version)

  $owner.ImagePath = $image_path
  $owner.TimeStamp = Get-Date
  $owner.DstImagePath = $dest_image_path
  try {
    $owner.StampScreenshot()
  } catch [exception]{
    Write-Output $_.Exception.Message
  }
  Write-Output ('Saving {0}' -f $dest_image_path)
} catch [exception]{
  Write-Output $_.Exception.Message
}

try {
  $driver.Quit()
} catch [exception]{
  # Ignore errors if unable to close the browser
}

# Cleanup - TODO  fix the bug 
# Remove-Item -Path $image_path -Force
