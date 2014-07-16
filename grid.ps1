New-Module -ScriptBlock {

  [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('System.Data') | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')  | out-null


  $f = New-Object System.Windows.Forms.Form

  $f.Text = 'how do we open these stones? '
  $f.AutoSize  = $true 

  $grid = New-Object System.Windows.Forms.DataGrid
  $grid.PreferredColumnWidth = 100 

  $grid.DataBindings.DefaultDataSourceUpdateMode = 0
  $grid.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)

  $grid.Name = 'dataGrid1'
  $grid.DataMember = ''
  $grid.TabIndex = 0
  $grid.Location = New-Object System.Drawing.Point(13,48)
  $grid.Dock = [System.Windows.Forms.DockStyle]::Fill
 
  $button = New-Object System.Windows.Forms.Button
  $button.Text = 'Open'
  $button.Dock = [System.Windows.Forms.DockStyle]::Bottom
 
  $f.Controls.Add( $button )
  $f.Controls.Add( $grid )

  
  $button.add_Click({$f.Close()})

  function Edit-Object($obj) {
    $grid.DataSource =  $obj
    $f.ShowDialog() | out-null
    $f.refresh()
    $f.dispose()
  }

Export-ModuleMember -Function Edit-Object

} | out-null
 

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

$ret = (Edit-Object $array)
}

$data = @{ 1 = @('wind',   'blows...'  ); 
           2 = @('fire',   'burns...'  );
           3 = @('water',  'falls...'  )
        }

display_result $data

