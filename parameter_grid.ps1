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


function Edit_Parameters {
  param(
    [hashtable]$parameters,
    [string]$title,
    [object]$caller = $null
  )

  @( 'System.Drawing','System.ComponentModel','System.Windows.Forms','System.Data') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $f = New-Object System.Windows.Forms.Form
  $f.SuspendLayout();

  $f.Text = $title
  $f.AutoSize = $true
  $grid = New-Object System.Windows.Forms.DataGridView
  $grid.AutoSize = $true
  $grid.DataBindings.DefaultDataSourceUpdateMode = 0

  $grid.Name = 'dataGrid1'
  $grid.DataMember = ''
  $grid.TabIndex = 0
  $grid.Location = New-Object System.Drawing.Point (13,50)
  $grid.Dock = [System.Windows.Forms.DockStyle]::Fill

  $grid.ColumnCount = 2
  $grid.Columns[0].Name = 'Parameter Name'
  $grid.Columns[1].Name = 'Value'

  $parameters.Keys | ForEach-Object {
    $row1 = @( $_,$parameters[$_].ToString())
    $grid.Rows.Add($row1)
  }

  $grid.Columns[0].ReadOnly = $true;

  foreach ($row in $grid.Rows) {
    $row.cells[0].Style.BackColor = [System.Drawing.Color]::LightGray
    $row.cells[0].Style.ForeColor = [System.Drawing.Color]::White
    $row.cells[1].Style.Font = New-Object System.Drawing.Font ('Lucida Console',9)
  }

  $button = New-Object System.Windows.Forms.Button
  $button.Text = 'Run'
  $button.Dock = [System.Windows.Forms.DockStyle]::Bottom

  $f.Controls.Add($button)
  $f.Controls.Add($grid)
  $grid.ResumeLayout($false)
  $f.ResumeLayout($false)

  $button.add_click({

      foreach ($row in $grid.Rows) {
        # do not close the form if some parameters are not entered
        if (($row.cells[0].Value -ne $null -and $row.cells[0].Value -ne '') -and ($row.cells[1].Value -eq $null -or $row.cells[1].Value -eq '')) {
          $row.cells[0].Style.ForeColor = [System.Drawing.Color]::Red
          $grid.CurrentCell = $row.cells[1]
          return;
        }
      }
      # TODO: return $caller.HashData
      # write-host ( '{0} = {1}' -f $row.cells[0].Value, $row.cells[1].Value.ToString())

      $f.Close()

    })

  $f.ShowDialog($caller) | Out-Null
  $f.Topmost = $True
  $f.Refresh()
  $f.Dispose()
}

# Evaluate what name parameters were defined for run
# http://stackoverflow.com/questions/21559724/getting-all-named-parameters-from-powershell-including-empty-and-set-ones

# Get the command name
$CommandName = $PSCmdlet.MyInvocation.InvocationName

# Get the list of parameters for the command
$ParameterList = (Get-Command -Name $CommandName).Parameters
$parameters = @{}
foreach ($Parameter in $ParameterList) {
  # Grab each parameter value, using Get-Variable
  $value = Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue
}
Write-Output '...'
# Convert to Hashtable - 
$parameters = @{}
$value | ForEach-Object { $parameters[$_.Name] = $_.Value }
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
Edit_Parameters -parameters ($parameters) -caller $caller -Title 'Provide parameters: '

return


