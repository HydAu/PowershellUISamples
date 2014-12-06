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

$shared_assemblies = @{ 
  'nunit.core.dll' = $null;
  'nunit.framework.dll' = $null;
  'GroupedListControl.dll' = $null ;
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
     Param(
	[String] $title, 
	[String] $message)

  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Generic') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Text') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Data') 

  $f = New-Object System.Windows.Forms.Form 

  $f.Text = $title
  $width = 700
  $f.Size = New-Object System.Drawing.Size ($width,400)
  $f.SuspendLayout()

if ($PSBoundParameters["show_buttons"]) {
  try {
} catch [Exception] { 
}
}

// http://www.codeproject.com/Articles/451742/Extending-Csharp-ListView-with-Collapsible-Groups
// http://www.codeproject.com/Articles/451735/Extending-Csharp-ListView-with-Collapsible-Groups
$glc = new-object -TypeName 'GroupedListControl.GroupListControl'
$glc.SuspendLayout()
$glc.Size=$f.Size
$glc.Anchor = ([System.Windows.Forms.AnchorStyles]( 0 `
    -bor [System.Windows.Forms.AnchorStyles]::Top     `
    -bor [System.Windows.Forms.AnchorStyles]::Bottom  `
    -bor [System.Windows.Forms.AnchorStyles]::Left    `
    -bor [System.Windows.Forms.AnchorStyles]::Right   `
))

<#
            glc.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                | System.Windows.Forms.AnchorStyles.Left)
                | System.Windows.Forms.AnchorStyles.Right)))
  #>          
            for($i = 1; $i -le 5; $i++)
            {
                [GroupedListControl.ListGroup]$lg = new-object  -TypeName 'GroupedListControl.ListGroup'
                $lg.Columns.Add("List Group " + $i.ToString(), 120)
                $lg.Columns.Add("Group " + $i + " SubItem 1", 150)
                $lg.Columns.Add("Group " + $i + " Subitem 2", 150)
                $lg.Name = ( "Group " + $i )
            # add some sample items:
            for($j = 1; $j -le 5; $j++)
                {
                    [System.Windows.Forms.ListViewItem]$item = $lg.Items.Add(("Item " + $j.ToString()))
                    $item.SubItems.Add($item.Text + " SubItem 1")
                    $item.SubItems.Add($item.Text + " SubItem 2")
                }

            # Add handling for the columnRightClick Event
            #    lg.ColumnRightClick += new ListGroup.ColumnRightClickHandler(lg_ColumnRightClick)
            #    lg.MouseClick += new MouseEventHandler(lg_MouseClick)

                $glc.Controls.Add($lg)
}

  $f.Controls.Add($glc)
  $glc.ResumeLayout($false)

  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True

  $f.Topmost = $True

  $caller = New-Object -typeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

  $f.Add_Shown( { $f.Activate() } )

  [Void] $f.ShowDialog([Win32Window] ($caller) )
  $f.Dispose()
  $result = $caller.Message
  $caller = $null
  return $result
}

$DebugPreference = 'Continue'
[void]GroupedListBox ''  ''
