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


# Assert Method signatures:
# for Microsoft.VisualStudio.TestTools.UnitTesting.dll
# http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.testtools.unittesting.assert.aspx
# for Nunit 
# http://www.nunit.org/index.php?p=assertions&r=2.2.7
# 


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

$public_assemblies = @(
  'Microsoft.VisualStudio.QualityTools.UnitTestFramework.dll',
  'Microsoft.VisualStudio.QualityTools.CodedUITestFramework.dll',
  'Microsoft.VisualStudio.TestTools.UITest.Common.dll',# Microsoft.VisualStudio.TestTools.UITest.Common.xml
  'Microsoft.VisualStudio.TestTools.UITest.Extension.dll',# Microsoft.VisualStudio.TestTools.UITest.Extension.xml
  'Microsoft.VisualStudio.TestTools.UITesting.dll',# Microsoft.VisualStudio.TestTools.UITesting.xml 
  'Microsoft.Windows.Design.Interaction.dll',# ? UIAutomationTypes
  $null # Microsoft.VisualStudio.QualityTools.WebTestFramework.xml

)


# TODO: assert that the correst SKU of Visual Studio is installed.
# Caption=Microsoft Visual Studio 2010 Premium - ENU
# PackageCode={B3C71C85-BB28-437A-8811-0C36513616B8}
# IdentifyingNumber={6742BE3D-1A59-3BFD-BA20-2FDA866099B8}

# NOTE: registry keys
#[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\Packages\{6077292c-6751-4483-8425-9026bc0187b6}]
#"Assembly"="Microsoft.VisualStudio.QualityTools.CodedUITestPackage, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
#"InprocServer32"="C:\\Windows\\system32\\mscoree.dll"
#"Class"="Microsoft.VisualStudio.TestTools.CodedUITest.UITestPackage"


[string]$public_assemblies_path = '..\IDE\PublicAssemblies'
$microsoft_assemblies_path = ("{0}\{1}" -f ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\VisualStudio\10.0\Setup\VS' -Name 'VS7CommonBinDir').VS7CommonBinDir),$public_assemblies_path)

if (-not (Test-Path -Path $microsoft_assemblies_path)) {

  # The MSBuild notation is $(VS100COMNTOOLS)
  # The "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" setting:
  # VS100COMNTOOLS=c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\

  $VS100COMNTOOLS = 'c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\'
  $microsoft_assemblies_path = ('{0}{1}' -f $VS100COMNTOOLS,$public_assemblies_path)
}
Write-Output ('Loading assembly from {0}' -f $microsoft_assemblies_path)

pushd $microsoft_assemblies_path
$public_assemblies | ForEach-Object {
  if ($_ -eq $null) { return }
  Write-Host $_
  Add-Type -Path $_
}
popd

# Private assemblies

$private_assemblies = @(
  'Microsoft.VisualStudio.TestTools.UITest.Playback.dll',
  'Microsoft.VisualStudio.TestTools.UITest.Framework.dll'
)

[string]$private_assemblies_path = '..\IDE\PrivateAssemblies'

$microsoft_assemblies_path = ("{0}\{1}" -f ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\VisualStudio\10.0\Setup\VS' -Name 'VS7CommonBinDir').VS7CommonBinDir),$private_assemblies_path)

if (-not (Test-Path -Path $microsoft_assemblies_path)) {

  $VS100COMNTOOLS = 'c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\'
  $microsoft_assemblies_path = ('{0}{1}' -f $VS100COMNTOOLS,$public_assemblies_path)
}
Write-Output ('Loading assembly from {0}' -f $microsoft_assemblies_path)
if (-not (Test-Path -Path $microsoft_assemblies_path)) {

  # The MSBuild notation is $(VS100COMNTOOLS)
  # The "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" setting:
  # VS100COMNTOOLS=c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\

  $VS100COMNTOOLS = 'c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\'
  $microsoft_assemblies_path = ('{0}{1}' -f $VS100COMNTOOLS,$public_assemblies_path)
}
Write-Output ('Loading assembly from {0}' -f $microsoft_assemblies_path)



pushd $microsoft_assemblies_path
$private_assemblies | ForEach-Object {
  if ($_ -eq $null) { return }
  Add-Type -Path $_
}
popd


$result = [Microsoft.VisualStudio.TestTools.UnitTesting.Assert]::AreEqual("true",(@( 'true','false') | Select-Object -First 1))
[Microsoft.VisualStudio.TestTools.UITest.Common.UIMap.UIMap]$uimap = New-Object Microsoft.VisualStudio.TestTools.UITest.Common.UIMap.UIMap
$uimap | Get-Member
$aut = New-Object Microsoft.VisualStudio.TestTools.UITesting.ApplicationUnderTest
try {
  $aut = [Microsoft.VisualStudio.TestTools.UITesting.ApplicationUnderTest]::Launch('C:\Windows\notepad.exe','C:\Windows\notepad.exe','')
  # $aut.Launch('C:\Windows\notepad.exe', 'C:\Windows\notepad.exe', '')
} catch [exception]{
  Write-Output (($_.Exception.Message) -split "`n")[0]

  # ignore 
  # Exception calling "Launch" with "1" argument(s): "The following error occurred when this process was started: 
  # Object reference not set to an instance of an object. File: C:\Windows\notepad.exe."
}

$aut | Get-Member


# $name = new-object Microsoft.VisualStudio.TestTools.UITesting.WinControls.WinWindow.PropertyNames
# .WinControls.WinWindow.PropertyNames]
#$name

$aut.SearchProperties['ClassName'] = 'Notepad'
$aut.WindowTitles.Add('Untitled - Notepad')

$uINewCtrlNMenuItem = new-object       Microsoft.VisualStudio.TestTools.UITesting.WinControls.WinMenuItem
$uINewCtrlNMenuItem.SearchProperties['Name']  = "New\tCtrl+N"
$uINewCtrlNMenuItem.WindowTitles.Add("Untitled - Notepad")
$uINewCtrlNMenuItem.Find()

<#
            Debug.WriteLine(DateTime.Now.ToString("dd-MM-yyyy:ss:mm")+ "\t start");
            ApplicationUnderTest aut = ApplicationUnderTest.Launch(@"C:\developer\sergueik\csharp\ControlOperations\ControlOperationsWinForms\bin\Debug\ControlOperationsWinForms.exe");
            WinButton wb = new WinButton(aut);
            wb.SearchProperties.Add(WinButton.PropertyNames.Name, "Create Listbox");
            wb.SearchProperties.Add(WinButton.PropertyNames.Name, "Create Listbox", PropertyExpressionOperator.Contains);
            Mouse.Click(wb);
            Debug.WriteLine(DateTime.Now.ToString("dd-MM-yyyy:ss:mm")+"\t Click");
            // now find the control that will apear after 5 seconds
            WinList wl = new WinList(aut);
            wl.SearchProperties.Add(WinList.PropertyNames.Name, "DynamicListbox");
            wl.WaitForControlExist(7000);
            // now click the button to wait for the control to become enabled
            Debug.WriteLine(DateTime.Now.ToString("dd-MM-yyyy:ss:mm")+"\t Found control ");
            
            WinButton wb2 = new WinButton(aut);
            wb2.SearchProperties.Add(WinButton.PropertyNames.Name, "btnEnable");
            
            Mouse.Click(wb2);
            Debug.WriteLine( DateTime.Now.ToString("dd-MM-yyyy:ss:mm")+ "\t click btn 2 " );
            
            wl.WaitForControlEnabled(7000);
            wl.SelectedItemsAsString = "Blue";
            Debug.WriteLine(DateTime.Now.ToString("dd-MM-yyyy:ss:mm") + "\t blue selected ");
            
            WinButton wb3 = new WinButton(aut);
            wb3.SearchProperties.Add(WinButton.PropertyNames.Name, "Remove Listbox");
            Mouse.Click(wb3);
            Debug.WriteLine( DateTime.Now.ToString("dd-MM-yyyy:ss:mm")+"\t Click 3 ");

            if (wl.WaitForControlNotExist(7000))
            {
                // control is now gone, so assert true
                Debug.WriteLine(DateTime.Now.ToString("dd-MM-yyyy:ss:mm")+"\t Control removed ");

                Assert.IsTrue(true);
            }
            else { Assert.IsTrue(false); }


#>
$UIItemEdit = $aut.UIUntitledNotepadWindow.UIItemWindow.UIItemEdit
[Microsoft.VisualStudio.TestTools.UITesting.Mouse]::Click($uINewCtrlNMenuItem ,(New-Object System.Drawing.Point (38,10)))
