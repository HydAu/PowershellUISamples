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


param(
  [string]$button = 'b1',
  [switch]$pause
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"))
  }
}


$o1 = New-Object PSObject
$o2 = New-Object PSObject

@( $o1,$o2) | ForEach-Object {
  Add-Member -InputObject $_ -MemberType 'NoteProperty' -Name 'Name' -Value '' -Force
  Add-Member -InputObject $_ -MemberType 'NoteProperty' -Name 'Text' -Value '' -Force
  Add-Member -InputObject $_ -MemberType 'NoteProperty' -Name 'Pressed' -Value $false -Force
  Add-Member -InputObject $_ -MemberType 'NoteProperty' -Name 'Enabled' -Value $false -Force
  Add-Member -InputObject $_ -MemberType 'NoteProperty' -Name 'Running' -Value $false -Force
}

$o1.Name = 'b1'
$o2.Name = 'b2'
$o1.Text = 'b1'
$o2.Text = 'b2'


$so = [hashtable]::Synchronized(
  @{
    'Buttons' = @( $o1,$o2);
  })

$o2.Pressed = $true
$so.Buttons | Format-Table -AutoSize

$inventory = @{
  'b1' =
  @{ 'server' = 'web30'; 'ip' = '173.194.46.30' };
  'b2' =
  @{ 'server' = 'web23'; 'ip' = '173.194.46.14' };
}

$jobids = @()
$jobs_remaining = @{}

$total_steps = 5
1..($total_steps) | ForEach-Object {

  $current_step = $_
  $message = ('Processed {0} / {1}' -f $current_step,$total_steps)
  Write-Output $message
  # Run Pressed buttons
  $so.Buttons | ForEach-Object {
    if ($_.Pressed) {
      # start-job 
      $message = ('Running "{0}"' -f $_.Text)
      Write-Output $message
      $_.Enabled = $false
      $_.Running = $true
      $_.Pressed = $false
      $inventory | Format-Table -AutoSize
      $deployment_hosts = $inventory[$_.Name]
      $deployment_hosts | Format-Table -AutoSize
      foreach ($deployment_host in $deployment_hosts) {
        $deployment_host_server = $deployment_host['server']
        $deployment_host_ip = $deployment_host['ip']
        $job = Start-Job -FilePath ((Get-ScriptDirectory) + '\' + 'warm_server.ps1') -ArgumentList @( $deployment_host_server,$deployment_host_ip)
        $jobid = $job | Select-Object -ExpandProperty id
        Write-Output ("Started job {0} for deployment host # {1}" -f $jobid,$deployment_host_server)
        $jobids += $jobid
        $jobs_remaining[$jobid] = $true
      }
    }
  }


  # Check Running jobs
  $so.Buttons | ForEach-Object {

    if ($_.Running) {
      # start-job 
      $message = ('Receiving "{0}"' -f $_.Text)
      Write-Output $message

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

        $_.Running = $false
        # receive-job 
        $_.Enabled = $true
        $_.Pressed = $false
      }
    }
  }
  Start-Sleep -Millisecond 1000
}


return;

$wait_retry_secs = 5
$max_retry_count = 100
$deployment_hosts = $inventory[$button]
$deployment_hosts | Format-Table -AutoSize

$jobids = @()
$jobs_remaining = @{}
Write-Output 'Creating job'
$deployment_hosts | Format-Table -AutoSize

# www.codeproject.com/Articles/15227/UI-for-Simple-HTTP-File-Downloader

$start = (Get-Date -UFormat '%s')

foreach ($deployment_host in $deployment_hosts) {
  $deployment_host_server = $deployment_host['server']
  $deployment_host_ip = $deployment_host['ip']
  # for testing purposes choose the sites that are down. 
  # $host_status = Test-Connection -Computername $deployment_host_ip -quiet -count 1
  # if ($host_status -ne $true) {
  #   continue;
  $job = Start-Job -FilePath ((Get-ScriptDirectory) + '\' + 'warm_server.ps1') -ArgumentList @( $deployment_host_server,$deployment_host_ip)
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

