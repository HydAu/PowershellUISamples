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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
  if ($env:SCRIPT_PATH -ne '' -and $env:SCRIPT_PATH -ne $null) {
    return $env:SCRIPT_PATH
  }
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}



Add-Type -TypeDefinition @"

using System;
using System.Drawing.Drawing2D;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace BitmapOther_c
{
    public class BitmapOther : System.Windows.Forms.Form
    {
        private System.ComponentModel.Container components = null;

        public BitmapOther()
        {
            InitializeComponent();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (components != null)
                {
                    components.Dispose();
                }
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.ClientSize = new System.Drawing.Size(292, 273);
            this.Name = "BitmapOther";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "BitmapOther";
            this.Load += new System.EventHandler(this.BitmapOther_Load);
        }

        [STAThread]
        static void Main()
        {
            Application.Run(new BitmapOther());
        }

        private void BitmapOther_Load(object sender, System.EventArgs e)
        {

        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Bitmap Bmp;
            String BackgroundImage = @"C:\developer\sergueik\powershell_ui_samples\Colorbars.JPG";
            // Paint background image 
            if (BackgroundImage != null)
            {
                Bmp = new Bitmap(BackgroundImage);
                Bmp.MakeTransparent(Color.White);
                Bmp.SetPixel(15, 20, Color.Black);
                Point Pt = new Point(20, 20);
                // e.Graphics.DrawImage(Bmp, 20,20, Width, Height);
            }

            e.Graphics.DrawLine(new Pen(Brushes.GreenYellow, 30), 60, 60, 200, 60);
            String DetaildImage = @"C:\developer\sergueik\powershell_ui_samples\database.bmp";
            Bmp = new Bitmap(DetaildImage);
            Bmp.MakeTransparent(Color.White);


            e.Graphics.DrawImage(Bmp, 40, 10, Bmp.Width / 2, Bmp.Height / 2);
            e.Graphics.DrawImage(Bmp, 40, 60, Bmp.Width / 2, Bmp.Height / 2);

            DetaildImage = @"C:\developer\sergueik\powershell_ui_samples\app.bmp";
            Bmp = new Bitmap(DetaildImage);
            Bmp.MakeTransparent(Color.White);

            e.Graphics.DrawImage(Bmp, 70, 10, Bmp.Width / 2, Bmp.Height / 2);
            e.Graphics.DrawImage(Bmp, 85, 25, Bmp.Width / 2, Bmp.Height / 2);
        }

        // # http://stackoverflow.com/questions/6956222/is-there-a-way-to-overlay-or-merge-a-drawing-bitmap-and-a-drawingimage
        private System.Drawing.Image MergeImages(System.Drawing.Image backgroundImage,
                                  System.Drawing.Image overlayImage)
        {
            Image theResult = backgroundImage;
            if (null != overlayImage)
            {
                Image theOverlay = overlayImage;
                if (PixelFormat.Format32bppArgb != overlayImage.PixelFormat)
                {
                    theOverlay = new Bitmap(overlayImage.Width,
                                            overlayImage.Height,
                                            PixelFormat.Format32bppArgb);
                    using (Graphics graphics = Graphics.FromImage(theOverlay))
                    {
                        graphics.DrawImage(overlayImage,
                                           new Rectangle(0, 0, theOverlay.Width, theOverlay.Height),
                                           new Rectangle(0, 0, overlayImage.Width, overlayImage.Height),
                                           GraphicsUnit.Pixel);
                    }
                    ((Bitmap)theOverlay).MakeTransparent();
                }

                using (Graphics graphics = Graphics.FromImage(theResult))
                {
                    graphics.DrawImage(theOverlay,
                                       new Rectangle(0, 0, theResult.Width, theResult.Height),
                                       new Rectangle(0, 0, theOverlay.Width, theOverlay.Height),
                                       GraphicsUnit.Pixel);
                }
            }
            return theResult;
        }
    }
}




"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll', 'System.Data.dll'

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string Message
    {
        get { return _message; }
        set { _message = value; }
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


$process_window = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

$clock = New-Object BitmapOther_c.BitmapOther
$clock.ShowDialog($process_window) | out-null

write-output $process_window.GetHashCode()

