param(
  [string]$target_host = $env:COMPUTERNAME,## '',
  [switch]$test,
  [switch]$local,
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
  # TODO : enforce position
  param(
    [string]$drive_name = 'C:',
    [string[]]$folders,
    [System.Management.Automation.PSReference]$result_ref,
    [string]$build_log
  )


  # http://poshcode.org/5647
  function Embedded-Get-FolderSize
  {

    param([string]$path)

    $fso = New-Object -ComObject Scripting.FileSystemObject

    Write-Host ('in the fixed ... "{0}"' -f $path)
    $local:result = [pscustomobject]@{}
    $folder = $fso.GetFolder($path)
    $size = $folder.Size
    if ($size -gt 1mb) {
      $local:result = [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1Kb) }
    }
    return $local:result
  }

  $result = @()
  $result_ref = ([ref]$result)

  $result_ref.Value = @()
  Write-Host 'Measuring:'

  $result_local = @() 
  $folders | ForEach-Object {

    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 

      if ($true) {
        Write-Host ('Measuring {0}' -f $path)
        # NOTE: the following does not work .
        # The inner function receives 
        # "System.Collections.ArrayList+ArrayListEnumeratorSimple"
        # - solution is to switch to regular 
        $result_new = Embedded-Get-FolderSize -Path $path.fullname
        Write-Host ('Measured {0}' -f $path)
        Write-Host $result_new
        if ($result_new -ne $null){
           $result_local += $result_new
        }
      }

    }
  } # result 
  Write-Host 'Pruning results'

  $pruned_result = @()
  $result_local | ForEach-Object {
    $row = $_;
    Write-Host ('row -->{0}' -f $row
    )
    $datarow = @{}
    $row.psobject.properties | ForEach-Object {

      # write-host  ('adding [{0} = {1}]' -f $_.Name,  $_.Value)
      $datarow[$_.Name] = $_.Value

    }
    # not the best schema 
    Write-Debug 'adding row... '
    $pruned_result += @{ $datarow['Name'] = $datarow['Size']; }

    # write-host  'clearing row'
    $datarow = $null
  }


  Write-Host ('Exporting results {0}' -f $pruned_result.Count)
  #  $result_local.GetType()
  $result_ref.Value = $pruned_result
  return $pruned_result



}
# http://poshcode.org/5647
function Get-FolderSize
{

  begin {
    $fso = New-Object -ComObject Scripting.FileSystemObject
  }
  process {
    $path = $input.fullname
    $folder = $fso.GetFolder($path)
    $size = $folder.Size
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


$skip_folders = @'
Program Files
Program Files (x86)
ProgramData
windows
sxs
Users
Bitnami
buildagent
Chef
cygwin
tools
java
vagrant.*
octopus
Perl
Ruby.*
RubyDev
wix
'@
$skip_folders_pattern = ('\b({0})\b' -f ($skip_folders -replace "\(", '\(' -replace "\)", '\)' -replace "`r`n", '|'))


  pushd $drive_name
  cd '\'
  $local:result = @()
  Get-ChildItem -Directory -ErrorAction SilentlyContinue | ForEach-Object { 
     $path = $_.fullname;

    if (-not ($path -match $skip_folders_pattern )) {
      $local:result += $path
      Write-Debug ('added {0} to $local:result ' -f $path)
    }
    else {
      Write-Debug ('Skipping directory from measuring: {0}' -f $path)
    } 
  }
  popd

  $result_ref.Value = $local:result
}

$drive_name = 'C:'
$level1 = @()
get_level1_directories -result_ref ([ref]$level1) -drive_name $drive_name

if ($PSBoundParameters["local"]) {

  Write-Debug 'Measuring:'

  # $level1 | Format-Table

  $result =
  $level1 | ForEach-Object {

    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 
      if ($true) {
        Write-Output -InputObject $path | Get-FolderSize } 
      }
  } | sort size -Descending


  Write-Debug "Result:"

  $pruned_result = @()
  $result | ForEach-Object {
    $row = $_; 
    Write-Debug  ('-->{0}' -f $row)
    $datarow = @{}
    $row.psobject.properties | ForEach-Object {

      Write-Debug  ('Adding [{0} = {1}]' -f $_.Name,$_.Value)
      $datarow[$_.Name] = $_.Value

    }

    # $datarow | Format-Table

    # NOTE: 
    # $pruned_result += $datarow  
    $pruned_result += @{ $datarow['Name'] = $datarow['Size']; }
    $datarow = $null
  }

  $pruned_result | Out-GridView

} else {

  

  
  # TODO - investigate why the following code fragment does not work.
  # $result = @(); $result_ref = ([ref]$result) 
  # $remote_run_step1 = Invoke-Command -computer $target_host -ScriptBlock ${function:remote_get_foldersize} -ArgumentList $drive_name,$level1,$result_ref
  $result = Invoke-Command -computer $target_host -ScriptBlock ${function:remote_get_foldersize} -ArgumentList $drive_name,$level1

  Write-Debug "Display result in gridview:"
  # $result

  $result | sort size -Descending | Out-GridView

}
