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
$domains_loopback = @(
  'metrics.carnival.com',
  'smetrics.carnival.com',
  'metrics.carnival.co.uk',
  'smetrics.carnival.co.uk',
  'static.ak.facebook.com',
  's-static.ak.facebook.com',
  'ad.doubleclick.net',
  'ad.yieldmanager.com',
  'pc1.yumenetworks.com',
  'fbstatic-a.akamaihd.net',
  'ad.amgdgt.com'
)

# note the order is opposite to what is written in hosts file
$domains_routed = @{

'www3.syscarnival.com' = '172.25.178.70'   ;
'uk3.syscarnival.com'  = '172.25.178.77'  ;

}
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

$current_file_content = Get-Content -Path $local_hosts_file -Encoding ascii


Write-Host -ForegroundColor 'green' 'Prune old routes'

$new_file_content = @()

($current_file_content -split "`n" )  | ForEach-Object {
     $line = $_   
  $keep  = $true
$domains_routed.Keys | ForEach-Object { 
  $domain_name = $_; 

  if ( $line -match $domain_name) {
   Write-Host -ForegroundColor 'yellow'  ( "Removing {0}"  -f $line ) 
  $keep  = $false
  } else {
  $keep  = $false
  }
  }
  if ($keep){
      $new_file_content += $line   
}


}

Write-Host -ForegroundColor 'green' 'Writing Loopback Rootes'
$domains_loopback | ForEach-Object { $domain_name = $_

  $domain_defined_check = $new_file_content -match $domain_name
  if ($domain_defined_check -eq $null -or $domain_defined_check.count -eq 0) {
    $new_file_content += ('127.0.0.1 {0}' -f $domain_name)
  }
}


Write-Host -ForegroundColor 'green' 'Writing Environment-specific Routes'
$domains_routed.Keys | ForEach-Object { 
  # Always add route
  $domain_name = $_; $ip_addreress = $domains_routed[$domain_name]
  $new_file_content += ('{0} {1}' -f $ip_addreress, $domain_name)
}

Set-Content -Path $fixed_hosts_file -Value $new_file_content


