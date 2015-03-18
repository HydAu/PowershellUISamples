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



  function Get-FolderSize-Embedded-Fixed
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

  function Get-FolderSize-Embedded-Broken
  {

    begin {
      $fso = New-Object -ComObject Scripting.FileSystemObject

      Write-Host ('in the embedded ... "{0}"' -f $input)
      #  Deserialized.Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData
    }
    process {
      $path = $input.fullname
      $folder = $fso.GetFolder($path)
      $size = $folder.Size
      if ($size -gt 1mb) {
        [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1Kb) } }
    }

  }
  $result = @()
  $result_ref = ([ref]$result)

  $result_ref.Value = @()
  Write-Host 'Measuring:'
  #  TODO illustrate
  # $folders | Format-Table
  <#  Not working

  $folders | ForEach-Object {

    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 
      if ($true) { Write-Output $path | Get-FolderSize-Embedded-Broken } }
  } | Set-Variable -Name 'result_local'


  #>
  <#  Not working
  $folders | ForEach-Object {
    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 

      if ($true) {
        Write-Host ('Measuring {0}' -f $path)
        # NOTE: the following does not work .
        # The inner function receives 
        # "System.Collections.ArrayList+ArrayListEnumeratorSimple"
        # - solution is to switch to regular 
        Write-Output $path | Get-FolderSize-Embedded-Broken
        Write-Host ('Measured {0}' -f $path)
      }

    }
  } | Set-Variable -Name 'result_local'

  #>
  <#
    Method invocation failed because [System.Management.Automation.PSObject]
    doesn't contain a method named 'op_Addition'.
  #>
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
        $result_new = Get-FolderSize-Embedded-Fixed -Path $path.fullname
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
    Write-Host 'adding row... '
    # 
    # $datarow | format-table
    # $pruned_result += $datarow  
    $pruned_result += @{ $datarow['Name'] = $datarow['Size']; }

    # write-host  'clearing row'
    $datarow = $null
  }


  Write-Host ('Exporting results {0}' -f $pruned_result.Count)
  #  $result_local.GetType()
  $result_ref.Value = $pruned_result
  return $pruned_result



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

  $skip = 'sxs'
  pushd $drive_name
  cd '\'
  $local:result = @()
  Get-ChildItem -Directory -ErrorAction SilentlyContinue | ForEach-Object { $path = $_.fullname;

    if (-not ($path -match '\b(Users|Program Files|Program Files \(x86\)|windows|vagrant.*|ruby.*|chef|opscode|java|sxs|Octopus|developer|cygwin|perl|buildagent|.m2)\b')) {
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

if ($PSBoundParameters["local"]) {

  Write-Output 'Measuring:'

  $level1 | Format-Table

  $result =
  $level1 | ForEach-Object {

    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 
      if ($true) { Write-Output $path | Get-FolderSize } }
  } | sort size -Descending


  Write-Output "Result:"
  # that will be an illusion 
  Write-Output $result


  <#

$result   | foreach-object {$item = $_; write-output  ('-->{0}' -f $item )}
-->@{Name=C:\inetpub\logs\LogFiles; Size=2584176.6953125}
-->@{Name=C:\inetpub\logs; Size=2584176.6953125}
-->@{Name=C:\inetpub\logs\LogFiles\W3SVC1; Size=2011022.12988281}
-->@{Name=C:\inetpub\logs\LogFiles\W3SVC4; Size=573153.387695313}
-->@{Name=C:\mss\clr.pdb\7D30549D4DD444F3B5C8D20C9F0066442; Size=19435}
-->@{Name=C:\mss\clr.pdb; Size=19435}
-->@{Name=C:\mss\kernel32.pdb\5EBCEEB557864581BEB3C7C7861964F82; Size=2307}
-->@{Name=C:\mss\kernel32.pdb; Size=2307}
-->@{Name=C:\mss\ntdll.pdb; Size=2123}
-->@{Name=C:\mss\ntdll.pdb\724B6980A706411CA075547FB95275562; Size=2123}
-->@{Name=C:\inetpub\temp; Size=2015.4912109375}
-->@{Name=C:\mss\System.Data.pdb\8E5C5488687B47678C6239CEC400DE9E1; Size=1555}
-->@{Name=C:\mss\System.Data.pdb; Size=1555}
-->@{Name=C:\inetpub\history; Size=1482.970703125}
-->@{Name=C:\inetpub\temp\appPools; Size=1194.673828125}
#>


  $pruned_result = @()
  $result | ForEach-Object {
    $row = $_; Write-Output ('-->{0}' -f $row)
    $datarow = @{}
    $row.psobject.properties | ForEach-Object {

      Write-Output ('adding [{0} = {1}]' -f $_.Name,$_.Value)
      $datarow[$_.Name] = $_.Value

    }
    # not the best schema 
    Write-Output 'adding row'
    $datarow | Format-Table
    # $pruned_result += $datarow  
    $pruned_result += @{ $datarow['Name'] = $datarow['Size']; }

    Write-Output 'clearing row'
    $datarow = $null
  }
  $pruned_result

  $pruned_result | Out-GridView

  <# 
  $level1 | ForEach-Object {
    Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_; # TODO assert 
      if ($true) { Write-Output $path | Get-FolderSize } }
  } | sort size -Descending | Out-GridView


#>
} else {

  $result = @();
  Write-Output '2'
  # remote_get_foldersize -drive_name $drive_name -folders $level1 -result_ref ([ref]$result)
  Write-Output '3'
  $result_ref = ([ref]$result)
  Write-Output '4'
  # $remote_run_step1 = Invoke-Command -computer $target_host -ScriptBlock ${function:remote_get_foldersize} -ArgumentList $drive_name,$level1,$result_ref
  $result = Invoke-Command -computer $target_host -ScriptBlock ${function:remote_get_foldersize} -ArgumentList $drive_name,$level1
  Write-Output '5'


  Write-Output "Result:"
$result

  $result | sort size -Descending | Out-GridView

}
