# http://powershell.cz/2013/04/04/hide-and-show-console-window-from-gui/
Add-Type -Name Window -Namespace Console -MemberDefinition @"
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
"@

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

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$f = New-Object System.Windows.Forms.Form
$f.SuspendLayout()
$f.Size = new-object System.Drawing.Size(132, 105)
$s = New-Object System.Windows.Forms.Button
$s.Text = 'ShowConsole'
$s.Location = New-Object System.Drawing.Point(10, 10)
$s.Size = new-object System.Drawing.Size(100, 22)

$s.add_Click({[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), $SW_SHOWNOACTIVATE)})
 
$h = New-Object System.Windows.Forms.Button
$h.Text = 'HideConsole'
$h.Size = $s.Size

$h.Location = New-Object System.Drawing.Point(10, 42)
$h.add_Click({ [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), $SW_HIDE )})
$f.Controls.AddRange(@( $s, $h))
$f.ResumeLayout($false)
[void]$f.ShowDialog()
