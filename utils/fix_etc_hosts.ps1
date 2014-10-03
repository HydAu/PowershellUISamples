param(
  [string]$target_host = '',
  [switch]$test,
  [switch]$append,
  [switch]$debug
)

if ($target_host -eq '') {
  $target_host = $env:TARGET_HOST
}

if (($target_host -eq '') -or ($target_host -eq $null)) {
  Write-Error 'The required parameter is missing : TARGET_HOST'
  exit (1)
}

function flush_dns {

  $command = 'C:\Windows\System32\ipconfig.exe /flushdns'
  # $command = 'C:\Windows\System32\ipconfig.exe /all'
  $result = (Invoke-Expression -Command $command)
  Write-Output $result
}

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


function fix_hosts_file {
  param(
    [string]$test,
    [string]$append
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

    'www3.syscarnival.com' = '172.25.178.70';
    'uk3.syscarnival.com' = '172.25.178.77';

  }

  Write-Output $env:COMPUTERNAME
  $local_hosts_file = 'c:\windows\system32\drivers\etc\hosts'
  # 
  # $fixed_hosts_file = ('{0}\{1}' -f (Get-ScriptDirectory),'hosts')
  $fixed_hosts_file = 'C:\temp\hosts.txt'
  if ($PSBoundParameters['test']) {
    Write-Output 'Running in TEST mode.'
    $local_hosts_file = $fixed_hosts_file
  } else {
    Write-Output 'Running in Update mode.'
    $fixed_hosts_file = $local_hosts_file
  }

  Write-Host -ForegroundColor 'green' @"
This script updates  ${fixed_hosts_file}
"@

  if ($PSBoundParameters['append']) {
    Write-Output 'Will append.'
    $current_content = Get-Content -Path $local_hosts_file -Encoding ascii
  } else {
    Write-Output 'Will overwrite.'

    $dummy_hosts_file = @"
# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
"@
    $current_content = $dummy_hosts_file -split "`n"
  }


  Write-Host -ForegroundColor 'green' 'Prune old routes'

  $new_file_content = @()

  ($current_file_content -split "`n") | ForEach-Object {
    $line = $_
    $keep = $true
    $domains_routed.Keys | ForEach-Object {
      $domain_name = $_;

      if ($line -match $domain_name) {
        Write-Host -ForegroundColor 'yellow' ("Removing {0}" -f $line)
        $keep = $false
      } else {
        $keep = $false
      }
    }
    if ($keep) {
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
    $new_file_content += ('{0} {1}' -f $ip_addreress,$domain_name)
  }

  Set-Content -Path $fixed_hosts_file -Value $new_file_content

}

if ($PSBoundParameters['test']) {
  Write-Output 'Starting in TEST mode.'
  $test_argument = 'test'
} else {
  Write-Output 'Starting in Update mode.'
  $test_argument = $null
}

if ($PSBoundParameters['append']) {
  Write-Output 'Will append.'
  $append_argument = 'append'
} else {
  Write-Output 'Will overwrite.'
  $append_argument = $null
}

$remote_run_step1 = Invoke-Command -computer $target_host -ScriptBlock ${function:fix_hosts_file} -ArgumentList $test_argument,$append_argument
Write-Output $remote_run_step1

if (-not ($PSBoundParameters['test'])) {
  $remote_run_step2 = Invoke-Command -computer $target_host -ScriptBlock ${function:flush_dns}
  Write-Output $remote_run_step2
}


