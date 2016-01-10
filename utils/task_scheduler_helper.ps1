# origin: http://windowsitpro.com/windows/create-scheduled-task-using-powershell
# http://blogs.technet.com/b/heyscriptingguy/archive/2015/01/13/use-powershell-to-create-scheduled-tasks.aspx
# http://blog.powershell.no/2012/05/28/working-with-scheduled-tasks-from-windows-powershell/
# https://mcpmag.com/articles/2012/06/26/managing-scheduled-tasks-part-2.aspx
# http://www.verboon.info/2013/12/powershell-creating-scheduled-tasks-with-powershell-version-3/

$scheduled_task_name = 'Scheduled Task Name'
$scheduled_task_action = New-ScheduledTaskAction –Execute 'notepad.exe' -argument "C:\Users\vagrant\test.ps1" -workingdirectory "c:\windows\temp"
$scheduled_task_trigger = New-ScheduledTaskTrigger -Daily -at 12:00PM

# New-ScheduledTaskTrigger -AtStartup
# New-ScheduledTaskTrigger -AtLogon
# New-ScheduledTaskTrigger -Daily -at 12:00PM

<# 
Creates:
<Triggers>
    <CalendarTrigger>
      <StartBoundary>2015-12-17T12:00:00</StartBoundary>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
#>
$domain_account = ".\${env:USERNAME}"
<# 
will lead to 
Register-ScheduledTask : No mapping between account names and security IDs was done.
#>

<# 
${env:USERDOMAIN} on a loose computer 
# will lead to error 
Register-ScheduledTask : The task XML contains a value which is incorrectly
formatted or out of range.
#>
$domain_account = 'BUILTIN\Administrators'
$scheduled_task_principal = New-ScheduledTaskPrincipal -GroupId $domain_account -RunLevel 'Highest'
$scheduled_task_settings_set = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -ExecutionTimeLimit ([TimeSpan]::Zero)
Register-ScheduledTask  -taskname $scheduled_task_name  -Action $scheduled_task_action -Principal $scheduled_task_principal -Trigger $scheduled_task_trigger -Settings $scheduled_task_settings_set

schtasks.exe /Query  /XML /TN $scheduled_task_name
schtasks.exe /Delete  /F /TN $scheduled_task_name
# the XML can be imported into the Task Scheduler 
# New-ScheduledTask not working yet , may be unnecessary
<#
useful Powershell options:
-NoLogo -NonInteractive -WindowStyle Hidden -Command "Import-Module PSScheduledJob; $jobDef = [Microsoft.PowerShell.ScheduledJob.ScheduledJobDefinition]::LoadFromStore('PowerShell – MyScript.ps1', 'C:\Users\<username>\AppData\Local\WindowsPowerShell\ScheduledJobs'); $jobDef.Run()"

#>
