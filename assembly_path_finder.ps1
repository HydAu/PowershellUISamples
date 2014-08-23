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
  param ([string] $registry_path,
         [string] $package_name

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

$shared_assemblies =  @(
    'Microsoft.VisualStudio.QualityTools.UnitTestFramework.dll'
)

$shared_assemblies_path = (  "{0}\{1}" -f   ( read_registry -registry_path '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall' -package_name '{6088FCFB-2FA4-3C74-A1D1-F687C5F14A0D}' ) , 'Common7\IDE\PublicAssemblies' ) 

pushd $shared_assemblies_path
$shared_assemblies | foreach-object { Unblock-File -Path $_ ; Add-Type -Path  $_ } 
popd

$result =[Microsoft.VisualStudio.TestTools.UnitTesting.Assert]::AreEqual("true", (@('true','false') | select-object -first 1) )

