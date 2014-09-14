# https://4sysops.com/archives/switch-windows-server-2012-gui-layers-with-powershell/
<#
# imagine that we want to get rid of Desktop Experience for the sake of performance increase:
Remove-WindowsFeature Desktop-Experience -Restart
# takes from Desktop Experience to Server with a GUI.
# NOTE: need to uninstall Visual Studio and other apps. Otherwise Desktop Experienced remains present.
Uninstall-WindowsFeature Server-Gui-Shell -Restart
# takes from Server with a GUI to Minimal Server Interface
# Most Powershell UI form examples continue to work: WPF OK, Windows Forms OK,win32 P/Invoke with some issues: toggle_console.ps1 is able to hide but not show the Powershell console window.
Remove-WindowsFeature User-Interfaces-Infra -Restart
# takes from Server with a GUI to Server Core
#>
