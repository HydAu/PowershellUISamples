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


 
function Edit_Parameters {
     Param(
	[Hashtable] $parameters,
        [String] $title,
	[Object] $caller= $null
    )

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')  | out-null


$f = New-Object System.Windows.Forms.Form
$f.Text = $title
$f.AutoSize  = $true 
$grid = New-Object System.Windows.Forms.DataGridView

$System_Drawing_Size = New-Object System.Drawing.Size
$grid.DataBindings.DefaultDataSourceUpdateMode = 0

$grid.Name = "dataGrid1"
$grid.DataMember = ''
$grid.TabIndex = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 13;
$System_Drawing_Point.Y = 48 ;
$grid.Location = $System_Drawing_Point
$grid.Dock = [System.Windows.Forms.DockStyle]::Fill

            $grid.ColumnCount = 2;
            $grid.Columns[0].Name = "Parameter Name";
            $grid.Columns[1].Name = "Value";
<#

            $grid.Columns[0].Name = "Parameter Name";
            $grid.Columns[1].Name = "Value";
            $row1 = @( "Number", 1000 );
            $grid.Rows.Add($row1);
            $row2 = @(  "String", "2000" );
            $grid.Rows.Add($row2);
            $row3 = @(  "String", "Product 3" );
            $grid.Rows.Add($row3);
            $row4 = @( "Boolean", $true );
            $grid.Rows.Add($row4);
#>

$p.Keys | foreach-object {
            $row1 = @( $_,  $p[$_]);
            $grid.Rows.Add($row1);
}

            $grid.Columns[0].ReadOnly = $true;

  foreach ($row in $grid.Rows){
             $row.cells[0].Style.BackColor = [System.Drawing.Color]::LightGray 
             $row.cells[0].Style.ForeColor = [System.Drawing.Color]::White
             $row.cells[1].Style.Font = New-Object System.Drawing.Font('Lucida Console', 9)
      }

$button = New-Object System.Windows.Forms.Button
$button.Text = 'Run'
$button.Dock = [System.Windows.Forms.DockStyle]::Bottom
 
$f.Controls.Add( $button )
$f.Controls.Add( $grid )


$button.add_Click({

  foreach ($row in $grid.Rows){

    if (($row.cells[0].Value -ne $null -and $row.cells[0].Value -ne '' ) -and ($row.cells[1].Value -eq $null -or $row.cells[1].Value -eq '')) { 
             $row.cells[0].Style.ForeColor = [System.Drawing.Color]::Red 
             $grid.CurrentCell  = $row.cells[1]
      return;
    }
    write-host ( '{0} = {1}' -f $row.cells[0].Value, $row.cells[1].Value)
}
$f.Close()

})

$f.ShowDialog() | out-null
$f.Topmost = $True
$f.refresh()
$f.Dispose()
} 

function test {
    [CmdletBinding()]
    param (
        [string] $string_param1 = '' , 
        [string] $string_param2 = '' , 
        [string] $string_param3 = '' , 
        [boolean] $boolean_param = $false,
        [int] $int_param
    )
    # Get the command name
    # http://stackoverflow.com/questions/21559724/getting-all-named-parameters-from-powershell-including-empty-and-set-ones
    $CommandName = $PSCmdlet.MyInvocation.InvocationName;
    # Get the list of parameters for the command
    $ParameterList = (Get-Command -Name $CommandName).Parameters;
    $parameters = @{}
    # Grab each parameter value, using Get-Variable
    foreach ($Parameter in $ParameterList) {

      $value = Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue;

    }

 $p = @{ }
 $value | foreach-object {$p[$_.Name] = $_.Value } 
 # $p.Keys | foreach-object {write-output ("{0} = '{1}'" -f   $_, $p[$_])}
 $p.GetType().Name
 Edit_Parameters -parameters ($p) -caller $caller -title  'Enter options: '
}

 $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

test -boolean_param $true -string_param1 'this' -string_param3 'test' -int_param 42
return


