<#
To see lots of debugging output , make the following setting vbefore running 
$DebugPreference = 'Continue';
#>


param(
  [switch]$help,
  [switch]$powerless,
  [switch]$local,
  [string]$source_computer = $env:COMPUTERNAME,
  [string]$destination_computer = $env:COMPUTERNAME,
  [string]$source_path = 'E:\Projects\uat.carnival.com\Carnival',
  [string]$application_name = 'CARNIVAL',
  [string]$exclude_dir = 'App_Data,CMS,Data',
  [string]$destination_parent = 'E:\Backups'
)

if ($PSBoundParameters['help']) {
  $usage = @"
Usage : hashed_backup.ps1 [-powerless] [-exclude_dir "<DIR1>[,<DIR2>]"] [-source_computer <SOURCE_COMPUTER>]  [-destination_computer <DESTINATION_COMPUTER>] [-source_path <SOURCE_PATH>] [-destination_parent <DESTINATION_PARENT_PATH>] [-application_name  <APPLICATION_NAME>] 

Copies the directory SOURCE_PATH on SOURE_COMPUTER to the directory
<DESTINATION_PARENT_PATH>\<APPLICATION_NAME>_yyyyMMddhhmmin 
e.g. D:\Backups\BookingEngine_201411040949
The script uses robocopy 'retry' mode with 4 retries
then computes md checksum of every file in each directory and compares the hashes.
powerless - does not actually -  only pretends to opy files. 
          Still performs md5 hash comparison only

exclude_dir - note that name of the option is singular - 
   pass the comma separated list of directories to exclude from copying and verifying, enclosed in quotes 
   e.g. 'TestLauncher,WebDriverFramework'

Additional param - use at your own risk

"@
  Write-Output $usage
  exit 0
}

$destination_path = ('{0}\{1}_{2}' -f $destination_parent,$application_name,(Get-Date -Format 'yyyyMMddhhmm'))

# TODO - provide option to skip time stamp in destination directory name
# $destination_path = ('{0}\{1}' -f $destination_parent,$application_name)

Write-Host ('Destination={0}' -f $destination_path)

function convert_to_unc {
  param(

    [string]$computer = $env:COMPUTERNAME,
    [string]$localpath = 'C:\TEMP\Automation Suite'
  )
  $file_path = ("\\{0}\{1}" -f $computer,$localpath)
  $unc_file_path = $file_path -replace ':','$'
  return $unc_file_path
}


function shorten_path_key {
  param(
    [string]$unc_path,
    [string]$filepath
  )

  Write-Debug ('filepath={0}' -f $filepath)
  Write-Debug ('unc_path ={0}' -f $unc_path)


  $unc_path_expr = $unc_path
  Write-Debug ('unc_path_expr ={0}' -f $unc_path_expr)
  $unc_path_expr += '\'
  Write-Debug ('unc_path_expr ={0}' -f $unc_path_expr)
  $unc_path_expr = $unc_path_expr -replace '\\','\\'
  Write-Debug ('unc_path_expr ={0}' -f $unc_path_expr)
  $unc_path_expr = $unc_path_expr -replace '\$','\$'
  Write-Debug ('unc_path_expr ={0}' -f $unc_path_expr)

  $filepath_key = $filepath -replace $unc_path_expr,''
  Write-Debug ('filepath_key ={0}' -f $filepath_key)

  return $filepath_key
}


function generate_checksums {
  param($unc_path,
    [System.Management.Automation.PSReference]$results_ref
  )
  Write-Host ('Generating chesksums for {0}' -f $unc_path)

  Write-Debug ('Excluding dirs {0} from hash' -f ($exclude_dirs -join " , "))
  $exclude_exprs = @()


  $exclude_dirs | ForEach-Object {

    [string]$_dir_ = $_
    if (($_dir_ -ne $null) -and ($_dir_ -ne '')) {
      $_expr_ = ('^{0}\\' -f $_dir_)
      $exclude_exprs += $_expr_
    }
  }

  $results = @{};
  $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider;

  pushd "${unc_path}"
  Write-Debug ("Ignoring ~> ""{0}""" -f ($exclude_exprs -join '|'))


  $md5 = New-Object -TypeName 'System.Security.Cryptography.MD5CryptoServiceProvider'
  $files =
  Get-ChildItem -Recurse | Where-Object { -not ($_.Attributes -match 'Directory') }

  # exclude the excluded paths from measuring 
  $files | Where-Object { -not ($_.Fulname -match 'Directory') } | ForEach-Object {
    $target_file = $_

    $found_exclusion = $false
    $fullname = $target_file.FullName
    $filepath_key = (shorten_path_key -unc_path "$unc_path" -FilePath "$fullname")

    $exclude_exprs | ForEach-Object {

      $exclude_expr = $_

      if ($filepath_key -match $exclude_expr) {
        $found_exclusion = $true
        # Write-Debug ('Match: {0} =~ {1}' -f $filepath_key  , $exclude_expr )
      }
    }
    if ($found_exclusion) {
      Write-Debug ('Skipping "{0}"' -f $filepath_key)
    } else {
      $results[$filepath_key] = [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($fullname)))
    }

  }

  popd
  # Write-Host $results.GetType()
  $results_ref.Value = $results

}

function compare_checksums {
  param([object]$data1,
    [object]$data2
  )

  $status = 0

  $data1.Keys | ForEach-Object {
    $filepath_key = $_


    if (-not $data2.Containskey($filepath_key)) {
      Write-Output 'Error 1'
      $status = 1
      Write-Output ("File missing on destination folder`nKey={0}" -f $filepath_key)
    }
    $data = $data1[$filepath_key]
    if ($data2.Item($filepath_key) -ne $data) {
      Write-Output 'Error 2'
      $status = 1
      Write-Output ('Key={0}' -f $filepath_key)
      Write-Output ('Data1={0}' -f $data)
      Write-Output ('Data2={0}' -f $data2.Item($filepath_key))

    }

  }

  $data2.Keys | ForEach-Object {
    $filepath_key = $_

    if (-not $data1.Containskey($filepath_key)) {
      Write-Output 'Error 3'
      $status = 1
      Write-Output ("Extra File on destination folder`nKey={0}" -f $filepath_key)
    }
  }

  return $status
}

# write-output (convert_to_unc)
if (-not $PSBoundParameters['local']) {

  $source_unc_path = convert_to_unc -computer $source_computer -localpath $source_path
  $destination_unc_path = convert_to_unc -computer $destination_computer -localpath $destination_path
} else {
  $source_unc_path = $source_path
  $destination_unc_path = $destination_path
}
$test_item = Get-Item -Path "${source_unc_path}" -ErrorAction silentlycontinue
# OK, do assert the homegrown way  
if ($test_item -ne $null) {
  Write-Output 'Source directory exist'
} else {
  Write-Output ('Source directory "{0}" does not exist' -f $source_unc_path)
  exit 1
}

$test_item = Get-Item -Path "${destination_unc_path}" -ErrorAction silentlycontinue
# OK, do assert the homegrown way  
if ($test_item -eq $null) {
  Write-Output 'Destination directory does not exist'
} else {
  Write-Output 'Warning Source directory already exist'
}

# NOTE ALL FLAGS are currently  defined in one place, and redundant
Write-Output ("Will copy ""{0}"" to ""{1}""" -f $source_unc_path, $destination_unc_path)

# /E :: copy subdirectories, including Empty ones.
# /NP:: No Progress - don't display percentage copied
# /NFL :: No File List - don't log file names.
# /NDL :: No Directory List - don't log directory names.
# /R   :: number of Retries on failed copies: default 1 million.
# /W   :: Wait time between retries: default is 30 seconds.
$switches = '/NFL /NDL /NP /E /R:3  /W:10'
if ( $PSBoundParameters['powerless']) {
  # /L :: List only - don't copy, timestamp or delete any files
  $switches = ( '/L {0}' -f $switches )
}

$post_switches = ''
$exclude_dirs = @()

$exclude_dirs = ($exclude_dir -split ',') -split ' '

Write-Debug ("Processing {0} directoruis to exclude from copying" -f $exclude_dirs.count)

$post_switches = ''
if (($exclude_dirs -ne $null) -and ($exclude_dirs.count -ne 0)) {
  $post_switches += ('/XD {0}' -f ($exclude_dirs -join " ")) # TODO MAP quotes
}

# Command
Write-Output "C:\Windows\System32\Robocopy.exe ${switches} ""${source_unc_path}"" ""${destination_unc_path}"" ${post_switches}"


$status_long = Invoke-Expression -Command "C:\Windows\System32\Robocopy.exe ${switches} ""${source_unc_path}"" ""${destination_unc_path}"" ${post_switches}"


Write-Debug ($status_long -join "`n")

$source_md5 = @{}
$destination_md5 = @{}
[void](generate_checksums -unc_path $source_unc_path -results_ref ([ref]$source_md5))
[void](generate_checksums -unc_path $destination_unc_path -results_ref ([ref]$destination_md5))

$exclude_exprs = @()

$exclude_dirs | ForEach-Object {

  [string]$_dir_ = $_
  if (($_dir_ -ne $null) -and ($_dir_ -ne '')) {
    $_expr_ = ('^{0}\\' -f $_dir_)
    $exclude_exprs += $_expr_
  }
}

Write-Debug ("Ignoring ~> ""{0}""" -f ($exclude_expr -join '|'))

$source_md5.Keys | ForEach-Object {
  $found_exclusion = $false
  $filepath_key = $_

  $exclude_exprs | ForEach-Object {

    $exclude_expr = $_

    if ($filepath_key -match $exclude_expr) {
      $found_exclusion = $true
      # Write-Output ('Match: {0} =~ {1}' -f $filepath_key  , $exclude_expr )
    }
  }
  if ($found_exclusion) {
    Write-Debug ('Skipping "{0}"' -f $filepath_key)
  } else {

    if (-not $destination_md5.Containskey($filepath_key)) {
      Write-Output 'Error 1'
      $status = 1
      Write-Output ("File missing on destination folder`nKey={0}" -f $filepath_key)
    }
    $data = $source_md5[$filepath_key]
    if ($destination_md5.Item($filepath_key) -ne $data) {
      Write-Output 'Error 2'
      $status = 1
      Write-Output ('Key={0}' -f $filepath_key)
      Write-Output ('Data1={0}' -f $data)
      Write-Output ('Data2={0}' -f $destination_md5.Item($filepath_key))

    }

  }

}

$destination_md5.Keys | ForEach-Object {
  $filepath_key = $_

  if (-not $source_md5.Containskey($filepath_key)) {
    Write-Output 'Error 3'
    $status = 1
    Write-Output ("Extra File on destination folder`nKey={0}" -f $filepath_key)
  }
}
# Supressed the call to compare_checksums
# $status = compare_checksums -data1 $destination_md5 -data2 $source_md5
exit $status

