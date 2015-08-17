#Copyright (c) 2015 Serguei Kouzmine
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


# http://www.adamtheautomator.com/powershell-event-logs/
# https://powertoe.wordpress.com/2009/1a2/30/powershell-and-scheduled-task-logs/
# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventing.reader%28v=vs.100%29.aspx
# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventing.reader.eventrecord_properties%28v=vs.110%29.aspx
# http://stackoverflow.com/questions/8567368/eventlogquery-time-format-expected/8575390#8575390
# http://blogs.msdn.com/b/davethompson/archive/2011/10/25/running-a-scheduled-task-after-another.aspx
# http://michal.is/blog/query-the-event-log-with-c-net/
# http://stackoverflow.com/questions/22685530/could-not-load-file-or-assembly-newtonsoft-json-or-one-of-its-dependencies-ma
# https://github.com/ricardotealdi/Simple.Serializer
# switch to http://www.codeproject.com/Articles/785293/Json-Parser-Viewer-and-Serializer


function run_helper_assembly
{
  param(
    [string]$assembly_name = '',
    [string]$query = @"
<QueryList>
<Query Id='0' Path='Microsoft-Windows-TaskScheduler/Operational'>
<Select Path='Microsoft-Windows-TaskScheduler/Operational'>*[System[Level=4 and TimeCreated[timediff(@SystemTime) &lt;= 1800000]]]</Select>
</Query>
</QueryList>
"@,
    [string]$logfile = 'report.log',
    [string]$comment = '',
    [switch]$verbose
  )

  if ($assembly_name -eq $null -or $assembly_name -eq '') { 
    Throw 'Need assembly name'
  }
  Write-Output $comment
  Write-Output "Loading embedded assembly ${assembly_name}"

  $helper = New-Object $assembly_name 
# -ErrorAction 'SilentlyContinue'

  $helper.Query = $query 
  [bool]$helper.Verbose =   [bool]$PSBoundParameters['verbose'].IsPresent

  Write-Debug ("Query:`r`n{0}" -f $helper.Query)
  try {
    $result = $helper.QueryActiveLog()
  } catch [exception]{

  }

  Write-Output ('Result: {0} rows' -f $result.count)
  Write-Output 'Sample entry:'
  Write-Output $result | Select-Object -First 1 | ConvertFrom-Json

  Write-Output '' | Out-File $report -Encoding 'ASCII'
  $result | Select-Object -First 1 | Out-File $report -Append -Encoding 'ASCII'

}


$report = 'report.log'
$DebugPreference = 'SilentlyContinue'
[string]$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'
$assembly_name = 'Newtonsoft.Json.dll'



Write-Debug "Loading external assembly ${assembly_name}"
add-type -path ([System.IO.Path]::Combine( $shared_assemblies_path  , $assembly_name))

Write-Debug 'Slow version'
$events_object = @()
$last_hour = (Get-Date) - (New-TimeSpan -Hour 1)
$events = Get-WinEvent -FilterHashtable @{ logname = "Microsoft-Windows-TaskScheduler/Operational"; level = "4"; StartTime = $last_hour }
$events | ForEach-Object {
  $events_object += $_
}
Write-Output ('Result: {0} rows' -f $events_object.count)
Write-Output 'Sample entry:'
$events_object | Select-Object -First 1 | Format-List


# $events_object | convertto-json -depth 10

Write-Debug 'Fast version'


# suppress the warnings - cannot use the CompilerParameters and ReferencedAssemblies parameters in the same command.

Add-Type -IgnoreWarnings @"
using System;
using System.Diagnostics.Eventing.Reader;
using System.Security;
using System.Collections;
using Newtonsoft.Json;

namespace EventQuery
{
    public class JsonSerializedWorkingExample
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

        private String _query = @"<QueryList>" +
                  "<Query Id='0' Path='Microsoft-Windows-TaskScheduler/Operational'>" +
                  "<Select Path='Microsoft-Windows-TaskScheduler/Operational'>" +
                  "*[System[(Level=1  or Level=2 or Level=3 or Level=4) and " +
                  "TimeCreated[timediff(@SystemTime) &lt;= 14400000]]]" + "</Select>" +
                  "</Query>" +
                  "</QueryList>";

        public String Query
        {
            get
            {
                return _query;
            }
            set
            {
                _query = value;
            }
        }
        public object[] QueryActiveLog()
        {
            // TODO: Extend structured query to two different event logs.
            EventLogQuery eventsQuery = new EventLogQuery("Application", PathType.LogName, Query);
            EventLogReader logReader = new EventLogReader(eventsQuery);
            return DisplayEventAndLogInformation(logReader);
        }

        private object[] DisplayEventAndLogInformation(EventLogReader logReader)
        {
            ArrayList eventlog_json_arraylist = new ArrayList();
            for (EventRecord eventInstance = logReader.ReadEvent();
                null != eventInstance; eventInstance = logReader.ReadEvent())
            {

	
                string eventlog_json = null;
                try { eventlog_json =  JsonConvert.SerializeObject(eventInstance);
		} catch (Exception e){
			// Assert
		}
                eventlog_json_arraylist.Add(eventlog_json);

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
            object[] result = eventlog_json_arraylist.ToArray();
            return result;
        }


    }
}


"@ -ReferencedAssemblies 'System.dll','System.Security.dll','System.Core.dll',([System.IO.Path]::Combine($shared_assemblies_path,$assembly_name))

Add-Type -IgnoreWarnings @"

using System;
using System.IO;
using System.Diagnostics.Eventing.Reader;
using System.Security;
using System.Collections;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;

namespace EventQuery
{
    public class JsonSerializedNonWorkingExample
    {
        // log the entries to console
        private bool _verbose;
        private bool _seen_error = false;

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

        private String _query = @"<QueryList>" +
                  "<Query Id='0' Path='Microsoft-Windows-TaskScheduler/Operational'>" +
                  "<Select Path='Microsoft-Windows-TaskScheduler/Operational'>" +
                  "*[System[(Level=1  or Level=2 or Level=3 or Level=4) and " +
                  "TimeCreated[timediff(@SystemTime) &lt;= 14400000]]]" + "</Select>" +
                  "</Query>" +
                  "</QueryList>";

        public String Query
        {
            get
            {
                return _query;
            }
            set
            {
                _query = value;
            }

        }


        public object[] QueryActiveLog()
        {
            // TODO: Extend structured query to two different event logs.
            EventLogQuery eventsQuery = new EventLogQuery("Application", PathType.LogName, Query);
            EventLogReader logReader = new EventLogReader(eventsQuery);
            return DisplayEventAndLogInformation(logReader);
        }

        private object[] DisplayEventAndLogInformation(EventLogReader logReader)
        {
            string event_instance_json_string = null;
            ArrayList eventlog_json_arraylist = new ArrayList();
            for (EventRecord eventInstance = logReader.ReadEvent();
                null != eventInstance; eventInstance = logReader.ReadEvent())
            {
                try
                {
                    event_instance_json_string = null;
                    MemoryStream event_instance_stream = new MemoryStream();
                    DataContractJsonSerializer event_instance_serializer =
                      new DataContractJsonSerializer(typeof(EventRecord));
                    event_instance_serializer.WriteObject(event_instance_stream, eventInstance);

                    event_instance_stream.Position = 0;
                    var event_instance_json_streamreader = new StreamReader(event_instance_stream);
                    event_instance_json_string = event_instance_json_streamreader.ReadToEnd();
                    Console.WriteLine(event_instance_json_string);
                }
                catch (Exception e)
                {
                    if (!_seen_error)
                    {
                        Console.WriteLine(e.ToString());
                    }
                    _seen_error = true;
                }
                eventlog_json_arraylist.Add(event_instance_json_string);
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
            object[] result = eventlog_json_arraylist.ToArray();
            return result;
        }
    }
}

"@ -ReferencedAssemblies 'System.dll','System.Xml.dll','System.Security.dll','System.Core.dll','System.Runtime.Serialization.dll'

run_helper_assembly -assembly_name 'EventQuery.JsonSerializedNonWorkingExample' -logfile 'broken.log' -comment 'Attempting JSON serialization that does not work' -verbose
run_helper_assembly -assembly_name 'EventQuery.JsonSerializedWorkingExample' -logfile 'report.log' -comment 'JSON serialization that works'

