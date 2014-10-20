# http://www.pinvoke.net/default.aspx/user32.enumdisplaysettings
# http://www.codeproject.com/Articles/6810/Dynamic-Screen-Resolution

Add-Type @"


using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;



public class Resulution_Helper
{

[StructLayout(LayoutKind.Sequential)]
public struct DEVMODE1 
{
	[MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)] public string dmDeviceName;
	public short  dmSpecVersion;
	public short  dmDriverVersion;
	public short  dmSize;
	public short  dmDriverExtra;
	public int    dmFields;

	public short dmOrientation;
	public short dmPaperSize;
	public short dmPaperLength;
	public short dmPaperWidth;

	public short dmScale;
	public short dmCopies;
	public short dmDefaultSource;
	public short dmPrintQuality;
	public short dmColor;
	public short dmDuplex;
	public short dmYResolution;
	public short dmTTOption;
	public short dmCollate;
	[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string dmFormName;
	public short dmLogPixels;
	public short dmBitsPerPel;
	public int   dmPelsWidth;
	public int   dmPelsHeight;

	public int   dmDisplayFlags;
	public int   dmDisplayFrequency;

	public int   dmICMMethod;
	public int   dmICMIntent;
	public int   dmMediaType;
	public int   dmDitherType;
	public int   dmReserved1;
	public int   dmReserved2;

	public int   dmPanningWidth;
	public int   dmPanningHeight;
};


	[DllImport("user32.dll")]
	public static extern int EnumDisplaySettings (string deviceName, int modeNum, ref DEVMODE1 devMode );  

       
	[DllImport("user32.dll")]
	public static extern int ChangeDisplaySettings(ref DEVMODE1 devMode, int flags);

	public const int ENUM_CURRENT_SETTINGS = -1;
	public const int CDS_UPDATEREGISTRY = 0x01;
	public const int CDS_TEST = 0x02;
	public const int DISP_CHANGE_SUCCESSFUL = 0;
	public const int DISP_CHANGE_RESTART = 1;
	public const int DISP_CHANGE_FAILED = -1;
public  Resulution_Helper()
        {
    DEVMODE1 vDevMode = new DEVMODE1();
    int i = 0;
    while (0 != EnumDisplaySettings(null, i, ref vDevMode))
    {
    Console.WriteLine("Width:{0} Height:{1} Color:{2} Frequency:{3}",
        vDevMode.dmPelsWidth,
        vDevMode.dmPelsHeight,
1 << vDevMode.dmBitsPerPel,         vDevMode.dmDisplayFrequency
    );
    i++;
    }

}         

}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'


$caller = New-Object -typename 'Resulution_Helper'
