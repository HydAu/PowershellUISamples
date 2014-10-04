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



Add-Type -TypeDefinition @"

// http://www.java2s.com/Code/CSharp/Components/UseanAutocompleteComboBox.htm
// shows first match instantly, need to rub to get to the next
using System;
using System.Windows.Forms;
using System.Drawing;

public class AutoCompleteComboBoxTest : System.Windows.Forms.Form {

   public AutoCompleteComboBoxTest(){
        AutoCompleteComboBox combo = new AutoCompleteComboBox();
        combo.Location = new Point(10,10);
        this.Controls.Add(combo);

         // 'Lorem ipsum dolor sit amet, consectetur adipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
        combo.Items.Add("Lorem");
        combo.Items.Add("ipsum");
        combo.Items.Add("dolor");
        combo.Items.Add("sit");
        combo.Items.Add("amet");
        combo.Items.Add("consectetur");
        combo.Items.Add("adipisicing");
        combo.Items.Add("elit");
        combo.Items.Add("sed"); 
        combo.Items.Add("do"); 
        combo.Items.Add("eiusmod"); 
        combo.Items.Add("tempor"); 
        combo.Items.Add("incididunt"); 
        combo.Items.Add("ut"); 
        combo.Items.Add("labore"); 
        combo.Items.Add("et"); 
        combo.Items.Add("dolore"); 
        combo.Items.Add("magna"); 
        combo.Items.Add("aliqua");
   }
   public static void Main(){
       Application.Run(new AutoCompleteComboBoxTest());
   } 
}


public class AutoCompleteComboBox : ComboBox {
    private bool controlKey = false;

    protected override void OnKeyPress( System.Windows.Forms.KeyPressEventArgs e) {
        base.OnKeyPress(e);
        if (e.KeyChar == (int)Keys.Escape) {
            this.SelectedIndex = -1;
            this.Text = "";
            controlKey = true;
        } else if (Char.IsControl(e.KeyChar)) {
            controlKey = true;
        } else {
            controlKey = false;
        }
    }

    protected override void OnTextChanged(System.EventArgs e) {
        base.OnTextChanged(e);
        if (this.Text != "" && !controlKey) {
            string matchText = this.Text;
            int match = this.FindString(matchText);
            if (match != -1) {
                this.SelectedIndex = match;
                this.SelectionStart = matchText.Length;
                this.SelectionLength = this.Text.Length - this.SelectionStart;
            }
        }
    }
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll'


$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$test = New-Object -type 'AutoCompleteComboBoxTest'
[void]$test.ShowDialog([win32window]($caller))
