Param (
        [switch] $browser
)

# http://poshcode.org/1942
function Assert {
    [CmdletBinding()]
    param(
       [Parameter(Position=0,ParameterSetName='Script', Mandatory=$true)]
       [ScriptBlock]$Script,
       [Parameter(Position=0,ParameterSetName='Condition', Mandatory=$true)]
       [bool]$Condition,
       [Parameter(Position=1,Mandatory=$true)]
       [string]$message )
     
       $message = "ASSERT FAILED: $message"
       if($PSCmdlet.ParameterSetName -eq 'Script') {
          try {
             $ErrorActionPreference = 'STOP'
             $success = &$Script
          } catch {
             $success = $false
             $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"        
          }
       } 
       if($PSCmdlet.ParameterSetName -eq 'Condition') {
          try {
             $ErrorActionPreference = 'STOP'
             $success = $Condition
          } catch {
             $success = $false
             $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"        
          }
       } 

       if(!$success) {
          throw $message
       }
    }

<#
 # HRESULT: 0x80131515
 # http://stackoverflow.com/questions/18801440/powershell-load-dll-got-error-add-type-could-not-load-file-or-assembly-webdr
 # Streams v1.56 - Enumerate alternate NTFS data streams
 #>

$shared_assemblies =  @(
    'WebDriver.dll',
    'WebDriver.Support.dll',
    'Selenium.WebDriverBackedSelenium.dll',
    'ThoughtWorks.Selenium.Core.dll',
    'ThoughtWorks.Selenium.UnitTests.dll',
    'ThoughtWorks.Selenium.IntegrationTests.dll',
    'Moq.dll'
)

$shared_assemblies_folder = 'c:\developer\sergueik\csharp\SharedAssemblies'
pushd $shared_assemblies_folder
$shared_assemblies | foreach-object { Unblock-File -Path $_ ; Add-Type -Path  $_ } 
popd


$phantomjs_executable_folder = 'C:\tools\phantomjs'

if ($PSBoundParameters['browser']) {
  # for grid testing 
  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
  $uri = [System.Uri]('http://127.0.0.1:4444/wd/hub')
  $driver = new-object OpenQA.Selenium.Remote.RemoteWebDriver($uri , $capability)
} else {
  $driver = new-object OpenQA.Selenium.PhantomJS.PhantomJSDriver($phantomjs_executable_folder)
  $driver.Capabilities.SetCapability('ssl-protocol', 'any' );
  $driver.Capabilities.SetCapability('ignore-ssl-errors', $true);
  $driver.capabilities.SetCapability("takesScreenshot", $false );
  $driver.capabilities.SetCapability("userAgent", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.34 (KHTML, like Gecko) PhantomJS/1.9.7 Safari/534.34")

  # currently unused 
  $options = new-object OpenQA.Selenium.PhantomJS.PhantomJSOptions
  $options.AddAdditionalCapability("phantomjs.executable.path", $phantomjs_executable_folder);

}  

# http://www.andykelk.net/tech/headless-browser-testing-with-phantomjs-selenium-webdriver-c-nunit-and-mono

[void]$driver.Manage().Timeouts().ImplicitlyWait( [System.TimeSpan]::FromSeconds(10 )) 
[string]$baseURL = $driver.Url ='http://www.wikipedia.org';
$driver.Navigate().GoToUrl(('{0}/' -f $baseURL ))
[OpenQA.Selenium.Remote.RemoteWebElement]$queryBox =  $driver.FindElement([OpenQA.Selenium.By]::Id('searchInput'))

# write-output $queryBox.GetType() | format-table -autosize

$queryBox.Clear()
$queryBox.SendKeys('Selenium')
$queryBox.SendKeys([OpenQA.Selenium.Keys]::ArrowDown)
$queryBox.Submit()
$driver.FindElement([OpenQA.Selenium.By]::LinkText('Selenium (software)')).Click()
$title =  $driver.Title

assert -Script { ($title.IndexOf('Selenium (software)') -gt -1 ) } -message $title 

try {
  $driver.Quit()
} catch [Exception] {
  # Ignore errors if unable to close the browser
}
# note:
# https://sepsx.codeplex.com/
