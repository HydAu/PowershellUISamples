#  http://chrisbensen.blogspot.com/2010/06/getfinalpathnamebyhandle.html
Add-Type -TypeDefinition @"
// "

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.IO;
using System.Net;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public class Utility
{

    private const int FILE_SHARE_READ = 1;
    private const int FILE_SHARE_WRITE = 2;

    private const int CREATION_DISPOSITION_OPEN_EXISTING = 3;

    private const int FILE_FLAG_BACKUP_SEMANTICS = 0x02000000;

    // http://msdn.microsoft.com/en-us/library/aa364962%28VS.85%29.aspx
    // http://pinvoke.net/default.aspx/kernel32/GetFileInformationByHandleEx.html

    // http://www.pinvoke.net/default.aspx/shell32/GetFinalPathNameByHandle.html
    [DllImport("kernel32.dll", EntryPoint = "GetFinalPathNameByHandleW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int GetFinalPathNameByHandle(IntPtr handle, [In, Out] StringBuilder path, int bufLen, int flags);

    // https://msdn.microsoft.com/en-us/library/aa364953%28VS.85%29.aspx


    // http://msdn.microsoft.com/en-us/library/aa363858(VS.85).aspx
    // http://www.pinvoke.net/default.aspx/kernel32.createfile
    [DllImport("kernel32.dll", EntryPoint = "CreateFileW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern SafeFileHandle CreateFile(string lpFileName, int dwDesiredAccess, int dwShareMode,
    IntPtr SecurityAttributes, int dwCreationDisposition, int dwFlagsAndAttributes, IntPtr hTemplateFile);

    public static string GetSymbolicLinkTarget(DirectoryInfo symlink)
    {
        SafeFileHandle directoryHandle = CreateFile(symlink.FullName, 0, 2, System.IntPtr.Zero, CREATION_DISPOSITION_OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, System.IntPtr.Zero);
        if (directoryHandle.IsInvalid)
            throw new Win32Exception(Marshal.GetLastWin32Error());

        StringBuilder path = new StringBuilder(512);
        int size = GetFinalPathNameByHandle(directoryHandle.DangerousGetHandle(), path, path.Capacity, 0);
        if (size < 0)
            throw new Win32Exception(Marshal.GetLastWin32Error());
        // http://msdn.microsoft.com/en-us/library/aa365247(v=VS.85).aspx
        if (path[0] == '\\' && path[1] == '\\' && path[2] == '?' && path[3] == '\\')
            return path.ToString().Substring(4);
        else
            return path.ToString();
    }
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll','System.Data.dll', 'mscorlib.dll'
$target = 'C:\Wix'
$symlink_directory = ("${env:TEMP}\{0}" -f (Get-Random -Maximum 1000))

$create_symlink_command = "cmd.exe /C MKLINK ${symlink_directory} ${target}"
write-output $create_symlink_command
invoke-expression -command $create_symlink_command
$show_symlink_command = "cmd.exe /C DIR /L ${env:TEMP}" 
write-output $create_symlink_command $show_symlink_command

invoke-expression -command $show_symlink_command
write-output 'Calling P/Invoke'

$symlink_directory_directoryinfo_object = new-object System.IO.DirectoryInfo($symlink_directory)
$symlink_target = [Utility]::GetSymbolicLinkTarget($symlink_directory_directoryinfo_object)
write-output ('{0} => {1} ' -f $symlink_directory, $symlink_target)
$recycle_command = "cmd.exe /c DEL `"${symlink_directory}`""
write-output $recycle_command
invoke-expression -command $recycle_command
