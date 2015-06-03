# http://stackoverflow.com/questions/4897655/create-shortcut-on-desktop-c-sharp
# http://www.vbaccelerator.com/home/NET/Code/Libraries/Shell_Projects/Creating_and_Modifying_Shortcuts/article.asp
# please note that
# https://github.com/guitarrapc/PowerShellUtil/blob/master/SymbolicLink/Set-SynbolicLink.ps1
# is not acceptable  solution 
# because of 
# http://stackoverflow.com/questions/23217460/how-to-create-soft-symbolic-link-using-java-nio-files
# http://stackoverflow.com/questions/8228030/getting-filesystemexception-a-required-privilege-is-not-held-by-the-client-usi

   param
    (
        [parameter(
            Mandatory = 1,
            Position  = 0,
            ValueFromPipeline =1,
            ValueFromPipelineByPropertyName = 1)]
        [Alias('TargetPath')]
        [Alias('FullName')]
        [String[]]
        $Path,

        [parameter(
            Mandatory = 1,
            Position  = 1,
            ValueFromPipelineByPropertyName = 1)]
        [String[]]
        $SymbolicPath
)
add-type @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;

namespace TestShellLink
{
    public class Provider
    {
        private string _symbolic_path = null;
        private string _target_path = null;

        public string TargetPath
        {
            get { return _target_path; }
            set { _target_path = value; }
        }
        public string SymbolicPath
        {
            get { return _symbolic_path; }
            set { _symbolic_path = value; }
        }

        public void SoftLink()
        {
            IShellLink link = (IShellLink)new ShellLink();

            // setup shortcut information
            link.SetDescription("My Description");
            link.SetPath(_target_path);

            // All Users => Environment.SpecialFolder.CommonDesktopDirectory
            IPersistFile file = (IPersistFile)link;
            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            string fullPath = Path.Combine(desktopPath, Path.Combine(String.Format(@"{0}\MyLink.lnk", _symbolic_path)));
            Console.Error.WriteLine(fullPath);
            file.Save(fullPath, false);
        }
    }

    [ComImport]
    [Guid("00021401-0000-0000-C000-000000000046")]
    internal class ShellLink
    {
    }

    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("000214F9-0000-0000-C000-000000000046")]
    internal interface IShellLink
    {
        void GetPath([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszFile, int cchMaxPath, out IntPtr pfd, int fFlags);
        void GetIDList(out IntPtr ppidl);
        void SetIDList(IntPtr pidl);
        void GetDescription([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName, int cchMaxName);
        void SetDescription([MarshalAs(UnmanagedType.LPWStr)] string pszName);
        void GetWorkingDirectory([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszDir, int cchMaxPath);
        void SetWorkingDirectory([MarshalAs(UnmanagedType.LPWStr)] string pszDir);
        void GetArguments([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszArgs, int cchMaxPath);
        void SetArguments([MarshalAs(UnmanagedType.LPWStr)] string pszArgs);
        void GetHotkey(out short pwHotkey);
        void SetHotkey(short wHotkey);
        void GetShowCmd(out int piShowCmd);
        void SetShowCmd(int iShowCmd);
        void GetIconLocation([Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszIconPath, int cchIconPath, out int piIcon);
        void SetIconLocation([MarshalAs(UnmanagedType.LPWStr)] string pszIconPath, int iIcon);
        void SetRelativePath([MarshalAs(UnmanagedType.LPWStr)] string pszPathRel, int dwReserved);
        void Resolve(IntPtr hwnd, int fFlags);
        void SetPath([MarshalAs(UnmanagedType.LPWStr)] string pszFile);
    }
}

"@  -ReferencedAssemblies 'mscorlib.dll','System.Runtime.InteropServices.dll', 'System.xml.dll'
$o = new-object -typename 'TestShellLink.Provider'
$o.TargetPath = $TargetPath
$o.SymbolicPath = $SymbolicPath
$o.SoftLink()
