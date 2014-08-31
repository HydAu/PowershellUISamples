param([string]$master_server = '',[string]$str_verbose = $false)
# [bool] $bool_verbose 
# if ()
# Load the entries from remote 
if ($master_server -eq '') {
  $master_server = $env:MASTER_NODE
}

if (($master_server -eq '') -or ($master_server -eq $null)) {
  Write-Error 'The required parameter is missing'
  exit (1)
}


New-Module -ScriptBlock {

  [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('System.Data') | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null



  $form = New-Object System.Windows.Forms.Form
  $form.AutoSize = $true
  $grid = New-Object System.Windows.Forms.DataGrid
  $grid.PreferredColumnWidth = 100

  $System_Drawing_Size = New-Object System.Drawing.Size
  #$System_Drawing_Size.Width = 640
  #$System_Drawing_Size.Height = 180
  #$grid.Size = $System_Drawing_Size
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
  $button.Text = 'Close'
  $button.Dock = [System.Windows.Forms.DockStyle]::Bottom

  $form.Controls.Add($button)
  $form.Controls.Add($grid)


  $button.add_click({ $form.Close() })

  function Edit-Object ($obj) {

    $grid.DataSource = $obj
    $form.ShowDialog() | Out-Null
    $form.Refresh()
  }

  Export-ModuleMember -Function Edit-Object
} | Out-Null

# cls


function display_result {
  param([object]$result_remote)


  $array = New-Object System.Collections.ArrayList

  foreach ($alias in $result_remote.Keys) {
    $o = New-Object PSObject
    $value = $result_remote[$alias]
    if ($value -match 'DBMSSOCN,(.+),(.+)') {
      $o | Add-Member Noteproperty 'Alias' $alias;
      $o | Add-Member Noteproperty 'Server' $matches[1];
      $o | Add-Member Noteproperty 'Port' $matches[2];
      $array.Add($o)
    }
  }
  $ret = (Edit-Object $array)

}



function read_registry_cliconfg {
  param([string]$registry_path = '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/MSSQLServer/Client/ConnectTo',[boolean]$unused_boolean_flag)

  pushd HKLM:
  cd -Path $registry_path
  # 
  $connect_to_setting = Get-Item -Path . | Where-Object { $_.Property -ne $null } | Select-Object -First 1
  $database_alias_name = $connect_to_setting.GetValueNames()
  # can be Object[] or String[] 
  if (-not ($database_alias_name.GetType().BaseType.Name -match 'Array')) {
    Write-Output 'Unexpected result type'
  }
  $results = $database_alias_name | ForEach-Object { @{ 'name' = $_; 'expression' = & { $connect_to_setting.GetValue($_) } } };

  $results_lookup = @{}
  $results | ForEach-Object { $results_lookup[$_.Name] = $_.expression }
  # Some code does not work 
  # $results_lookup | sort-object -property Name |format-table -autosize 
  # $results_lookup.Keys | sort-object | foreach-object  {write-output ("{0} `t`t`t`t{1}" -f $_, $results_lookup[$_])}
  popd
  $results_lookup


}
<# 
TODO: compare two objects 
write-output "Run locally."
#>
Write-Output "Run locally "
$step_local = read_registry_cliconfg '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/MSSQLServer/Client/ConnectTo' $true
Write-Output $step_local
# cls

Write-Output "Run remotey on ${master_server}"
$step_remote = Invoke-Command -computer $master_server -ScriptBlock ${function:read_registry_cliconfg} -ArgumentList '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/MSSQLServer/Client/ConnectTo',$true
# $step_remote =  invoke-command -computer $master_server  -ScriptBlock ${function:read_registry_cliconfg} -Authentication Credssp -ArgumentList '/HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/MSSQLServer/Client/ConnectTo', $true 
Write-Output $step_remote
# TODO: detect TC  environment
# if ($env:JENKINS_HOME -eq '') {
# 	display_result  $step_remote
# }
