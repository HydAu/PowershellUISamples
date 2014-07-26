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

# http://www.java2s.com/Code/CSharpAPI/System.Windows.Forms/TabControlControlsAdd.htm
function PromptWithTabs(
	[String] $title, 
        [Object] $caller
	){

        [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
        [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 

        $f = New-Object System.Windows.Forms.Form 
        $f.Text = $title

        $panel2 = new-object System.Windows.Forms.TabPage
        $textbox1 = new-object System.Windows.Forms.TextBox
        $panel1 = new-object System.Windows.Forms.TabPage
        $button1 = new-object System.Windows.Forms.Button
        $tab_contol1 = new-object System.Windows.Forms.TabControl
        $panel2.SuspendLayout()
        $panel1.SuspendLayout()
        $tab_contol1.SuspendLayout()
        $f.SuspendLayout()

        $panel2.Controls.Add($textbox1)
        $panel2.Location = new-object System.Drawing.Point(4, 22)
        $panel2.Name = "tabPage2"
        $panel2.Padding = new-object System.Windows.Forms.Padding(3)
        $panel2.Size = new-object System.Drawing.Size(259, 47)
        $panel2.TabIndex = 1
        $panel2.Text = "Input Tab"

        $textbox1.Location = new-object System.Drawing.Point(72, 7)
        $textbox1.Name = "textBoxMessage"
        $textbox1.Size = new-object System.Drawing.Size(100, 20)
        $textbox1.TabIndex = 0

        $l1 = New-Object System.Windows.Forms.Label
        $l1.Location = New-Object System.Drawing.Size(72,32) 
        $l1.Size = New-Object System.Drawing.Size(100,10) 
        $l1.Text = ''         

        $l1.Font = new-object System.Drawing.Font('Microsoft Sans Serif', 8, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, 0);
        $panel2.Controls.Add($l1) 


        $textbox1.Add_Leave( { 
           param(
            [Object] $sender, 
            [System.EventArgs] $eventargs 
            )
          if ($sender.Text.length -eq 0) {
          $l1.Text = 'Please enter the data first'
         #   [System.Windows.Forms.MessageBox]::Show('Please enter the data first') 
       
          $tab_contol1.SelectedIndex = 1
          $sender.Select()
          $result =  $sender.Focus()
#        $f.ActiveControl = $sender
}
}) 

        $panel1.Controls.Add($button1)
        $panel1.Location = new-object System.Drawing.Point(4, 22)
        $panel1.Name = "tabPage1"
        $panel1.Padding = new-object System.Windows.Forms.Padding(3)
        $panel1.Size = new-object System.Drawing.Size(259, 47)
        $panel1.TabIndex = 0
        $panel1.Text = "Action Tab"



        $button1.Location = new-object System.Drawing.Point(74, 7)
        $button1.Name = "buttonShowMessage"
        $button1.Size = new-object System.Drawing.Size(107, 24)
        $button1.TabIndex = 0
        $button1.Text = "Show Message"
        $button1_Click = {
           param(
            [Object] $sender, 
            [System.EventArgs] $eventargs 
            )
            [System.Windows.Forms.MessageBox]::Show($textbox1.Text);
        }
        $button1.Add_Click($button1_Click)

        $tab_contol1.Controls.Add($panel1)
        $tab_contol1.Controls.Add($panel2)
        $tab_contol1.Location = new-object System.Drawing.Point(13, 13)
        $tab_contol1.Name = "tabControl1"
        $tab_contol1.SelectedIndex = 1
        $textbox1.Select()
        $textbox1.Enabled  = $true
        $tab_contol1.Size = new-object System.Drawing.Size(267, 83)
        $tab_contol1.TabIndex = 0
        
        $f.AutoScaleBaseSize = new-object System.Drawing.Size(5, 13)
        $f.ClientSize = new-object System.Drawing.Size(292, 103)
        $f.Controls.Add($tab_contol1)
        $panel2.ResumeLayout($false)
        $panel2.PerformLayout()
        $panel1.ResumeLayout($false)
        $tab_contol1.ResumeLayout($false)
        $f.ResumeLayout($false)
        # $textbox1.Focus()
        $f.ActiveControl = $textbox1

        $f.Topmost = $true


        $f.Add_Shown( { $f.Activate() } )
        $f.KeyPreview = $True


        [Void] $f.ShowDialog([Win32Window ] ($caller) )

        $f.Dispose() 
}

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _txtUser;
    private string _txtPassword;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }


    public string TxtUser
    {
        get { return _txtUser; }
        set { _txtUser = value; }
    }
    public string TxtPassword
    {
        get { return _txtPassword; }
        set { _txtPassword = value; }
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
$title = 'Enter credentials' 
$user =  'admin'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptWithTabs -title $title -user $user -caller $caller
if ($caller.Data -ne $RESULT_CANCEL) {
write-debug ("Result is : {0} / {1}  " -f  $caller.TxtUser , $caller.TxtPassword )
}
