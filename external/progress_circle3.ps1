# http://poshcode.org/5520
# Asynchronous GUI by Peter Kriegel

param(
  [switch]$pause
)

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



# http://poshcode.org/5520
# Asynchronous GUI by Peter Kriegel
# Simon Mourier See: http://stackoverflow.com/questions/14401704/update-winforms-not-wpf-ui-from-another-thread

Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'
# VisualStyles are only needed for a very few Windows Forms controls like ProgessBar
[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms.VisualStyles')


$Form = New-Object System.Windows.Forms.Form
$l1 = New-Object System.Windows.Forms.Label
$is= New-Object System.Windows.Forms.FormWindowState
$Form.Text = 'Demo Form'
$Form.Name = 'Form'
$Form.DataBindings.DefaultDataSourceUpdateMode = 0
$Form.ClientSize = New-Object System.Drawing.Size (216,121)
# Label 
$l1.Name = 'progress_label'
$l1.Location = New-Object System.Drawing.Point (70,34)
$l1.Size = New-Object System.Drawing.Size (100,23)
$l1.Text = 'Round:'


#  progressCircle1
$c1 = New-Object -TypeName 'ProgressCircle.ProgressCircle'
$c1.Location = New-Object System.Drawing.Point (20,20)
$c1.Name = "progress_circle"
$c1.PCElapsedTimeColor1 = [System.Drawing.Color]::Chartreuse
$c1.PCElapsedTimeColor2 = [System.Drawing.Color]::Yellow
$c1.PCLinearGradientMode = [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
$c1.PCRemainingTimeColor1 = [System.Drawing.Color]::Navy
$c1.PCRemainingTimeColor2 = [System.Drawing.Color]::LightBlue
$c1.PCTotalTime = 25
$c1.Size = New-Object System.Drawing.Size (47,45)
$c1.TabIndex = 3
$progress_complete = $c1.add_PCCompleted
$progress_complete.Invoke({
    param([object]$sender,[string]$message)
    # [System.Windows.Forms.MessageBox]::Show('Task completed!')
    $l1.Text = ('Task completed!')
  })


$Form.Controls.AddRange(@($l1,$c1))

$is= $Form.WindowState

$Form.add_Load({
    $Form.WindowState = $InitialFormWindowState
  })

$rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($Host)
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()

$rs.SessionStateProxy.SetVariable('Form',$Form)
$po = [System.Management.Automation.PowerShell]::Create()
$po.Runspace = $rs

$po.AddScript({
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::Run($Form)
  })

$res = $po.BeginInvoke()

if ($PSBoundParameters['pause']) {
  Write-Output 'Pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}


<#

# Executing a Scriptblock (which represents a specified delegate), on the GUI thread that
# owns the control's underlying window handle, with the specified list of arguments.

$TextBox.Invoke( [System.Action[string]] { param($Message) $TextBox.Text = $Message },
    $MyMessage )

#>


# subclass
$eventargs = New-Object -TypeName 'System.EventArgs'

Add-Member -InputObject $eventargs -MemberType 'NoteProperty' -Name 'Increment' -Value 0 -Force
Add-Member -InputObject $eventargs -MemberType 'NoteProperty' -Name 'Total' -Value 0 -Force

$handler = [System.EventHandler]{
  param(
    [object]$sender,
    [System.EventArgs]$e
  )
  $local:increment = $e.Increment
  $local:total = $e.Total
  $sender.Increment($local:increment)
  try {
    $elems = $sender.Parent.Controls.Find('progress_label',$false)
  } catch [exception]{
  }
  if ($elems -ne $null) {
    $elems[0].Text = ('Round: {0}' -f $local:total)
  }

}

1..25 | ForEach-Object {

  $eventargs.Total = $_
  $eventargs.Increment = 1
  [void]$c1.BeginInvoke($handler,($c1,([System.EventArgs]$eventargs)))


$c1.Invoke(
    [System.Action[int]] { 
        param($increment) 
$sender.Increment($increment) 
    },
    # Argument for the System.Action delegate scriptblock
    1
)

  Start-Sleep -Milliseconds (Get-Random -Maximum 1000)

}

if ($PSBoundParameters['pause']) {
  # block PowerShell Main-Thread to leave it alive until user enter something
  Write-Output 'Pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 2000
}


[System.Windows.Forms.Application]::Exit()
$po.EndInvoke($res)
$rs.Close()
$po.Dispose()


