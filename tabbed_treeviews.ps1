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

# http://www.java2s.com/Code/CSharpAPI/System.Windows.Forms/TabControlControlsAdd.htm
# with sizes adjusted to run the focus demo
function TabsWithTreeViews (
  [string]$title,
  [object]$caller
) {

  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $panel2 = New-Object System.Windows.Forms.TabPage
  $panel1 = New-Object System.Windows.Forms.TabPage
  $tab_contol1 = New-Object System.Windows.Forms.TabControl
  $panel2.SuspendLayout()
  $panel1.SuspendLayout()
  $tab_contol1.SuspendLayout()
  $f.SuspendLayout()

  $panel2.Location = New-Object System.Drawing.Point (4,22)
  $panel2.Name = 'tabPage2'
  $panel2.Padding = New-Object System.Windows.Forms.Padding (3)
  $panel2.Size = New-Object System.Drawing.Size (259,352)
  $panel2.AutoSize = $true
  $panel2.TabIndex = 1
  $panel2.Text = 'Source Node'

  $l1 = New-Object System.Windows.Forms.Label
  $l1.Location = New-Object System.Drawing.Point (8,12)
  $l1.Size = New-Object System.Drawing.Size (220,16)
  $l1.Text = 'enter status message here'

  $l1.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',8,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0);

  $groupBox1 = New-Object System.Windows.Forms.GroupBox

  $groupBox1.SuspendLayout()

  $groupBox1.Controls.AddRange(@( $l1))
  $groupBox1.Location = New-Object System.Drawing.Point (8,230)
  $groupBox1.Name = 'groupBox1'
  $groupBox1.Size = New-Object System.Drawing.Size (244,32)
  $groupBox1.TabIndex = 0
  $groupBox1.TabStop = $false
  $groupBox1.Text = 'status'
  $panel2.Controls.Add($groupBox1)

  $t2 = New-Object System.Windows.Forms.TreeView
  $t2.Font = New-Object System.Drawing.Font ('Tahoma',10.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,[System.Byte]0);

  $i = New-Object System.Windows.Forms.ImageList ($components)
  $i.Images.Add([System.Drawing.SystemIcons]::Application)
  $t2.ImageList = $i
  $t2.Anchor = ((([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom) `
         -bor [System.Windows.Forms.AnchorStyles]::Left) `
       -bor [System.Windows.Forms.AnchorStyles]::Right)
  $t2.ImageIndex = -1
  $t2.Location = New-Object System.Drawing.Point (4,5)
  $t2.Name = 'treeFood'
  $t2.SelectedImageIndex = -1
  $t2.Size = New-Object System.Drawing.Size (284,224)

  $t2.AutoSize = $true
  $t2.TabIndex = 1;
  $panel2.Controls.AddRange(@( $t2))

  # http://msdn.microsoft.com/en-us/library/system.windows.forms.tabpage.visiblechanged%28v=vs.110%29.aspx
  $panel2.Add_VisibleChanged({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $t2.SuspendLayout()
      $t2.Nodes.Clear()
      $node = $t2.Nodes.Add('Source Environment')
      $server = $node.Nodes.Add('Test Server')
      $databases = $server.Nodes.Add('Databases')
      $server.Nodes.Add('DB 1')
      $server.Nodes.Add('DB 2')

      $server.Nodes.Add('Application')
      $sites = $server.Nodes.Add('IIS Web Sites')

      $sites.Nodes.Add('Site 1')
      $sites.Nodes.Add('Site 2')
      $sites.Nodes.Add('Site 3')
      $t2.ResumeLayout($false)
      $t2.PerformLayout()
    })
  $panel1.Location = New-Object System.Drawing.Point (4,22)
  $panel1.Name = 'tabPage1'
  $panel1.Padding = New-Object System.Windows.Forms.Padding (3)
  $panel1.Size = New-Object System.Drawing.Size (259,252)
  $panel1.TabIndex = 0
  $panel1.Text = 'Destination Node'

  $t1 = New-Object System.Windows.Forms.TreeView
  $t1.Font = New-Object System.Drawing.Font ('Tahoma',10.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,[System.Byte]0);

  $t1.ImageList = $i

  $t1.Anchor = ((([System.Windows.Forms.AnchorStyles]::Top `
           -bor [System.Windows.Forms.AnchorStyles]::Bottom) `
         -bor [System.Windows.Forms.AnchorStyles]::Left) `
       -bor [System.Windows.Forms.AnchorStyles]::Right)
  $t1.ImageIndex = -1
  $t1.Location = New-Object System.Drawing.Point (4,5)
  $t1.Name = 'treeFood'
  $t1.SelectedImageIndex = -1
  $t1.Size = New-Object System.Drawing.Size (284,224)

  $t1.AutoSize = $true
  $t1.TabIndex = 1;
  $panel1.Controls.AddRange(@( $t1))

  $panel1.Add_VisibleChanged({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $t1.SuspendLayout()
      $t1.Nodes.Clear()
      $node = $t1.Nodes.Add('Target Environment')
      $node.Nodes.Add('Database Server')
      $node.Nodes.Add('Application Server')
      $sites = $node.Nodes.Add('Web Server')
      $sites.Nodes.Add('Site 1')
      $sites.Nodes.Add('Site 2')
      $sites.Nodes.Add('Site 3')
      $t1.ResumeLayout($false)
      $t1.PerformLayout()
    })

  $tab_contol1.Controls.Add($panel1)
  $tab_contol1.Controls.Add($panel2)

  $tab_contol1.Location = New-Object System.Drawing.Point (13,13)
  $tab_contol1.Name = 'tabControl1'
  $tab_contol1.SelectedIndex = 1
  $tab_contol1.Size = New-Object System.Drawing.Size (267,288)
  $tab_contol1.TabIndex = 0

  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $f.ClientSize = New-Object System.Drawing.Size (292,308)
  $f.Controls.Add($tab_contol1)
  $panel2.ResumeLayout($false)
  $panel2.PerformLayout()
  $panel1.ResumeLayout($false)
  $tab_contol1.ResumeLayout($false)
  $f.ResumeLayout($false)

  $f.Topmost = $true
  $f.Add_Shown({ $f.Activate() })
  $f.KeyPreview = $True
  [void]$f.ShowDialog([win32window]($caller))

  $f.Dispose()
}

Add-Type -TypeDefinition @"
// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
  get { return _data; }
  set { _data = value; }
    }
    public string Message
    {
  get { return _message; }
  set { _message = value; }
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

$DebugPreference = 'Continue'
$title = 'Settings Transfer'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

TabsWithTreeViews -Title $title -caller $caller
# write-debug ("Message is : {0} " -f  $caller.Message )
