Write-Host -ForegroundColor 'green' @"
This call shows 32-bit IE version
"@

if (-not [environment]::Is64BitProcess) {
  $path = '/SOFTWARE/Microsoft/Internet Explorer'

} else {
  $path = '/SOFTWARE/Wow6432Node/Microsoft/Internet Explorer'}

$hive = 'HKLM:'

$name = 'svcVersion'
$value = '0'


pushd $hive
cd $path
$setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
if ($setting -ne $null) {
  $setting = $setting.svcVersion
}
popd

Write-Output $setting
<#
This does not work with IE 8 
#>


# Detect Internet Explorer Developer Channel
# "${env:LOCALAPPDATA}\Microsoft\AppV\Client\Integration\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\Root\VFS\ProgramFiles\Internet Explorer\iexplore.exe"

# HKEY_CLASSES_ROOT\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1
# HKEY_CURRENT_USER\Software\Classes\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1
# HKEY_CURRENT_USER\Software\Microsoft\AppV\Client\Integration\Ownership\SOFTWARE\Microsoft\AppV\Client\Packages\9bd02eed-6c11-4ff0-8a3e-0b4733ee86a1
# HKEY_CURRENT_USER\Software\Microsoft\AppV\Client\Integration\Packages\{9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1}

"Integration Location" "%LOCALAPPDATA%\Microsoft\AppV\Client\Integration\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1"
"Staged Location" "C:\ProgramData\App-V\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\681E2361-2C6F-4D47-A8B7-D3F7B288CB45"


# HKEY_CURRENT_USER\Software\Microsoft\AppV\Client\Packages\9bd02eed-6c11-4ff0-8a3e-0b4733ee86a1\REGISTRY\USER\S-1-5-21-440999728-2294759910-2183037890-1000\Software\Microsoft\Internet Explorer

# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\Versions\681E2361-2C6F-4D47-A8B7-D3F7B288CB45\REGISTRY\MACHINE\Software\Microsoft\Internet Explorer

"svcVersion" "DC1"


# HKEY_USERS\S-1-5-21-440999728-2294759910-2183037890-1000\Software\Classes\AppV\Client\Packages\9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1\REGISTRY\USER\S-1-5-21-440999728-2294759910-2183037890-1000_Classes