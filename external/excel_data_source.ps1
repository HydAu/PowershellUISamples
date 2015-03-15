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
[string]$query = "Select * from [${sheet_name}] where [id] = 4"
[System.Data.OleDb.OleDbConnection]$connection = New-Object System.Data.OleDb.OleDbConnection ("$oledb_provider;$data_source;$ext_arg")
[System.Data.OleDb.OleDbCommand]$command = New-Object System.Data.OleDb.OleDbCommand ($query)


[System.Data.DataTable]$data_table = New-Object System.Data.DataTable
[System.Data.OleDb.OleDbDataAdapter]$ole_db_adapter = New-Object System.Data.OleDb.OleDbDataAdapter
$ole_db_adapter.SelectCommand = $command

$command.Connection = $connection
$rows = $ole_db_adapter.Fill($data_table)
$rows | Out-Null
$connection.open()
$data_reader = $command.ExecuteReader()

$row_num = 1
[System.Data.DataRow]$data_record = $null
foreach ($data_record in $data_table) {
$data_record 
  # Reading the columns of the current row
  Write-Host ("row:{0}" -f $row_num)
  $row_data = @{
    'id' = $null;
    'server' = $null;
    'status' = $null;
    'date' = $null;
    'result' = $null;
    'guid' = $null;
  }
  #
  # $row_data_keys = New-Object object[] ($row_data.Keys.Count)
  # [System.Array]::copy(($row_data.Keys),$row_data_keys,$row_data.Keys.Count)
  # Cannot find an overload for "Copy" and the argument count: "3".
  # 
  # $row_data_keys = ($row_data.Keys).Clone()
  # Method invocation failed because [System.Collections.Hashtable+KeyCollection] doesn't contain a method named 'Clone'.
  $row_data_keys = [String[]]($row_data.Keys)
  $row_data_keys | ForEach-Object {
    # An error occurred while enumerating through a collection: Collection was
    # modified; enumeration operation may not execute..
    $cell_name = $_
    $cell_value = $data_record."${cell_name}"
    $row_data[$cell_name] = $cell_value
  }
  Write-Output ("row:{0}" -f $row)
  $row_data
  <#
 $result = @()
 $row_data_keys | foreach-object {
 $key_name = $_
 $result += ( '{0}="{1}"' -f $key_name, $row_data[$key_name] )
 }

 Write-Output ("row:{0}`n{1}`n" -f $row,[System.String]::Join("`r`n", $result))
 #>
  Write-Output "`n"
  $row_num++
}


$data_reader.close()

function update_fields  {  
param (
    [string]$sql ,
    # [ref]$connection does not work here
    # [System.Management.Automation.PSReference]$connection_ref,
    [System.Data.OleDb.OleDbConnection]$connection,
    [String]$where_column_name,
    [Object]$where_column_value,
    [String]$update_column_name,
    [Object]$update_column_value,
    [System.Management.Automation.PSReference]$update_column_type_ref = ([ref] [System.Data.OleDb.OleDbType]::VarChar) ,
    [System.Management.Automation.PSReference]$where_column_type_ref = ([ref] [System.Data.OleDb.OleDbType]::Numeric ) 
 

)

[System.Data.OleDb.OleDbCommand]$local:command = New-Object System.Data.OleDb.OleDbCommand
$local:command.Connection = $connection

$local:command.Parameters.Add($update_column_name,$update_column_type_ref.Value).Value = $update_column_value
$local:command.Parameters.Add($where_column_name,$where_column_type_ref.Value).Value = $where_column_value
$local:command.CommandText = $sql

# Exception calling "Prepare" with "0" argument(s): "OleDbCommand.Prepare method requires all variable length parameters to have an explicitly set non-zero Size."
# $command.Prepare()

$local:result = $local:command.ExecuteNonQuery()
Write-Output ('Update query: {0}' -f (($sql -replace $update_column_name, $update_column_value) -replace $where_column_name, $where_column_value ))
Write-Output ('Update result: {0}' -f $local:result)

$local:command.Dispose()

return

}


update_fields  -connection $connection -sql "UPDATE [${sheet_name}] SET [server] = @server WHERE [id] = @id" -update_column_name '@server' -update_column_value 'sergueik11' -where_column_name '@id' -where_column_value 11 

$new_record_id  = 11
$new_guid = $guid = [guid]::NewGuid()

$sql = "Insert into [${sheet_name}] ([id],[server],[status],[result],[date],[guid]) values($new_record_id, 'sergueik9','True',42,'3/8/2015 4:00:00 PM', '${new_guid}')"
$command.CommandText = $sql
$result = $command.ExecuteNonQuery()

Write-Output ('Insert result: {0}' -f $result)

# $sql = "UPDATE [${sheet_name}] SET [server] = @server, [status] = @status, [result] = @result , [guid]  = '@guid' WHERE [id] = @id"
# $sql = "UPDATE [${sheet_name}] SET [server] = @server, [status] = @status, [result] = @result WHERE [server] = @server"

update_fields -connection $connection -sql "UPDATE [${sheet_name}] SET [guid] = @guid WHERE [id] = @id" -update_column_name '@guid' -update_column_value (([guid]::NewGuid()).ToString()) -where_column_name '@id' -where_column_value 1 
update_fields -connection $connection -sql "UPDATE [${sheet_name}] SET [guid] = @guid WHERE [id] = @id" -update_column_name '@guid' -update_column_value '86eb4a11-64b9-4f58-aad7-0b82bc984253' -where_column_name '@id' -where_column_value 2 
update_fields -connection $connection -sql "UPDATE [${sheet_name}] SET [status] = @status WHERE [id] = @id" -update_column_name "@status" -update_column_value $false -update_column_type_ref ([ref] [System.Data.OleDb.OleDbType]::Boolean ) -where_column_name '@id' -where_column_value 2


update_fields  -connection $connection -sql "UPDATE [${sheet_name}] SET [id] = @id WHERE [server] = @server" -where_column_name '@server' -where_column_value 'sergueik11' -update_column_name '@id' -update_column_value 11  -where_column_type_ref  ([ref] [System.Data.OleDb.OleDbType]::VarChar) 



update_fields -connection $connection `
-sql "UPDATE [${sheet_name}] SET [id] = @id WHERE [guid] = @guid" `
-where_column_name '@guid' `
-where_column_value '86eb4a11-64b9-4f58-aad7-0b82bc984253' `
-where_column_type_ref  ([ref] [System.Data.OleDb.OleDbType]::VarChar)  `
-update_column_name '@id' `
-update_column_value 2 `

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


