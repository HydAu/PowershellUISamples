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
  [string]$servers_file = '',
  [string]$use_servers_file = ''
)


# http://www.codeproject.com/Tips/816113/Console-Monitor
Add-Type -TypeDefinition @"

// "
// intend to call from a Form or from a timer 

using System;
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Drawing.Imaging;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    public IntPtr Handle
    {
        get { return _hWnd; }
    }
    private int _count = 0;
    public int Count
    {
        get { return _count; }
        set { _count = value; }
    }
    public String TakeScreenshot()
    {
        Bitmap bmp = new Bitmap(Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);
        Graphics gr = Graphics.FromImage(bmp);
        gr.CopyFromScreen(0, 0, 0, 0, bmp.Size);
        string str = string.Format(@"C:\temp\Snap[{0}].jpeg", _count);
        bmp.Save(str, ImageFormat.Jpeg);
        bmp.Dispose();
        gr.Dispose();
        return str;
    }
    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'

<#
http://blogs.technet.com/b/heyscriptingguy/archive/2011/06/16/use-asynchronous-event-handling-in-powershell.aspx
http://www.nivot.org/blog/post/2008/05/23/BackgroundTimerPowerShellWPFWidget
http://jrich523.wordpress.com/2011/06/13/creating-a-timer-event-in-powershell/
#>

$owner = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

$timer = New-Object System.Timers.Timer

[int32]$max_iterations = 10
[int32]$iteration = 0

$action = {
  Write-Host "Iteration # ${iteration}"
  Write-Host "Timer Elapse Event: $(get-date -Format 'HH:mm:ss')"
  # now displosing
  $screen_grabber  = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

  $screen_grabber.count = $iteration
  $screen_grabber.TakeScreenshot()
  $screen_grabber = $null
  $iteration++
  if ($iteration -ge $max_iterations)
  {
    Write-Host 'Stopping'
    $timer.stop()
    Unregister-Event thetimer -Force 
    Write-Host 'Completed'    
  }
}

# http://www.ravichaganti.com/blog/passing-variables-or-arguments-to-an-event-action-in-powershell/
Register-ObjectEvent -InputObject $timer -EventName elapsed –SourceIdentifier thetimer -Action $action
<#
TODO : catch and unregister
Register-ObjectEvent : Cannot subscribe to event. A subscriber with sourceidentifier 'thetimer' already exists.

#>
$timer.Interval = 1000 # milliseconds

Write-Output 'Starting'
$timer.start()

# http://amazingcarousel.com/examples/jquery-image-carousel-with-text-id7/
# http://www.codeproject.com/Articles/808930/Animated-Image-Slide-Show
