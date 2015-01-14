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
  [switch]$debug
)
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}

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


# http://www.codeproject.com/Tips/834853/How-to-create-an-Expandable-Collapsible-Panel

Add-Type -TypeDefinition @"

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ExpandablePanelSample
{

    public class frmMain : System.Windows.Forms.Panel
    {

        public frmMain()
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
            this.pnlMenu = new System.Windows.Forms.Panel();
            this.pnlMenuGroup3 = new System.Windows.Forms.Panel();
            this.button8 = new System.Windows.Forms.Button();
            this.button9 = new System.Windows.Forms.Button();
            this.button10 = new System.Windows.Forms.Button();
            this.btnMenuGroup3 = new System.Windows.Forms.Button();
            this.pnlMenuGroup2 = new System.Windows.Forms.Panel();
            this.button4 = new System.Windows.Forms.Button();
            this.button5 = new System.Windows.Forms.Button();
            this.button6 = new System.Windows.Forms.Button();
            this.btnMenuGroup2 = new System.Windows.Forms.Button();
            this.pnlMenuGroup1 = new System.Windows.Forms.Panel();
            this.button3 = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.btnMenuGroup1 = new System.Windows.Forms.Button();
            this.lblMenu = new System.Windows.Forms.Label();
            this.pnlMenu.SuspendLayout();
            this.pnlMenuGroup3.SuspendLayout();
            this.pnlMenuGroup2.SuspendLayout();
            this.pnlMenuGroup1.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlMenu
            // 
            this.pnlMenu.Controls.Add(this.pnlMenuGroup3);
            this.pnlMenu.Controls.Add(this.pnlMenuGroup2);
            this.pnlMenu.Controls.Add(this.pnlMenuGroup1);
            this.pnlMenu.Controls.Add(this.lblMenu);
            this.pnlMenu.Dock = System.Windows.Forms.DockStyle.Left;
            this.pnlMenu.Location = new System.Drawing.Point(0, 0);
            this.pnlMenu.Name = "pnlMenu";
            this.pnlMenu.Size = new System.Drawing.Size(200, 449);
            this.pnlMenu.TabIndex = 1;
            // 
            // pnlMenuGroup3
            // 
            this.pnlMenuGroup3.Controls.Add(this.button8);
            this.pnlMenuGroup3.Controls.Add(this.button9);
            this.pnlMenuGroup3.Controls.Add(this.button10);
            this.pnlMenuGroup3.Controls.Add(this.btnMenuGroup3);
            this.pnlMenuGroup3.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlMenuGroup3.Location = new System.Drawing.Point(0, 231);
            this.pnlMenuGroup3.Name = "pnlMenuGroup3";
            this.pnlMenuGroup3.Size = new System.Drawing.Size(200, 109);
            this.pnlMenuGroup3.TabIndex = 3;
            // 
            // button8
            // 
            this.button8.BackColor = System.Drawing.Color.Silver;
            this.button8.Dock = System.Windows.Forms.DockStyle.Top;
            this.button8.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button8.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button8.Location = new System.Drawing.Point(0, 75);
            this.button8.Name = "button8";
            this.button8.Size = new System.Drawing.Size(200, 25);
            this.button8.TabIndex = 3;
            this.button8.Text = "Sub Menu 3";
            this.button8.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button8.UseVisualStyleBackColor = false;
            // 
            // button9
            // 
            this.button9.BackColor = System.Drawing.Color.Silver;
            this.button9.Dock = System.Windows.Forms.DockStyle.Top;
            this.button9.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button9.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button9.Location = new System.Drawing.Point(0, 50);
            this.button9.Name = "button9";
            this.button9.Size = new System.Drawing.Size(200, 25);
            this.button9.TabIndex = 2;
            this.button9.Text = "Sub Menu 2";
            this.button9.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button9.UseVisualStyleBackColor = false;
            // 
            // button10
            // 
            this.button10.BackColor = System.Drawing.Color.Silver;
            this.button10.Dock = System.Windows.Forms.DockStyle.Top;
            this.button10.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button10.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button10.Location = new System.Drawing.Point(0, 25);
            this.button10.Name = "button10";
            this.button10.Size = new System.Drawing.Size(200, 25);
            this.button10.TabIndex = 1;
            this.button10.Text = "Sub Menu 1";
            this.button10.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button10.UseVisualStyleBackColor = false;
            // 
            // btnMenuGroup3
            // 
            this.btnMenuGroup3.BackColor = System.Drawing.Color.Gray;
            this.btnMenuGroup3.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnMenuGroup3.FlatAppearance.BorderColor = System.Drawing.Color.Gray;
            this.btnMenuGroup3.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMenuGroup3.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnMenuGroup3.Location = new System.Drawing.Point(0, 0);
            this.btnMenuGroup3.Name = "btnMenuGroup3";
            this.btnMenuGroup3.Size = new System.Drawing.Size(200, 25);
            this.btnMenuGroup3.TabIndex = 0;
            this.btnMenuGroup3.Text = "Menu Group 3";
            this.btnMenuGroup3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnMenuGroup3.UseVisualStyleBackColor = false;
            this.btnMenuGroup3.Click += new System.EventHandler(this.btnMenuGroup3_Click);
            // 
            // pnlMenuGroup2
            // 
            this.pnlMenuGroup2.Controls.Add(this.button4);
            this.pnlMenuGroup2.Controls.Add(this.button5);
            this.pnlMenuGroup2.Controls.Add(this.button6);
            this.pnlMenuGroup2.Controls.Add(this.btnMenuGroup2);
            this.pnlMenuGroup2.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlMenuGroup2.Location = new System.Drawing.Point(0, 127);
            this.pnlMenuGroup2.Name = "pnlMenuGroup2";
            this.pnlMenuGroup2.Size = new System.Drawing.Size(200, 104);
            this.pnlMenuGroup2.TabIndex = 2;
            // 
            // button4
            // 
            this.button4.BackColor = System.Drawing.Color.Silver;
            this.button4.Dock = System.Windows.Forms.DockStyle.Top;
            this.button4.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button4.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button4.Location = new System.Drawing.Point(0, 75);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(200, 25);
            this.button4.TabIndex = 3;
            this.button4.Text = "Sub Menu 3";
            this.button4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button4.UseVisualStyleBackColor = false;
            // 
            // button5
            // 
            this.button5.BackColor = System.Drawing.Color.Silver;
            this.button5.Dock = System.Windows.Forms.DockStyle.Top;
            this.button5.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button5.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button5.Location = new System.Drawing.Point(0, 50);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(200, 25);
            this.button5.TabIndex = 2;
            this.button5.Text = "Sub Menu 2";
            this.button5.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button5.UseVisualStyleBackColor = false;
            // 
            // button6
            // 
            this.button6.BackColor = System.Drawing.Color.Silver;
            this.button6.Dock = System.Windows.Forms.DockStyle.Top;
            this.button6.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button6.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button6.Location = new System.Drawing.Point(0, 25);
            this.button6.Name = "button6";
            this.button6.Size = new System.Drawing.Size(200, 25);
            this.button6.TabIndex = 1;
            this.button6.Text = "Sub Menu 1";
            this.button6.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button6.UseVisualStyleBackColor = false;
            // 
            // btnMenuGroup2
            // 
            this.btnMenuGroup2.BackColor = System.Drawing.Color.Gray;
            this.btnMenuGroup2.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnMenuGroup2.FlatAppearance.BorderColor = System.Drawing.Color.Gray;
            this.btnMenuGroup2.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMenuGroup2.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnMenuGroup2.Location = new System.Drawing.Point(0, 0);
            this.btnMenuGroup2.Name = "btnMenuGroup2";
            this.btnMenuGroup2.Size = new System.Drawing.Size(200, 25);
            this.btnMenuGroup2.TabIndex = 0;
            this.btnMenuGroup2.Text = "Menu Group 2";
            this.btnMenuGroup2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnMenuGroup2.UseVisualStyleBackColor = false;
            this.btnMenuGroup2.Click += new System.EventHandler(this.btnMenuGroup2_Click);
            // 
            // pnlMenuGroup1
            // 
            this.pnlMenuGroup1.Controls.Add(this.button3);
            this.pnlMenuGroup1.Controls.Add(this.button2);
            this.pnlMenuGroup1.Controls.Add(this.btnMenuGroup1);
            this.pnlMenuGroup1.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlMenuGroup1.Location = new System.Drawing.Point(0, 23);
            this.pnlMenuGroup1.Name = "pnlMenuGroup1";
            this.pnlMenuGroup1.Size = new System.Drawing.Size(200, 104);
            this.pnlMenuGroup1.TabIndex = 1;
            // 
            // button3
            // 
            this.button3.BackColor = System.Drawing.Color.Silver;
            this.button3.Dock = System.Windows.Forms.DockStyle.Top;
            this.button3.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button3.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button3.Location = new System.Drawing.Point(0, 75);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(200, 25);
            this.button3.TabIndex = 3;
            this.button3.Text = "Sub Menu 3";
            this.button3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button3.UseVisualStyleBackColor = false;
            // 
            // button2
            // 
            this.button2.BackColor = System.Drawing.Color.Silver;
            this.button2.Dock = System.Windows.Forms.DockStyle.Top;
            this.button2.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.button2.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.button2.Location = new System.Drawing.Point(0, 50);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(200, 25);
            this.button2.TabIndex = 2;
            this.button2.Text = "Sub Menu 2";
            this.button2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.button2.UseVisualStyleBackColor = false;
            // 
            // btnMenuGroup1
            // 
            this.btnMenuGroup1.BackColor = System.Drawing.Color.Gray;
            this.btnMenuGroup1.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnMenuGroup1.FlatAppearance.BorderColor = System.Drawing.Color.Gray;
            this.btnMenuGroup1.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMenuGroup1.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnMenuGroup1.Location = new System.Drawing.Point(0, 0);
            this.btnMenuGroup1.Name = "btnMenuGroup1";
            this.btnMenuGroup1.Size = new System.Drawing.Size(200, 25);
            this.btnMenuGroup1.TabIndex = 0;
            this.btnMenuGroup1.Text = "Menu Group 1";
            this.btnMenuGroup1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnMenuGroup1.UseVisualStyleBackColor = false;
            this.btnMenuGroup1.Click += new System.EventHandler(this.btnMenuGroup1_Click);
            // 
            // lblMenu
            // 
            this.lblMenu.BackColor = System.Drawing.Color.DarkGray;
            this.lblMenu.Dock = System.Windows.Forms.DockStyle.Top;
            this.lblMenu.ForeColor = System.Drawing.Color.White;
            this.lblMenu.Location = new System.Drawing.Point(0, 0);
            this.lblMenu.Name = "lblMenu";
            this.lblMenu.Size = new System.Drawing.Size(200, 23);
            this.lblMenu.TabIndex = 0;
            this.lblMenu.Text = "Main Menu";
            this.lblMenu.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;


            this.ClientSize = new System.Drawing.Size(200, 449);
            this.Controls.Add(this.pnlMenu);
            pnlMenuGroup1.Height = 25;
            pnlMenuGroup2.Height = 25;
            pnlMenuGroup3.Height = 25;

            btnMenuGroup1.Image =
            btnMenuGroup2.Image =
            btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");

            this.pnlMenu.ResumeLayout(false);
            this.pnlMenuGroup3.ResumeLayout(false);
            this.pnlMenuGroup2.ResumeLayout(false);
            this.pnlMenuGroup1.ResumeLayout(false);
            this.ResumeLayout(false);

        }


        private System.Windows.Forms.Panel pnlMenu;
        private System.Windows.Forms.Panel pnlMenuGroup1;
        private System.Windows.Forms.Button btnMenuGroup1;
        private System.Windows.Forms.Label lblMenu;
        private System.Windows.Forms.Panel pnlMenuGroup3;
        private System.Windows.Forms.Button button8;
        private System.Windows.Forms.Button button9;
        private System.Windows.Forms.Button button10;
        private System.Windows.Forms.Button btnMenuGroup3;
        private System.Windows.Forms.Panel pnlMenuGroup2;
        private System.Windows.Forms.Button button4;
        private System.Windows.Forms.Button button5;
        private System.Windows.Forms.Button button6;
        private System.Windows.Forms.Button btnMenuGroup2;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.Button button2;

        private void frmMain_Load(object sender, EventArgs e)
        {
            this.Width = Screen.PrimaryScreen.WorkingArea.Width;
            this.Height = Screen.PrimaryScreen.WorkingArea.Height;
            Left = Top = 0;

            pnlMenuGroup1.Height = 25;
            pnlMenuGroup2.Height = 25;
            pnlMenuGroup3.Height = 25;

            btnMenuGroup1.Image =
            btnMenuGroup2.Image =
            btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
        }

        private void btnMenuGroup1_Click(object sender, EventArgs e)
        {
            if (pnlMenuGroup1.Height == 25)
            {
                pnlMenuGroup1.Height = (25 * 4) + 2;
                btnMenuGroup1.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\up.png");
            }
            else
            {
                pnlMenuGroup1.Height = 25;
                btnMenuGroup1.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
            }
        }

        private void btnMenuGroup2_Click(object sender, EventArgs e)
        {
            if (pnlMenuGroup2.Height == 25)
            {
                pnlMenuGroup2.Height = (25 * 4) + 2;
                btnMenuGroup2.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\up.png");
            }
            else
            {
                pnlMenuGroup2.Height = 25;
                btnMenuGroup2.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
            }
        }

        private void btnMenuGroup3_Click(object sender, EventArgs e)
        {
            if (pnlMenuGroup3.Height == 25)
            {
                pnlMenuGroup3.Height = (25 * 4) + 2;
                btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\up.png");
            }
            else
            {
                pnlMenuGroup3.Height = 25;
                btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
            }
        }

    }
}
//
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Xml.Linq','System.Xml','System.Data'



# [void]$test.ShowDialog([win32window ]($caller))

function PromptExpandable {
  param
  (
    [string]$title,
    [object]$caller
  )

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')


  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $f.ClientSize = New-Object System.Drawing.Size (288,248)
  $panel = New-Object -TypeName 'ExpandablePanelSample.frmMain'
  $f.Controls.AddRange(@( $panel))
  $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
  $f.MaximizeBox = $false
  $panel.ResumeLayout($false)
  $f.ResumeLayout($false)

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))

}

# $test = New-Object -TypeName 'ExpandablePanelSample.frmMain' 
$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptExpandable -caller $caller -Title 'Expandable Panel Sample'

<#

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

$p = New-Object System.Windows.Forms.Panel
$pnlMenu = New-Object System.Windows.Forms.Panel
$pnlMenuGroup3 = New-Object System.Windows.Forms.Panel
$button8 = New-Object System.Windows.Forms.Button
$button9 = New-Object System.Windows.Forms.Button
$button10 = New-Object System.Windows.Forms.Button
$btnMenuGroup3 = New-Object System.Windows.Forms.Button
$pnlMenuGroup2 = New-Object System.Windows.Forms.Panel
$button4 = New-Object System.Windows.Forms.Button
$button5 = New-Object System.Windows.Forms.Button
$button6 = New-Object System.Windows.Forms.Button
$btnMenuGroup2 = New-Object System.Windows.Forms.Button
$pnlMenuGroup1 = New-Object System.Windows.Forms.Panel
$button3 = New-Object System.Windows.Forms.Button
$button2 = New-Object System.Windows.Forms.Button
$btnMenuGroup1 = New-Object System.Windows.Forms.Button
$lblMenu = New-Object System.Windows.Forms.Label
$pnlMenu.SuspendLayout()
$pnlMenuGroup3.SuspendLayout()
$pnlMenuGroup2.SuspendLayout()
$pnlMenuGroup1.SuspendLayout()
$p.SuspendLayout()
#  
#  pnlMenu
#  
$pnlMenu.Controls.Add($pnlMenuGroup3)
$pnlMenu.Controls.Add($pnlMenuGroup2)
$pnlMenu.Controls.Add($pnlMenuGroup1)
$pnlMenu.Controls.Add($lblMenu)
$pnlMenu.Dock = [System.Windows.Forms.DockStyle]::Left
$pnlMenu.Location = New-Object System.Drawing.Point (0,0)
$pnlMenu.Name = "pnlMenu"
$pnlMenu.Size = New-Object System.Drawing.Size (200,449)
$pnlMenu.TabIndex = 1
#  
#  pnlMenuGroup3
#  
$pnlMenuGroup3.Controls.Add($button8)
$pnlMenuGroup3.Controls.Add($button9)
$pnlMenuGroup3.Controls.Add($button10)
$pnlMenuGroup3.Controls.Add($btnMenuGroup3)
$pnlMenuGroup3.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlMenuGroup3.Location = New-Object System.Drawing.Point (0,231)
$pnlMenuGroup3.Name = "pnlMenuGroup3"
$pnlMenuGroup3.Size = New-Object System.Drawing.Size (200,109)
$pnlMenuGroup3.TabIndex = 3
#  
#  button8
#  
$button8.BackColor = [System.Drawing.Color]::Silver
$button8.Dock = [System.Windows.Forms.DockStyle]::Top
$button8.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button8.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button8.Location = New-Object System.Drawing.Point (0,75)
$button8.Name = "button8"
$button8.Size = New-Object System.Drawing.Size (200,25)
$button8.TabIndex = 3
$button8.Text = "Sub Menu 3"
$button8.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button8.UseVisualStyleBackColor = $false
#  
#  button9
#  
$button9.BackColor = [System.Drawing.Color]::Silver
$button9.Dock = [System.Windows.Forms.DockStyle]::Top
$button9.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button9.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button9.Location = New-Object System.Drawing.Point (0,50)
$button9.Name = "button9"
$button9.Size = New-Object System.Drawing.Size (200,25)
$button9.TabIndex = 2
$button9.Text = "Sub Menu 2"
$button9.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button9.UseVisualStyleBackColor = $false
#  
#  button10
#  
$button10.BackColor = [System.Drawing.Color]::Silver
$button10.Dock = [System.Windows.Forms.DockStyle]::Top
$button10.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button10.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button10.Location = New-Object System.Drawing.Point (0,25)
$button10.Name = "button10"
$button10.Size = New-Object System.Drawing.Size (200,25)
$button10.TabIndex = 1
$button10.Text = "Sub Menu 1"
$button10.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button10.UseVisualStyleBackColor = $false
#  
#  btnMenuGroup3
#  
$btnMenuGroup3.BackColor = [System.Drawing.Color]::Gray
$btnMenuGroup3.Dock = [System.Windows.Forms.DockStyle]::Top
$btnMenuGroup3.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$btnMenuGroup3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnMenuGroup3.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$btnMenuGroup3.Location = New-Object System.Drawing.Point (0,0)
$btnMenuGroup3.Name = "btnMenuGroup3"
$btnMenuGroup3.Size = New-Object System.Drawing.Size (200,25)
$btnMenuGroup3.TabIndex = 0
$btnMenuGroup3.Text = "Menu Group 3"
$btnMenuGroup3.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$btnMenuGroup3.UseVisualStyleBackColor = $false
# $btnMenuGroup3.Click += new-Object  System.EventHandler($btnMenuGroup3_Click)
#  
#  pnlMenuGroup2
#  
$pnlMenuGroup2.Controls.Add($button4)
$pnlMenuGroup2.Controls.Add($button5)
$pnlMenuGroup2.Controls.Add($button6)
$pnlMenuGroup2.Controls.Add($btnMenuGroup2)
$pnlMenuGroup2.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlMenuGroup2.Location = New-Object System.Drawing.Point (0,127)
$pnlMenuGroup2.Name = "pnlMenuGroup2"
$pnlMenuGroup2.Size = New-Object System.Drawing.Size (200,104)
$pnlMenuGroup2.TabIndex = 2
#  
#  button4
#  
$button4.BackColor = [System.Drawing.Color]::Silver
$button4.Dock = [System.Windows.Forms.DockStyle]::Top
$button4.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button4.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button4.Location = New-Object System.Drawing.Point (0,75)
$button4.Name = "button4"
$button4.Size = New-Object System.Drawing.Size (200,25)
$button4.TabIndex = 3
$button4.Text = "Sub Menu 3"
$button4.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button4.UseVisualStyleBackColor = $false
#  
#  button5
#  
$button5.BackColor = [System.Drawing.Color]::Silver
$button5.Dock = [System.Windows.Forms.DockStyle]::Top
$button5.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button5.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button5.Location = New-Object System.Drawing.Point (0,50)
$button5.Name = "button5"
$button5.Size = New-Object System.Drawing.Size (200,25)
$button5.TabIndex = 2
$button5.Text = "Sub Menu 2"
$button5.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button5.UseVisualStyleBackColor = $false
#  
#  button6
#  
$button6.BackColor = [System.Drawing.Color]::Silver
$button6.Dock = [System.Windows.Forms.DockStyle]::Top
$button6.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button6.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button6.Location = New-Object System.Drawing.Point (0,25)
$button6.Name = "button6"
$button6.Size = New-Object System.Drawing.Size (200,25)
$button6.TabIndex = 1
$button6.Text = "Sub Menu 1"
$button6.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button6.UseVisualStyleBackColor = $false
#  
#  btnMenuGroup2
#  
$btnMenuGroup2.BackColor = [System.Drawing.Color]::Gray
$btnMenuGroup2.Dock = [System.Windows.Forms.DockStyle]::Top
$btnMenuGroup2.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$btnMenuGroup2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnMenuGroup2.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$btnMenuGroup2.Location = New-Object System.Drawing.Point (0,0)
$btnMenuGroup2.Name = "btnMenuGroup2"
$btnMenuGroup2.Size = New-Object System.Drawing.Size (200,25)
$btnMenuGroup2.TabIndex = 0
$btnMenuGroup2.Text = "Menu Group 2"
$btnMenuGroup2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$btnMenuGroup2.UseVisualStyleBackColor = $false
# $btnMenuGroup2.Click += new-Object  System.EventHandler($btnMenuGroup2_Click)
#  
#  pnlMenuGroup1
#  
$pnlMenuGroup1.Controls.Add($button3)
$pnlMenuGroup1.Controls.Add($button2)
$pnlMenuGroup1.Controls.Add($btnMenuGroup1)
$pnlMenuGroup1.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlMenuGroup1.Location = New-Object System.Drawing.Point (0,23)
$pnlMenuGroup1.Name = "pnlMenuGroup1"
$pnlMenuGroup1.Size = New-Object System.Drawing.Size (200,104)
$pnlMenuGroup1.TabIndex = 1
#  
#  button3
#  
$button3.BackColor = [System.Drawing.Color]::Silver
$button3.Dock = [System.Windows.Forms.DockStyle]::Top
$button3.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button3.Location = New-Object System.Drawing.Point (0,75)
$button3.Name = "button3"
$button3.Size = New-Object System.Drawing.Size (200,25)
$button3.TabIndex = 3
$button3.Text = "Sub Menu 3"
$button3.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button3.UseVisualStyleBackColor = $false
#  
#  button2
#  
$button2.BackColor = [System.Drawing.Color]::Silver
$button2.Dock = [System.Windows.Forms.DockStyle]::Top
$button2.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$button2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button2.Location = New-Object System.Drawing.Point (0,50)
$button2.Name = "button2"
$button2.Size = New-Object System.Drawing.Size (200,25)
$button2.TabIndex = 2
$button2.Text = "Sub Menu 2"
$button2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$button2.UseVisualStyleBackColor = $false
#  
#  btnMenuGroup1
#  
$btnMenuGroup1.BackColor = [System.Drawing.Color]::Gray
$btnMenuGroup1.Dock = [System.Windows.Forms.DockStyle]::Top
$btnMenuGroup1.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$btnMenuGroup1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnMenuGroup1.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$btnMenuGroup1.Location = New-Object System.Drawing.Point (0,0)
$btnMenuGroup1.Name = "btnMenuGroup1"
$btnMenuGroup1.Size = New-Object System.Drawing.Size (200,25)
$btnMenuGroup1.TabIndex = 0
$btnMenuGroup1.Text = "Menu Group 1"
$btnMenuGroup1.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$btnMenuGroup1.UseVisualStyleBackColor = $false
# $btnMenuGroup1.Click += new-Object  System.EventHandler($btnMenuGroup1_Click)
#  
#  lblMenu
#  
$lblMenu.BackColor = [System.Drawing.Color]::DarkGray
$lblMenu.Dock = [System.Windows.Forms.DockStyle]::Top
$lblMenu.ForeColor = [System.Drawing.Color]::White
$lblMenu.Location = New-Object System.Drawing.Point (0,0)
$lblMenu.Name = "lblMenu"
$lblMenu.Size = New-Object System.Drawing.Size (200,23)
$lblMenu.TabIndex = 0
$lblMenu.Text = "Main Menu"
$lblMenu.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter


$p.ClientSize = New-Object System.Drawing.Size (200,449)
$p.Controls.Add($pnlMenu)
$pnlMenuGroup1.Height = 25
$pnlMenuGroup2.Height = 25
$pnlMenuGroup3.Height = 25

$btnMenuGroup1.Image =
$btnMenuGroup2.Image =
$btnMenuGroup3.Image = New-Object Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\down.png")

$pnlMenu.ResumeLayout($false)
$pnlMenuGroup3.ResumeLayout($false)
$pnlMenuGroup2.ResumeLayout($false)
$pnlMenuGroup1.ResumeLayout($false)
$p.ResumeLayout($false)



#>
