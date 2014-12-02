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
