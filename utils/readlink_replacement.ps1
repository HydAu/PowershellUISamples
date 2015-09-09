#Copyright (c) 2015 Serguei Kouzmine
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

    public static string GetSymbolicLinkTarget(FileInfo symlink)
    {
        SafeFileHandle fileHandle = CreateFile(symlink.FullName, 0, 2, System.IntPtr.Zero, CREATION_DISPOSITION_OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, System.IntPtr.Zero);
        if (fileHandle.IsInvalid)
            throw new Win32Exception(Marshal.GetLastWin32Error());

        StringBuilder path = new StringBuilder(512);
        int size = GetFinalPathNameByHandle(fileHandle.DangerousGetHandle(), path, path.Capacity, 0);
        if (size < 0)
            throw new Win32Exception(Marshal.GetLastWin32Error());
        // http://msdn.microsoft.com/en-us/library/aa365247(v=VS.85).aspx
        if (path[0] == '\\' && path[1] == '\\' && path[2] == '?' && path[3] == '\\')
            return path.ToString().Substring(4);
        else
            return path.ToString();
    }

}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Runtime.InteropServices.dll','System.Net.dll','System.Data.dll','mscorlib.dll'

$current_user = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not (New-Object Security.Principal.WindowsPrincipal $current_user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
  Write-Host "`nPlease execute this script with administrative privileges as creation of links requires.`nAborting..`n"
#  exit
}


$target_dir = 'C:\Wix'
$symlink_directory = ("${env:TEMP}\{0}" -f (Get-Random -Maximum 1000))

$create_symlink_command = "cmd.exe /C MKLINK /J  ${symlink_directory} ${target_dir}"
Write-Output $create_symlink_command
Invoke-Expression -Command $create_symlink_command
$show_symlink_command = "cmd.exe /C DIR /L ${env:TEMP}"
Write-Output $create_symlink_command $show_symlink_command

Invoke-Expression -Command $show_symlink_command
Write-Output 'Calling P/Invoke'

$symlink_directory_directoryinfo_object = New-Object System.IO.DirectoryInfo ($symlink_directory)
$symlink_target = [utility]::GetSymbolicLinkTarget($symlink_directory_directoryinfo_object)
Write-Output ('{0} => {1} ' -f $symlink_directory,$symlink_target)
$recycle_command = "cmd.exe /c RD `"${symlink_directory}`""
Write-Output $recycle_command
Invoke-Expression -Command $recycle_command
# Does not work fordirectories ?
if (Get-Item -Path $symlink_directory -ErrorAction 'silentlycontinue') {
  Remove-Item -Force $symlink_directory
}

$target_file = 'C:\Wix\dark.exe'
$symlink_file = ("${env:TEMP}\{0}" -f (Get-Random -Maximum 1000))

$create_symlink_command = "cmd.exe /C MKLINK ${symlink_file} ${target_file}"
# You do not have sufficient privilege to perform this operation.
Write-Output $create_symlink_command
Invoke-Expression -Command $create_symlink_command
$show_symlink_command = "cmd.exe /C DIR /L ${env:TEMP}"
Write-Output $create_symlink_command $show_symlink_command

Invoke-Expression -Command $show_symlink_command
Write-Output 'Calling P/Invoke'

$symlink_file_dirinfo_object = New-Object System.IO.DirectoryInfo ([System.IO.Path]::GetDirectoryName($symlink_file))
$symlink_file_fileinfo_object = New-Object System.IO.FileInfo ($symlink_file)
# NOT supported yet.
$symlink_target = [utility]::GetSymbolicLinkTarget($symlink_file_fileinfo_object)
Write-Output ('{0} => {1} ' -f $symlink_file,$symlink_target)
$recycle_command = "cmd.exe /c DEL /Q `"${symlink_file}`""
Write-Output $recycle_command
Invoke-Expression -Command $recycle_command
# Does not work 
if (Get-Item -Path $symlink_file -ErrorAction 'silentlycontinue') {
  Remove-Item -Force $symlink_file
}
