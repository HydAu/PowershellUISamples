param(
  [switch]$debug,
  [switch]$test
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
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
$domains = @(
  'static.ak.facebook.com',
  's-static.ak.facebook.com',
  'ad.doubleclick.net',
  'ad.yieldmanager.com',
  'pc1.yumenetworks.com',
  'fbstatic-a.akamaihd.net',
  'ad.amgdgt.com'
)

$local_hosts_file = 'c:\windows\system32\drivers\etc\hosts'
$fixed_hosts_file = ('{0}\{1}' -f (Get-ScriptDirectory),'hosts')

if ($PSBoundParameters['test']) {
  $local_hosts_file = $fixed_hosts_file
} else {
  $fixed_hosts_file = $local_hosts_file
}
Write-Host -ForegroundColor 'green' @"
This script updates  ${fixed_hosts_file}
"@
$current_content = Get-Content -Path $local_hosts_file -Encoding ascii

$domains | ForEach-Object { $domain = $_


  $domain_defined_check = $current_content -match $domain
  if ($domain_defined_check -eq $null -or $domain_defined_check.count -eq 0) {
    $current_content += ('127.0.0.1 {0}' -f $domain)
  }
}

Set-Content -Path $fixed_hosts_file -Value $current_content


