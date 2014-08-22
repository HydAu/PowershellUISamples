# Microsoft.VisualStudio.TestTools.UnitTesting
# registry  Visual_Studio_Team_Test_Agent_x86
# Microsoft Visual Studio Test Agent 2010 - ENU
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{6088FCFB-2FA4-3C74-A1D1-F687C5F14A0D}
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\15D46E6F7EE9FA540A32DC953FDEFB9E
# string assert class
# note CodedUI  HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\10.0\Packages\{6077292c-6751-4483-8425-9026bc0187b6}
# http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.testtools.unittesting.assert.aspx

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

# for Microsoft.VisualStudio.TestTools.UnitTesting.dll
write-output  ( read_registry -registry_path '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall' -package_name '{6088FCFB-2FA4-3C74-A1D1-F687C5F14A0D}' )
# TODO for nunit.framework.dll 
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-21-52832475-59735490-1501187911-186867\Components\01A9DBD987BE1B05F8AD3F77F95AAEAA
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-21-52832475-59735490-1501187911-186867\Components\2FE4EB3A1F5407F5CA3307D9E2B23146
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-21-52832475-59735490-1501187911-186867\Components\578F65BFDD4B53F46A181A0659D85CD4
# HKEY_USERS\S-1-5-21-52832475-59735490-1501187911-186867\Software\nunit.org\NUnit\2.6.3
