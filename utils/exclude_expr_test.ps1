param(
  [string]$exclude_dir = 'TestLauncher,something else'
)

$exclude_dirs = @()

$exclude_dirs = ($exclude_dir -split ',') -split ' '
$exclude_dirs
$exclude_dirs.count

$post_switches = ''
if (($exclude_dirs -ne $null) -and ($exclude_dirs.count -ne 0)) {
  $post_switches += ('/XD {0}' -f ($exclude_dirs -join " ")) # TODO MAP quotes
}
$post_switches
$exclude_exprs = @()

$exclude_dirs | ForEach-Object {

  [string]$_dir_ = $_
  if (($_dir_ -ne $null) -and ($_dir_ -ne '')) {
    $_expr_ = ('^{0}\\' -f $_dir_)
    $exclude_exprs += $_expr_
  }
}
$exclude_exprs | Format-List


$test_key = 'TestLauncher\foo'
$found = $false
$exclude_exprs | ForEach-Object {
  $exclude_expr = $_
  if ($test_key -match $exclude_expr) {
    $found = $true
    Write-Output 'match'
  }
}

$test_key = 'TzzzestLauncher\foo'
if ($test_key -match $exclude_expr) {

  Write-Output 'match'
} else {
  Write-Output 'pass'
}
return

