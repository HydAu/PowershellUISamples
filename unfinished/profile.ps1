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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
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

$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
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

[NUnit.Framework.Assert]::IsTrue($host.Version.Major -ge 2)
# TODO : leftover profile lock file
<#
 Directory of C:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\wfywwbuv.default

10/05/2014  06:21 PM                 0 parent.lock
#>
if (Get-Item -Path 'C:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\wfywwbuv.default\parent.lock' -ErrorAction 'SilentlyContinue') {
  Remove-Item -Path 'C:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\wfywwbuv.default\parent.lock'
}

try {
  $connection = (New-Object Net.Sockets.TcpClient)
  $connection.Connect("127.0.0.1",4444)
  $connection.Close()
} catch {
  Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "start cmd.exe /c c:\java\selenium\selenium.cmd"
  Start-Sleep -Seconds 10
}
[string]$profile_directory = 'C:\Users\sergueik\AppData\Roaming\Mozilla\Firefox\Profiles\wfywwbuv.default'
$profile = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile_directory)
Write-Debug 'Starting'
$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($profile)
$selenium | Get-Member
Write-Debug 'Closing'
try {
  $selenium.Close()
  $selenium.Quit()
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]
}


