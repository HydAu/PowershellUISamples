# https://4sysops.com/archives/switch-windows-server-2012-gui-layers-with-powershell/
<#
# imagine that we want to get rid of Desktop Experience for the sake of performance increase:
Remove-WindowsFeature Desktop-Experience -Restart
# takes from Desktop Experience to Server with a GUI.
# NOTE: need to uninstall Visual Studio and other apps.
Uninstall-WindowsFeature Server-Gui-Shell -Restart
# takes from Server with a GUI to Minimal Server Interface
# Powershell UI form examples work, except toggle_display.ps1 which manages to show the form, and hide console, but never shows console back.
Remove-WindowsFeature User-Interfaces-Infra -Restart
# takes from Server with a GUI to Server Core
#>
