#Copyright (c) 2014 Serguei Kouzmine
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
#
[CmdletBinding()]
param([string]$string_param1 = '',
  [string]$string_param2 = '',
  [string]$string_param3 = '',
  [boolean]$boolean_param = $false,
  [int]$int_param
)


Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;

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

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}


($caller = New-Object -typeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)) | out-null

# http://msdn.microsoft.com/en-us/library/windows/desktop/bb774065%28v=vs.85%29.aspx
# http://msdn.microsoft.com/en-us/library/windows/desktop/bb774096%28v=vs.85%29.aspx
# http://msdn.microsoft.com/en-us/library/windows/desktop/bb773205%28v=vs.85%29.aspx

$BIF_NONEWFOLDERBUTTON = 0x00000200
$BIF_BROWSEINCLUDEFILES  = 0x00004000

$BIF_NEWDIALOGSTYLE = 0x00000040 
$BIF_EDITBOX = 0x00000010

$shell_obj = new-object -com 'Shell.Application'

<#
[System.__ComObject]$folder_obj = ($shell_obj.BrowseForFolder(
  [System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle,
  'Choose Folder',
  ($BIF_NEWDIALOGSTYLE -bor $BIF_NONEWFOLDERBUTTON),
  (Get-ScriptDirectory ))
)
# $folder_obj.GetType() | format-list
$folder_path = $folder_obj.Self.Path
write-output $folder_path
#>
<#
$file_obj = $null
try{ 
[System.__ComObject]$file_obj = ($shell_obj.BrowseForFolder(
  [System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle,
  'Choose File',
  $BIF_BROWSEINCLUDEFILES,
  0)) 
} catch [Exception] { 
write-output $_.Exception.Message
# System.Reflection.TargetInvocationException
# $_.Exception | get-member
# Exception has been thrown by the target of an invocation. ???
}

$file_obj.GetType() | format-list 
$file_obj.Self | get-member
# Exception from HRESULT: 0x80004005 (E_FAIL)
# $folder_obj.GetType() | format-list
$file_path = $file_obj.Self.Path
write-output $file_path
#>



Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

<#
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    Filter = 'Documents (*.docx)|*.docx|SpreadSheet (*.xlsx)|*.xlsx'
}
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileNames

Add-Type -AssemblyName System.Windows.Forms
 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $true
}
 
[void]$FileBrowser.ShowDialog()
$FileBrowser.FileNames

# shttp://www.powershellmagazine.com/2013/07/01/pstip-using-the-system-windows-forms-openfiledialog-class/
#>
# *** Entry Point to Script ***

Get-FileName -initialDirectory "c:\fso"
# https://social.technet.microsoft.com/Forums/en-US/ebc8a618-4cd0-4328-b0f1-3c70d811309c/getting-the-file-location-using-openfiledialog-in-powershell
#>
<#
Add-Type -AssemblyName system.Windows.Forms
$SetBackupLocation = New-Object System.Windows.Forms.OpenFileDialog

$SetBackupLocation.Filter = "All files (*.*)|*.*"
$SetBackupLocation.FilterIndex = 2
$SetBackupLocation.RestoreDirectory = $true

$rc = $SetBackupLocation.ShowDialog()
if ($rc -eq [System.Windows.Forms.DialogResult]::OK)
{

$BackupLocation = $SetBackupLocation.FileName #Full path with filename
$BackupLocationFile = $SetBackupLocation.SafeFileName #File name
$BackupLocation = $BackupLocation.Replace($BackupLocationFile, "")		

write-output $BackupLocation		
	
}



Add-Type -AssemblyName system.Windows.Forms
$SetBackupLocation2 = New-Object System.Windows.Forms.SaveFileDialog
$SetBackupLocation2.Filter = "All files (*.*)|*.*"
$SetBackupLocation2.FilterIndex = 2
$SetBackupLocation2.RestoreDirectory = $true
$SetBackupLocation2.FileName = 'backupfile'
$rc = $SetBackupLocation2.ShowDialog()
$rc
http://www.experts-exchange.com/Programming/Languages/Scripting/Powershell/Q_28330518.html


if($result -eq “OK”) {

$inputFile = $myDialog.FileName

# Continue working with file

}

else {

Write-Host “Cancelled by user”

}
#>

<#
# http://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/

# Show an Open Folder Dialog and return the directory selected by the user.
function Read-FolderBrowserDialog([string]$Message, [string]$InitialDirectory, [switch]$NoNewFolderButton)
{
    $browseForFolderOptions = 0
    if ($NoNewFolderButton) { $browseForFolderOptions += 512 }
 
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, $browseForFolderOptions, $InitialDirectory)
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) > $null
    return $selectedDirectory
}
#>