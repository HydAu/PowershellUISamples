#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


# www.codeproject.com/Articles/15227/UI-for-Simple-HTTP-File-Downloader
# http://www.codeproject.com/Articles/24373/Multiple-Thread-Progress-Bar-Control
param(
  [string]$servers_file = ''
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
  if ($env:SCRIPT_PATH -ne '' -and $env:SCRIPT_PATH -ne $null) {
    return $env:SCRIPT_PATH
  }
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}

if ($servers_file -eq '') {
  $servers_file = $env:SERVERS_FILE
}
if (($servers_file -eq $null) -or ($servers_file -eq '')) {
  $(throw "Please specify a SERVERS_FILE to use.")
  exit 1
}

$deployment_hosts = @()
$known_dowm_hosts = @{}
$wait_retry_secs = 5
$max_retry_count = 100

$script_directory = Get-ScriptDirectory
Write-Output "Script directory: ${script_directory}"
$servers_file = ('{0}\{1}' -f $script_directory,$servers_file)
$servers = $servers_file

Import-Csv $servers | ForEach-Object { $entry = @{ 'server' = $_.servername; 'ip' = $_.ipaddress };
  $deployment_hosts += $entry
}
$deployment_hosts | Format-Table -AutoSize

$jobids = @()
$jobs_remaining = @{}
Write-Output 'Creating jobs'
Write-Output "Deployment hosts:"
$deployment_hosts | Format-Table -AutoSize
foreach ($deployment_host in $deployment_hosts) {
  $deployment_host_server = $deployment_host['server']
  $deployment_host_ip = $deployment_host['ip']
  Write-Output $deployment_host_ip
}
$start = (Get-Date -UFormat '%s')

foreach ($deployment_host in $deployment_hosts) {
  $deployment_host_server = $deployment_host['server']
  $deployment_host_ip = $deployment_host['ip']
  if ($known_dowm_hosts.containskey($deployment_host_server)) {
    continue;
  }
  # $host_status = Test-Connection -Computername $deployment_host_ip -quiet -count 1
  # if ($host_status -ne $true) {
  #   continue;
  $job = Start-Job -FilePath ($script_directory + '\' + 'warm_server.ps1') -ArgumentList @( $deployment_host_server,$deployment_host_ip)
  $jobid = $job | Select-Object -ExpandProperty id
  Write-Output ("Started job {0} for deployment host # {1}" -f $jobid,$deployment_host_server)
  $jobids += $jobid
  $jobs_remaining[$jobid] = $true
}
Write-Output 'Waiting for jobs to complete.'

$jobs_completed = @()
foreach ($retry in 0..$max_retry_count) {
  Write-Debug ('Try #{0}' -f $retry)
  Get-Job -State 'Completed'
  $jobs_completed = Get-Job -State 'Completed' | Select-Object -ExpandProperty id | Where-Object { $jobs_remaining.containskey($_) }
  Write-Output ("The number of completed jobs = {0}" -f $jobs_completed.Length)
  if ($jobs_completed -ne $null -and ($jobs_completed.Length -gt 0)) {
    Write-Output ('Finishing {0} jobs' -f $jobs_completed.Length)
    foreach ($deployment_host_index in 0..$jobs_completed.Length) {
      $jobid = $jobs_completed[$deployment_host_index]
      if ($jobid -ne $null) {
        Write-Output ('Finishing job #{0}' -f $jobid)
        Get-Job -Id $jobid
        $dummy = Wait-Job -Id $jobid;
        Write-Output "Receiving job #${jobid}"
        # Receive-Job -id $jobid | out-file './jobs.log' -append 
        Receive-Job -Id $jobid -OutVariable $result
        Write-Output $result
        Remove-Job -Id $jobid
      }
    }
  }
  $jobs_running = Get-Job -State 'Running' | Select-Object -ExpandProperty id | Where-Object { $jobs_remaining.containskey($_) }
  if ($jobs_running.Length -gt 0) {
    $end = (Get-Date -UFormat '%s')
    $elapsed = New-TimeSpan -Seconds ($end - $start)
    Write-Host ('waiting  {0:00}:{1:00}:{2:00} for {3} remaining jobs to complete' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,$jobs_running.Length)

    Start-Sleep -Seconds $wait_retry_secs
  } else {
    Write-Host 'All jobs complete'
    break;
  }
}
Write-Output 'Cleanup'
$jobids = Get-Job -State 'Completed' | Select-Object -ExpandProperty id
if ($jobids -ne $null) {
  foreach ($deployment_host_index in 0..$jobids.Length) {
    if ($jobids[$deployment_host_index] -ne $null) {
      $jobid = $jobids[$deployment_host_index]
      Write-Output "Remove job #${jobid}"
      Remove-Job -Id $jobid
    }
  }
}
Write-Output 'Cleanup of possible blocked jobs'
Get-Job -State 'Blocked' | Select-Object -ExpandProperty id | ForEach-Object { Remove-Job -Id $_ -Force }

