# http://www.adamtheautomator.com/powershell-event-logs/
# https://powertoe.wordpress.com/2009/1a2/30/powershell-and-scheduled-task-logs/


# slow
$events_object = @()
$last_hour = (get-date) - (new-timespan -hour 1)
$events = get-winevent -FilterHashtable @{logname = "Microsoft-Windows-TaskScheduler/Operational"; level = "4"; StartTime = $last_hour}
$events |foreach {
    $events_object += $_
}

# $events_object | convertto-json -depth 10
# return

# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventing.reader%28v=vs.100%29.aspx
# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventing.reader.eventrecord_properties%28v=vs.110%29.aspx
# http://stackoverflow.com/questions/8567368/eventlogquery-time-format-expected/8575390#8575390

Add-Type -IgnoreWarnings @"

using System;
using System.Diagnostics.Eventing.Reader;
using System.Security;
using Newtonsoft.Json;
namespace EventQuery
{
    public class EventQueryExample
    {
        public void QueryActiveLog()
        {
            // TODO: Extend structured query to two different event logs.
            string queryString = 
                 @"<QueryList>" +
                  "<Query Id=\"0\" Path=\"Microsoft-Windows-TaskScheduler/Operational\">" +
                  "<Select Path=\"Microsoft-Windows-TaskScheduler/Operational\">" +
                  "*[System[(Level=1  or Level=2 or Level=3 or Level=4) and " +
                  "TimeCreated[timediff(@SystemTime) &lt;= 14400000]]]" + "</Select>" +
                  "</Query>" +
                  "</QueryList>";

            EventLogQuery eventsQuery = new EventLogQuery("Application", PathType.LogName, queryString);
            EventLogReader logReader = new EventLogReader(eventsQuery);
            DisplayEventAndLogInformation(logReader);

        }

        private void DisplayEventAndLogInformation(EventLogReader logReader)
        {
            for (EventRecord eventInstance = logReader.ReadEvent();
                null != eventInstance; eventInstance = logReader.ReadEvent())
            {

                string eventlog_string = JsonConvert.SerializeObject(eventInstance );
                Console.WriteLine("-----------------------------------------------------");
                Console.WriteLine("Event ID: {0}", eventInstance.Id);
                Console.WriteLine("Level: {0}", eventInstance.Level);
                Console.WriteLine("LevelDisplayName: {0}", eventInstance.LevelDisplayName);
                Console.WriteLine("Opcode: {0}", eventInstance.Opcode);
                Console.WriteLine("OpcodeDisplayName: {0}", eventInstance.OpcodeDisplayName);
                Console.WriteLine("TimeCreated: {0}", eventInstance.TimeCreated);

                Console.WriteLine("Publisher: {0}", eventInstance.ProviderName);

                try
                {
                    Console.WriteLine("Description: {0}", eventInstance.FormatDescription());
                }
                catch (EventLogException)
                {
                    // The event description contains parameters, and no parameters were 
                    // passed to the FormatDescription method, so an exception is thrown.

                }

                // Cast the EventRecord object as an EventLogRecord object to 
                // access the EventLogRecord class properties
                EventLogRecord logRecord = (EventLogRecord)eventInstance;
                Console.WriteLine("Container Event Log: {0}", logRecord.ContainerLog);
            }
        }

    }
}

"@ -ReferencedAssemblies 'System.dll', 'System.Security.dll', 'System.Core.dll', 'c:\developer\sergueik\csharp\appium-skeleton\packages\Newtonsoft.Json.6.0.8\lib\net20\Newtonsoft.Json.dll' 
# -CompilerParameters   '/nowarn'
# You cannot use the CompilerParameters and ReferencedAssemblies parameters in the same command.

$o = new-object 'EventQuery.EventQueryExample'
$o.QueryActiveLog()
# http://blogs.msdn.com/b/davethompson/archive/2011/10/25/running-a-scheduled-task-after-another.aspx
# http://michal.is/blog/query-the-event-log-with-c-net/


<#
.SYNOPSIS
	Loads calller-provided list of .net assembly dlls or fails with a custom exception
	
.DESCRIPTION
	Loads calller-provided list of .net assembly dlls or fails with a custom exception    
.EXAMPLE
	load_shared_assemblies -shared_assemblies_path 'c:\tools' -shared_assemblies @('WebDriver.dll','WebDriver.Support.dll','nunit.framework.dll')
.LINK 
	
	
.NOTES

	VERSION HISTORY
	2015/06/22 Initial Version
#>

function load_shared_assemblies {

  param(
    [string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies',

    [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll',
      'nunit.core.dll',
      'nunit.framework.dll'
    )
  )
  pushd $shared_assemblies_path

  $shared_assemblies | ForEach-Object {
    Unblock-File -Path $_;
    # Write-Debug $_
    Add-Type -Path $_ }
  popd
} 

load_shared_assemblies -shared_assemblies 'Newtonsoft.Json.dll'
load_shared_assemblies -shared_assemblies 'YamlDotNet.dll','YamlDotNet.dll' -shared_assemblies_path 'C:\developer\sergueik\powershell_ui_samples\external\csharp\YamlUtility\packages\YamlDotNet.3.5.0\lib\net35' 


<#
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="NUnit" version="2.6.3" targetFramework="net40" />
  <package id="YamlDotNet" version="3.5.0" targetFramework="net40" />
</packages>
Add-Type : (0) : Warning as Error: The predefined type 'System.Runtime.CompilerServices.ExtensionAttribute' is defined in multiple assemblies in the global alias; using definition from 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.dll'
(1) :
#>
