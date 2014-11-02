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

param(
  [switch]$debug
)
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


Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
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

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Windows.Forms;
using System.ComponentModel;
using System.Collections;
using System.Drawing;
using System.Runtime.InteropServices;

namespace C2C.FileSystem
{
    public class FileSystemTreeView : TreeView
    {
        private TreeNode _selectedNode;
        private bool _showFiles = true;
        public bool ShowFiles
        {
            get { return this._showFiles; }
            set { this._showFiles = value; }
        }

        private ImageList _imageList = new ImageList();
        private Hashtable _systemIcons = new Hashtable();
        private IWin32Window _caller;

        private string _data;
        public String Data
        {
            get { return this._data; }
            set { this._data = value; }
        }

        private string _iconPath = @"C:\developer\sergueik\powershell_ui_samples\unfinished\folder.ico";
        public String IconPath
        {
            get { return this._iconPath; }
            set { this._iconPath = value; }
        }

        private bool _debug = false;
        public bool Debug
        {
            get { return this._debug; }
            set { this._debug = value; }
        }

        public static readonly int Folder = 0;

        public FileSystemTreeView()
        {
            this.ImageList = _imageList;
            this.MouseDown += new MouseEventHandler(FileSystemTreeView_MouseDown);
            this.BeforeExpand += new TreeViewCancelEventHandler(FileSystemTreeView_BeforeExpand);
        }

        public FileSystemTreeView(IWin32Window caller)
            : this()
        {
            this._caller = caller;
        }

        void FileSystemTreeView_MouseDown(object sender, MouseEventArgs e)
        {
            TreeNode node = this.GetNodeAt(e.X, e.Y);
            _selectedNode = node;
            if (node == null)
                return;
            this.SelectedNode = node; //selected the node under the mouse         
        }

        void FileSystemTreeView_BeforeExpand(object sender, TreeViewCancelEventArgs e)
        {
            if (e.Node is FileNode) return;

            DirectoryNode node = (DirectoryNode)e.Node;

            if (!node.Loaded)
            {
                node.Nodes[0].Remove(); //remove the fake child node used for virtualization
                node.LoadDirectory();
                if (this._showFiles == true)
                    node.LoadFiles();
            }
        }
        private void FileSystemTreeView_AfterSelect(System.Object sender,
                System.Windows.Forms.TreeViewEventArgs e)
        {
            // e.Action = Unknown
            if (_selectedNode != null && _selectedNode.Parent != null)
            {
                if (_debug)
                {
                    MessageBox.Show(String.Format("AfterSelect: {0}", _selectedNode.FullPath.ToString()));
                }
                this._data = _selectedNode.FullPath.ToString();
            }
        }

        public void Load(string directoryPath)
        {
            if (Directory.Exists(directoryPath) == false)
                throw new DirectoryNotFoundException(String.Format("Directory Not Found: {0}", directoryPath));

            _systemIcons.Clear();
            _imageList.Images.Clear();
            Nodes.Clear();
            Icon folderIcon = new Icon(this._iconPath);

            _imageList.Images.Add(folderIcon);
            _systemIcons.Add(FileSystemTreeView.Folder, 0);

            DirectoryNode node = new DirectoryNode(this, new DirectoryInfo(directoryPath));
            node.Expand();
        }

        public int GetIconImageIndex(string path)
        {
            string extension = Path.GetExtension(path);

            if (_systemIcons.ContainsKey(extension) == false)
            {
                Icon icon = ShellIcon.GetSmallIcon(path);
                _imageList.Images.Add(icon);
                _systemIcons.Add(extension, _imageList.Images.Count - 1);
            }

            return (int)_systemIcons[Path.GetExtension(path)];
        }

    }

    public class DirectoryNode : TreeNode
    {
        private DirectoryInfo _directoryInfo;

        public DirectoryNode(DirectoryNode parent, DirectoryInfo directoryInfo)
            : base(directoryInfo.Name)
        {
            this._directoryInfo = directoryInfo;

            this.ImageIndex = FileSystemTreeView.Folder;
            this.SelectedImageIndex = this.ImageIndex;

            parent.Nodes.Add(this);

            Virtualize();
        }

        public DirectoryNode(FileSystemTreeView treeView, DirectoryInfo directoryInfo)
            : base(directoryInfo.Name)
        {
            this._directoryInfo = directoryInfo;

            this.ImageIndex = FileSystemTreeView.Folder;
            this.SelectedImageIndex = this.ImageIndex;

            treeView.Nodes.Add(this);

            Virtualize();

        }

        void Virtualize()
        {
            int fileCount = 0;

            try
            {
                if (this.TreeView.ShowFiles == true)
                    fileCount = this._directoryInfo.GetFiles().Length;

                if ((fileCount + this._directoryInfo.GetDirectories().Length) > 0)
                    new FakeChildNode(this);
            }
            catch
            {
            }
        }

        public void LoadDirectory()
        {
            foreach (DirectoryInfo directoryInfo in _directoryInfo.GetDirectories())
            {
                new DirectoryNode(this, directoryInfo);
            }
        }

        public void LoadFiles()
        {
            foreach (FileInfo file in _directoryInfo.GetFiles())
            {
                new FileNode(this, file);
            }
        }

        public bool Loaded
        {
            get
            {
                if (this.Nodes.Count != 0)
                {
                    if (this.Nodes[0] is FakeChildNode)
                        return false;
                }

                return true;
            }
        }

        public new FileSystemTreeView TreeView
        {
            get { return (FileSystemTreeView)base.TreeView; }
        }
    }

    public class FileNode : TreeNode
    {
        private FileInfo _fileInfo;
        private DirectoryNode _directoryNode;

        public FileNode(DirectoryNode directoryNode, FileInfo fileInfo)
            : base(fileInfo.Name)
        {
            this._directoryNode = directoryNode;
            this._fileInfo = fileInfo;

            this.ImageIndex = ((FileSystemTreeView)_directoryNode.TreeView).GetIconImageIndex(_fileInfo.FullName);
            this.SelectedImageIndex = this.ImageIndex;

            _directoryNode.Nodes.Add(this);
        }
    }

    public class FakeChildNode : TreeNode
    {
        public FakeChildNode(TreeNode parent)
            : base()
        {
            parent.Nodes.Add(this);
        }
    }

    public class ShellIcon
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct SHFILEINFO
        {
            public IntPtr hIcon;
            public IntPtr iIcon;
            public uint dwAttributes;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szDisplayName;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 80)]
            public string szTypeName;
        };

        class Win32
        {
            public const uint SHGFI_ICON = 0x100;
            public const uint SHGFI_LARGEICON = 0x0; // 'Large icon
            public const uint SHGFI_SMALLICON = 0x1; // 'Small icon

            [DllImport("shell32.dll")]
            public static extern IntPtr SHGetFileInfo(string pszPath, uint dwFileAttributes, ref SHFILEINFO psfi, uint cbSizeFileInfo, uint uFlags);
        }


        public ShellIcon()
        {
            // TODO: Add constructor logic here
        }


        public static Icon GetSmallIcon(string fileName)
        {
            IntPtr hImgSmall; //the handle to the system image list
            SHFILEINFO shinfo = new SHFILEINFO();

            //Use this to get the small Icon
            hImgSmall = Win32.SHGetFileInfo(fileName, 0, ref shinfo, (uint)Marshal.SizeOf(shinfo), Win32.SHGFI_ICON | Win32.SHGFI_SMALLICON);

            //The icon is returned in the hIcon member of the shinfo struct
            return System.Drawing.Icon.FromHandle(shinfo.hIcon);
        }


        public static Icon GetLargeIcon(string fileName)
        {
            IntPtr hImgLarge; //the handle to the system image list
            SHFILEINFO shinfo = new SHFILEINFO();

            //Use this to get the large Icon
            hImgLarge = Win32.SHGetFileInfo(fileName, 0, ref shinfo, (uint)Marshal.SizeOf(shinfo), Win32.SHGFI_ICON | Win32.SHGFI_LARGEICON);

            //The icon is returned in the hIcon member of the shinfo struct
            return System.Drawing.Icon.FromHandle(shinfo.hIcon);
        }
    }

}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Data')

# set up form

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$chooser = New-Object -TypeName 'C2C.FileSystem.FileSystemTreeView' -ArgumentList ($caller)
$chooser.IconPath = [System.IO.Path]::Combine( (Get-ScriptDirectory),  'folder.ico'  )
if ($PSBoundParameters["debug"]) {
    $chooser.Debug = $true
}

$form = New-Object System.Windows.Forms.Form
$form.Text = $title


$form.Size = New-Object System.Drawing.Size (700,450)

$panel = New-Object System.Windows.Forms.Panel


$panel1 = New-Object System.Windows.Forms.Panel
$btnDirectory = New-Object System.Windows.Forms.Button
$label1 = New-Object System.Windows.Forms.Label
$txtDirectory = New-Object System.Windows.Forms.TextBox
$treePanel = New-Object System.Windows.Forms.Panel
$panel1.SuspendLayout()
$form.SuspendLayout()

# 
# panel1
# 
$panel1.Controls.Add($btnDirectory)
$panel1.Controls.Add($label1)
$panel1.Controls.Add($txtDirectory)
$panel1.Dock = [System.Windows.Forms.DockStyle]::Top
$panel1.Location = New-Object System.Drawing.Point (0,0)
$panel1.Name = 'panel1'
$panel1.Size = New-Object System.Drawing.Size (681,57)
$panel1.TabIndex = 0

$objADcheckbox = New-Object System.Windows.Forms.CheckBox
$objADcheckbox.Location = New-Object System.Drawing.Point (515,27)
$objADcheckbox.Size = New-Object System.Drawing.Size (120,20)
$objADcheckbox.Text = 'Files'

$panel1.Controls.Add($objADcheckbox)
$objADcheckbox.add_click({ if ($objADcheckbox.Checked -eq $true) { $chooser.ShowFiles = $true } else { $chooser.ShowFiles = $false } })


# 
# btnDirectory
# 
$btnDirectory.Location = New-Object System.Drawing.Point (560,27)
$btnDirectory.Name = "btnDirectory"
$btnDirectory.Size = New-Object System.Drawing.Size (60,21)
$btnDirectory.TabIndex = 2
$btnDirectory.Text = 'Select'
$btnDirectory.add_click({ if ($caller.Data -ne $null) { $form.Close() } })

# 
# label1
# 
$label1.Location = New-Object System.Drawing.Point (9,9)
$label1.Name = 'label1'
$label1.Size = New-Object System.Drawing.Size (102,18)
$label1.TabIndex = 1
$label1.Text = 'Selection:'

# 
# txtDirectory
# 
$txtDirectory.Location = New-Object System.Drawing.Point (9,27)
$txtDirectory.Name = "txtDirectory"
$txtDirectory.Size = New-Object System.Drawing.Size (503,20)
$txtDirectory.TabIndex = 0
$txtDirectory.Text = ""
# $txtDirectory.KeyDown += New-Object System.Windows.Forms.KeyEventHandler($txtDirectory_KeyDown)
# $txtDirectory.KeyPress += New-Object System.Windows.Forms.KeyPressEventHandler($txtDirectory_KeyPress)

# 
# treePanel
# 
$treePanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$treePanel.Location = New-Object System.Drawing.Point (0,57)
$treePanel.Name = "treePanel"
$treePanel.Size = New-Object System.Drawing.Size (621,130)
$treePanel.TabIndex = 1

$treePanel.Controls.Add($chooser)
$chooser.ShowFiles = $false
$chooser.Dock = [System.Windows.Forms.DockStyle]::Fill
$chooser.Add_AfterSelect({ $txtDirectory.Text = $caller.Data = $chooser.Data })
$chooser.Load('C:\')
# Form1
# 
$form.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
$form.ClientSize = New-Object System.Drawing.Size (621,427)
$form.Controls.Add($treePanel)
$form.Controls.Add($panel1)
$form.Name = 'Form1'
$form.Text = 'Demo Chooser'
$panel1.ResumeLayout($false)
$form.ResumeLayout($false)
$form.Add_Shown({ $form.Activate() })
$form.KeyPreview = $True
$form.Add_KeyDown({

    if ($_.KeyCode -eq 'Escape') { $caller.Data = $null }
    else { return }
    $form.Close()
  })

[void]$form.ShowDialog([win32window ]($caller))

$form.Dispose()
Write-Output $caller.Data
