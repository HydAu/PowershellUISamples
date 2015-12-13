
[string] $shortcut = 'Git Bash'
$target = "${env:userprofile}\Desktop\${shortcut}.lnk"

if ( -not (test-path $target ) ) { 
  throw ('Not a valid path: "{0}"' -f $target )
}


Add-Type -TypeDefinition @"
using System;
using System.Text;

using System.Runtime.InteropServices;

public class Helper
{
    [DllImport("user32.dll")]
    public static extern int LoadString(IntPtr h, uint id, System.Text.StringBuilder sb, int maxBuffer);
    [DllImport("kernel32.dll")]
    public static extern IntPtr LoadLibrary(string s);
    public Helper() { }
}
"@

$verbs = @{
  'PintoStartMenu' = 5381;
  'UnpinfromStartMenu' = 5382;
  'PintoTaskbar' = 5386;
  'UnpinfromTaskbar' = 5387;
}
$verbid = $verbs['PintoTaskbar']
$shell32_helper = [helper]::LoadLibrary('shell32.dll')
$maxVerbLength = 255
$verbBuilder = New-Object Text.StringBuilder '',$maxVerbLength
[void][helper]::LoadString($shell32_helper,$verbId,$verbBuilder,$maxVerbLength)
Write-Debug ('Looking if "{0}" is available' -f $verbBuilder.ToString())
$verb = $verbBuilder.ToString()


$o = New-Object -ComObject 'shell.application'
$d = $o.Namespace(0x0)
$l = $d.ParseName($x)
if ($DEBUG){ 
  Write-Output 'Verbs:'
  $l.Verbs() | Select-Object -Property 'Name'
}
# https://msdn.microsoft.com/en-us/library/windows/desktop/bb787850%28v=vs.85%29.aspx
$itemVerb = $l.Verbs() | Where-Object { $_.Name -eq $verb }

if ($itemVerb -eq $null) {
  # on Windows 10, with some settings, there may be no 'Pin to Taskbar' Verb shown (anot no such action in context menu).
  throw ( 'Verb {0} not found.' -f $verb )
} else {
  $itemVerb | Select-Object -ExpandProperty 'Name' | Write-Host -foreground 'yellow'
  # https://msdn.microsoft.com/en-us/library/windows/desktop/bb774170%28v=vs.85%29.aspx
  $itemVerb.DoIt()
}

get-childitem -path "${env:appdata}\Microsoft\Internet Explorer\Quick Launch\User Pinned\Taskbar" -name "${shortcut}.lnk"

return


# misc. related links
# https://msdn.microsoft.com/en-us/library/windows/desktop/bb787850%28v=vs.85%29.aspx
# "%appdata%\Microsoft\Internet Explorer\Quick Launch\User Pinned\Taskbar"
# http://www.msfn.org/board/topic/154143-command-to-pin-or-unpin-program-from-taskbar/
# http://blogs.technet.com/b/deploymentguys/archive/2009/04/08/pin-items-to-the-start-menu-or-windows-7-taskbar-via-script.aspx
# https://gallery.technet.microsoft.com/scriptcenter/b66434f1-4b3f-4a94-8dc3-e406eb30b750
# http://powershell.com/cs/media/p/15280.aspx
# https://msdn.microsoft.com/en-us/library/windows/desktop/bb787850%28v=vs.85%29.aspx
# http://winaero.com/comment.php?comment.news.108
# https://4sysops.com/archives/configure-pinned-programs-on-the-windows-taskbar-with-group-policy/
