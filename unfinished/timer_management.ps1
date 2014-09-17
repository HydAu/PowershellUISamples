$timer = New-Object System.Timers.Timer

[int32]$complete = 0
$action = {

  Write-Host "Invocation # ${complete}"
  Write-Host "Timer Elapse Event: $(get-date -Format 'HH:mm:ss')"
  $complete++
  if ($complete -eq 4)
  {
    Write-Host 'Completed'
    $timer.stop()
    Unregister-Event thetimer
  }
}
Register-ObjectEvent -InputObject $timer -EventName elapsed –SourceIdentifier thetimer -Action $action

$timer.Interval = 3000 # milliseconds

Write-Output 'Starting'
$timer.start()

<#
// http://colleenmorrow.com/2012/09/20/parsing-windows-event-logs-with-powershell/
// http://www.computerperformance.co.uk/powershell/powershell_eventlog.htm
// http://www.java2s.com/Code/CSharp/Windows/Getfirst5messagefromsystemeventlog.htm
// http://www.techrepublic.com/article/pro-tip-extend-your-event-log-search-capabilities-with-powershells-get-eventlog-cmdlet/
using System;
  using System.Resources;
  using System.Drawing;
  using System.Collections;
  using System.Windows.Forms;
  using System.Resources;
  using Microsoft.Win32;

  // For event log.
  using System.Diagnostics;
  class Test
  {
    static void Main(string[] args)
    {
      EventLog log = new EventLog();
      log.Log = "Application";
      log.Source = "www.java2s.com";
      log.WriteEntry("message from my own example...");
      
      // Display the first 5 entries in the Application log.
      for(int i = 0; i < 5; i++)
      {
                Console.WriteLine("Message: " + log.Entries[i].Message + "\n" +  
            "Box: " + log.Entries[i].MachineName + "\n" +
            "App: " + log.Entries[i].Source + "\n" +
            "Time entered: " + log.Entries[i].TimeWritten, 
            "Application Log entry:");
      }
      log.Close();
    }
  }
   
#>
           
       