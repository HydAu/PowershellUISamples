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

param(
  [switch]$test,
  [switch]$debug)


# http://www.codeproject.com/Tips/842376/Create-Floating-Sliding-Moving-Menu-in-Csharp-NET
Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Ribbon
{

    public class Panel : System.Windows.Forms.Panel
    {

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.Timer timer2;
        private System.Windows.Forms.UserControl _usrCtrl;
        private System.ComponentModel.IContainer components = null;
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.panel1 = new System.Windows.Forms.Panel();
            this.panel2 = new System.Windows.Forms.Panel();
            this.button2 = new System.Windows.Forms.Button();
            this.button1 = new System.Windows.Forms.Button();
            this.panel3 = new System.Windows.Forms.Panel();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.timer2 = new System.Windows.Forms.Timer(this.components);
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.DimGray;
            this.panel1.Controls.Add(this.panel2);
            this.panel1.Controls.Add(this.button2);
            this.panel1.Controls.Add(this.button1);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.panel1.Location = new System.Drawing.Point(5, 5);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(464, 100);
            this.panel1.TabIndex = 0;
            // 
            // panel2
            // 

            this.panel2.BackColor = System.Drawing.Color.DarkGray;
            this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel2.Location = new System.Drawing.Point(20, 0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(424, 100);
            this.panel2.TabIndex = 2;
            this._usrCtrl.Left = this._usrCtrl.Top = 0;
            panel2.Controls.Add(this._usrCtrl);
            this._usrCtrl.Show();

            // 
            // button2
            // 
            this.button2.Dock = System.Windows.Forms.DockStyle.Right;
            this.button2.FlatAppearance.BorderColor = System.Drawing.Color.Gray;
            this.button2.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button2.ForeColor = System.Drawing.Color.Silver;
            this.button2.Location = new System.Drawing.Point(444, 0);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(20, 100);
            this.button2.TabIndex = 1;
            this.button2.Text = ">";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.MouseDown += new System.Windows.Forms.MouseEventHandler(this.button2_MouseDown);
            this.button2.MouseUp += new System.Windows.Forms.MouseEventHandler(this.button2_MouseUp);
            // 
            // button1
            // 
            this.button1.Dock = System.Windows.Forms.DockStyle.Left;
            this.button1.FlatAppearance.BorderColor = System.Drawing.Color.Gray;
            this.button1.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button1.ForeColor = System.Drawing.Color.Silver;
            this.button1.Location = new System.Drawing.Point(0, 0);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(20, 100);
            this.button1.TabIndex = 0;
            this.button1.Text = "<";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.button1_MouseDown);
            this.button1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.button1_MouseUp);
            // 
            // panel3
            // 
            this.panel3.BackColor = System.Drawing.Color.Gray;
            this.panel3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel3.Location = new System.Drawing.Point(5, 105);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(464, 202);
            this.panel3.TabIndex = 1;
            // 
            // timer1
            // 
            this.timer1.Interval = 5;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // timer2
            // 
            this.timer2.Interval = 5;
            this.timer2.Tick += new System.EventHandler(this.timer2_Tick);
            // 

            // Panel
            // 
            this.BackColor = System.Drawing.Color.LightGray;
            this.ClientSize = new System.Drawing.Size(474, 312);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel1);
            this.Name = "Panel";
            this.Padding = new System.Windows.Forms.Padding(5);
            this.Text = "Floating Menu Sample Project";
 

            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        public Panel(System.Windows.Forms.UserControl u)
        {
         if (u == null)
            throw new ArgumentNullException("Usercontrol required");
          this._usrCtrl = u; 
          InitializeComponent();
        }


        private void timer1_Tick(object sender, EventArgs e)
        {
            if (this._usrCtrl.Left < 0)
            {
                this._usrCtrl.Left = this._usrCtrl.Left + 5;
            }
        }

        private void timer2_Tick(object sender, EventArgs e)
        {
            if (this._usrCtrl.Right >= panel2.Left + panel2.Width)
            {
                this._usrCtrl.Left = this._usrCtrl.Left - 5;
            }
        }

        private void button1_MouseDown(object sender, MouseEventArgs e)
        {
            timer1.Start();
        }

        private void button1_MouseUp(object sender, MouseEventArgs e)
        {
            timer1.Stop();
        }

        private void button2_MouseDown(object sender, MouseEventArgs e)
        {
            timer2.Start();
        }

        private void button2_MouseUp(object sender, MouseEventArgs e)
        {
            timer2.Stop();
        }
    }


}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.Xml.dll'


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


function PromptRibbon {

  param(
    [string]$title,
    [string]$message,
    [object]$caller
  )


  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $f.Size = New-Object System.Drawing.Size (470,135)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
  $f.StartPosition = 'CenterScreen'

  $u = New-Object System.Windows.Forms.UserControl
  $p1 = New-Object System.Windows.Forms.Panel
  $l1 = New-Object System.Windows.Forms.Label

  $p2 = New-Object System.Windows.Forms.Panel
  $l2 = New-Object System.Windows.Forms.Label

  $b1 = New-Object System.Windows.Forms.Button
  $b2 = New-Object System.Windows.Forms.Button
  $b3 = New-Object System.Windows.Forms.Button
  $b4 = New-Object System.Windows.Forms.Button
  $b5 = New-Object System.Windows.Forms.Button
  $b6 = New-Object System.Windows.Forms.Button
  $b7 = New-Object System.Windows.Forms.Button
  $b8 = New-Object System.Windows.Forms.Button
  $b9 = New-Object System.Windows.Forms.Button
  $b10 = New-Object System.Windows.Forms.Button
  $b11 = New-Object System.Windows.Forms.Button
  $b12 = New-Object System.Windows.Forms.Button
  $b13 = New-Object System.Windows.Forms.Button
  $b14 = New-Object System.Windows.Forms.Button
  $b15 = New-Object System.Windows.Forms.Button
  $b16 = New-Object System.Windows.Forms.Button
  $b17 = New-Object System.Windows.Forms.Button
  $b18 = New-Object System.Windows.Forms.Button
  $b19 = New-Object System.Windows.Forms.Button
  $b20 = New-Object System.Windows.Forms.Button
  $p1.SuspendLayout()
  $p2.SuspendLayout()
  $u.SuspendLayout()

  #  panels
  $cnt = 0
  @(
    ([ref]$p1),
    ([ref]$p2)
  ) | ForEach-Object {
    $p = $_.Value
    $p.BackColor = [System.Drawing.Color]::Silver
    $p.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $p.Dock = [System.Windows.Forms.DockStyle]::Left
    $p.Location = New-Object System.Drawing.Point ((440 * $cnt),0)
    $p.Name = ('panel {0}' -f $cnt)
    $p.Size = New-Object System.Drawing.Size (440,100)
    $p.TabIndex = $cnt
    $cnt++
  }

  # labels
  $cnt = 0
  @(
    ([ref]$l1),
    ([ref]$l2)
  ) | ForEach-Object {
    $l = $_.Value
    $l.BackColor = [System.Drawing.Color]::DarkGray
    $l.Dock = [System.Windows.Forms.DockStyle]::Top
    $l.Location = New-Object System.Drawing.Point (0,0)
    $l.Name = ('label {0}' -f $cnt)
    $l.Size = New-Object System.Drawing.Size (176,23)
    $l.TabIndex = 0
    $l.Text = ('Menu Group  {0}' -f $cnt)
    $l.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $cnt++
  }
  # buttons
$positions = @{
1  = @{'x' =   6; 'y' = 27; };
2  = @{'x' =   6; 'y' = 64; };
3  = @{'x' =  92; 'y' = 27; };
4  = @{'x' =  92; 'y' = 64; };
5  = @{'x' = 178; 'y' = 27; };
6  = @{'x' = 178; 'y' = 64; };
7  = @{'x' = 264; 'y' = 27; };
8  = @{'x' = 264; 'y' = 64; };
9  = @{'x' = 350; 'y' = 27; };
10 = @{'x' = 350; 'y' = 64; };
11 = @{'x' =   6; 'y' = 27; };
12 = @{'x' =   6; 'y' = 64; };
13 = @{'x' =  92; 'y' = 27; };
14 = @{'x' =  92; 'y' = 64; };
15 = @{'x' = 178; 'y' = 27; };
16 = @{'x' = 178; 'y' = 64; };
17 = @{'x' = 264; 'y' = 27; };
18 = @{'x' = 264; 'y' = 64; };
19 = @{'x' = 350; 'y' = 27; };
20 = @{'x' = 350; 'y' = 64; };

}
  $cnt = 1

  @(
    ([ref]$b1),
    ([ref]$b2),
    ([ref]$b3),
    ([ref]$b4),
    ([ref]$b5),
    ([ref]$b6),
    ([ref]$b7),
    ([ref]$b8),
    ([ref]$b9),
    ([ref]$b10),
    ([ref]$b11),
    ([ref]$b12),
    ([ref]$b13),
    ([ref]$b14),
    ([ref]$b15),
    ([ref]$b16),
    ([ref]$b17),
    ([ref]$b18),
    ([ref]$b19),
    ([ref]$b20)
  ) | ForEach-Object {
    $b = $_.Value
    $x = $positions[$cnt]['x']
    $y = $positions[$cnt]['y']
    write-Debug ('button{0} x = {1}  y = {2}' -f $cnt,$x,$y)
    $b.Location = New-Object System.Drawing.Point ( $x, $y)
    $b.Name = ('button{0}' -f $cnt)
    $b.Size = New-Object System.Drawing.Size (80,30)
    $b.TabIndex = 1
    $b.Text = ('Button {0}' -f $cnt)
    $b.UseVisualStyleBackColor = $true
    $cnt++

  }

  #  button1
  function button_click {

    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )
    $who = $sender.Text
    [System.Windows.Forms.MessageBox]::Show(("We are processing {0}." -f $who))

  }
  $eventMethod1 = $b1.add_click
  $eventMethod1.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $caller.Data = $sender.Text
      button_click -Sender $sender -eventargs $eventargs

    })

  #  button2
  $eventMethod2 = $b2.add_click
  $eventMethod2.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $caller.Data = $sender.Text
      button_click -Sender $sender -eventargs $eventargs
    })

  #  button3

  $eventMethod3 = $b3.add_click
  $eventMethod3.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $caller.Data = $sender.Text
      button_click -Sender $sender -eventargs $eventargs
    })

  #  button4


  #  button5

  #  button6

  #  button7

  #  button8

  #  button9

  #  button10

  # Panel1 label and buttons
  $p1.Controls.Add($l1)
  $p1.Controls.AddRange(@( $b10,$b9,$b8,$b7,$b6,$b5, $b4,$b3,$b2,$b1))


  #  button11

  #  button12

  #  button13

  #  button14

  $eventMethod14 = $b14.add_click
  $eventMethod14.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $who = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(("We are processing {0}." -f $who))
      $caller.Data = $sender.Text
    })

  #  button15

  #  button16

  #  button17

  #  button18

  #  button19

  #  button20


  # Panel2 label and buttons
  $p2.Controls.AddRange(@( $b20,$b19,$b18,$b17,$b16,$b15, $b14,$b13,$b12,$b11))
  $p2.Controls.Add($l2)

  #  UserControl1
  $u.AutoScaleDimensions = New-Object System.Drawing.SizeF (6,13)
  $u.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $u.BackColor = [System.Drawing.Color]::Gainsboro

  $u.Controls.AddRange(@($p2,$p1))
  $u.Name = 'UserControl1'
  $u.Size = New-Object System.Drawing.Size (948,100)
  $p1.ResumeLayout($false)
  $p2.ResumeLayout($false)
  $u.ResumeLayout($false)

  $r = New-Object -TypeName 'Ribbon.Panel' -ArgumentList ([System.Windows.Forms.UserControl]$u)
  $r.Size = $f.Size

  $f.Controls.Add($r)
  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptRibbon -Title 'Floating Menu Sample Project' -caller $caller
Write-Output $caller.Data