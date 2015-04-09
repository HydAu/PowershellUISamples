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

function PromptCalendar (

  [string]$title,
  [string]$message,
  [object]$caller
  ) {

@('System.Data', 'System.Drawing','System.Windows.Forms') |  foreach-object {   [void] [System.Reflection.Assembly]::LoadWithPartialName($_) } 

[string]$result = ''

$f = New-Object System.Windows.Forms.Form
$f.Text = $title


$f.Size = New-Object System.Drawing.Size(650,120)
$f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

$m = New-Object System.Windows.Forms.MonthCalendar
$b = New-Object System.Windows.Forms.Button
$f.SuspendLayout()

$m.FirstDayOfWeek = [System.Windows.Forms.Day]::Thursday
$m.Location = New-Object System.Drawing.Point(16, 16)
$m.Name = 'monthCalendar1'
$m.ShowTodayCircle = $false
$m.ShowWeekNumbers = $true
$m.TabIndex = 0

$b.Location = New-Object System.Drawing.Point(48, 184)
$b.Name = 'button1'
$b.Size = New-Object System.Drawing.Size(128, 23)
$b.TabIndex = 1
$b.Text = 'Selection Range'
$f.AutoScaleBaseSize = New-Object System.Drawing.Size(5, 13)
$f.ClientSize = New-Object System.Drawing.Size(232, 213)
$f.Controls.AddRange(@( $b, $m))
$f.Name = 'Calendar'
$f.Text = 'Calendar Control'
$f.ResumeLayout($false)

	 
$Calendar_Load = $f.Add_Load 
$Calendar_Load.Invoke({
	param(
		[object]$sender,
		[System.EventArgs]$e 
	)

	[string ]$str = $m.Text.ToString()  
})

$b_Click = $b.Add_Click 

$b_Click.Invoke({
	param(
		[object]$sender,
		[System.EventArgs]$e 
	)

	[SelectionRange]$sr = $m.SelectionRange
	[SelectionRange]$st = $sr.Start
	[SelectionRange]$se = $sr.End  
	$caller.Data =  ( "RANGE START = {0}`nRANGE END = {1}" -f $st.ToString() , $se.ToString() );
})

  $f.Topmost = $True
  $f.Add_Shown({ $f.Activate() })
  [void]$f.ShowDialog([win32window]($caller))
  $f.Dispose()
}

Add-Type -TypeDefinition @" 

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public string Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$DebugPreference = 'Continue'
$title = 'Question'
$message = "Continue to Next step?"
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptCalendar -Title $title -Message $message -caller $caller
$result = $caller.Data
Write-Debug ("Result is : {0} " -f $caller.Data)





