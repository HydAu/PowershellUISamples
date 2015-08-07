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

# suppress the warning:
# Add-Type : (0) : Warning as Error: The predefined type 'System.Runtime.CompilerServices.ExtensionAttribute' is defined in multiple assemblies in the global alias; using definition from 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.dll'
# One cannot use the CompilerParameters and ReferencedAssemblies parameters in the same command.

Add-Type -IgnoreWarnings @"

using System;
using System.Diagnostics.Eventing.Reader;
using System.Security;
using System.Collections;
using Newtonsoft.Json;

namespace EventQuery
{
    public class EventQueryExample
    {
        // log the entries to console
        private bool _verbose;
        public bool Verbose
        {
            get
            {
                return _verbose;
            }
            set
            {
                _verbose = value;
            }

        }

        public object[] QueryActiveLog()
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
            return DisplayEventAndLogInformation(logReader);

        }

        private object[] DisplayEventAndLogInformation(EventLogReader logReader)
        {
            ArrayList eventlog_json_array = new ArrayList();
            for (EventRecord eventInstance = logReader.ReadEvent();
                null != eventInstance; eventInstance = logReader.ReadEvent())
            {

                string eventlog_json = JsonConvert.SerializeObject(eventInstance);
                eventlog_json_array.Add(eventlog_json);

                if (Verbose)
                {
                    Console.WriteLine("-----------------------------------------------------");
                    Console.WriteLine("Event ID: {0}", eventInstance.Id);
                    Console.WriteLine("Level: {0}", eventInstance.Level);
                    Console.WriteLine("LevelDisplayName: {0}", eventInstance.LevelDisplayName);
                    Console.WriteLine("Opcode: {0}", eventInstance.Opcode);
                    Console.WriteLine("OpcodeDisplayName: {0}", eventInstance.OpcodeDisplayName);
                    Console.WriteLine("TimeCreated: {0}", eventInstance.TimeCreated);
                    Console.WriteLine("Publisher: {0}", eventInstance.ProviderName);
                }
                try
                {
                    if (Verbose)
                    {
                        Console.WriteLine("Description: {0}", eventInstance.FormatDescription());
                    }
                }
                catch (EventLogException)
                {

                    // The event description contains parameters, and no parameters were 
                    // passed to the FormatDescription method, so an exception is thrown.

                }

                // Cast the EventRecord object as an EventLogRecord object to 
                // access the EventLogRecord class properties
                EventLogRecord logRecord = (EventLogRecord)eventInstance;
                if (Verbose)
                {

                    Console.WriteLine("Container Event Log: {0}", logRecord.ContainerLog);
                }
            }
            object[] result = eventlog_json_array.ToArray();
            return result;
        }


    }
}

"@ -ReferencedAssemblies 'System.dll', 'System.Security.dll', 'System.Core.dll', 'c:\developer\sergueik\csharp\appium-skeleton\packages\Newtonsoft.Json.6.0.8\lib\net20\Newtonsoft.Json.dll' 

$o = new-object 'EventQuery.EventQueryExample'
$o.Verbose = $false
$r = $o.QueryActiveLog()
$r  | select-object -first 1 
# http://blogs.msdn.com/b/davethompson/archive/2011/10/25/running-a-scheduled-task-after-another.aspx
# http://michal.is/blog/query-the-event-log-with-c-net/

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
(1) :
#>

<#
{
    "Id": 102,
    "Version": 0,
    "Qualifiers": null,
    "Level": 4,
    "Task": 102,
    "Opcode": 2,
    "Keywords": -9223372036854775807,
    "RecordId": 18359,
    "ProviderName": "Microsoft-Windows-TaskScheduler",
    "ProviderId": "de7b24ea-73c8-4a09-985d-5bdadcfa9017",
    "LogName": "Microsoft-Windows-TaskScheduler/Operational",
    "ProcessId": 436,
    "ThreadId": 2692,
    "MachineName": "sergueik42",
    "UserId": {
        "BinaryLength": 12,
        "AccountDomainSid": null,
        "Value": "S-1-5-18"
    },
    "TimeCreated": "2015-08-06T20:12:25.3151096-04:00",
    "ActivityId": "bcd9f31f-286e-49e5-8d64-9e398bfe213d",
    "RelatedActivityId": null,
    "ContainerLog": "Microsoft-Windows-TaskScheduler/Operational",
    "MatchedQueryIds": [],
    "Bookmark": {
        "BookmarkText": "<BookmarkList>\r\n  <Bookmark Channel='Microsoft-Windows-TaskScheduler/Operational' RecordId='18359' IsCurrent='true'/>\r\n</BookmarkList>"
    },
    "LevelDisplayName": "Information",
    "OpcodeDisplayName": "Stop",
    "TaskDisplayName": "Task completed",
    "KeywordsDisplayNames": [],
    "Properties": [{
        "Value": "\\Microsoft\\Windows\\RAC\\RacTask"
    }, {
        "Value": "NT AUTHORITY\\LOCAL SERVICE"
    }, {
        "Value": "bcd931f-286e-49e5-8d64-9e398bfe213d"
    }]
}
#>