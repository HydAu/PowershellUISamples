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
using System.Drawing;
using System.Windows.Forms;

public class TimerPanel : System.Windows.Forms.Panel
{
    private System.Timers.Timer _timer;
    private System.ComponentModel.Container components = null;
    public System.Timers.Timer Timer
    {
        get
        {
            return _timer;
        }
        set { _timer = value; }
    }


    public TimerPanel()
    {
        InitializeComponent();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            if (components != null)
            {
                components.Dispose();
            }
        }
        _timer.Stop();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        this._timer = new System.Timers.Timer();
        ((System.ComponentModel.ISupportInitialize)(this._timer)).BeginInit();
        this.SuspendLayout();
        this._timer.Interval = 1000;
        this._timer.Start();
        this._timer.Enabled = true;
        this._timer.SynchronizingObject = this;
        this._timer.Elapsed += new System.Timers.ElapsedEventHandler(this.OnTimerElapsed);
        ((System.ComponentModel.ISupportInitialize)(this._timer)).EndInit();
        this.ResumeLayout(false);

    }

    private void OnTimerElapsed(object sender, System.Timers.ElapsedEventArgs e)
    {
        // Console.WriteLine(".");
    }

}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$RESULT_OK = 0
$RESULT_CANCEL = 1
$RESULT_TIMEOUT = 2

$Readable = @{
  $RESULT_OK = 'OK';
  $RESULT_CANCEL = 'CANCEL';
  $RESULT_TIMEOUT = 'TIMEOUT';
}

function PromptAuto  {

param(
  [string]$title,
  [string]$message,
  [object]$caller
)

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $f.Size = New-Object System.Drawing.Size (240,110)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True
  $f.Add_KeyDown({

      if ($_.KeyCode -eq 'O') { $caller.Data = $RESULT_OK }
      elseif ($_.KeyCode -eq 'Escape') { $caller.Data = $RESULT_CANCEL }
      else { return }
      $f.Close()

    })

  $b1 = New-Object System.Windows.Forms.Button
  $b1.Location = New-Object System.Drawing.Size (50,40)
  $b1.Size = New-Object System.Drawing.Size (75,23)
  $b1.Text = 'OK'
  $b1.add_click({ $caller.Data = $RESULT_OK; $f.Close(); })
  $p = New-Object TimerPanel
  $p.Size = $f.Size

  $p.Controls.Add($b1)
  $end = (Get-Date -UFormat "%s")
  $end = ([int]$end + 60)
  $b2 = New-Object System.Windows.Forms.Button
  $b2.Location = New-Object System.Drawing.Size (130,40)
  $b2.Size = New-Object System.Drawing.Size (75,23)
  $b2.Text = 'Cancel'
  $b2.add_click({
      $caller.Data = $RESULT_CANCEL;
      $f.Close();
    })
  $p.Controls.Add($b2)

  $l = New-Object System.Windows.Forms.Label
  $l.Location = New-Object System.Drawing.Size (10,20)
  $l.Size = New-Object System.Drawing.Size (280,20)
  $l.Text = $message
  $p.Controls.Add($l)

  $p.Timer.Stop()
  $p.Timer.Interval = 5000;
  $p.Timer.Start()
  $p.Timer.add_Elapsed({
      $start = (Get-Date -UFormat "%s")

      $elapsed = New-TimeSpan -Seconds ($start - $end)
      $l.Text = ('Remaining time {0:00}:{1:00}:{2:00}' -f $elapsed.Hours,$elapsed.Minutes,$elapsed.Seconds,($end - $start))

      if ($end - $start -lt 0) {
        $caller.Data = $RESULT_TIMEOUT;
        $f.Close()
      }

    })
  $f.Controls.Add($p)
  $f.Topmost = $True

  $caller.Data = $RESULT_TIMEOUT;
  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}

Add-Type -TypeDefinition @" 

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;

    public int Data
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
$title = 'Prompt w/timeout'
$message = "Continue ?"
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptAuto -Title $title -Message $message -caller $caller
$result = $caller.Data
Write-Debug ("Result is : {0} ({1})" -f $Readable.Item($result),$result)
