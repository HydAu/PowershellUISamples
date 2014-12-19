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
# with sizes adjusted to run the focus demo

Add-Type -TypeDefinition @"

// "
using System;
using System.Text;
using System.Net;
using System.Windows.Forms;

using System.Runtime.InteropServices;

public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _cookies;
    private string _url;

    public string Cookies
    {
        get { return _cookies; }
        set { _cookies = value; }
    }

    public string Url
    {
        get { return _url; }
        set { _url = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }

    [DllImport("wininet.dll", SetLastError = true)]
    public static extern bool InternetGetCookieEx(
        string url,
        string cookieName,
        StringBuilder cookieData,
        ref int size,
        Int32 dwFlags,
        IntPtr lpReserved);

    private const int INTERNET_COOKIE_HTTPONLY = 0x00002000;
    private const int INTERNET_OPTION_END_BROWSER_SESSION = 42;

    public string GetGlobalCookies(string uri)
    {
        int datasize = 1024;
        StringBuilder cookieData = new StringBuilder((int)datasize);
        if (InternetGetCookieEx(uri, null, cookieData, ref datasize, INTERNET_COOKIE_HTTPONLY, IntPtr.Zero)
            && cookieData.Length > 0)
        {
            return cookieData.ToString().Replace(';', ',');
        }
        else
        {
            return null;
        }
    }


}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll'


function promptForContinueWithCookies (
  [string]$login_url = $null,
  [object]$caller = $null
)
{
  @( 'System.Drawing','System.Collections','System.ComponentModel','System.Windows.Forms','System.Data') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $timer1 = New-Object System.Timers.Timer
  $label1 = New-Object System.Windows.Forms.Label

  $f.SuspendLayout()
  $components = New-Object System.ComponentModel.Container


  $browser = New-Object System.Windows.Forms.WebBrowser
  $f.SuspendLayout();

  # webBrowser1
  $browser.Dock = [System.Windows.Forms.DockStyle]::Fill
  $browser.Location = New-Object System.Drawing.Point (0,0)
  $browser.Name = "webBrowser1"
  $browser.Size = New-Object System.Drawing.Size (600,600)
  $browser.TabIndex = 0
  # Form1 
  $f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6,13)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.ClientSize = New-Object System.Drawing.Size (600,600)
  $f.Controls.Add($browser)
  $f.Text = "Login to octopus"
  $f.ResumeLayout($false)



  $f.add_Load({
      param([object]$sender,[System.EventArgs]$eventArgs)
      $browser.Navigate($login_url);
    })

  $browser.Add_Navigated(
    {

      param([object]$sender,[System.Windows.Forms.WebBrowserNavigatedEventArgs]$eventArgs)
      # wait for the user to successfully log in 
      # then capture the global cookies and sent to $caller
      $url = $browser.Url.ToString()
      if ($caller -ne $null -and $url -ne $null -and $url -match $caller.Url) {
        $caller.Cookies = $caller.GetGlobalCookies($url)
      }
    }
  )

  $f.ResumeLayout($false)
  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))

}

$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$service_host = 'http://localhost:8088'
$login_route = 'app#/users/sign-in'
$login_url = ('{0}/{1}' -f $service_host,$login_route)

$caller.Url = 'app#/environments'

promptForContinueWithCookies $login_url $caller

Write-Host ("{0}->{1}" -f,$caller.Url,$caller.Cookies)
