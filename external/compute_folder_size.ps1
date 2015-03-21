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
    [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1Kb) }
  }

}


$skip = 'sxs'
pushd 'C:'
cd '\'
$level1 = @()
Get-ChildItem -Directory -ErrorAction SilentlyContinue | ForEach-Object { $path = $_.fullname;

  if (-not ($path -match '\b(Program Files|Program Files \(x86\)|windows|sxs)\b')) {
    $level1 += $path
    Write-Output ('added {0} to $level1 ' -f $path)
  }
  else {
    Write-Output ('Skipping directory from measuring: {0}' -f $path)
  } }
popd
Write-output 'Measuring:' 
$level1 | Format-Table
pushd 'C:'
cd '\'
$level1 | ForEach-Object {

  Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $path = $_; # TODO assert 
    if ($true) { Write-Output $path | Get-FolderSize } }
} | sort size -Descending | Out-GridView

popd
