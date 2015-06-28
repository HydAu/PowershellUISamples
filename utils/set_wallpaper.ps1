

#requires -version 2.0

param(
  [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true )]
  [string]$image_path,
  [Parameter(Position=1, Mandatory=$false)]
  [string]$display_style = 'Stretch'
)

# http://www.pinvoke.net/default.aspx/user32.systemparametersinfo
# http://poshcode.org/5356
# http://poshcode.org/5693
Add-Type -ErrorAction Stop -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Utils 
{


    public enum Wallpaper_Style : int
    {
        Tile, Center, Stretch, NoChange
    }



    // https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947%28v=vs.85%29.aspx
    public class Wallpaper
    {


        [Flags]
        public enum SPIF
        {
            None = 0x00,
            SPIF_UPDATEINIFILE = 0x01,
            SPIF_SENDCHANGE = 0x02,
            SPIF_SENDWININICHANGE = 0x02
        }

        const int NO_ERROR = 0;

        // only needed constants 
        public const uint SPI_SETDESKWALLPAPER = 0x0014;
        public const uint SPI_GETDESKWALLPAPER = 0x0073;

        // For setting the path of the desktop wallpaper
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SystemParametersInfo(uint uiAction, uint uiParam, String pvParam, SPIF fWinIni);

        // For getting the path of the current desktop wallpaper
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SystemParametersInfo(uint uiAction, uint uiParam, StringBuilder pvParam, SPIF fWinIni);

        public static void SetWallpaper(string path, Wallpaper_Style style)
        {
            bool retVal = SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF.SPIF_UPDATEINIFILE | SPIF.SPIF_SENDWININICHANGE);       
            if (!retVal)
            {
                Console.WriteLine(String.Format("Failed to set wallpaper: {0}", path));

                int err = NO_ERROR;
                err = System.Runtime.InteropServices.Marshal.GetLastWin32Error();
                if (err != NO_ERROR)
                {
                    Console.WriteLine(err);
                }
                else {
                    Console.WriteLine("No error set");
                }
            }

            
            RegistryKey key = Registry.CurrentUser.OpenSubKey(@"Control Panel\\Desktop", true);
            switch (style)
            {
                case Wallpaper_Style.Stretch:
                    key.SetValue(@"WallpaperStyle", "2");
                    key.SetValue(@"TileWallpaper", "0");
                    break;
                case Wallpaper_Style.Center:
                    key.SetValue(@"WallpaperStyle", "1");
                    key.SetValue(@"TileWallpaper", "0");
                    break;
                case Wallpaper_Style.Tile:
                    key.SetValue(@"WallpaperStyle", "1");
                    key.SetValue(@"TileWallpaper", "1");
                    break;
                case Wallpaper_Style.NoChange:
                    break;
            }
            key.Close();
            StringBuilder sb = new StringBuilder(500);
            if (SystemParametersInfo(SPI_GETDESKWALLPAPER, (uint)sb.Capacity, sb, SPIF.None))
            {
                Console.WriteLine(sb.ToString());
            }
        }
    }
}

"@

# Note: for XP changing the wallpaper only works for BMP. 
# In Vista, at least, this works with additional image types: JPEG and GIF, but not for PNG

$converted_image_path  = Convert-Path $image_path
[Utils.Wallpaper]::SetWallpaper($converted_image_path,$display_style)
