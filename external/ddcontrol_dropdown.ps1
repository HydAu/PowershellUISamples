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

<#
DDControl.Designer.cs
DDControl.cs
#>
# $DebugPreference = 'Continue'

param(
  [switch]$pause
)

#  http://www.codeproject.com/Tips/590903/How-to-Create-a-Dropdown-Button-Control
#
Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Drawing.Drawing2D;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace Dropdown_Button
{

    public delegate void ItemClickedDelegate(object sender, ToolStripItemClickedEventArgs e);

    public class DDControl : UserControl
    {

        private string imgFolderPath = Directory.GetCurrentDirectory();

        public string ImgFolderPath
        {
            get { return imgFolderPath; }
            set { imgFolderPath = value; }
        }
        public event ItemClickedDelegate ItemClickedEvent;

        public List<string> LstOfValues = new List<string>();
        public DDControl()
        {
            InitializeComponent();
        }

        public void FillControlList(List<string> lst)
        {
            LstOfValues = lst;
            SetMyButtonProperties();
        }

        private void ShowDropDown()
        {
            ContextMenuStrip contextMenuStrip = new ContextMenuStrip();
            for (int i = 0; i <= LstOfValues.Count - 1; i++)
            {
                //add the item
                contextMenuStrip.Items.Add(LstOfValues[i]);
                //add the image
                string imgPath = Path.Combine(imgFolderPath, @"icon" + i + ".bmp");
                if (File.Exists(imgPath))
                {
                    // Console.Error.WriteLine(String.Format("{0} {1} {2}", i, LstOfValues[i], imgPath));
                    contextMenuStrip.Items[i].Image = Image.FromFile(imgPath);
                }
                else
                {
                    // item will be added w/o image when out of images
                }
            }
            //adding ItemClicked event to contextMenuStrip
            contextMenuStrip.ItemClicked += contextMenuStrip_ItemClicked;
            //show menu strip control
            contextMenuStrip.Show(btnDropDown, new Point(0, btnDropDown.Height));
        }

        private void SetMyButtonProperties()
        {
            btnDropDown.Image = Image.FromFile(Path.Combine(imgFolderPath, @"arrow.png"));
            // Align the image right of the button
            btnDropDown.ImageAlign = ContentAlignment.MiddleRight;
            //Align the text left of the button.
            btnDropDown.TextAlign = ContentAlignment.MiddleLeft;
        }


        private void btnDropDown_Click(object sender, EventArgs e)
        {
            try
            {
                ShowDropDown();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }

        void contextMenuStrip_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            try
            {
                ToolStripItem item = e.ClickedItem;
                //set the text of the button
                btnDropDown.Text = item.Text;
                if (ItemClickedEvent != null)
                {
                    ItemClickedEvent(sender, e);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
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
            this.btnDropDown = new System.Windows.Forms.Button();
            this.SuspendLayout();
            //
            // btnDropDown
            //
            this.btnDropDown.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
            | System.Windows.Forms.AnchorStyles.Left)
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnDropDown.Location = new System.Drawing.Point(3, 0);
            this.btnDropDown.Name = "btnDropDown";
            this.btnDropDown.Size = new System.Drawing.Size(116, 23);
            this.btnDropDown.TabIndex = 0;
            this.btnDropDown.UseVisualStyleBackColor = true;
            this.btnDropDown.Click += new System.EventHandler(this.btnDropDown_Click);
            //
            // DDControl
            //
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnDropDown);
            this.Name = "DDControl";
            this.Size = new System.Drawing.Size(122, 24);
            this.ResumeLayout(false);
        }

        private System.Windows.Forms.Button btnDropDown;

    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'


# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"))
  }
}

@( 'System.Drawing','System.Windows.Forms', 'System.Windows.Forms.VisualStyles') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
$result = ''

$f = New-Object System.Windows.Forms.Form
$l1 = New-Object System.Windows.Forms.Label

$l = New-Object System.Windows.Forms.Label
$o = New-Object -TypeName 'Dropdown_Button.dDControl'
$o.ImgFolderPath = (Get-ScriptDirectory)
$o.FillControlList([System.Collections.Generic.List[string]]@( 'option 1      ','option 2      ','option 3      ','option 4      '))

$f.SuspendLayout()

# label1
$l.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$l.Location = New-Object System.Drawing.Point (12,39)
$l.Name = "label1"
$l.Size = New-Object System.Drawing.Size (237,53)
$l.TabIndex = 4

# dDControl
$o.Location = New-Object System.Drawing.Point (12,12)
$o.Name = "dDControl"
$o.Size = New-Object System.Drawing.Size (237,24)
$o.TabIndex = 1

# Form
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (263,109)
$f.Controls.Add($o)

# $f.Controls.AddRange(@($l,$o))
$f.Name = "DemoForm"
$f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$f.Text = "DropDown Button Demo"
$f.ResumeLayout($false)
# TODO: merge with http://www.codeproject.com/Articles/4479/A-Simple-Bitmap-Button-Implementation
# http://www.alkanesolutions.co.uk/2013/04/19/embedding-base64-image-strings-inside-a-powershell-application/
$f.Add_Shown({ $f.Activate() })
[void]$f.ShowDialog()
$o.Text
Write-Debug $result
