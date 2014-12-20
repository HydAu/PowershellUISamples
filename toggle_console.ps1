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

# http://powershell.cz/2013/04/04/hide-and-show-console-window-from-gui/
Add-Type -Name Window -Namespace Console -MemberDefinition @"
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
"@

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$f = New-Object System.Windows.Forms.Form
$f.SuspendLayout()
$f.Size = New-Object System.Drawing.Size (132,105)
# $f.Location = New-Object System.Drawing.Point(0 , 0)
$s = New-Object System.Windows.Forms.Button
$s.Text = 'ShowConsole'
function toggle_console_display {
  param([int]$ShowWindowCommand
  )
  # http://pinvoke.net/default.aspx/Enums/ShowWindowCommand.html
  $SW_HIDE = 0
  $SW_SHOWNORMAL = 1
  $SW_NORMAL = 1
  $SW_SHOWMINIMIZED = 2
  $SW_SHOWMAXIMIZED = 3
  $SW_MAXIMIZE = 3
  $SW_SHOWNOACTIVATE = 4
  $SW_SHOW = 5
  $SW_MINIMIZE = 6
  $SW_SHOWMINNOACTIVE = 7
  $SW_SHOWNA = 8
  $SW_RESTORE = 9
  $SW_SHOWDEFAULT = 10
  $SW_FORCEMINIMIZE = 11
  $SW_MAX = 11
  [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(),$ShowWindowCommand)
}

$s.Location = New-Object System.Drawing.Point (10,12)
$s.Size = New-Object System.Drawing.Size (100,22)

$s.add_Click({ toggle_console_display ($SW_SHOWNOACTIVATE) })
$f.add_Closing({ toggle_console_display ($SW_SHOWNORMAL) })
$h = New-Object System.Windows.Forms.Button
$h.Text = 'HideConsole'
$h.Size = $s.Size

$h.Location = New-Object System.Drawing.Point (10,42)
$h.add_Click({ toggle_console_display ($SW_HIDE) })
$f.Controls.AddRange(@( $s,$h))
$f.ResumeLayout($false)
[void]$f.ShowDialog()
