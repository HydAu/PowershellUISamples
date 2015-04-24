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
$message_status_keywords = ('(?:{0})' -f ($message_status_keywords -replace "`r`n",'|'))
Write-Output $message_status_keywords

$data = Get-WinEvent -LogName 'Microsoft-Windows-TaskScheduler/Operational' -ErrorAction silentlycontinue `
   | 
   Where-Object { $_.ProviderName -eq 'Microsoft-Windows-TaskScheduler' -and $_.Message -match '^Task Scheduler' } `
   |
Where-Object { $_.Message -match $message_status_keywords }


$data.Count

