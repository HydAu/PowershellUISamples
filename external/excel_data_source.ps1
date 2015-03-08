# http://www.cosmonautdreams.com/2013/09/06/Parse-Excel-Quickly-With-Powershell.html
# for singlee column spreadsheets see also
# http://blogs.technet.com/b/heyscriptingguy/archive/2008/09/11/how-can-i-read-from-excel-without-using-excel.aspx

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
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
$data_name = 'Servers.xls'
[string]$filename = ('{0}\{1}' -f (Get-ScriptDirectory),$data_name)

$sheet_name = 'ServerList$'
[string]$oledb_provider = 'Provider=Microsoft.Jet.OLEDB.4.0'
$data_source = "Data Source = $filename"
$ext_arg = "Extended Properties=Excel 8.0"
[string]$query = "Select * from [${sheet_name}]"
[System.Data.OleDb.OleDbConnection]$connection= New-Object System.Data.OleDb.OleDbConnection("$oledb_provider;$data_source;$ext_arg")
[System.Data.OleDb.OleDbCommand]$command = New-Object System.Data.OleDb.OleDbCommand($query)


[System.Data.DataTable]$data_table = new-object System.Data.DataTable
[System.Data.OleDb.OleDbDataAdapter]$ole_db_adapter = New-Object System.Data.OleDb.OleDbDataAdapter
$ole_db_adapter.SelectCommand = $command

$command.Connection = $connection
# $sql = "Insert into [${sheet_name}] (id,name) values('5','e')"
# $sql = "Update [${sheet_name}] set name = 'New Name' where id=1";
# $command.CommandText = sql
# $command.ExecuteNonQuery()
$rows = $ole_db_adapter.Fill($data_table)
$rows | Out-Null
$connection.open()
$data_reader = $command.ExecuteReader()

$row = 1
[System.Data.DataRow]$data_record = $null 
ForEach ($data_record in $data_table) {
 
    # Reading the columns of the current row
    # $data_record | get-member
    $server_cell_value = $data_record.'server'
    $status_cell_value = $data_record.'status'
    write-host ("row:{0}`nserver={1}`nstatus={2}`n" -f $row,$server_cell_value,$status_cell_value )
    $row++
}
$data_reader.close()

$sql =  "Insert into [${sheet_name}] (server,status) values('sergueik9',2)"
$command.CommandText = $sql
$command.ExecuteNonQuery()

$sql = "UPDATE [${sheet_name}] SET [server] = @server, [status] = @status WHERE [server] = @server"
$command.Parameters.Add("@server", [System.Data.OleDb.OleDbType]::VarChar).Value = 'sergueik9'
$command.Parameters.Add("@status", [System.Data.OleDb.OleDbType]::VarChar).Value = '42'
$command.CommandText = $sql
$command.ExecuteNonQuery()

$command.Dispose()
$connection.close()
<#

$com_object=New-Object -ComObject Excel.Application
$com_object.Visible=$false
$workbook=$com_object.Workbooks.Open($data_name)
$sheet_name = 'ServerList$'
$worksheet = $workbook.sheets.item($sheet_name)
$rows_count =  ($worksheet.UsedRange.Rows).count
$col_num = 1

for($row_num = 2 ; $row_num -le $rows_count ; $row_num++)
{
  $worksheet.cells.item($row_num,$col_num).value2 | out-null
   }
$com_object.quit()

#>
