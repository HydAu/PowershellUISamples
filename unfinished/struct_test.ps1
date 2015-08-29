
Add-Type -TypeDefinition @" 
// "
using System;
using System.Windows.Forms;
namespace Caller
{
    public struct Inner
    {
        public bool flag;
        public Int32 value;
    }

    public enum Parameter : uint
    {
        ZERO = 0,
        ONE = 1
    }


    public class Win32Window : IWin32Window
    {
        private IntPtr _hWnd;
        private string _data;
        //  unaccessible 
        public enum Parameter : uint
        {
            ZERO = 0,
            ONE = 1
        }
        //  unaccessible 
        public struct Inner
        {
            public bool flag;
            public Int32 value;
        }

        public string Data
        {
            get { return _data; }
            set { _data = value; }
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
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll'


$caller = New-Object Caller.Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$inner = New-Object Caller.Inner

$inner.flag = $true
Write-Host $inner.flag
$parameter = [Caller.Parameter]::ONE
Write-Host $parameter
try {
  $parameter = [Caller.Win32Window.Parameter]::ONE
  Write-Host $parameter
} catch [exception]{
  Write-Debug ("Exception : {0}`n...`n" -f (($_.Exception.Message) -split "`n")[0])
}

