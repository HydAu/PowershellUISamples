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


Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _numeric;
    private string _timestr;

    public int Numeric
    {
        get { return _numeric; }
        set { _numeric = value; }
    }

    public string TimeStr
    {
        get { return _timestr; }
        set { _timestr = value; }
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


# http://stackoverflow.com/questions/16789399/looking-for-time-picker-control-with-half-hourly-up-down
Add-Type -TypeDefinition @"


public class TimePicker : System.Windows.Forms.DomainUpDown
{
    public TimePicker()
    {         
        // build the list of times, in reverse order because the up/down buttons go the other way
        for (double time = 23.5; time >= 0; time -= 0.5)
        {
            int hour = (int)time; // cast to an int, we only get the whole number which is what we want
            int minutes = (int)((time - hour) * 60); // subtract the hour from the time variable to get the remainder of the hour, then multiply by 60 as .5 * 60 = 30 and 0 * 60 = 0

            this.Items.Add(hour.ToString("00") + ":" + minutes.ToString("00")); // format the hour and minutes to always have two digits and concatenate them together with the colon between them, then add to the Items collection
        }

        this.SelectedIndex = Items.IndexOf("09:00"); // select a default time

        this.Wrap = true; // this enables the picker to go to the first or last item if it is at the end of the list (i.e. if the user gets to 23:30 it wraps back around to 00:00 and vice versa)
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'


function UpDownsPrompt
{
  param(
    [object]$caller
  )

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Generic')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Collections')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Text')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Data')

  $f = New-Object System.Windows.Forms.Form

  $f.Size = New-Object System.Drawing.Size (180,120)
  $numeric_updown = New-Object System.Windows.Forms.NumericUpDown
  $numeric_updown.SuspendLayout()

  $numeric_updown.Parent = $this
  $numeric_updown.Location = New-Object System.Drawing.Point (30,80)
  $numeric_updown.Size = New-Object System.Drawing.Size (50,20)
  $numeric_updown.Value = 1
  $numeric_updown.Minimum = 0
  $numeric_updown.Maximum = 1000
  $numeric_updown.Increment = 1
  $numeric_updown.DecimalPlaces = 0
  $numeric_updown.ReadOnly = $false
  $numeric_updown.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right
  # $numeric_updown.ValueChanged += new EventHandler(numeric_updown_OnValueChanged);


  $handler = {
    param(
      [object]$sender,
      [System.EventArgs]$eventargs)
    $caller.Numeric = $numeric_updown.Value
  }

  $eventMethod = $numeric_updown.add_ValueChanged
  $eventMethod.Invoke($handler)


  $time_updown = New-Object TimePicker
  $time_updown.Parent = $f
  $time_updown.Location = New-Object System.Drawing.Point (30,50)
  $time_updown.Size = New-Object System.Drawing.Size (70,20)
  $time_updown.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right
  $time_updown.ReadOnly = $true
  # $time_updown.TextChanged += new EventHandler(time_updown_OnTextChanged);

  $handler = {
    param(
      [object]$sender,
      [System.EventArgs]$eventargs)
    $caller.TimeStr = $time_updown.SelectedItem.ToString()
  }

  $eventMethod = $time_updown.add_TextChanged
  $eventMethod.Invoke($handler)

  $time_updown.SuspendLayout()

  $time_updown.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0);
  $time_updown.ReadOnly = $true

  $time_updown.TabIndex = 0
  $time_updown.TabStop = $false
  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $f.ClientSize = New-Object System.Drawing.Size (180,120)
  $components = New-Object System.ComponentModel.Container

  $f.Controls.AddRange(@( $time_updown,$numeric_updown))

  $f.Name = 'Form1'
  $f.Text = 'UpDown Sample'
  $time_updown.ResumeLayout($false)
  $numeric_updown.ResumeLayout($false)
  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True

  $f.Topmost = $True
  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}

$DebugPreference = 'Continue'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
UpDownsPrompt -caller $caller

Write-Debug ('Time Selection is : {0}' -f $caller.TimeStr)
Write-Debug ('Numeric Value is : {0}' -f $caller.Numeric)
$caller = $null



