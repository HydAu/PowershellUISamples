param(
  [string]$image_path
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

# http://www.codeproject.com/Tips/816113/Console-Monitor
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Drawing.Imaging;
public class WindowHelper
{
    private Bitmap bmp;
    private int _count = 0;

    private string _timeStamp;
    private string _browser;
    private string _imagePath;
    private string _srcImagePath;

    private string _dstImagePath;

    public string DstImagePath
    {
        get { return _dstImagePath; }
        set { _dstImagePath = value; }
    }

    public string TimeStamp
    {
        get { return _timeStamp; }
        set { _timeStamp = value; }
    }

    public string ImagePath
    {
        get { return _imagePath; }
        set { _imagePath = value; }
    }


    public string SrcImagePath
    {
        get { return _srcImagePath; }
        set { _srcImagePath = value; }
    }

    public string Browser
    {
        get { return _browser; }
        set { _browser = value; }
    }
    public int Count
    {
        get { return _count; }
        set { _count = value; }
    }
    public void Screenshot()
    {
        bmp = new Bitmap(Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);
        Graphics gr = Graphics.FromImage(bmp);
        gr.CopyFromScreen(0, 0, 0, 0, bmp.Size);
        StampScreenshot();

        string str = _dstImagePath;
        bmp.Save(str, ImageFormat.Jpeg);        
    }

    public void StampScreenshot()
    {
        string firstText = _timeStamp;
        string secondText = _browser;

        PointF firstLocation = new PointF(10f, 10f);
        PointF secondLocation = new PointF(10f, 55f);
        if (bmp == null)
        {
            bmp = createFromFile();
        }

        using (Graphics graphics = Graphics.FromImage(bmp))
        {
            using (Font arialFont = new Font("Arial", 40))
            {
                graphics.DrawString(firstText, arialFont, Brushes.White, firstLocation);
                graphics.DrawString(secondText, arialFont, Brushes.Aqua, secondLocation);
            }

        }
        //  bmp.Save(_imagePath, ImageFormat.Jpeg);
        string str = _dstImagePath;
        bmp.Save(str, ImageFormat.Jpeg);
    }
    public WindowHelper()
    {
    }


    private Bitmap createFromFile()
    {
        Bitmap bmp;
        bmp = new Bitmap(_imagePath);
        return bmp;
    }
}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'


 $guid = [guid]::NewGuid()
   $image_name = ($guid.ToString())
   $image_name = 'bd6afdc3-af3e-4e4d-907b-5f6d2e182539'
   $image_name = 'd2f5aaf9-066d-4b50-b9ae-0c9f45d2a97f'
[string]$image_path = ('{0}\{1}.{2}' -f (Get-ScriptDirectory),  $image_name , '.png'  )
[string]$src_image_path = ('{0}\{1}.{2}' -f (Get-ScriptDirectory),  $image_name , '.jpg'  )
[string]$dest_image_path = ('{0}\{1}-new.{2}' -f (Get-ScriptDirectory),  $image_name , '.jpg'  )
# $screenshot.SaveAsFile($image_path), [System.Drawing.Imaging.ImageFormat]::Png)
   $iteration = '123' 
   $browser = 'chrome'

$owner = New-Object WindowHelper
  $owner.count = $iteration
  $owner.Browser = $browser
  $owner.ImagePath = $src_image_path
  $owner.TimeStamp = Get-Date
  $owner.DstImagePath  = $dest_image_path
  $owner| get-member 
  try {  
  $owner.StampScreenshot()
 } catch [Exception]  {
   write-output $_.Exception.Message
 }

<#
$owner = New-Object WindowHelper
  $owner.count = $iteration
  $owner.Browser = $browser
  $owner.ImagePath = $image_path
$owner.TimeStamp = Get-Date

  $owner| get-member 
  try {  
  $owner.StampScreenshot()
 } catch [Exception]  {
   write-output $_.Exception.Message
 }
#>

# Cleanup
try {
  $driver.Quit()
} catch [Exception] {
  # Ignore errors if unable to close the browser
}
