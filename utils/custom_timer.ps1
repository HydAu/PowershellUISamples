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


# for Microsoft.VisualStudio.TestTools.UnitTesting.dll
# http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.testtools.unittesting.assert.aspx
# note CodedUI  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\Packages\{6077292c-6751-4483-8425-9026bc0187b6}

function read_registry{
  param ([string] $registry_path = '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall' , 
         [string] $package_name =  '{6088FCFB-2FA4-3C74-A1D1-F687C5F14A0D}'

)

pushd HKLM:
cd -path $registry_path
$settings = get-childitem -Path . | where-object { $_.Property  -ne $null } | where-object {$_.name -match  $package_name } |   select-object -first 1
$values = $settings.GetValueNames()

if ( -not ($values.GetType().BaseType.Name -match  'Array' ) ) {
  throw 'Unexpected result type'
}
$result = $null 
$values | where-object {$_ -match 'InstallLocation'} | foreach-object {$result = $settings.GetValue($_).ToString() ; write-debug $result}

popd
$result


}



# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
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

$shared_assemblies =  @(
    'Microsoft.VisualStudio.QualityTools.UnitTestFramework.dll'

)

$env:SHARED_ASSEMBLIES_PATH =  'c:\developer\sergueik\csharp\SharedAssemblies'
$env:SCREENSHOT_PATH =  'C:\developer\sergueik\powershell_ui_samples' 


$shared_assemblies_path = (  "{0}\{1}" -f   ( read_registry -registry_path '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall' -package_name '{6088FCFB-2FA4-3C74-A1D1-F687C5F14A0D}' ) , 'Common7\IDE\PublicAssemblies' ) 
$screenshot_path = $env:SCREENSHOT_PATH
pushd $shared_assemblies_path
$shared_assemblies | foreach-object { 
$assembly = $_ 
write-host  ( 'Loading "{0}\{1}"' -f $shared_assemblies_path  , $assembly)
Unblock-File -Path $_ ; Add-Type -Path  $_ 

} 
popd
return
# Microsoft.VisualStudio.TestTools.UnitTesting
# is abstract. Cannot initialize 
# need to subclass 
$o = new-object -TypeName 'Microsoft.VisualStudio.TestTools.UnitTesting.TestContext'
# http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.testtools.unittesting.testcontext.aspx
# http://blogs.msdn.com/b/visualstudioalm/archive/2014/11/17/using-selenium-with-cloud-load-testing.aspx
# http://stackoverflow.com/questions/11495830/unit-testing-a-class-that-uses-a-timer
$o.BeginTimer("BingSearchTest_Navigate")
start-sleep -milleseconds 100
#  _driver.Navigate().GoToUrl("http://www.bing.com/");
$o.EndTimer("BingSearchTest_Navigate")
# TODO for nunit.framework.dll 
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-21-52832475-59735490-1501187911-186867\Components\01A9DBD987BE1B05F8AD3F77F95AAEAA
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-21-52832475-59735490-1501187911-186867\Components\2FE4EB3A1F5407F5CA3307D9E2B23146
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-21-52832475-59735490-1501187911-186867\Components\578F65BFDD4B53F46A181A0659D85CD4
# HKEY_USERS\S-1-5-21-52832475-59735490-1501187911-186867\Software\nunit.org\NUnit\2.6.3
