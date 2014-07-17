  $RESULT_OK = 0
  $RESULT_CANCEL = 2
  $Readable = @{ 
    $RESULT_OK = 'OK' 
    $RESULT_CANCEL = 'CANCEL'
  } 



Add-Type -TypeDefinition @"
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


function PromptGrid(
	[System.Collections.IList] $data, 
	[Object] $caller = $null 
	){

  if ($caller -eq $null ){
    $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
  }

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')  | out-null


$f = New-Object System.Windows.Forms.Form
$f.Text = 'how do we open these stones? '
$f.AutoSize  = $true 
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
$System_Drawing_Point.Y = 48 ;
$grid.Location = $System_Drawing_Point
$grid.Dock = [System.Windows.Forms.DockStyle]::Fill
 
$button = New-Object System.Windows.Forms.Button
$button.Text = 'Open'
$button.Dock = [System.Windows.Forms.DockStyle]::Bottom
 
$f.Controls.Add( $button )
$f.Controls.Add( $grid )


$button.add_Click({
# http://msdn.microsoft.com/en-us/library/system.windows.forms.datagridviewrow.cells%28v=vs.110%29.aspx
# [System.Windows.Forms.DataGridViewSelectedRowCollection]$rows = $grid.SelectedRows
# $str = ''
#[System.Windows.Forms.DataGridViewRow]$row = $null 
# 
#[System.Windows.Forms.DataGridViewSelectedCellCollection] $selected_cells = $grid.SelectedCells; 
$caller.Data =  0

# for ($counter = 0; $counter -lt ($grid.Rows.Count);$counter++) { 

$caller.Data = $caller.Data + 10 
# }
#foreach ($row in $rows) { 
#$str +=  $row.Cells[0].Value
#
#}
if ($grid.IsSelected(0)){
 $caller.Data = 11; 
} else { 
 $caller.Data = 42; 

}
 $caller.Data = $str
$f.Close()

})



$grid.DataSource =  $data
$f.ShowDialog([Win32Window ] ($caller)) | out-null

$f.Topmost = $True


$f.refresh()

} 
 

function display_result{
param ([Object] $result)

$array = New-Object System.Collections.ArrayList

foreach ($key in $result.keys){
  $value = $result[$key]
  $o = New-Object PSObject   
  $o | add-member Noteproperty 'Substance'  $value[0]
  $o | add-member Noteproperty 'Action' $value[1]
  $array.Add($o)
}

$process_window = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$ret = (PromptGrid $array $process_window)
write-output @('->', $process_window.Data) 
}

$data = @{ 1= @('wind', 'blows...'); 
           2 = @('fire',  'burns...');
           3 = @('water',  'falls...')
        }

$DebugPreference = 'Continue'

display_result $data

