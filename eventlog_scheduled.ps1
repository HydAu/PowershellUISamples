# http://blogs.technet.com/b/wincat/archive/2011/08/25/trigger-a-powershell-script-from-a-windows-event.aspx

#>
# Script Name: eventlog_scheduled.ps1
# Usage Example (use a valid ID found via Event Viewer XML view of an event): powershell .\TriggerScript.ps1 -event_record_id 1 -event_channel Application
#
# Create a fake event or testing with the following command (from an elevated command prompt):
#   eventcreate /T INFORMATION /SO SomeApplication /ID 1000 /L APPLICATION /D "<Params><Timestamp>2011-08-29T21:24:03Z</Timestamp><InputFile>C:\temp\Some Test File.txt</InputFile><Result>Success</Result></Params>"

# Collects all named paramters (all others end up in $Args)
param(
[string] $event_record_id,
[string] $event_channel
)


$event = get-winevent -LogName $event_channel -FilterXPath ( "<QueryList><Query Id='0' Path='{0}'><Select Path='{0}'>*[System[(EventRecordID={1})]]</Select></Query></QueryList>" -f $event_channel, $event_record_id  )


[xml]$eventParams = $event.Message
if ($eventParams.Params.TimeStamp) {
    [datetime]$eventTimestamp = $eventParams.Params.TimeStamp
    $eventFile = $eventParams.Params.InputFile

    $popupObject = new-object -comobject wscript.shell
    $popupObject.popup("RecordID: " + $event_record_id + ", Channel: " + $event_channel + ", Event Timestamp: " + $eventTimestamp + ", File: " + $eventFile)
}

invoke-expression -command $command
[string]$command = @"
eventcreate /T INFORMATION /SO SomeApplication /ID 1000 /L APPLICATION /D "<Params><Timestamp>2011-08-29T21:24:03Z</Timestamp><InputFile>C:\temp\Some Test File.txt</InputFile><Result>Success</Result></Params>"
"@
$result = (invoke-expression -command $command)
<#
eventcreate /T INFORMATION /SO SomeApplication /ID 1000 /L APPLICATION /D "<Params><Timestamp>2011-08-29T21:24:03Z</Timestamp><InputFile>C:\temp\Some Test File.txt</InputFile><Result>Success</Result></Params>"
#>
<#
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Events>
  <Event xmlns="http://schemas.microsoft.com/win/2004/08/events/event">
    <System>
      <Provider Name="Microsoft-Windows-User Profiles Service" Guid="{89B1E9F0-5AFF-44A6-9B44-0A07A7CE5845}"/>
      <EventID>1531</EventID>
      <Version>0</Version>
      <Level>4</Level>
      <Task>0</Task>
      <Opcode>0</Opcode>
      <Keywords>0x8000000000000000</Keywords>
      <TimeCreated SystemTime="2014-08-23T00:21:25.013987200Z"/>
      <EventRecordID>15672</EventRecordID>
      <Correlation/>
      <Execution ProcessID="872" ThreadID="996"/>
      <Channel>Application</Channel>
      <Computer>sergueik42</Computer>
      <Security UserID="S-1-5-18"/>
    </System>
    <EventData/>
  </Event>
</Events>
#>
