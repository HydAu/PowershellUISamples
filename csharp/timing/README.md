Info
----
Running Windows Desktop Application directly by puppet will be hanging Puppet and Vagrant:
```
node 'windows' {
  $run_command = 'C:\Users\vagrant\Desktop\timing\Program\bin\Debug\timing.exe'
  exec { 'Run desktop application':
    command => $run_command,
    logoutput => true,
  }
}
```
one can run it through Task Scheduler ([modified puppet-windows_xmltask](https://github.com/sergueik/puppet-windows_xmltask):
```
node 'windows' {
  $run_command = 'C:\Users\vagrant\Desktop\timing\Program\bin\Debug\timing.exe'
  custom_command { 'launch timing system tray app':
    command => $run_command,
    script  => 'launch_timing_system_tray_app',
    wait    => false,
  }
}
```


will create the files:

```
    Directory: C:\temp\launch_timing_system_tray_app


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---        11/18/2015   7:50 AM      14535 launch_timing_system_tray_app.372.log
-a---        11/18/2015   7:48 AM       2651 launch_timing_system_tray_app.372.xml
-a---        11/18/2015   7:48 AM       2769 launch_timing_system_tray_app.ps1

```
![Running system tray application via Windows Scheduled Task from Puppet](https://raw.githubusercontent.com/sergueik/powershell_ui_samples/master/screenshots/555.png)
