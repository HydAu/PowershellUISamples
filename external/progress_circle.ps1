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
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
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

#  http://www.codeproject.com/Articles/25575/ProgressCircle-An-Alternative-to-ProgressBar
Add-Type -TypeDefinition @"


/////////////////////////////////////////////////////////////////////////////
// ProgressCircle.cs - progress control
//
// Written by Sergio A. B. Petrovcic (sergio_petrovcic@hotmail.com)
// Copyright (c) 2008 Sergio A. B. Petrovcic.
//
// This code may be used in compiled form in any way you desire. This
// file may be redistributed by any means PROVIDING it is
// not sold for profit without the authors written consent, and
// providing that this notice and the authors name is included.
//
// This file is provided "as is" with no expressed or implied warranty.
// The author accepts no liability if it causes any damage to you or your
// computer whatsoever.
//
// If you find bugs, have suggestions for improvements, etc.,
// please contact the author.
//
// History (Date/Author/Description):
// ----------------------------------
//
// 2008/04/23: Sergio A. B. Petrovcic
// - Original implementation

using System;
using System.Collections.Generic;

using System.Data;
using System.Diagnostics;

using System.Drawing;
using System.Drawing.Drawing2D;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace ProgressCircle
{
public partial class ProgressCircle : UserControl
{
public delegate void EventHandler (object sender, string message);
public event EventHandler m_EventIncremented;

public event EventHandler PCIncremented
{
        add { m_EventIncremented += new EventHandler (value); }
        remove { m_EventIncremented -= new EventHandler (value); }
}
public event EventHandler m_EventCompleted;
public event EventHandler PCCompleted
{
        add { m_EventCompleted += new EventHandler (value); }
        remove { m_EventCompleted -= new EventHandler (value); }
}

private LinearGradientMode m_eLinearGradientMode = LinearGradientMode.Vertical;
public LinearGradientMode PCLinearGradientMode
{
        get { return m_eLinearGradientMode; }
        set { m_eLinearGradientMode = value; }
}
private Color m_oColor1RemainingTime = Color.Navy;
public Color PCRemainingTimeColor1
{
        get { return m_oColor1RemainingTime; }
        set { m_oColor1RemainingTime = value; }
}
private Color m_oColor2RemainingTime = Color.LightSlateGray;
public Color PCRemainingTimeColor2
{
        get { return m_oColor2RemainingTime; }
        set { m_oColor2RemainingTime = value; }
}
private Color m_oColor1ElapsedTime = Color.IndianRed;
public Color PCElapsedTimeColor1
{
        get { return m_oColor1ElapsedTime; }
        set { m_oColor1ElapsedTime = value; }
}
private Color m_oColor2ElapsedTime = Color.Gainsboro;
public Color PCElapsedTimeColor2
{
        get { return m_oColor2ElapsedTime; }
        set { m_oColor2ElapsedTime = value; }
}
private int m_iTotalTime = 100;
public int PCTotalTime
{
        get { return m_iTotalTime; }
        set { m_iTotalTime = value; }
}
private int m_iElapsedTime = 0;
public int PCElapsedTime
{
        get { return m_iElapsedTime; }
        set { m_iElapsedTime = value; }
}

public ProgressCircle()
{
        InitializeComponent ();
}

public void Increment (int a_iValue)
{
        if (m_iElapsedTime > m_iTotalTime)
                return;

        if (m_iElapsedTime + a_iValue >= m_iTotalTime) {
                m_iElapsedTime = m_iTotalTime;
                this.Refresh ();
                if (m_EventIncremented != null)
                        m_EventIncremented (this, null);
                if (m_EventCompleted != null)
                        m_EventCompleted (this, null);
        }
        else{
                m_iElapsedTime += a_iValue;
                this.Refresh ();
                if (m_EventIncremented != null)
                        m_EventIncremented (this, null);
        }
}
private void ProgressCircle_Paint (object sender, PaintEventArgs e)
{
        Rectangle t_oRectangle = new Rectangle (0, 0, this.Width, this.Height);
        Brush t_oBrushRemainingTime = new LinearGradientBrush (t_oRectangle, m_oColor1RemainingTime, m_oColor2RemainingTime, m_eLinearGradientMode);
        Brush t_oBrushElapsedTime = new LinearGradientBrush (t_oRectangle, m_oColor1ElapsedTime, m_oColor2ElapsedTime, m_eLinearGradientMode);

        e.Graphics.FillEllipse (t_oBrushRemainingTime, t_oRectangle);
        e.Graphics.FillPie (t_oBrushElapsedTime, t_oRectangle, -90f, (float)(360 * m_iElapsedTime / m_iTotalTime));
}

private void InitializeComponent ()
{
        this.SuspendLayout ();

        this.AutoScaleDimensions = new System.Drawing.SizeF (6F, 13F);
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.Name = "LmaProgressBar";
        this.Size = new System.Drawing.Size (104, 89);
        this.Paint += new System.Windows.Forms.PaintEventHandler (this.ProgressCircle_Paint);
        this.ResumeLayout (false);
}
}
}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object -TypeName 'System.Windows.Forms.Form'
$f.Text = $title
$f.SuspendLayout()

#  button1
$b1 = New-Object System.Windows.Forms.Button
$b1.Location = New-Object System.Drawing.Point (12,44)
$b1.Name = "button1"
$b1.Size = New-Object System.Drawing.Size (75,23)
$b1.TabIndex = 0
$b1.Text = "Start"
$b1.UseVisualStyleBackColor = $true

$progress_click = $b1.add_click
$progress_click.Invoke({
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )
    $b1.Enabled = $false
    $p.Value = 0
    $c1.PCElapsedTime = 0
    for ([int]$i = 0; $i -ne 100; $i++)
    {
      $p.Increment(1)
      $c1.Increment(1)
      [System.Threading.Thread]::Sleep(100)
    }
    $b1.Enabled = $true
  })

#  progressBar1
$p = New-Object System.Windows.Forms.ProgressBar
$p.Location = New-Object System.Drawing.Point (12,112)
$p.Name = "progressBar1"
$p.Size = New-Object System.Drawing.Size (187,16)
$p.TabIndex = 2;
  
#  progressCircle1
$c1 = New-Object -TypeName 'ProgressCircle.ProgressCircle'
$c1.Location = New-Object System.Drawing.Point (105,12)
$c1.Name = "progressCircle1"
$c1.PCElapsedTimeColor1 = [System.Drawing.Color]::Chartreuse
$c1.PCElapsedTimeColor2 = [System.Drawing.Color]::Yellow
$c1.PCLinearGradientMode = [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
$c1.PCRemainingTimeColor1 = [System.Drawing.Color]::Navy
$c1.PCRemainingTimeColor2 = [System.Drawing.Color]::LightBlue
$c1.PCTotalTime = 100
$c1.Size = New-Object System.Drawing.Size (94,89)
$c1.TabIndex = 3
$progress_complete = $c1.add_PCCompleted
$progress_complete.Invoke({

    param([object]$sender,[string]$message)

    [System.Windows.Forms.MessageBox]::Show('Task completed!')
  })

#  Form1
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (210,140)
$f.Controls.Add($c1)
$f.Controls.Add($p)
$f.Controls.Add($b1)
$f.Name = "Form1"
$f.Text = "ProgressCircle"
$f.ResumeLayout($false)

$f.Topmost = $True

$f.Add_Shown({ $f.Activate() })

[void]$f.ShowDialog([win32window]($caller))

$f.Dispose()

