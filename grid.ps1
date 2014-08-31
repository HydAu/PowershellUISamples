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

$RESULT_OK = 0
$RESULT_CANCEL = 2
$Readable = @{
  $RESULT_OK = 'OK'
  $RESULT_CANCEL = 'CANCEL'
}



Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
// inline callback class 
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


New-Module -ScriptBlock {

  [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('System.Data') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null


  $f = New-Object System.Windows.Forms.Form
  $f.Text = 'how do we open these stones? '
  $f.AutoSize = $true
  $grid = New-Object System.Windows.Forms.DataGrid
  $grid.PreferredColumnWidth = 100

  $System_Drawing_Size = New-Object System.Drawing.Size
  $grid.DataBindings.DefaultDataSourceUpdateMode = 0
  $grid.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)

  $grid.Name = "dataGrid1"
  $grid.DataMember = ''
  $grid.TabIndex = 0
  $System_Drawing_Point = New-Object System.Drawing.Point
  $System_Drawing_Point.X = 13;
  $System_Drawing_Point.Y = 48;
  $grid.Location = $System_Drawing_Point
  $grid.Dock = [System.Windows.Forms.DockStyle]::Fill

  $button = New-Object System.Windows.Forms.Button
  $button.Text = 'Open'
  $button.Dock = [System.Windows.Forms.DockStyle]::Bottom

  $f.Controls.Add($button)
  $f.Controls.Add($grid)


  $button.add_click({
      #  http://msdn.microsoft.com/en-us/library/system.windows.forms.datagrid.isselected%28v=vs.110%29.aspx
      if ($grid.IsSelected(0)) {
        $caller.Data = 1;
      }
      $f.Close()

    })

  function Edit-Object ([object]$obj,[object]$caller) {



    if ($caller -eq $null) {
      Write-Output '.'
      $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
    } else {
      Write-Output '?'
    }


    $grid.DataSource = $obj
    $f.ShowDialog() | Out-Null

    $f.Topmost = $True


    $f.Refresh()
  }

  Export-ModuleMember -Function Edit-Object
  Export-ModuleMember -Variable caller

} | Out-Null


function display_result {
  param([object]$result)

  $array = New-Object System.Collections.ArrayList

  foreach ($key in $result.Keys) {
    $value = $result[$key]
    $o = New-Object PSObject
    $o | Add-Member Noteproperty 'Substance' $value[0]
    $o | Add-Member Noteproperty 'Action' $value[1]
    $array.Add($o)
  }

  $caller = $null
  $ret = (Edit-Object $array $caller)
  Write-Output @( '->',$caller.Handle)
}

$data = @{ 1 = @( 'wind','blows...');
  2 = @( 'fire','burns...');
  3 = @( 'water','falls...')
}

display_result $data

