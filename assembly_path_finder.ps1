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
# for Nunit 
# http://www.nunit.org/index.php?p=assertions&r=2.2.7
# note CodedUI  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\Packages\{6077292c-6751-4483-8425-9026bc0187b6}

function read_registry {
  param([string]$registry_path,
    [string]$package_name

  )

  pushd HKLM:

  cd -Path $registry_path
  $settings = Get-ChildItem -Path . | Where-Object { $_.Property -ne $null } | Where-Object { $_.Name -match $package_name } | Select-Object -First 1
  $values = $settings.GetValueNames()

  if (-not ($values.GetType().BaseType.Name -match 'Array')) {
    throw 'Unexpected result type'
  }
  $result = $null
  $values | Where-Object { $_ -match 'InstallLocation' } | ForEach-Object { $result = $settings.GetValue($_).ToString(); Write-Debug $result }

  popd
  $result

}

$shared_assemblies = @(
  'Microsoft.VisualStudio.QualityTools.UnitTestFramework.dll'
)
# for MSTEST
$shared_assemblies_path = ("{0}\{1}" -f (read_registry -registry_path '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall' -package_name '{6088FCFB-2FA4-3C74-A1D1-F687C5F14A0D}'),'Common7\IDE\PublicAssemblies')
Write-Output ("Loading assembly from {0}" -f $shared_assemblies_path)
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd

$result = [Microsoft.VisualStudio.TestTools.UnitTesting.Assert]::AreEqual("true",(@( 'true','false') | Select-Object -First 1))


<#
Microsoft.VisualStudio.QualityTools.UnitTestFramework.dll

Caption=Microsoft Visual Studio 2010 Service Pack 1
PackageCode={E36D1CC4-511B-4631-8482-BDBFFCC23F04}
IdentifyingNumber={ED780CA9-0687-3C12-B439-3369F224941F}
has blank InstallLocation

Caption=Microsoft Visual Studio 2010 Performance Collection Tools SP1 - ENU
PackageCode={6E1B280F-80B7-4BFC-B7A1-ADE8457D4D11}
IdentifyingNumber={170DE2A7-4768-370C-9671-D8D17826EFBF}
has blank InstallLocation


Caption=Microsoft Visual Studio 2010 Premium - ENU
PackageCode={B3C71C85-BB28-437A-8811-0C36513616B8}
IdentifyingNumber={6742BE3D-1A59-3BFD-BA20-2FDA866099B8}




Caption=NUnit 2.6.3
PackageCode={4D5C4AE0-EFFE-4F38-A30D-3CDA440C05E4}
IdentifyingNumber={002B407D-DE66-4601-A10C-45941586C767}
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{002B407D-DE66-4601-A10C-45941586C767}
has blank InstallLocation

HKEY_USERS\S-1-5-21-440999728-2294759910-2183037890-1000\Software\nunit.org\NUnit\2.6.3

#>
