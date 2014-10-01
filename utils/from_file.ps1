param(
  [string]$image_path
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
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

# http://www.codeproject.com/Tips/816113/Console-Monitor
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Drawing.Imaging;
public class WindowHelper : IDisposable
{
    private Bitmap _bmp;
    private Graphics _graphics;
    private int _count = 0;
    private Font _font;

    private string _timeStamp;
    private string _browser;
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
        _bmp = new Bitmap(Screen.PrimaryScreen.Bounds.Width, Screen.PrimaryScreen.Bounds.Height);
        _graphics = Graphics.FromImage(_bmp);
        _graphics.CopyFromScreen(0, 0, 0, 0, _bmp.Size);
        StampScreenshot();
        _bmp.Save(_dstImagePath, ImageFormat.Jpeg);        
    }

    public void StampScreenshot()
    {
        string firstText = _timeStamp;
        string secondText = _browser;

        PointF firstLocation = new PointF(10f, 10f);
        PointF secondLocation = new PointF(10f, 55f);
        if (_bmp == null)
        {
            createFromFile();
        }
        _graphics = Graphics.FromImage(_bmp);
        _font = new Font("Arial", 40);
        _graphics.DrawString(firstText, _font, Brushes.White, firstLocation);
        _graphics.DrawString(secondText, _font, Brushes.Aqua, secondLocation);
        _bmp.Save(_dstImagePath, ImageFormat.Jpeg);
    }
    public WindowHelper()
    {
    }

~WindowHelper()
    {
        Console.WriteLine("destructor");
    }
   
    public void Dispose()
    {
        Console.WriteLine("implementation of IDisposable.Dispose()");
        _font.Dispose();
        _bmp.Dispose();
        _graphics.Dispose();

    }
    private void createFromFile()
    {
        try {
        _bmp = new Bitmap(_srcImagePath);
        } catch (Exception e){
           throw e;
        }
        if (_bmp == null ){
           throw new Exception("failed to load image");
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'


$guid = [guid]::NewGuid()
$image_name = ($guid.ToString())
$image_name = '4f654c89-5efd-43ef-9173-0cfe125ca9az'

[string]$src_image_path = ('{0}\{1}.{2}' -f (Get-ScriptDirectory),$image_name,'jpg')
[string]$dest_image_path = ('{0}\{1}-new.{2}' -f (Get-ScriptDirectory),$image_name,'jpg')
$iteration = '123'
$browser = 'chrome'

$owner = New-Object WindowHelper
$owner.count = $iteration
$owner.Browser = $browser
$owner.SrcImagePath = $src_image_path
$owner.TimeStamp = Get-Date
$owner.DstImagePath = $dest_image_path
<#
try {
  $owner.Screenshot()
} catch [exception]{
  Write-Output $_.Exception.Message
}
#>

try {
  $owner.StampScreenshot()
} catch [exception]{
  Write-Output $_.Exception.Message
}

