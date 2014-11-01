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

Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;

    public int Data
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
    /// <summary>
    /// Summary description for DirectoryTreeView.
    /// </summary> 
    ///    

    public class FileSystemTreeView : TreeView
    {
        private bool _showFiles = true;
        private ImageList _imageList = new ImageList();
        private Hashtable _systemIcons = new Hashtable();

        public static readonly int Folder = 0;

        public FileSystemTreeView()
        {
            this.ImageList = _imageList;
            this.MouseDown += new MouseEventHandler(FileSystemTreeView_MouseDown);
            this.BeforeExpand += new TreeViewCancelEventHandler(FileSystemTreeView_BeforeExpand);
        }

        public FileSystemTreeView(IWin32Window caller)
        {
            this.ImageList = _imageList;
            this.MouseDown += new MouseEventHandler(FileSystemTreeView_MouseDown);
            this.BeforeExpand += new TreeViewCancelEventHandler(FileSystemTreeView_BeforeExpand);
       }



        void FileSystemTreeView_MouseDown(object sender, MouseEventArgs e)
        {
            TreeNode node = this.GetNodeAt(e.X, e.Y);

            if (node == null)
                return;

            this.SelectedNode = node; //select the node under the mouse         
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

        public void Load(string directoryPath)
        {
            if (Directory.Exists(directoryPath) == false)
                throw new DirectoryNotFoundException("Directory Not Found");

            _systemIcons.Clear();
            _imageList.Images.Clear();
            Nodes.Clear();
            string icon_path = @"C:\developer\sergueik\powershell_ui_samples\unfinished\folder.ico" ;
            Icon folderIcon = new Icon(icon_path);

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

        public bool ShowFiles
        {
            get { return this._showFiles; }
            set { this._showFiles = value; }
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

	/// <summary>
	/// Summary description for ShellIcon.
	/// </summary>
	/// <summary>
	/// Summary description for ShellIcon.  Get a small or large Icon with an easy C# function call
	/// that returns a 32x32 or 16x16 System.Drawing.Icon depending on which function you call
	/// either GetSmallIcon(string fileName) or GetLargeIcon(string fileName)
	/// </summary>
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
			//
			// TODO: Add constructor logic here
			//
		}


		public static Icon GetSmallIcon(string fileName)
		{
			IntPtr hImgSmall; //the handle to the system image list
			SHFILEINFO shinfo = new SHFILEINFO();


			//Use this to get the small Icon
			hImgSmall = Win32.SHGetFileInfo(fileName, 0, ref shinfo,(uint)Marshal.SizeOf(shinfo),Win32.SHGFI_ICON | Win32.SHGFI_SMALLICON);


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

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll'

<#
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
// using C2C.FileSystem;

namespace DirectoryTreeView
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
      private System.Windows.Forms.Panel panel1;
      private System.Windows.Forms.TextBox txtDirectory;
      private System.Windows.Forms.Label label1;
      private System.Windows.Forms.Button btnDirectory;
      private C2C.FileSystem.FileSystemTreeView tree;
      private System.Windows.Forms.Panel treePanel;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
         this.panel1 = new System.Windows.Forms.Panel();
         this.btnDirectory = new System.Windows.Forms.Button();
         this.label1 = new System.Windows.Forms.Label();
         this.txtDirectory = new System.Windows.Forms.TextBox();
         this.treePanel = new System.Windows.Forms.Panel();
         this.panel1.SuspendLayout();
         this.SuspendLayout();
         // 
         // panel1
         // 
         this.panel1.Controls.Add(this.btnDirectory);
         this.panel1.Controls.Add(this.label1);
         this.panel1.Controls.Add(this.txtDirectory);
         this.panel1.Dock = System.Windows.Forms.DockStyle.Top;
         this.panel1.Location = new System.Drawing.Point(0, 0);
         this.panel1.Name = "panel1";
         this.panel1.Size = new System.Drawing.Size(721, 57);
         this.panel1.TabIndex = 0;
         // 
         // btnDirectory
         // 
         this.btnDirectory.Location = new System.Drawing.Point(615, 27);
         this.btnDirectory.Name = "btnDirectory";
         this.btnDirectory.Size = new System.Drawing.Size(30, 21);
         this.btnDirectory.TabIndex = 2;
         this.btnDirectory.Text = "...";
         this.btnDirectory.Click += new System.EventHandler(this.btnDirectory_Click);
         // 
         // label1
         // 
         this.label1.Location = new System.Drawing.Point(9, 9);
         this.label1.Name = "label1";
         this.label1.Size = new System.Drawing.Size(102, 18);
         this.label1.TabIndex = 1;
         this.label1.Text = "Directory:";
         // 
         // txtDirectory
         // 
         this.txtDirectory.Location = new System.Drawing.Point(9, 27);
         this.txtDirectory.Name = "txtDirectory";
         this.txtDirectory.Size = new System.Drawing.Size(603, 20);
         this.txtDirectory.TabIndex = 0;
         this.txtDirectory.Text = "";
         this.txtDirectory.KeyDown += new System.Windows.Forms.KeyEventHandler(this.txtDirectory_KeyDown);
         this.txtDirectory.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtDirectory_KeyPress);
         // 
         // treePanel
         // 
         this.treePanel.Dock = System.Windows.Forms.DockStyle.Fill;
         this.treePanel.Location = new System.Drawing.Point(0, 57);
         this.treePanel.Name = "treePanel";
         this.treePanel.Size = new System.Drawing.Size(721, 530);
         this.treePanel.TabIndex = 1;
         // 
         // Form1
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(721, 587);
         this.Controls.Add(this.treePanel);
         this.Controls.Add(this.panel1);
         this.Name = "Form1";
         this.Text = "Demo Application";
         this.Load += new System.EventHandler(this.Form1_Load);
         this.panel1.ResumeLayout(false);
         this.ResumeLayout(false);

      }
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}

      private void Form1_Load(object sender, System.EventArgs e)
      {
         tree = new  C2C.FileSystem.FileSystemTreeView();         
         treePanel.Controls.Add( tree );
         tree.Dock = DockStyle.Fill;
         //tree.ShowFiles = false;
      }
      

      private void btnDirectory_Click(object sender, System.EventArgs e)
      {
         FolderBrowserDialog dlg = new FolderBrowserDialog();

         if( dlg.ShowDialog() == DialogResult.OK )
         {
            txtDirectory.Text = dlg.SelectedPath;
            tree.Load( txtDirectory.Text );
         }
      }

      private void txtDirectory_KeyPress(object sender, System.Windows.Forms.KeyPressEventArgs e)
      {
                
         
      }

      private void txtDirectory_KeyDown(object sender, System.Windows.Forms.KeyEventArgs e)
      {
         if(  e.KeyData == Keys.Enter )
         {
            if( System.IO.Directory.Exists( txtDirectory.Text ) == false )
            {
               MessageBox.Show( "Directory Does Not Exist", "Invalid Directory", MessageBoxButtons.OK, MessageBoxIcon.Information );
               return;
            }
            tree.Load( txtDirectory.Text );
         }
      }
	}
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll', 'System.Data.dll'

# does not compile
#>

$caller = New-Object -typeName  'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$chooser = New-Object -typeName 'C2C.FileSystem.FileSystemTreeView' -ArgumentList ($caller)

# $container = new-Object -typename 'DirectoryTreeView.Form1'
# $container.Show()


  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Data')

  # set up form
  $form = New-Object System.Windows.Forms.Form
  $form.Text = $title


  $form.Size = New-Object System.Drawing.Size ($width,400)

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
         $panel1.Dock =  [System.Windows.Forms.DockStyle]::Top
         $panel1.Location = New-Object System.Drawing.Point(0, 0)
         $panel1.Name = "panel1"
         $panel1.Size = New-Object System.Drawing.Size(721, 57)
         $panel1.TabIndex = 0
         # 
         # btnDirectory
         # 
         $btnDirectory.Location = New-Object System.Drawing.Point(615, 27)
         $btnDirectory.Name = "btnDirectory"
         $btnDirectory.Size = New-Object System.Drawing.Size(30, 21)
         $btnDirectory.TabIndex = 2
         $btnDirectory.Text = "..."
         # $btnDirectory.Click += New-Object System.EventHandler($btnDirectory_Click)

         # 
         # label1
         # 
         $label1.Location = New-Object System.Drawing.Point(9, 9)
         $label1.Name = "label1"
         $label1.Size = New-Object System.Drawing.Size(102, 18)
         $label1.TabIndex = 1
         $label1.Text = "Directory:"

         # 
         # txtDirectory
         # 
         $txtDirectory.Location = New-Object System.Drawing.Point(9, 27)
         $txtDirectory.Name = "txtDirectory"
         $txtDirectory.Size = New-Object System.Drawing.Size(603, 20)
         $txtDirectory.TabIndex = 0
         $txtDirectory.Text = ""
         # $txtDirectory.KeyDown += New-Object System.Windows.Forms.KeyEventHandler($txtDirectory_KeyDown)
         # $txtDirectory.KeyPress += New-Object System.Windows.Forms.KeyPressEventHandler($txtDirectory_KeyPress)

         # 
         # treePanel
         # 
         $treePanel.Dock =  [System.Windows.Forms.DockStyle]::Fill
         $treePanel.Location = New-Object System.Drawing.Point(0, 57)
         $treePanel.Name = "treePanel"
         $treePanel.Size = New-Object System.Drawing.Size(721, 530)
         $treePanel.TabIndex = 1

         $treePanel.Controls.Add($chooser);
         $chooser.Dock = [System.Windows.Forms.DockStyle]::Fill
         $chooser.Load( 'C:\' )   
         # Form1
         # 
         $form.AutoScaleBaseSize = New-Object System.Drawing.Size(5, 13)
         $form.ClientSize = New-Object System.Drawing.Size(721, 587)
         $form.Controls.Add($treePanel)
         $form.Controls.Add($panel1)
         $form.Name = "Form1"
         $form.Text = "Demo Application"
         #  $form.Load += New-Object System.EventHandler($form.Form1_Load)
         $panel1.ResumeLayout($false)
         $form.ResumeLayout($false)
<#
  $panel.Dock = "Fill"
  $form.Controls.Add($panel)

  $lv = New-Object windows.forms.ListView
  $panel.Controls.Add($lv)

#>

  $form.Add_Shown({ $form.Activate() })
  $form.KeyPreview = $True
  $form.Add_KeyDown({

      if ($_.KeyCode -eq 'Escape') { $caller.Data = $RESULT_CANCEL }
      else { return }
      $form.Close()
    })

  [void]$form.ShowDialog([win32window ]($caller))

  $form.Dispose()
