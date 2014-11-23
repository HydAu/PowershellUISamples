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
  [string]$profile = 'default'
  #  [string]$profile = 'Selenium'
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


$shared_assemblies = @{
  'WebDriver.dll' = 2.44;
  'WebDriver.Support.dll' = '2.44';
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = '2.6.3';

}


$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies.Keys | ForEach-Object {
  # http://all-things-pure.blogspot.com/2009/09/assembly-version-file-version-product.html
  $assembly = $_
  $assembly_path = [System.IO.Path]::Combine($shared_assemblies_path,$assembly)
  $assembly_version = [Reflection.AssemblyName]::GetAssemblyName($assembly_path).Version
  $assembly_version_string = ('{0}.{1}' -f $assembly_version.Major,$assembly_version.Minor)
  if ($shared_assemblies[$assembly] -ne $null) {

    if (-not ($shared_assemblies[$assembly] -match $assembly_version_string)) {
      Write-Output ('Need {0} {1}, got {2}' -f $assembly,$shared_assemblies[$assembly],$assembly_path)
      Write-Output $assembly_version
      throw ('invalid version :{0}' -f $assembly )
    }
  }

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd
return
$verificationErrors = New-Object System.Text.StringBuilder

# use Default Web Site to host the page. Enable Directory Browsing.

$hub_port = '4444'
$uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port))


try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect($hub_host,[int]$hub_port)
  $connection.Close()
} catch {
  Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"

  Start-Sleep -Seconds 3
}



$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver

# [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)

# $base_url = 'https://www.priceline.com/smartphone/home.do?plf=PCLN'
$base_url = 'http://www.priceline.com/'
$selenium.Navigate().GoToUrl($base_url)
$selenium.Navigate().Refresh()
set_timeouts ([ref]$selenium)
# Cleanup
cleanup ([ref]$selenium)




