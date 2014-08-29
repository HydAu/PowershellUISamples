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
    /// <summary>
    /// Summary description for BitmapOther.
    /// </summary>
  public class BitmapOther : System.Windows.Forms.Form
  {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.Container components = null;

    public BitmapOther()
    {
      //
      // Required for Windows Form Designer support
      //
      InitializeComponent();

      //
      // TODO: Add any constructor code after InitializeComponent call
      //
    }

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    protected override void Dispose( bool disposing )
    {
      if( disposing )
      {
        if (components != null) 
        {
          components.Dispose();
        }
      }
      base.Dispose( disposing );
    }

        #region Windows Form Designer generated code
    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
      // 
      // BitmapOther
      // 
      this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
      this.ClientSize = new System.Drawing.Size(292, 273);
      this.Name = "BitmapOther";
      this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
      this.Text = "BitmapOther";
      this.Load += new System.EventHandler(this.BitmapOther_Load);

    }
        #endregion

    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main() 
    {
      Application.Run(new BitmapOther());
    }

    private void BitmapOther_Load(object sender, System.EventArgs e)
    {
    
    }

    protected override void OnPaint ( PaintEventArgs e )
    {
      Bitmap BMP = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\Colorbars.JPG");
      Point Pt = new Point(20,20);

   //   BMP.SetPixel(15,20,Color.Black);
      BMP.MakeTransparent( BMP.GetPixel(15,25) );

      e.Graphics.DrawImage(BMP, Pt);
      e.Graphics.DrawLine(new Pen(Brushes.GreenYellow,30),60,60,200,60);


      
    }

// # http://stackoverflow.com/questions/6956222/is-there-a-way-to-overlay-or-merge-a-drawing-bitmap-and-a-drawingimage
// ...
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

