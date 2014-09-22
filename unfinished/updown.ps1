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


# http://www.java2s.com/Tutorial/CSharp/0460__GUI-Windows-Forms/DomainUpDownselecteditemchangedevent.htmhttp://www.java2s.com/Tutorial/CSharp/0460__GUI-Windows-Forms/DomainUpDownselecteditemchangedevent.htm
Add-Type -TypeDefinition @"

//  "

using System;
using System.Drawing;
using System.Windows.Forms;

public class NumericUpDowns : Form
{
  NumericUpDown nupdwnH;
  TimePicker nupdwnM;
  public NumericUpDowns()
  {
    Size = new Size(480,580);
    nupdwnH = new NumericUpDown();
    nupdwnH.Parent = this;
    nupdwnH.Location = new Point(90, 50);
    nupdwnH.Size = new Size(50,20);
    nupdwnH.Value = 1;
    nupdwnH.Minimum = 0;
    nupdwnH.Maximum = 1000;
    nupdwnH.Increment = 1;    //  decimal
    nupdwnH.DecimalPlaces = 0;
    nupdwnH.ReadOnly = false;
    nupdwnH.TextAlign = HorizontalAlignment.Right;
    nupdwnH.ValueChanged += new EventHandler(nupdwnH_OnValueChanged);

    nupdwnM = new TimePicker();
    nupdwnM.Parent = this;
    nupdwnM.Location = new Point(30, 50);
    nupdwnM.Size = new Size(70,20);
    nupdwnM.TextAlign = HorizontalAlignment.Right;
    nupdwnM.ReadOnly = true;
    nupdwnM.TextChanged += new EventHandler(nupdwnM_OnTextChanged);
    nupdwnM.LostFocus += new EventHandler(nupdwnM_OnTextChanged);

  }  

  private void nupdwnH_OnValueChanged(object sender, EventArgs e)
  {
    Console.WriteLine(nupdwnH.Value);
  }

  private void nupdwnM_OnTextChanged(object sender, EventArgs e)
  {
    Console.WriteLine(nupdwnM.SelectedItem.ToString());
  }
 
 public static void Main() 
  {
    Application.Run(new NumericUpDowns());
  }

}

//  http://stackoverflow.com/questions/16789399/looking-for-time-picker-control-with-half-hourly-up-down
class TimePicker : System.Windows.Forms.DomainUpDown
{
    public TimePicker()
    {         
        // build the list of times, in reverse order because the up/down buttons go the other way
        for (double time = 23.5; time >= 0; time -= 0.5)
        {
            int hour = (int)time; // cast to an int, we only get the whole number which is what we want
            int minutes = (int)((time - hour) * 60); // subtract the hour from the time variable to get the remainder of the hour, then multiply by 60 as .5 * 60 = 30 and 0 * 60 = 0

            this.Items.Add(hour.ToString("00") + ":" + minutes.ToString("00")); // format the hour and minutes to always have two digits and concatenate them together with the colon between them, then add to the Items collection
        }

        this.SelectedIndex = Items.IndexOf("09:00"); // select a default time

        this.Wrap = true; // this enables the picker to go to the first or last item if it is at the end of the list (i.e. if the user gets to 23:30 it wraps back around to 00:00 and vice versa)
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll'

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
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)


$test = new-Object -TypeName 'NumericUpDowns'
[void]$test.ShowDialog([win32window ]($caller))
