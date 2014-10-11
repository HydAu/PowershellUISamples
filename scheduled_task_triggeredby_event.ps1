#Copyright (c) 2014 Serguei Kouzmine
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

param(# Collects all named paramters - the rest end up in $Args
  [string]$event_record_id = '17954',
  [string]$event_channel = 'Application',
  [switch]$create_event

)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"))
  }
}


if ($PSBoundParameters["create_event"]) {

  $date_str = '{0:yyyy-MM-ddTHH:mm:ssZ}' -f (Get-Date)
  [string]$command = @"
eventcreate /T INFORMATION /SO SomeApplication /ID 1000 /L APPLICATION /D "<Params><Timestamp>${date_str}</Timestamp><InputFile>C:\developer\sergueik\powershell_ui_samples\dummy.txt</InputFile><Result>Success</Result></Params>"
"@
  $result = (Invoke-Expression -Command $command)
  # $result = 
  # SUCCESS: An event of type 'INFORMATION' was created in the 'APPLICATION' log with 'SomeApplication' as the source.
} else {


  # http://blogs.technet.com/b/wincat/archive/2011/08/25/trigger-a-powershell-script-from-a-windows-event.aspx


  # alternative ways to compose XPath query:
  # direct:
  $event = Get-WinEvent -LogName $event_channel -FilterXPath "*[System[(EventRecordID=$event_record_id)]]"
  # indirect:
  $event = Get-WinEvent -LogName $event_channel -FilterXPath ("<QueryList><Query Id='0' Path='{0}'><Select Path='{0}'>*[System[(EventRecordID={1})]]</Select></Query></QueryList>" -f $event_channel,$event_record_id)

  # alternative ways to extract event fields:

  # XML
  $event_obj = ([xml]$event.ToXml())
  if ($eventParams.Event.System.TimeCreated.SystemTime)
  {
    [xml]$event_obj.Event.eventdata.data | Select-Object -Property @{ Label = 'InputFile'; Expression = "Name" },@{ Label = 'EventData'; Expression = "#text" } | ConvertTo-Csv -NoTypeInformation | Out-File ('{0}\{1}' -f (Get-ScriptDirectory),'appusage.csv') -Append
  }
  # VB-style
  [xml]$eventParams = $event_obj.Event.eventdata.data
  if ($eventParams.Params.TimeStamp) {
    [datetime]$eventTimestamp = $eventParams.Params.TimeStamp
    $eventFile = $eventParams.Params.InputFile

    $popupObject = New-Object -ComObject wscript.shell
    $popupObject.popup("RecordID: " + $event_record_id + ", Channel: " + $event_channel + ", Event Timestamp: " + $eventTimestamp + ", File: " + $eventFile)
  }

}

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
