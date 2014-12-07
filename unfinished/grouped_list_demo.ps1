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
  [switch]$show_buttons
)

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


# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
  $invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($invocation.PSScriptRoot) {
    $invocation.PSScriptRoot
  }
  elseif ($invocation.MyCommand.Path) {
    Split-Path $invocation.MyCommand.Path
  } else {
    $invocation.InvocationName.Substring(0,$invocation.InvocationName.LastIndexOf(""))
  }
}

$shared_assemblies = @{
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = $null;
  'GroupedListControl.dll' = $null;
}

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies.Keys | ForEach-Object {
  # http://all-things-pure.blogspot.com/2009/09/assembly-version-file-version-product.html
  $assembly = $_
  $assembly_path = [System.IO.Path]::Combine($shared_assemblies_path,$assembly)
  $assembly_version = [Reflection.AssemblyName]::GetAssemblyName($assembly_path).Version
  $assembly_version_string = ('{0}.{1}' -f $assembly_version.Major,$assembly_version.Minor)
  if ($shared_assemblies[$assembly] -ne $null) {
    # http://stackoverflow.com/questions/26999510/selenium-webdriver-2-44-firefox-33
    if (-not ($shared_assemblies[$assembly] -match $assembly_version_string)) {
      Write-Output ('Need {0} {1}, got {2}' -f $assembly,$shared_assemblies[$assembly],$assembly_path)
      Write-Output $assembly_version
      throw ('invalid version :{0}' -f $assembly)
    }
  }

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd


function GroupedListBox
{
  param(
    [string]$title,
 [bool]$show_buttons)

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Generic')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Collections')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Text')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Data')

  $f = New-Object System.Windows.Forms.Form

  $f.Text = $title
  $width = 500
  $f.Size = New-Object System.Drawing.Size ($width,400)
  # http://www.codeproject.com/Articles/451742/Extending-Csharp-ListView-with-Collapsible-Groups
  # http://www.codeproject.com/Articles/451735/Extending-Csharp-ListView-with-Collapsible-Groups
  $glc = New-Object -TypeName 'GroupedListControl.GroupListControl'


  $glc.SuspendLayout()

  $glc.AutoScroll = $true
  $glc.BackColor = [System.Drawing.SystemColors]::Control
  $glc.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
  $glc.SingleItemOnlyExpansion = $false
  $glc.WrapContents = $false
  $glc.Anchor = ([System.Windows.Forms.AnchorStyles](0 `
         -bor [System.Windows.Forms.AnchorStyles]::Top `
         -bor [System.Windows.Forms.AnchorStyles]::Bottom `
         -bor [System.Windows.Forms.AnchorStyles]::Left `
         -bor [System.Windows.Forms.AnchorStyles]::Right `
      ))


  $f.SuspendLayout()

  if ($show_buttons) {
        [System.Windows.Forms.CheckBox]$cb1 = new-object -TypeName 'System.Windows.Forms.CheckBox'
        $cb1.AutoSize = $true
        $cb1.Location = new-object System.Drawing.Point(12, 52)
        $cb1.Name = "chkSingleItemOnlyMode"
        $cb1.Size = new-object System.Drawing.Size(224, 17)
        $cb1.Text = 'Single-Group toggle'
        $cb1.UseVisualStyleBackColor = $true
        function chkSingleItemOnlyMode_CheckedChanged
        {
         param([Object] $sender, [EventArgs] $e)
            $glc.SingleItemOnlyExpansion = $cb1.Checked
            if ($glc.SingleItemOnlyExpansion) {
                $glc.CollapseAll()
            } else {
                $glc.ExpandAll()
            }
        }
        $cb1.Add_CheckedChanged({ chkSingleItemOnlyMode_CheckedChanged } )
        [System.Windows.Forms.Label]$label1 = new-object -TypeName 'System.Windows.Forms.Label' 
        $label1.Location = new-object System.Drawing.Point(12, 13)
        $label1.Size = new-object System.Drawing.Size(230, 18) 
	$label1.Text = 'Grouped List Control Demo'
        # $label1.Font = new System.Drawing.Font("Lucida Sans", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)))
        [System.Windows.Forms.Button]$button1 = new-object -TypeName 'System.Windows.Forms.Button' 

            $button1.Location = new-object System.Drawing.Point(303, 46)
            $button1.Name = "button1"
            $button1.Size = new-object System.Drawing.Size(166, 23)
            $button1.TabIndex = 3
            $button1.Text = 'Add Data Items (disconnected)'
            $button1.UseVisualStyleBackColor = true
            $button1.Add_Click( { write-host $glc.GetType() 
$x =  $glc | get-member
write-host ($x -join "`n")
})
         
#        private System.Windows.Forms.Button button2;
    $f.Controls.Add($cb1)
    $f.Controls.Add($button1)
    $f.Controls.Add($label1)

    $glc.Location =  new-object System.Drawing.Point(0, 75)
    $glc.Size =  new-object  System.Drawing.Size($f.size.Width, ($f.size.Height - 75))

  } else { 
  $glc.Size = $f.Size

}

  for ($group = 1; $group -le 5; $group++)
  {
    [GroupedListControl.ListGroup]$lg = New-Object -TypeName 'GroupedListControl.ListGroup'
    $lg.Columns.Add("List Group " + $group.ToString(), 120 )
    $lg.Columns.Add("Group " + $group + " SubItem 1", 150 )
    $lg.Columns.Add("Group " + $group + " Subitem 2", 150 )
    $lg.Name = ("Group " + $group)
    # add some sample items:
    for ($j = 1; $j -le 5; $j++){
      [System.Windows.Forms.ListViewItem]$item = $lg.Items.Add(("Item " + $j.ToString()))
      $item.SubItems.Add($item.Text + " SubItem 1")
      $item.SubItems.Add($item.Text + " SubItem 2")
    }

    # Add handling for the columnRightClick Event. 
    # Note: It is unfinished in the original GroupedListBox
    #    lg.ColumnRightClick += new ListGroup.ColumnRightClickHandler(lg_ColumnRightClick)
    #    lg.MouseClick += new MouseEventHandler(lg_MouseClick)
    # TODO: http://msdn.microsoft.com/en-us/library/system.windows.forms.listview.columnclick%28v=vs.110%29.aspx
    <#
     private void ColumnClick(object o, ColumnClickEventArgs e)
        {
            // Set the ListViewItemSorter property to a new ListViewItemComparer  
            // object. Setting this property immediately sorts the  
            // ListView using the ListViewItemComparer object. 
            this.listView1.ListViewItemSorter = new ListViewItemComparer(e.Column);
        }

    #>
    $glc.Controls.Add($lg)
  }

  $f.Controls.Add($glc)
  $glc.ResumeLayout($false)

  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True

  $f.Topmost = $True

  $caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window]($caller))
  $f.Dispose()
  $result = $caller.Message
  $caller = $null
  return $result
}
$show_buttons_arg  = $false

  if ($PSBoundParameters["show_buttons"]) {
$show_buttons_arg = $true
  }
$DebugPreference = 'Continue'
GroupedListBox -Title '' -show_buttons $show_buttons_arg | Out-Null

