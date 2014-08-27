param (
  [string] $servers_file = '',
  [string] $use_servers_file = ''
) 



if ($use_servers_file -eq '') {
	$use_servers_file = $env:USE_SERVERS_FILE
}

if ($servers_file -eq '') {
	$servers_file = $env:SERVERS_FILE
}

if ((($servers_file -eq $null ) -or ($servers_file -eq '') ) -and (($use_servers_file  -eq $true ) -or ($use_servers_file  -eq 'true') ))  {
  $(throw "Please specify a SERVERS_FILE to use.")
  exit 1
}

$deployment_hosts = @( )
$known_dowm_hosts = @{ } 
$wait_retry_secs = 5
$max_retry_count = 100 

#Import servername and IP address from CSV File


# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{

   if ($env:SCRIPT_PATH -ne '' -and $env:SCRIPT_PATH -ne $null ) {
    # override 
    return $env:SCRIPT_PATH
   }

    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

$script_directory = Get-ScriptDirectory

write-output "Script directory: ${script_directory}"

$servers_file  = ( '{0}\{1}' -f $script_directory, $servers_file )
$servers = $servers_file
$csv = Import-CSV $servers 
$csv| foreach-object {$entry =   @{ 'server' = $_.servername ; 'ip' = $_.ipaddress }; 
       $deployment_hosts +=        $entry
}
$deployment_hosts  | format-table -autosize

       

$jobids = @() 
$jobs_remaining = @{}
write-output 'Creating jobs'
write-output "Deployment hosts:"
$deployment_hosts  | format-table -autosize
foreach ($deployment_host in $deployment_hosts) {
$deployment_host_server =  $deployment_host['server']
$deployment_host_ip =  $deployment_host['ip']
write-output $deployment_host_ip
}
# return
foreach ($deployment_host in $deployment_hosts) {
$deployment_host_server =  $deployment_host['server']
$deployment_host_ip =  $deployment_host['ip']

if ($known_dowm_hosts.containskey($deployment_host_server) ) {
   continue;

}
# $host_status = Test-Connection -Computername $deployment_host_ip -quiet -count 1
# if ($host_status -ne $true) {
#   continue;
#}

$job = start-job -FilePath ($script_directory  + '\' + 'warm_server.ps1' ) -ArgumentList @($deployment_host_server, $deployment_host_ip)  

$jobid = $job | select-object -ExpandProperty id 
write-output ("Started job {0} for deployment host # {1}" -f  $jobid , $deployment_host_server )
$jobids +=  $jobid
$jobs_remaining[$jobid] = $true
}

write-output 'Waiting for jobs to complete.'

$jobs_completed = @() 

foreach ($retry in 0..$max_retry_count){

write-output "Try ${retry}"
get-job -State 'Completed'

$jobs_completed = get-job -State 'Completed' | select-object -expandproperty id | where-object {$jobs_remaining.containskey($_)}
write-output ( "The number of completed jobs = {0}" -f $jobs_completed.length  )

if ($jobs_completed.length -gt 0 ){

write-output ('Finishing {0} jobs' -f $jobs_completed.length) 
foreach ($deployment_host_index in 0..$jobs_completed.length) {

  $jobid = $jobs_completed[$deployment_host_index]
  write-output ('Finishing job {0}' -f $jobid)

  if ($jobid -ne $null){
    get-job -Id $jobid
    $dummy = wait-Job -Id $jobid  ; 
    write-output "Receiving job ${jobid}"
    # Receive-Job -id $jobid | out-file './jobs.log' -append 
    Receive-Job -Id $jobid  -OutVariable $result
    write-output $result
    Remove-Job -Id $jobid 
  }
}

}
$jobs_running = get-job -State 'Running' | select-object -expandproperty id | where-object {$jobs_remaining.containskey($_)}
if ($jobs_running.length -gt 0 ){
  write-host  ( 'waiting {0} second for {1} remaining jobs to complete' -f  $wait_retry_secs, $jobs_running.length  )
  start-sleep -seconds $wait_retry_secs
} else {
  write-host 'All jobs complete'
  break;
}
}


write-output 'Cleanup'
$jobids = get-job -State 'Completed' | select-object -expandproperty id 
if ($jobids -ne $null){
  foreach ($deployment_host_index in 0..$jobids.length  ) { 
    if( $jobids[$deployment_host_index] -ne $null) { 
      $jobid =  $jobids[$deployment_host_index]
      write-output "Remove job #${jobid}"  
      remove-job -id $jobid
    }
  }
}
 
write-output 'Cleanup of possible blocked jobs'

get-job -State 'Blocked' | select-object -expandproperty id | foreach-object {remove-job -Id $_ -force}