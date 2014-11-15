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
        public  System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.Timer timer2;


        public UserControl usrCtrl = null;

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

            // usrCtrl.Left = usrCtrl.Top = 0;
            // panel2.Controls.Add(usrCtrl);
            // usrCtrl.Show();
            // usrCtrl =
            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }


        public Panel()
        {
            InitializeComponent();
        }


        private void timer1_Tick(object sender, EventArgs e)
        {
            if (usrCtrl.Left < 0)
            {
                usrCtrl.Left = usrCtrl.Left + 5;
            }
        }

        private void timer2_Tick(object sender, EventArgs e)
        {
            if (usrCtrl.Right >= panel2.Left + panel2.Width)
            {
                usrCtrl.Left = usrCtrl.Left - 5;
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

    public class UserControl1 : UserControl
    {

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button button4;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Button button5;
        private System.Windows.Forms.Button button6;
        private System.Windows.Forms.Button button7;
        private System.Windows.Forms.Button button8;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Button button9;
        private System.Windows.Forms.Button button10;
        private System.Windows.Forms.Button button11;
        private System.Windows.Forms.Button button12;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Panel panel4;
        private System.Windows.Forms.Button button13;
        private System.Windows.Forms.Button button14;
        private System.Windows.Forms.Button button15;
        private System.Windows.Forms.Button button16;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Panel panel5;
        private System.Windows.Forms.Button button17;
        private System.Windows.Forms.Button button18;
        private System.Windows.Forms.Button button19;
        private System.Windows.Forms.Button button20;
        private System.Windows.Forms.Label label5;

        public UserControl1()
        {
            InitializeComponent();
        }

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
            this.panel1 = new System.Windows.Forms.Panel();
            this.label1 = new System.Windows.Forms.Label();
            this.button1 = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.button4 = new System.Windows.Forms.Button();
            this.panel2 = new System.Windows.Forms.Panel();
            this.button5 = new System.Windows.Forms.Button();
            this.button6 = new System.Windows.Forms.Button();
            this.button7 = new System.Windows.Forms.Button();
            this.button8 = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.panel3 = new System.Windows.Forms.Panel();
            this.button9 = new System.Windows.Forms.Button();
            this.button10 = new System.Windows.Forms.Button();
            this.button11 = new System.Windows.Forms.Button();
            this.button12 = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.panel4 = new System.Windows.Forms.Panel();
            this.button13 = new System.Windows.Forms.Button();
            this.button14 = new System.Windows.Forms.Button();
            this.button15 = new System.Windows.Forms.Button();
            this.button16 = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.panel5 = new System.Windows.Forms.Panel();
            this.button17 = new System.Windows.Forms.Button();
            this.button18 = new System.Windows.Forms.Button();
            this.button19 = new System.Windows.Forms.Button();
            this.button20 = new System.Windows.Forms.Button();
            this.label5 = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel3.SuspendLayout();
            this.panel4.SuspendLayout();
            this.panel5.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.Silver;
            this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel1.Controls.Add(this.button4);
            this.panel1.Controls.Add(this.button3);
            this.panel1.Controls.Add(this.button2);
            this.panel1.Controls.Add(this.button1);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(178, 100);
            this.panel1.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.DarkGray;
            this.label1.Dock = System.Windows.Forms.DockStyle.Top;
            this.label1.Location = new System.Drawing.Point(0, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(176, 23);
            this.label1.TabIndex = 0;
            this.label1.Text = "Menu Group 1";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(6, 27);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(80, 30);
            this.button1.TabIndex = 1;
            this.button1.Text = "button1";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(6, 64);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(80, 30);
            this.button2.TabIndex = 2;
            this.button2.Text = "button2";
            this.button2.UseVisualStyleBackColor = true;
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(92, 28);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(80, 30);
            this.button3.TabIndex = 3;
            this.button3.Text = "button3";
            this.button3.UseVisualStyleBackColor = true;
            // 
            // button4
            // 
            this.button4.Location = new System.Drawing.Point(92, 64);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(80, 30);
            this.button4.TabIndex = 4;
            this.button4.Text = "button4";
            this.button4.UseVisualStyleBackColor = true;
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.Silver;
            this.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel2.Controls.Add(this.button5);
            this.panel2.Controls.Add(this.button6);
            this.panel2.Controls.Add(this.button7);
            this.panel2.Controls.Add(this.button8);
            this.panel2.Controls.Add(this.label2);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel2.Location = new System.Drawing.Point(178, 0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(178, 100);
            this.panel2.TabIndex = 1;
            // 
            // button5
            // 
            this.button5.Location = new System.Drawing.Point(92, 64);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(80, 30);
            this.button5.TabIndex = 4;
            this.button5.Text = "button5";
            this.button5.UseVisualStyleBackColor = true;
            // 
            // button6
            // 
            this.button6.Location = new System.Drawing.Point(92, 28);
            this.button6.Name = "button6";
            this.button6.Size = new System.Drawing.Size(80, 30);
            this.button6.TabIndex = 3;
            this.button6.Text = "button6";
            this.button6.UseVisualStyleBackColor = true;
            // 
            // button7
            // 
            this.button7.Location = new System.Drawing.Point(6, 64);
            this.button7.Name = "button7";
            this.button7.Size = new System.Drawing.Size(80, 30);
            this.button7.TabIndex = 2;
            this.button7.Text = "button7";
            this.button7.UseVisualStyleBackColor = true;
            // 
            // button8
            // 
            this.button8.Location = new System.Drawing.Point(6, 27);
            this.button8.Name = "button8";
            this.button8.Size = new System.Drawing.Size(80, 30);
            this.button8.TabIndex = 1;
            this.button8.Text = "button8";
            this.button8.UseVisualStyleBackColor = true;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.DarkGray;
            this.label2.Dock = System.Windows.Forms.DockStyle.Top;
            this.label2.Location = new System.Drawing.Point(0, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(176, 23);
            this.label2.TabIndex = 0;
            this.label2.Text = "Menu Group 2";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // panel3
            // 
            this.panel3.BackColor = System.Drawing.Color.Silver;
            this.panel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel3.Controls.Add(this.button9);
            this.panel3.Controls.Add(this.button10);
            this.panel3.Controls.Add(this.button11);
            this.panel3.Controls.Add(this.button12);
            this.panel3.Controls.Add(this.label3);
            this.panel3.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel3.Location = new System.Drawing.Point(356, 0);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(178, 100);
            this.panel3.TabIndex = 2;
            // 
            // button9
            // 
            this.button9.Location = new System.Drawing.Point(92, 64);
            this.button9.Name = "button9";
            this.button9.Size = new System.Drawing.Size(80, 30);
            this.button9.TabIndex = 4;
            this.button9.Text = "button9";
            this.button9.UseVisualStyleBackColor = true;
            // 
            // button10
            // 
            this.button10.Location = new System.Drawing.Point(92, 28);
            this.button10.Name = "button10";
            this.button10.Size = new System.Drawing.Size(80, 30);
            this.button10.TabIndex = 3;
            this.button10.Text = "button10";
            this.button10.UseVisualStyleBackColor = true;
            // 
            // button11
            // 
            this.button11.Location = new System.Drawing.Point(6, 64);
            this.button11.Name = "button11";
            this.button11.Size = new System.Drawing.Size(80, 30);
            this.button11.TabIndex = 2;
            this.button11.Text = "button11";
            this.button11.UseVisualStyleBackColor = true;
            // 
            // button12
            // 
            this.button12.Location = new System.Drawing.Point(6, 27);
            this.button12.Name = "button12";
            this.button12.Size = new System.Drawing.Size(80, 30);
            this.button12.TabIndex = 1;
            this.button12.Text = "button12";
            this.button12.UseVisualStyleBackColor = true;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.DarkGray;
            this.label3.Dock = System.Windows.Forms.DockStyle.Top;
            this.label3.Location = new System.Drawing.Point(0, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(176, 23);
            this.label3.TabIndex = 0;
            this.label3.Text = "Menu Group 3";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // panel4
            // 
            this.panel4.BackColor = System.Drawing.Color.Silver;
            this.panel4.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel4.Controls.Add(this.button13);
            this.panel4.Controls.Add(this.button14);
            this.panel4.Controls.Add(this.button15);
            this.panel4.Controls.Add(this.button16);
            this.panel4.Controls.Add(this.label4);
            this.panel4.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel4.Location = new System.Drawing.Point(534, 0);
            this.panel4.Name = "panel4";
            this.panel4.Size = new System.Drawing.Size(178, 100);
            this.panel4.TabIndex = 3;
            // 
            // button13
            // 
            this.button13.Location = new System.Drawing.Point(92, 64);
            this.button13.Name = "button13";
            this.button13.Size = new System.Drawing.Size(80, 30);
            this.button13.TabIndex = 4;
            this.button13.Text = "button13";
            this.button13.UseVisualStyleBackColor = true;
            // 
            // button14
            // 
            this.button14.Location = new System.Drawing.Point(92, 28);
            this.button14.Name = "button14";
            this.button14.Size = new System.Drawing.Size(80, 30);
            this.button14.TabIndex = 3;
            this.button14.Text = "button14";
            this.button14.UseVisualStyleBackColor = true;
            // 
            // button15
            // 
            this.button15.Location = new System.Drawing.Point(6, 64);
            this.button15.Name = "button15";
            this.button15.Size = new System.Drawing.Size(80, 30);
            this.button15.TabIndex = 2;
            this.button15.Text = "button15";
            this.button15.UseVisualStyleBackColor = true;
            // 
            // button16
            // 
            this.button16.Location = new System.Drawing.Point(6, 27);
            this.button16.Name = "button16";
            this.button16.Size = new System.Drawing.Size(80, 30);
            this.button16.TabIndex = 1;
            this.button16.Text = "button16";
            this.button16.UseVisualStyleBackColor = true;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.DarkGray;
            this.label4.Dock = System.Windows.Forms.DockStyle.Top;
            this.label4.Location = new System.Drawing.Point(0, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(176, 23);
            this.label4.TabIndex = 0;
            this.label4.Text = "Menu Group 4";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // panel5
            // 
            this.panel5.BackColor = System.Drawing.Color.Silver;
            this.panel5.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel5.Controls.Add(this.button17);
            this.panel5.Controls.Add(this.button18);
            this.panel5.Controls.Add(this.button19);
            this.panel5.Controls.Add(this.button20);
            this.panel5.Controls.Add(this.label5);
            this.panel5.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel5.Location = new System.Drawing.Point(712, 0);
            this.panel5.Name = "panel5";
            this.panel5.Size = new System.Drawing.Size(178, 100);
            this.panel5.TabIndex = 4;
            // 
            // button17
            // 
            this.button17.Location = new System.Drawing.Point(92, 64);
            this.button17.Name = "button17";
            this.button17.Size = new System.Drawing.Size(80, 30);
            this.button17.TabIndex = 4;
            this.button17.Text = "button17";
            this.button17.UseVisualStyleBackColor = true;
            // 
            // button18
            // 
            this.button18.Location = new System.Drawing.Point(92, 28);
            this.button18.Name = "button18";
            this.button18.Size = new System.Drawing.Size(80, 30);
            this.button18.TabIndex = 3;
            this.button18.Text = "button18";
            this.button18.UseVisualStyleBackColor = true;
            // 
            // button19
            // 
            this.button19.Location = new System.Drawing.Point(6, 64);
            this.button19.Name = "button19";
            this.button19.Size = new System.Drawing.Size(80, 30);
            this.button19.TabIndex = 2;
            this.button19.Text = "button19";
            this.button19.UseVisualStyleBackColor = true;
            // 
            // button20
            // 
            this.button20.Location = new System.Drawing.Point(6, 27);
            this.button20.Name = "button20";
            this.button20.Size = new System.Drawing.Size(80, 30);
            this.button20.TabIndex = 1;
            this.button20.Text = "button20";
            this.button20.UseVisualStyleBackColor = true;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.DarkGray;
            this.label5.Dock = System.Windows.Forms.DockStyle.Top;
            this.label5.Location = new System.Drawing.Point(0, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(176, 23);
            this.label5.TabIndex = 0;
            this.label5.Text = "Menu Group 5";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // UserControl1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Gainsboro;
            this.Controls.Add(this.panel5);
            this.Controls.Add(this.panel4);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Name = "UserControl1";
            this.Size = new System.Drawing.Size(948, 100);
            this.panel1.ResumeLayout(false);
            this.panel2.ResumeLayout(false);
            this.panel3.ResumeLayout(false);
            this.panel4.ResumeLayout(false);
            this.panel5.ResumeLayout(false);
            this.ResumeLayout(false);

        }

    }

//} // line # 611

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


  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $f.Size = New-Object System.Drawing.Size (470,135)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
  $f.StartPosition = 'CenterScreen'
  $r = New-Object -TypeName 'Ribbon.Panel'

  $r.Size = $f.Size

  $u = New-Object System.Windows.Forms.UserControl
  $p1 = New-Object System.Windows.Forms.Panel
  $l1 = New-Object System.Windows.Forms.Label
  $b1 = New-Object System.Windows.Forms.Button
  $b2 = New-Object System.Windows.Forms.Button
  $b3 = New-Object System.Windows.Forms.Button
  $b4 = New-Object System.Windows.Forms.Button
  $p2 = New-Object System.Windows.Forms.Panel
  $b5 = New-Object System.Windows.Forms.Button
  $b6 = New-Object System.Windows.Forms.Button
  $b7 = New-Object System.Windows.Forms.Button
  $b8 = New-Object System.Windows.Forms.Button
  $l2 = New-Object System.Windows.Forms.Label
  $p3 = New-Object System.Windows.Forms.Panel
  $b9 = New-Object System.Windows.Forms.Button
  $b10 = New-Object System.Windows.Forms.Button
  $b11 = New-Object System.Windows.Forms.Button
  $b12 = New-Object System.Windows.Forms.Button
  $l3 = New-Object System.Windows.Forms.Label
  $p4 = New-Object System.Windows.Forms.Panel
  $b13 = New-Object System.Windows.Forms.Button
  $b14 = New-Object System.Windows.Forms.Button
  $b15 = New-Object System.Windows.Forms.Button
  $b16 = New-Object System.Windows.Forms.Button
  $l4 = New-Object System.Windows.Forms.Label
  $p5 = New-Object System.Windows.Forms.Panel
  $b17 = New-Object System.Windows.Forms.Button
  $b18 = New-Object System.Windows.Forms.Button
  $b19 = New-Object System.Windows.Forms.Button
  $b20 = New-Object System.Windows.Forms.Button
  $l5 = New-Object System.Windows.Forms.Label
  $p1.SuspendLayout()
  $p2.SuspendLayout
  $p3.SuspendLayout
  $p4.SuspendLayout
  $p5.SuspendLayout
  $u.SuspendLayout
  #  
  #  panel1
  #  
  $p1.BackColor = [System.Drawing.Color]::Silver
  $p1.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $p1.Controls.Add($b4)
  $p1.Controls.Add($b3)
  $p1.Controls.Add($b2)
  $p1.Controls.Add($b1)
  $p1.Controls.Add($l1)
  $p1.Dock = [System.Windows.Forms.DockStyle]::Left
  $p1.Location = New-Object System.Drawing.Point (0,0)
  $p1.Name = "panel1"
  $p1.Size = New-Object System.Drawing.Size (178,100)
  $p1.TabIndex = 0
  #  
  #  label1
  #  
  $l1.BackColor = [System.Drawing.Color]::DarkGray
  $l1.Dock = [System.Windows.Forms.DockStyle]::Top
  $l1.Location = New-Object System.Drawing.Point (0,0)
  $l1.Name = "label1"
  $l1.Size = New-Object System.Drawing.Size (176,23)
  $l1.TabIndex = 0
  $l1.Text = "Menu Group 1"
  $l1.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  #  
  #  button1
  #  
  $b1.Location = New-Object System.Drawing.Point (6,27)
  $b1.Name = "button1"
  $b1.Size = New-Object System.Drawing.Size (80,30)
  $b1.TabIndex = 1
  $b1.Text = "button1"
  $b1.UseVisualStyleBackColor = $true
  #  
  #  button2
  #  
  $b2.Location = New-Object System.Drawing.Point (6,64)
  $b2.Name = "button2"
  $b2.Size = New-Object System.Drawing.Size (80,30)
  $b2.TabIndex = 2
  $b2.Text = "button2"
  $b2.UseVisualStyleBackColor = $true
  #  
  #  button3
  #  
  $b3.Location = New-Object System.Drawing.Point (92,28)
  $b3.Name = "button3"
  $b3.Size = New-Object System.Drawing.Size (80,30)
  $b3.TabIndex = 3
  $b3.Text = "button3"
  $b3.UseVisualStyleBackColor = $true
  #  
  #  button4
  #  
  $b4.Location = New-Object System.Drawing.Point (92,64)
  $b4.Name = "button4"
  $b4.Size = New-Object System.Drawing.Size (80,30)
  $b4.TabIndex = 4
  $b4.Text = "button4"
  $b4.UseVisualStyleBackColor = $true
  #  
  #  panel2
  #  
  $p2.BackColor = [System.Drawing.Color]::Silver
  $p2.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $p2.Controls.Add($b5)
  $p2.Controls.Add($b6)
  $p2.Controls.Add($b7)
  $p2.Controls.Add($b8)
  $p2.Controls.Add($l2)
  $p2.Dock = [System.Windows.Forms.DockStyle]::Left
  $p2.Location = New-Object System.Drawing.Point (178,0)
  $p2.Name = "panel2"
  $p2.Size = New-Object System.Drawing.Size (178,100)
  $p2.TabIndex = 1
  #  
  #  button5
  #  
  $b5.Location = New-Object System.Drawing.Point (92,64)
  $b5.Name = "button5"
  $b5.Size = New-Object System.Drawing.Size (80,30)
  $b5.TabIndex = 4
  $b5.Text = "button5"
  $b5.UseVisualStyleBackColor = $true
  #  
  #  button6
  #  
  $b6.Location = New-Object System.Drawing.Point (92,28)
  $b6.Name = "button6"
  $b6.Size = New-Object System.Drawing.Size (80,30)
  $b6.TabIndex = 3
  $b6.Text = "button6"
  $b6.UseVisualStyleBackColor = $true
  #  
  #  button7
  #  
  $b7.Location = New-Object System.Drawing.Point (6,64)
  $b7.Name = "button7"
  $b7.Size = New-Object System.Drawing.Size (80,30)
  $b7.TabIndex = 2
  $b7.Text = "button7"
  $b7.UseVisualStyleBackColor = $true
  #  
  #  button8
  #  
  $b8.Location = New-Object System.Drawing.Point (6,27)
  $b8.Name = "button8"
  $b8.Size = New-Object System.Drawing.Size (80,30)
  $b8.TabIndex = 1
  $b8.Text = "button8"
  $b8.UseVisualStyleBackColor = $true
  #  
  #  label2
  #  
  $l2.BackColor = [System.Drawing.Color]::DarkGray
  $l2.Dock = [System.Windows.Forms.DockStyle]::Top
  $l2.Location = New-Object System.Drawing.Point (0,0)
  $l2.Name = "label2"
  $l2.Size = New-Object System.Drawing.Size (176,23)
  $l2.TabIndex = 0
  $l2.Text = "Menu Group 2"
  $l2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  #  
  #  panel3
  #  
  $p3.BackColor = [System.Drawing.Color]::Silver
  $p3.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $p3.Controls.Add($b9)
  $p3.Controls.Add($b10)
  $p3.Controls.Add($b11)
  $p3.Controls.Add($b12)
  $p3.Controls.Add($l3)
  $p3.Dock = [System.Windows.Forms.DockStyle]::Left
  $p3.Location = New-Object System.Drawing.Point (356,0)
  $p3.Name = "panel3"
  $p3.Size = New-Object System.Drawing.Size (178,100)
  $p3.TabIndex = 2
  #  
  #  button9
  #  
  $b9.Location = New-Object System.Drawing.Point (92,64)
  $b9.Name = "button9"
  $b9.Size = New-Object System.Drawing.Size (80,30)
  $b9.TabIndex = 4
  $b9.Text = "button9"
  $b9.UseVisualStyleBackColor = $true
  #  
  #  button10
  #  
  $b10.Location = New-Object System.Drawing.Point (92,28)
  $b10.Name = "button10"
  $b10.Size = New-Object System.Drawing.Size (80,30)
  $b10.TabIndex = 3
  $b10.Text = "button10"
  $b10.UseVisualStyleBackColor = $true
  #  
  #  button11
  #  
  $b11.Location = New-Object System.Drawing.Point (6,64)
  $b11.Name = "button11"
  $b11.Size = New-Object System.Drawing.Size (80,30)
  $b11.TabIndex = 2
  $b11.Text = "button11"
  $b11.UseVisualStyleBackColor = $true
  #  
  #  button12
  #  
  $b12.Location = New-Object System.Drawing.Point (6,27)
  $b12.Name = "button12"
  $b12.Size = New-Object System.Drawing.Size (80,30)
  $b12.TabIndex = 1
  $b12.Text = "button12"
  $b12.UseVisualStyleBackColor = $true
  #  
  #  label3
  #  
  $l3.BackColor = [System.Drawing.Color]::DarkGray
  $l3.Dock = [System.Windows.Forms.DockStyle]::Top
  $l3.Location = New-Object System.Drawing.Point (0,0)
  $l3.Name = "label3"
  $l3.Size = New-Object System.Drawing.Size (176,23)
  $l3.TabIndex = 0
  $l3.Text = "Menu Group 3"
  $l3.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  #  
  #  panel4
  #  
  $p4.BackColor = [System.Drawing.Color]::Silver
  $p4.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $p4.Controls.Add($b13)
  $p4.Controls.Add($b14)
  $p4.Controls.Add($b15)
  $p4.Controls.Add($b16)
  $p4.Controls.Add($l4)
  $p4.Dock = [System.Windows.Forms.DockStyle]::Left
  $p4.Location = New-Object System.Drawing.Point (534,0)
  $p4.Name = "panel4"
  $p4.Size = New-Object System.Drawing.Size (178,100)
  $p4.TabIndex = 3
  #  
  #  button13
  #  
  $b13.Location = New-Object System.Drawing.Point (92,64)
  $b13.Name = "button13"
  $b13.Size = New-Object System.Drawing.Size (80,30)
  $b13.TabIndex = 4
  $b13.Text = "button13"
  $b13.UseVisualStyleBackColor = $true
  #  
  #  button14
  #  
  $b14.Location = New-Object System.Drawing.Point (92,28)
  $b14.Name = "button14"
  $b14.Size = New-Object System.Drawing.Size (80,30)
  $b14.TabIndex = 3
  $b14.Text = "button14"
  $b14.UseVisualStyleBackColor = $true
  #  
  #  button15
  #  
  $b15.Location = New-Object System.Drawing.Point (6,64)
  $b15.Name = "button15"
  $b15.Size = New-Object System.Drawing.Size (80,30)
  $b15.TabIndex = 2
  $b15.Text = "button15"
  $b15.UseVisualStyleBackColor = $true
  #  
  #  button16
  #  
  $b16.Location = New-Object System.Drawing.Point (6,27)
  $b16.Name = "button16"
  $b16.Size = New-Object System.Drawing.Size (80,30)
  $b16.TabIndex = 1
  $b16.Text = "button16"
  $b16.UseVisualStyleBackColor = $true
  #  
  #  label4
  #  
  $l4.BackColor = [System.Drawing.Color]::DarkGray
  $l4.Dock = [System.Windows.Forms.DockStyle]::Top
  $l4.Location = New-Object System.Drawing.Point (0,0)
  $l4.Name = "label4"
  $l4.Size = New-Object System.Drawing.Size (176,23)
  $l4.TabIndex = 0
  $l4.Text = "Menu Group 4"
  $l4.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  #  
  #  panel5
  #  
  $p5.BackColor = [System.Drawing.Color]::Silver
  $p5.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
  $p5.Controls.Add($b17)
  $p5.Controls.Add($b18)
  $p5.Controls.Add($b19)
  $p5.Controls.Add($b20)
  $p5.Controls.Add($l5)
  $p5.Dock = [System.Windows.Forms.DockStyle]::Left
  $p5.Location = New-Object System.Drawing.Point (712,0)
  $p5.Name = "panel5"
  $p5.Size = New-Object System.Drawing.Size (178,100)
  $p5.TabIndex = 4
  #  
  #  button17
  #  
  $b17.Location = New-Object System.Drawing.Point (92,64)
  $b17.Name = "button17"
  $b17.Size = New-Object System.Drawing.Size (80,30)
  $b17.TabIndex = 4
  $b17.Text = "button17"
  $b17.UseVisualStyleBackColor = $true
  #  
  #  button18
  #  
  $b18.Location = New-Object System.Drawing.Point (92,28)
  $b18.Name = "button18"
  $b18.Size = New-Object System.Drawing.Size (80,30)
  $b18.TabIndex = 3
  $b18.Text = "button18"
  $b18.UseVisualStyleBackColor = $true
  #  
  #  button19
  #  
  $b19.Location = New-Object System.Drawing.Point (6,64)
  $b19.Name = "button19"
  $b19.Size = New-Object System.Drawing.Size (80,30)
  $b19.TabIndex = 2
  $b19.Text = "button19"
  $b19.UseVisualStyleBackColor = $true
  #  
  #  button20
  #  
  $b20.Location = New-Object System.Drawing.Point (6,27)
  $b20.Name = "button20"
  $b20.Size = New-Object System.Drawing.Size (80,30)
  $b20.TabIndex = 1
  $b20.Text = "button20"
  $b20.UseVisualStyleBackColor = $true
  #  
  #  label5
  #  
  $l5.BackColor = [System.Drawing.Color]::DarkGray
  $l5.Dock = [System.Windows.Forms.DockStyle]::Top
  $l5.Location = New-Object System.Drawing.Point (0,0)
  $l5.Name = "label5"
  $l5.Size = New-Object System.Drawing.Size (176,23)
  $l5.TabIndex = 0
  $l5.Text = "Menu Group 5"
  $l5.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  #  
  #  UserControl1
  #  
  $u.AutoScaleDimensions = New-Object System.Drawing.SizeF (6,13)
  $u.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $u.BackColor = [System.Drawing.Color]::Gainsboro
  $u.Controls.Add($p5)
  $u.Controls.Add($p4)
  $u.Controls.Add($p3)
  $u.Controls.Add($p2)
  $u.Controls.Add($p1)
  $u.Name = "UserControl1"
  $u.Size = New-Object System.Drawing.Size (948,100)
  $p1.ResumeLayout($false)
  $p2.ResumeLayout($false)
  $p3.ResumeLayout($false)
  $p4.ResumeLayout($false)
  $p5.ResumeLayout($false)
  $u.ResumeLayout($false)
  $bp = $r.panel2

  $bp.BackColor = [System.Drawing.Color]::White
  $bp.Dock = [System.Windows.Forms.DockStyle]::Fill
  $bp.Location = new-object System.Drawing.Point (20,0)
  $bp.Name = "panel2"
  $bp.Size = New-Object System.Drawing.Size (424,100)
  $bp.TabIndex = 2

  $u.Left = $u.Top = 0
  $r.panel2.Controls.Add($u)

  $u.Show()
  $f.Controls.Add($r)
  $r.usrCtrl = $u
  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)


PromptRibbon -Title 'Floating Menu Sample Project' -caller $caller

<#



#>
