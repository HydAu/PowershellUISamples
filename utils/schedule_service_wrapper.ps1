#Copyright (c) 2014,2015 Serguei Kouzmine
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
# $DebugPreference = 'Continue'

# origin http://windowsitpro.com/powershell/how-use-powershell-report-scheduled-tasks
# Get-ScheduledTask.ps1


# TODO assert  registry contains 
# [HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0f87369f-a4e5-4cfc-bd3e-73e6154572dd}]
# @="TaskScheduler class"


$TaskService = New-Object -ComObject 'Schedule.Service'
$TaskService.Connect()
$rootFolder = $TaskService.GetFolder('\')
[bool]$Hidden = $false
$tasks = $rootFolder.GetTasks($Hidden.IsPresent -as [int])
$tasks_data = @( @{ 'name' = $null; 'commandline' = $null; 'arguments' = $null; })
$tasks | ForEach-Object {
  $task = $_;
  $task_info = [xml]$task.xml

  $local:result = @{
    'name' = $task.Name;
    'commandline' = $task_info.Task.Actions.Exec.Command;
    'arguments ' = $task_info.Task.Actions.Exec.Arguments;
  }

  $tasks_data += $local:result

}

$tasks_data
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/3cde4612-fb23-45b2-a90f-bfeb6798deff/how-to-use-powershell-to-query-windows-2008-task-history-in-task-scheduler?forum=winserverpowershell
$message_status_keywords = @"
Launched
Finished
Completed
Failed to start
Did not launch
"@
$message_status_keywords = ('({0})' -f ($message_status_keywords -replace "`r`n",'|'))
Write-Debug $message_status_keywords

$log_data = @( @{ 'status' = $null; 'time_created' = $null; 'message' = $null })

Get-WinEvent -LogName 'Microsoft-Windows-TaskScheduler/Operational' -ErrorAction silentlycontinue `
   |
Where-Object { $_.ProviderName -eq 'Microsoft-Windows-TaskScheduler' -and $_.Message -match '^Task Scheduler' } `
   |
ForEach-Object { $eventlog_record = $_;
  if ($eventlog_record.Message -match $message_status_keywords) { $record = @{ 'status' = $null; 'time_created' = $null; 'message' = $null }
    $record['status'] = $matches[1]
    $record['time_created'] = $eventlog_record.TimeCreated
    $record['message'] = $eventlog_record.Message
    $log_data += $record
  } }

$log_data.Count
$log_data

# To purge
# [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System\Microsoft-Windows-TaskScheduler]
# "ProviderGuid"="{de7b24ea-73c8-4a09-985d-5bdadcfa9017}"
# "EventMessageFile"=hex(2):25,53,79,73,74,65,6d,52,6f,6f,74,25,5c,73,79,73,74,65,6d,33,32,5c,73,63,68,65,64,73,76,63,2e,64,6c,6c,00
# that is %SystemRoot%\system32\schedsvc.dll 

# Note also 
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Fusion\References\TaskScheduler, Version=6.1.0.0, Culture=Neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=msil]
# C:\Windows\winsxs\msil_taskscheduler_31bf3856ad364e35_6.1.7601.17514_none_170487c39d98ec89\TaskScheduler.dll
# Need c# API

# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventlog_methods(v=vs.110).aspx
Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Threading;

public class EventLogAccessSample
{
    public EventLogAccessSample()
    {

    }
    public void Change()
    {


        string logName;

        if (EventLog.SourceExists("Microsoft-Windows-TaskScheduler"))
        {


            // Find the log associated with this source.    
            logName = EventLog.LogNameFromSourceName("Microsoft-Windows-TaskScheduler", ".");
            // Make sure the source is in the log we believe it to be in. 
            if (logName != "Microsoft-Windows-TaskScheduler")
            {
                // EventLog.DeleteEventSource("Microsoft-Windows-TaskScheduler");
                return;
            }
            // Delete the source and the log.
            EventLog.DeleteEventSource("Microsoft-Windows-TaskScheduler");
            EventLog.Delete(logName);

            Console.WriteLine(logName + " deleted.");
        }
        else
        {

            Console.WriteLine(" not found  -  creating deleted.");
            // Create the event source to make next try successful.
            EventLog.CreateEventSource("Microsoft-Windows-TaskScheduler", "MyLog");
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll', 'System.Diagnostics.Tools'

$o = new-object -typename 'EventLogAccessSample'
# $o.Change()

# stop task scheduler and event log
# remove / truncate %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TaskScheduler%4Operational.evtx
# stat services 
# this requires admin access
