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
    private string _script_directory;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string ScriptDirectory
    {
        get { return _script_directory; }
        set { _script_directory = value; }
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


$shared_assemblies = @(
  'DropDownTreeView.dll'
)

$shared_assemblies_folder = 'c:\developer\sergueik\csharp\SharedAssemblies'
pushd $shared_assemblies_folder
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd


# http://www.codeproject.com/Articles/14544/A-TreeView-Control-with-ComboBox-Dropdown-Nodes

function PromptTreeView
{
  param(
    [string]$title,
    [object]$caller = $null
  )

  @( 'System.Drawing','System.Collections.Generic','System.Collections','System.ComponentModel','System.Windows.Forms','System.Text','System.Data') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title
  $t = New-Object DropDownTreeView.DropDownTreeView
  $components = New-Object System.ComponentModel.Container
  $f.SuspendLayout()
  $t.Font = New-Object System.Drawing.Font ('Tahoma',10.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,[System.Byte]0)

  $i = New-Object System.Windows.Forms.ImageList ($components)
  $i.Images.Add([System.Drawing.SystemIcons]::Application)
  $script_path = $caller.ScriptDirectory
  foreach ($n in @( 1,2,3)) {
    $image_path = ('{0}\color{1}.gif' -f $script_path,$n)
    $image = [System.Drawing.Image]::FromFile($image_path)
    $i.Images.Add($image)
  }
  $t.ImageList = $i

  $t.Anchor = ((([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom) `
         -bor [System.Windows.Forms.AnchorStyles]::Left) `
       -bor [System.Windows.Forms.AnchorStyles]::Right)
  $t.ImageIndex = -1
  $t.Location = New-Object System.Drawing.Point (4,5)
  $t.Name = "treeFood"
  $t.SelectedImageIndex = -1
  $t.Size = New-Object System.Drawing.Size (284,256)
  $t.TabIndex = 1;
  $treeview_AfterSelect = $t.add_AfterSelect
  $treeview_AfterSelect.Invoke({
      param(
        [object]$sender,
        [System.Windows.Forms.TreeViewEventArgs]$eventargs
      )
      if ($eventargs.Action -eq [System.Windows.Forms.TreeViewAction]::ByMouse) {
        # [System.Windows.Forms.MessageBox]::Show($eventargs.Node.Text);
        $caller.Message += ('{0},' -f $eventargs.Node.Text)
      }
    })
  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $f.ClientSize = New-Object System.Drawing.Size (292,266)
  $f.Controls.AddRange(@( $t))
  $f.Name = 'DropDownComboboxTreeViewExample'
  $f.Text = 'DropDown Combobox TreeView Example'
  $f_Load = $f.add_Load
  $f_Load.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      [System.Windows.Forms.TreeNode]$tn1 = New-Object System.Windows.Forms.TreeNode ("Node")

      [DropDownTreeView.DropDownTreeNode]$dtn1 = New-Object DropDownTreeView.DropDownTreeNode ("Credentials")
      $dtn1.ComboBox.Items.AddRange(@( "LocalService","LocalSystem ","NetworkService"))
      $dtn1.ComboBox.SelectedIndex = 0

      [DropDownTreeView.DropDownTreeNode]$dtn2 = New-Object DropDownTreeView.DropDownTreeNode ("Install")
      $installs = @( 'Typical','Compact','Custom')
      $dtn2.ComboBox.Items.AddRange($installs)
      $dtn2.ComboBox.SelectedIndex = 0
      $handler_combobox_closed = {
        param(
          [object]$sender,
          [System.EventArgs]$eventargs
        )
        try {
          [System.Windows.Forms.ComboBox]$cb = $sender
          [System.Windows.Forms.MessageBox]::Show($cb.SelectedItem.ToString())
          # $caller.Message += ('{0},' -f $cb.SelectedItem.ToString())
        } catch [exception]{
        }
      }


      $t.Nodes.Add($tn1)
      $t.Nodes.Add($dtn2)
      $t.Nodes.Add($dtn1)

      $combobox1_DropDownClosed = $dtn1.ComboBox.add_DropDownClosed
      $combobox1_DropDownClosed.Invoke($handler_combobox_closed)

      $combobox2_DropDownClosed = $dtn2.ComboBox.add_DropDownClosed
      $combobox2_DropDownClosed.Invoke($handler_combobox_closed)

    })


  $f.ResumeLayout($false)


  $f.Name = 'Form1'
  $f.Text = 'TreeView Sample'
  $t.ResumeLayout($false)

  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $false

  $f.Topmost = $True
  if ($caller -eq $null) {
    $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
  }

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window]($caller))

  $t.Dispose()
  $f.Dispose()
  $result = $caller.Message
  $caller = $null
  return $result
}

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"))
  }
}

$DebugPreference = 'Continue'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$caller.ScriptDirectory = Get-ScriptDirectory
$result = PromptTreeView 'Items' $caller

Write-Debug ('Selection is : {0}' -f,$result)
