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
<#
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\WebDriver.dll'
Unblock-File 'c:\developer\sergueik\csharp\SharedAssemblies\WebDriver.dll'
Unblock-File 'c:\developer\sergueik\csharp\SharedAssemblies\WebDriver.Support.dll'
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\WebDriver.Support.dll'
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\Selenium.WebDriverBackedSelenium.dll'
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\ThoughtWorks.Selenium.Core.dll'
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\ThoughtWorks.Selenium.IntegrationTests.dll'
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\ThoughtWorks.Selenium.UnitTests.dll'
Add-Type -Path 'c:\developer\sergueik\csharp\SharedAssemblies\Moq.dll'
#>

# http://selenium.googlecode.com/svn/trunk/docs/api/dotnet/html/N_OpenQA_Selenium.htm
$driver = new-object OpenQA.Selenium.Firefox.FirefoxDriver 
[void]$driver.Manage().Timeouts().ImplicitlyWait( [System.TimeSpan]::FromSeconds(10 )) 
[string]$baseURL = $driver.Url ='http://www.wikipedia.org';
$driver.Navigate().GoToUrl(('{0}/' -f $baseURL ))
[OpenQA.Selenium.Remote.RemoteWebElement]$queryBox =  $driver.FindElement([OpenQA.Selenium.By]::Id('searchInput'))

# write-output $queryBox.GetType() | format-table -autosize

$queryBox.Clear()
$queryBox.SendKeys("Selenium")
$queryBox.SendKeys([OpenQA.Selenium.Keys]::ArrowDown)
$queryBox.Submit()
$driver.FindElement([OpenQA.Selenium.By]::LinkText('Selenium (software)')).Click()
$title =  $driver.Title

assert -Script { ($title.IndexOf('Selenium (software)') -gt -1 ) } -message $title 
$driver.Quit()

# note:
# https://sepsx.codeplex.com/
