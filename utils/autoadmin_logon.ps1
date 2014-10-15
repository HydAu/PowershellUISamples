param(
  [string]$target_host = '',
  [switch]$enforce,
  [switch]$debug
)

if ($target_host -eq '') {
  $target_host = $env:TARGET_HOST
}


# Macro extrapolation partially works under HEREDOC.

Write-Host -ForegroundColor 'green' ('This call tells if specific account  {0}/{1} would auto log on  {2}' `
     -f $settings.DefaultDomainName,$settings.DefaultUserName,$target_host)


function pure_script {

param(
  [bool]$enforce

)

  if ($enforce) {

write-host "xxx"
}
$settings = @{
  'AutoAdminLogon' = '1';
  # NOTE - account converted to the lower case
  'DefaultUserName' = '_automatedtest';
  'DefaultPassword' = '@ut0te$t!';
  'DefaultDomainName' = 'carnival';
}

$results = @() 
  <# PS is not backward compatible with old tools.
PS C:\Users\tso-sergueik\Desktop\Scripts> 
invoke-expression -command 
"wmic.exe /node:hqvdix64ded0055.carnival.com path win32_computersystem get username,AdminPasswordStatus,Caption /format:list"
Invalid GET Expression.
#>
  $path = '/SOFTWARE/Microsoft/Windows NT/CurrentVersion/Winlogon'
  $name = $null
  $value = $null
  $hive = 'HKLM:'
  pushd $hive
 
  cd $path

  $settings.Keys | ForEach-Object {
    $name = $_
    $value = $settings.Item($name)
    Write-Host -ForegroundColor 'green' (' Reading Setting {0}' -f $name )
    $setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
$results  += $setting
  if ($enforce) {
    Write-Host -ForegroundColor 'green' ('Setting {0} => xxx' -f $name,$value)
if ($setting -ne $null) {

  Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
} else {
  if (-not ($setting -match $value)) {
    New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
  }
}
}
  }

  popd
  return $results
}
if (($target_host -eq '') -or ($target_host -eq $null) -or $target_host -match $env:HOSTNAME) {
  Write-Output 'Run locally'
  if ($PSBoundParameters['enforce']) {
  $result = pure_script $true
  } else {
  $result = pure_script
  }
  Write-Output $result
} else {
  Write-Output 'Run remotely'
  if ($PSBoundParameters['enforce']) {
  $arg = $true
  } else {
  $arg = $null
  }

  $remote_run_result = Invoke-Command -computer $target_host -ScriptBlock ${function:pure_script} -ArgumentList @($arg)   2>&1 
  Write-Output $remote_run_result
}
return


