Write-Output "Dump copy"


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
# TODO Transaction 
$profile_path_relative = 'Mozilla\Firefox'

$cached_appdata = ('{0}\data\roaming\{1}' -f (Get-ScriptDirectory),$profile_path_relative)
$cached_localappdata = ('{0}\data\local\{1}' -f (Get-ScriptDirectory),$profile_path_relative)

$profile_path_appdata = ('{0}\{1}' -f $env:APPDATA,$profile_path_relative)
$profile_path_localappdata = ('{0}\{1}' -f $env:LOCALAPPDATA,$profile_path_relative)

$mapped_paths = @{
  $cached_appdata = $profile_path_appdata;
  $cached_localappdata = $profile_path_localappdata;
}


<#
The default profile should always be present
#>

# Copy default profiles into data
# 
<#
$mapped_paths.Keys | ForEach-Object {
  $data_source_path = $_
  $data_target_path = $mapped_paths[$data_source_path]
#
# Copy-Item -Recurse -Path $data_target_path\*default -Destination $data_target_path -Force -ErrorAction 'SilentlyContinue'
}
#>

Write-Output $mapped_paths.Keys
$mapped_paths.Keys | ForEach-Object {
  $data_source_path = $_
  $data_target_path = $mapped_paths[$data_source_path]

  Write-Output "remove-item -recurse -Path ${data_target_path} -Force -ErrorAction 'SilentlyContinue'" -filter 

  Remove-Item -Recurse -Path $data_target_path -Force -ErrorAction 'SilentlyContinue'
  Write-Output "copy-item -recurse -Path ${data_source_path}  -Destination ${data_target_path} -force -errorAction 'SilentlyContinue'"
  Copy-Item -Recurse -Path $data_source_path -Destination $data_target_path -Force -ErrorAction 'SilentlyContinue'
}

Write-Output "Append profiles.ini"

$new_profile = @"

[Profile1]
Name=selenium
IsRelative=1
Path=Profiles/k7b0ih7r.selenium
Default=1

"@
write-output $new_profile | out-file -Filepath ('{0}\profiles.ini' -f  $profile_path_appdata  ) -append -encoding ascii 
Write-Output "Rename uniquely TBD"
# rename unique
pushd $cached_localappdata
$directory_name_current =  (get-childitem -path '.' -filter '*default' | select-object -expandproperty Name )


if ($directory_name_current -eq $null ){
   throw  'The profile directory was not found'
}

$display_name = 'default' 
# TODO Regexp 
$new_name = $directory_name_current -replace '^.+\.' ,'xxxxx.' 
# Use C escapes not Powershell escapes

popd 
pushd $profile_path_appdata
$profiles_ini  = ( get-item -path 'profiles.ini' | select-object -expandproperty Name )
$profile_data = ( get-content $profiles_ini | out-string  )
popd

<# 
[Profile0]
Name=default
IsRelative=1
Path=Profiles/6nt9gnww.default


Append 

[Profile1]
Name=selenium
IsRelative=1
Path=Profiles/k7b0ih7r.selenium
Default=1



#>
