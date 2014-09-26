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


 // http://msdn.microsoft.com/en-us/library/ms172532%28v=vs.90%29.aspx
using System;
using System.Drawing;
using System.Windows.Forms;

    public class TimerPanel : System.Windows.Forms.Panel
    {
        private string _message;

        private System.Timers.Timer timer1;
        private System.ComponentModel.Container components = null;

        public System.Timers.Timer Timer
        {
            get { 
                return timer1; 
           }
           set { timer1 = value; }
        }


        public TimerPanel()
        {
            InitializeComponent();

        }

        public string Message
        {
            get { 
                return _message; 
           }
           set { _message = value; }
        }
        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if (components != null) 
                {
                    components.Dispose();
                }
            }
            timer1.Stop();

            base.Dispose( disposing );
        }

        private void InitializeComponent()
        {
         this.timer1 = new System.Timers.Timer();
         ((System.ComponentModel.ISupportInitialize)(this.timer1)).BeginInit();
         this.SuspendLayout();
// 
//         this.Load += new System.EventHandler(this.TimerPanel_Load );

            timer1.Interval = 1000 ;
            // Start the Timer
            timer1.Start();
            // Enable the timer. The timer starts now
            timer1.Enabled = true ; 

         // 
         // timer1
         // 
         this.timer1.Enabled = true;
         this.timer1.SynchronizingObject = this;
         this.timer1.Elapsed += new System.Timers.ElapsedEventHandler(this.OnTimerElapsed);

         ((System.ComponentModel.ISupportInitialize)(this.timer1)).EndInit();
         this.ResumeLayout(false);

      }

        private void OnTimerElapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
	Console.WriteLine(".");
//         throw new Exception(); 
        }

    }
"@ -ReferencedAssemblies 'System.Windows.Forms.dll'



$RESULT_POSITIVE = 0
$RESULT_NEGATIVE = 1
$RESULT_CANCEL = 2

$Readable = @{
  $RESULT_NEGATIVE = 'NO!';
  $RESULT_POSITIVE = 'YES!';
  $RESULT_CANCEL = 'MAYBE...'
}

function PromptAuto (
  [string]$title,
  [string]$message,
  [object]$caller
) {

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')


  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title


  $f.Size = New-Object System.Drawing.Size (650,120)
  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True
  $f.Add_KeyDown({

      if ($_.KeyCode -eq 'M') { $caller.Data = $RESULT_POSITIVE }
      elseif ($_.KeyCode -eq 'A') { $caller.Data = $RESULT_NEGATIVE }
      elseif ($_.KeyCode -eq 'Escape') { $caller.Data = $RESULT_CANCEL }
      else { return }
      $f.Close()

    })

  $b1 = New-Object System.Windows.Forms.Button
  $b1.Location = New-Object System.Drawing.Size (50,40)
  $b1.Size = New-Object System.Drawing.Size (75,23)
  $b1.Text = 'Yes!'
  $b1.add_click({ $caller.Data = $RESULT_POSITIVE; $f.Close(); })
  $p = New-Object TimerPanel
  $p.Controls.Add($b1)

  $b2 = New-Object System.Windows.Forms.Button
  $b2.Location = New-Object System.Drawing.Size (125,40)
  $b2.Size = New-Object System.Drawing.Size (75,23)
  $b2.Text = 'No!'
  $b2.add_click({ $caller.Data = $RESULT_NEGATIVE; $f.Close(); })
  $p.Controls.Add($b2)

  $b3 = New-Object System.Windows.Forms.Button
  $b3.Location = New-Object System.Drawing.Size (200,40)
  $b3.Size = New-Object System.Drawing.Size (75,23)
  $b3.Text = 'Maybe'
  $b3.add_click({ $caller.Data = $RESULT_CANCEL; $f.Close() })
  $p.Controls.Add($b3)

  $l = New-Object System.Windows.Forms.Label
  $l.Location = New-Object System.Drawing.Size (10,20)
  $l.Size = New-Object System.Drawing.Size (280,20)
  $l.Text = $message
  $p.Controls.Add($l)
  $p.Timer.add_Elapsed({
 $caller.Data = $RESULT_CANCEL; $f.Close() 
}) 
  $f.Controls.Add($p)

  $f.Topmost = $True


  $caller.Data = $RESULT_CANCEL;
  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
 # $p | get-member
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
$title = 'Question'
$message = "Continue to Next step?"
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptAuto -Title $title -Message $message -caller $caller
$result = $caller.Data
Write-Debug ("Result is : {0} ({1})" -f $Readable.Item($result),$result)
