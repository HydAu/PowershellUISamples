param(
  [string]$target_host = '',
  [switch]$test,
  [switch]$debug
)

if ($target_host -eq '') {
  $target_host = $env:TARGET_HOST
}

if (($target_host -eq '') -or ($target_host -eq $null)) {
  Write-Error 'The required parameter is missing : TARGET_HOST'
  exit (1)
}

# Test run runs locally 
# same host 
# TBD: serialization file path 

if ($PSBoundParameters["test"]) {
  $result_json = ('{0}\{1}' -f (Get-ScriptDirectory),'data.json')
  $target_host = $env:COMPUTERNAME
}

else {

  $node_host = $target_host
  # $result_json = ('{0}\{1}' -f $selenium_folder,$result_json)

}

function remote_get_foldersize {

  param(
    [string]$drive_name = 'C:',
    [string[]]$folders,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$build_log
  )


  function Get-FolderSize-Embedded
  {

    begin {
      $fso = New-Object -ComObject Scripting.FileSystemObject
    }
    process {
      $path = $input.fullname
      $folder = $fso.GetFolder($path)
      $size = $folder.size
      if ($size -gt 1mb) {
        [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1Kb) } }
    }

  }


  Write-Output 'Measuring:'
  $folders | Format-Table
  $folders | ForEach-Object {

    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 
      if ($true) { Write-Output $path | Get-FolderSize-Embedded } }
  } | Set-Variable -Name 'result_local'


  $result_ref.Value = $result_local
}
# 
function Get-FolderSize
{

  begin {
    $fso = New-Object -ComObject Scripting.FileSystemObject
  }
  process {
    $path = $input.fullname
    $folder = $fso.GetFolder($path)
    $size = $folder.size
    if ($size -gt 1mb) {
      [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1Kb) } }
  }

}

function get_level1_directories

{
  param(
    [string]$drive_name = 'C:',
    [System.Management.Automation.PSReference]$result_ref,
    [string]$build_log
  )

  $skip = 'sxs'
  pushd $drive_name
  cd '\'
  $local:result = @()
  Get-ChildItem -Directory -ErrorAction SilentlyContinue | ForEach-Object { $path = $_.fullname;

    if (-not ($path -match '\b(Program Files|Program Files \(x86\)|windows|vagrant.*|ruby.*|chef|opscode|java|sxs|Octopus|developer|cygwin|perl|buildagent|.m2)\b')) {
      $local:result += $path
      Write-Output ('added {0} to $local:result ' -f $path)
    }
    else {
      Write-Output ('Skipping directory from measuring: {0}' -f $path)
    } }
  popd

  $result_ref.Value = $local:result
}

$drive_name = 'C:'
$level1 = @()
get_level1_directories -result_ref ([ref]$level1) -drive_name $drive_name
Write-Output 'Measuring:'
<#
$level1 | Format-Table
$level1 | ForEach-Object {

  Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $path = $_; # TODO assert 
    if ($true) { Write-Output $path | Get-FolderSize } }
} | sort size -Descending | Out-GridView
#>

[object[]]$result = @();
remote_get_foldersize -drive_name $drive_name -folders $level1 -result_ref ([ref]$result)

$result | sort size -Descending | Out-GridView
# $remote_run_step1 = Invoke-Command -computer $target_host -ScriptBlock ${function:fix_json_file} -ArgumentList $json_template,$result_json,$test
