# http://www.cyberforum.ru/powershell/thread1502608.html
# http://www.pinvoke.net/default.aspx/user32.getwindowrect
# http://www.pinvoke.net/default.aspx/user32.findwindow
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32
{
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll", SetLastError = true)]
    static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll", EntryPoint = "FindWindow", SetLastError = true)]
    static extern IntPtr FindWindowByCaption(IntPtr ZeroOnly /* IntPtr.Zero should be the first parameter. */, string lpWindowName);

    // You can also call FindWindow(default(string), lpWindowName) or FindWindow((string)null, lpWindowName)
}
[StructLayout(LayoutKind.Sequential)]
public struct RECT
{
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
}
"@
 
start notepad
sleep -Milliseconds 50
 
$h =[Win32]::FindWindow("Notepad",[IntPtr]::Zero)
#
#$h = (Get-Process | where {$_.MainWindowTitle -match "Notepad"}).MainWindowHandle
if ($h -eq [IntPtr]::Zero) {return "not found"}
$rcWindow = New-Object RECT
[void][Win32]::GetWindowRect($h,[ref]$rcWindow)
 $left = 0
$top  = 0
 
$WndWidth  = $rcWindow.Right - $rcWindow.Left
$WndHeight = $rcWindow.Bottom -$rcWindow.Top
[void][Win32]::MoveWindow($h, $left, $top, $WndWidth, $WndHeight, $true)
