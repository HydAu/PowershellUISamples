param(
  [string]$json_template = 'NODE_config_FF_IE_CH_Port5555.json',
  [string]$result_json = 'NODE_config_FF_IE_CH_Port5555.json',
  [string]$selenium_folder = 'c:\selenium-dotnet',
  [string]$hub_host = '192.168.56.101',
  [int]$hub_port = 4444,
  [string]$node_host = $env:COMPUTERNAME,
  [string]$ie_version = '9',
  [switch]$test
)


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

# Production run users the same basename but differnt path 
# for template and final json
# Test run creates a file locally 
#
if ($PSBoundParameters["test"]) {
  $result_json = ('{0}\{1}' -f (Get-ScriptDirectory),'test.json')
}

else {
  Write-Output ('Creating folder "{0}"' -f $selenium_folder)
  if (-not (Get-Item -Path $selenium_folder -ErrorAction 'SilentlyContinue')) {
    Write-Output ('Creating folder "{0}"' -f $selenium_folder)
    New-Item -Path $selenium_folder -ErrorAction 'SilentlyContinue' -Type 'Directory'
  }

  $result_json = ('{0}\{1}' -f $selenium_folder,$result_json)
}
if ($hub_host -eq '') {
  $hub_host = $env:HUB_HOST
}

if (($hub_host -eq '') -or ($hub_host -eq $null)) {
  Write-Error 'The required parameter is missing : HUB_HOST'
  exit (1)
}


if ($hub_port -eq '') {
  $hub_port = $env:HUB_PORT
}

if (($hub_port -eq '') -or ($hub_port -eq $null)) {
  Write-Error 'The required parameter is missing : HUB_PORT'
  exit (1)
}


if ($node_host -eq '') {
  $node_host = $env:NODE_HOST
}

if (($node_host -eq '') -or ($node_host -eq $null)) {
  Write-Error 'The required parameter is missing : NODE_HOST'
  exit (1)
}


$result = (Get-Content -Path $json_template) -join "`n"
$json_object = ConvertFrom-Json -InputObject $result
$json_object.configuration.hubHost = $hub_host
$json_object.configuration.hubPort = $hub_port
$configuration_object = $json_object.configuration
Add-Member -InputObject $configuration_object -NotePropertyName 'host' -NotePropertyValue '' -Force
$json_object.configuration = $configuration_object
$json_object.configuration.host = $node_host

# truncate the file

'' | Out-File -FilePath $result_json -Encoding ascii -Force -Append
ConvertTo-Json -InputObject $json_object | Out-File -FilePath $result_json -Encoding ascii -Force -Append

