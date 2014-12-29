# http://www.codeproject.com/Articles/17954/Show-progress-using-the-NotifyIcon-application-tra
<#

[DllImport("user32.dll", EntryPoint = "DestroyIcon", CharSet = CharSet.Auto, ExactSpelling = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool DestroyIcon(HandleRef hIcon);

drawBrush.Dispose();
ImageGraphics.Dispose();
 
Icon oldIcon  = trayIcon.Icon;
trayIcon.Icon = Icon.FromHandle(bmp.GetHicon());
trayIcon.Text = text;
 
NativeMethods.DestroyIcon(new HandleRef(this, oldIcon.Handle));
 
oldIcon.Dispose();
bmp.Dispose();

#>
# http://www.codeproject.com/Articles/7122/Dynamically-Generating-Icons-safely
