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

// "
// http://www.java2s.com/Code/CSharp/GUI-Windows-Form/ProgressBarHost.htm

using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace ProgressBarHost
{


    public class Progress : System.Windows.Forms.UserControl
    {
        internal System.Windows.Forms.Label lblProgress;
        internal System.Windows.Forms.ProgressBar Bar;
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;

        public Progress()
        {
            // This call is required by the Windows.Forms Form Designer.
            InitializeComponent();

            // TODO: Add any initialization after the InitForm call

        }

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if(components != null)
                {
                    components.Dispose();
                }
            }
            base.Dispose( disposing );
        }

        #region Component Designer generated code
        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.lblProgress = new System.Windows.Forms.Label();
            this.Bar = new System.Windows.Forms.ProgressBar();
            this.SuspendLayout();
            // 
            // lblProgress
            // 
            this.lblProgress.Anchor = ((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
                | System.Windows.Forms.AnchorStyles.Right);
            this.lblProgress.Location = new System.Drawing.Point(5, 46);
            this.lblProgress.Name = "lblProgress";
            this.lblProgress.Size = new System.Drawing.Size(152, 16);
            this.lblProgress.TabIndex = 3;
            this.lblProgress.Text = "0% Done";
            this.lblProgress.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            // 
            // Bar
            // 
            this.Bar.Anchor = ((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
                | System.Windows.Forms.AnchorStyles.Right);
            this.Bar.Location = new System.Drawing.Point(5, 6);
            this.Bar.Name = "Bar";
            this.Bar.Size = new System.Drawing.Size(154, 32);
            this.Bar.TabIndex = 2;
            // 
            // Progress
            // 
            this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                          this.lblProgress,
                                                                          this.Bar});
            this.Name = "Progress";
            this.Size = new System.Drawing.Size(164, 68);
            this.ResumeLayout(false);

        }
        #endregion
        
        [Description("The current value (between 0 and Maximum) which sets the position of the progress bar"), 
        Category("Behavior"), DefaultValue(0)]
        public int Value
        {
            get
            {
                return Bar.Value;
            }
            set
            {
                Bar.Value = value;
                UpdateLabel();
            }
        }

        public int Maximum
        {
            get
            {
                return Bar.Maximum;
            }
            set
            {
                Bar.Maximum = value;
            }
        }

        public int Step
        {
            get
            {
                return Bar.Step;
            }
            set
            {
                Bar.Step = value;
            }
        }

        public void PerformStep()
        {
            Bar.PerformStep();
            UpdateLabel();
        }

        private void UpdateLabel()
        {
            lblProgress.Text = (Math.Round((decimal)(Bar.Value * 100) /
                Bar.Maximum)).ToString();
            lblProgress.Text += "% Done";
        }
    }



}

public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private bool _visible;

    public bool Visible
    {
        get { return _visible; }
        set { _visible = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    private ProgressBarHost.Progress _target;
    public ProgressBarHost.Progress Target
    {
        get { return _target; }
        set { _target = value; }
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.ComponentModel.dll'



# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}

$so = [hashtable]::Synchronized(@{
    'Result' = [string]'';
    'Visible' = [bool]$false;
    'ScriptDirectory' = [string]'';
    'Form' = [System.Windows.Forms.Form]$null;
    'Progress' = [ProgressBarHost.Progress]$null;
    'NeedData' = [bool]$false;
    'HaveData' = [bool]$false;

  })

$so.ScriptDirectory = Get-ScriptDirectory

$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so',$so)



$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)


$run_script = [powershell]::Create().AddScript({



    function Progressbar (
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
      $components = New-Object System.ComponentModel.Container
      $progress_status = New-Object ProgressBarHost.Progress
      $so.Progress = $progress_status
      $progress_status.Location = New-Object System.Drawing.Point (12,8)
      $progress_status.Name = "status"
      $progress_status.Size = New-Object System.Drawing.Size (272,88)
      $progress_status.TabIndex = 0

      $b1 = New-Object System.Windows.Forms.Button
      $b1.Location = New-Object System.Drawing.Size (140,152)
      $b1.Size = New-Object System.Drawing.Size (92,24)
      $b1.Text = 'forward'
      $b1.add_click({ $progress_status.PerformStep()
          if ($progress_status.Maximum -eq $progress_status.Value)
          {
            $b1.Enabled = false;
          }

        })

      $f.Controls.Add($b1)
      $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,14)
      $f.ClientSize = New-Object System.Drawing.Size (292,194)
      $f.Controls.Add($progress_status)
      $f.Topmost = $True


      $caller.Visible = $true;
      $so.Visible = $caller.Visible
      $f.Add_Shown({ $f.Activate() })

      [void]$f.ShowDialog([win32window ]($caller))

      $f.Dispose()
    }

    Progressbar -Title $title -Message $message -caller $caller

  })


# -- main program -- 
Clear-Host
$run_script.Runspace = $rs

$handle = $run_script.BeginInvoke()

Start-Sleep 3
$max_cnt = 10
$cnt = 0
while ($cnt -lt $max_cnt) {
  $cnt++
  Start-Sleep -Milliseconds 100
  $so.Progress.PerformStep()
}
