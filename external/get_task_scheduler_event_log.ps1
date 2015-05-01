# http://www.adamtheautomator.com/powershell-event-logs/
# https://powertoe.wordpress.com/2009/1a2/30/powershell-and-scheduled-task-logs/
$servername = "tome-mac"
$schedule = new-object -com("Schedule.Service")
$schedule.connect($servername)
$tasks = $schedule.getfolder("\").gettasks(0)
$tasks |select name, lasttaskresult, lastruntime

$yesterday = (get-date) - (new-timespan -day 1)
$events = get-winevent -FilterHashtable @{logname = "Microsoft-Windows-TaskScheduler/Operational"; level = "2"; StartTime = $yesterday}
$events |foreach {
    $_
}
