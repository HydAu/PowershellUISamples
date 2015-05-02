# http://www.adamtheautomator.com/powershell-event-logs/
# https://powertoe.wordpress.com/2009/1a2/30/powershell-and-scheduled-task-logs/


# slow
$last_hour = (get-date) - (new-timespan -hour 1)
$events = get-winevent -FilterHashtable @{logname = "Microsoft-Windows-TaskScheduler/Operational"; level = "4"; StartTime = $last_hour}
$events |foreach {
    $_
}

# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventing.reader%28v=vs.100%29.aspx
# https://msdn.microsoft.com/en-us/library/system.diagnostics.eventing.reader.eventrecord_properties%28v=vs.110%29.aspx

Add-Type @"
using System;
using System.Diagnostics.Eventing.Reader;
using System.Security;

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

"@ -ReferencedAssemblies 'System.dll', 'System.Security.dll', 'System.Core.dll'

$o = new-object 'EventQuery.EventQueryExample'
$o.QueryActiveLog()

