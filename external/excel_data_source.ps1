#Copyright (c) 2015 Serguei Kouzmine
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


# http://tech.pro/tutorial/803/csharp-tutorial-using-the-built-in-oledb-csv-parser
# http://www.codeproject.com/Articles/27802/Using-OleDb-to-Import-Text-Files-tab-CSV-custom
# http://www.cosmonautdreams.com/2013/09/06/Parse-Excel-Quickly-With-Powershell.html
# for singlee column spreadsheets see also
# http://blogs.technet.com/b/heyscriptingguy/archive/2008/09/11/how-can-i-read-from-excel-without-using-excel.aspx

param(
[string]$format = 'excel',
  [switch]$pause,
  [switch]$show

)
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


function initialize_data_reader {
  param(

    [string]$data_name,
    [string]$sheet_name,
    [string]$query ,
    [System.Management.Automation.PSReference]$connection_ref,
    [System.Management.Automation.PSReference]$command_ref,
    [System.Management.Automation.PSReference]$data_table_ref,
    [System.Management.Automation.PSReference]$data_reader_ref,
    [bool]$debug

)


[string]$filename = ('{0}\{1}' -f (Get-ScriptDirectory),$data_name)


[string]$oledb_provider = 'Provider=Microsoft.Jet.OLEDB.4.0'
$data_source = "Data Source = $filename"
$ext_arg = "Extended Properties=Excel 8.0"

if ($false) {
# $ext_arg = "Extended Properties='text;HDR=Yes;FMT=Delimited(,)';"
# $sheet_name = $data_name
}
[string]$query = "Select * from [${sheet_name}] WHERE ISNULL(guid)"
# $x = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=`"C:\developer\sergueik\powershell_ui_samples\external`";Extended Properties='text;HDR=Yes;FMT=Delimited(,)';"
# [System.Data.OleDb.OleDbConnection]$local:connection = New-Object System.Data.OleDb.OleDbConnection ($x)

[System.Data.OleDb.OleDbConnection]$local:connection = New-Object System.Data.OleDb.OleDbConnection ("$oledb_provider;$data_source;$ext_arg")
[System.Data.OleDb.OleDbCommand]$local:command = New-Object System.Data.OleDb.OleDbCommand ($query)


[System.Data.DataTable]$local:data_table = New-Object System.Data.DataTable
[System.Data.OleDb.OleDbDataAdapter]$ole_db_adapter = New-Object System.Data.OleDb.OleDbDataAdapter
$ole_db_adapter.SelectCommand = $local:command

$local:command.Connection = $connection

$rows = $ole_db_adapter.Fill($local:data_table)

<#
Exception calling "Fill" with "1" argument(s): "The connection for viewing your linked Microsoft Excel worksheet was lost."
#>

$rows | Out-Null
$local:connection.open()
$local:data_reader = $local:command.ExecuteReader()

  $data_reader_ref.value =  ([System.Data.OleDb.OleDbDataReader]$local:data_reader)
  $data_table_ref.value = $local:data_table
  $connection_ref.value = $local:connection 
  $command_ref.value = $local:command

} 

$command = New-Object System.Data.OleDb.OleDbCommand
$conection =  New-Object System.Data.OleDb.OleDbConnection 
$data_reader  = [Object]

$data_name = 'TestConfiguration.xls'
# $data_name = 'Servers.csv'
$sheet_name = 'TestConfiguration$'
$data_table = New-Object System.Data.DataTable
initialize_data_reader -data_name $data_name -sheet_name $sheet_name -connection_ref ([ref]$connection) -data_reade_ref ([ref]$data_reade) -command_ref ([ref]$command) -data_table_ref ([ref]$data_table)




$row_num = 1
[System.Data.DataRow]$data_record = $null
foreach ($data_record in $data_table) {

  # Reading the columns of the current row
  Write-Host ("row:{0}" -f $row_num)
  $row_data = @{
    'id' = $null;
    'server' = $null;
    'date' = $null;
    'done' = $null;
    'route' = $null;
    'booking_url' = $null;
    'port' = $null;
    'destination' = $null; 
    'guid' = $null;
  }

  # Method invocation failed because [System.Collections.Hashtable+KeyCollection] doesn't contain a method named 'Clone'.

  [string[]]($row_data.Keys) | ForEach-Object {
    $cell_name = $_
    $cell_value = $data_record."${cell_name}"
    $row_data[$cell_name] = $cell_value
  }
  Write-Output ("row:{0}" -f $row)

  $row_data | format-table -autosize 
  Write-Output "`n"
  $row_num++
}

([System.Data.OleDb.OleDbDataReader]$data_reader).close()
return

function insert_row_new {
  param(
    [string]$sql,
    # [ref]$connection does not work here
    # [System.Management.Automation.PSReference]$connection_ref,
    [System.Data.OleDb.OleDbConnection]$connection,
    [System.Collections.Hashtable]$new_row_data

  )

  [string[]]$columns = [string[]]($row_data.Keys)

  [System.Data.OleDb.OleDbCommand]$local:command = New-Object System.Data.OleDb.OleDbCommand
  $local:command.Connection = $connection

  $local:insert_name_part = @()
  $local:insert_value_part = @()

  $columns | ForEach-Object {
    $column_name = $_
    $column_data = $new_row_data[$column_name]
    $local:command.Parameters.Add(('@{0}' -f $column_name),$column_data['type']).Value = $column_data['value']
    Write-Output ('@{0} = {1}' -f $column_name,$column_data['value'])
    $local:insert_name_part += ('[{0}]' -f $column_name)
    $local:insert_value_part += ('@{0}' -f $column_name)
  }

  $local:generated_sql = (($sql -replace '@insert_name_part',($local:insert_name_part -join ',')) -replace '@insert_value_part',($local:insert_value_part -join ','))

  Write-Output ('Insert query: {0}' -f $local:generated_sql)

  $new_row_data.Keys | ForEach-Object {
    $column_name = $_
    $column_data = $new_row_data[$column_name]
    Write-Output ('@{0} = {1}' -f $column_name,$column_data['value'])
  }
  $local:command.CommandText = $local:generated_sql

  $local:result = $local:command.ExecuteNonQuery()

  Write-Output ('Insert result: {0}' -f $local:result)

  $local:command.Dispose()

  return $local:result

}


function update_single_field {
  param(
    [string]$sql,
    # [ref]$connection does not seem to work here
    # [System.Management.Automation.PSReference]$connection_ref,
    [System.Data.OleDb.OleDbConnection]$connection,
    [string]$where_column_name,
    [object]$where_column_value,
    [string]$update_column_name,
    [object]$update_column_value,
    [System.Management.Automation.PSReference]$update_column_type_ref = ([ref][System.Data.OleDb.OleDbType]::VarChar),
    [System.Management.Automation.PSReference]$where_column_type_ref = ([ref][System.Data.OleDb.OleDbType]::Numeric)
  )

  [System.Data.OleDb.OleDbCommand]$local:command = New-Object System.Data.OleDb.OleDbCommand
  $local:command.Connection = $connection

  $local:command.Parameters.Add($update_column_name,$update_column_type_ref.Value).Value = $update_column_value
  $local:command.Parameters.Add($where_column_name,$where_column_type_ref.Value).Value = $where_column_value
  $local:command.CommandText = $sql

  # TODO: Exception calling "Prepare" with "0" argument(s): "OleDbCommand.Prepare method requires all variable length parameters to have an explicitly set non-zero Size."
  # $command.Prepare()

  $local:result = $local:command.ExecuteNonQuery()
  Write-Output ('Update query: {0}' -f (($sql -replace $update_column_name,$update_column_value) -replace $where_column_name,$where_column_value))
  Write-Output ('Update result: {0}' -f $local:result)

  $local:command.Dispose()

  return $local:result

}

update_single_field `
   -connection $connection `
   -sql "UPDATE [${sheet_name}] SET [server] = @server WHERE [id] = @id" `
   -update_column_name '@server' `
   -update_column_value 'sergueik11' `
   -where_column_name '@id' `
   -where_column_value 11

$new_record_id = 11
$new_guid = $guid = [guid]::NewGuid()

$sql = "Insert into [${sheet_name}] ([id],[server],[status],[result],[date],[guid]) values($new_record_id, 'sergueik9','True',42,'3/8/2015 4:00:00 PM', '${new_guid}')"
$command.CommandText = $sql
$result = $command.ExecuteNonQuery()

Write-Output ('Insert result: {0}' -f $result)

# TODO : multiple columns
# $sql = "UPDATE [${sheet_name}] SET [server] = @server, [status] = @status, [result] = @result , [guid]  = '@guid' WHERE [id] = @id"

update_single_field `
   -connection $connection `
   -sql "UPDATE [${sheet_name}] SET [guid] = @guid WHERE [id] = @id" `
   -update_column_name '@guid' `
   -update_column_value ([guid]::NewGuid()).ToString() `
   -where_column_name '@id' `
   -where_column_value 1

update_single_field `
   -connection $connection `
   -sql "UPDATE [${sheet_name}] SET [guid] = @guid WHERE [id] = @id" `
   -update_column_name '@guid' `
   -update_column_value ([guid]::NewGuid()).ToString()`
   -where_column_name '@id' `
   -where_column_value 2


update_single_field `
   -connection $connection `
   -sql "UPDATE [${sheet_name}] SET [status] = @status WHERE [id] = @id" `
   -update_column_name "@status" `
   -update_column_value $false `
   -update_column_type_ref ([ref][System.Data.OleDb.OleDbType]::Boolean) `
   -where_column_name '@id' `
   -where_column_value 2


update_single_field `
   -connection $connection `
   -sql "UPDATE [${sheet_name}] SET [id] = @id WHERE [server] = @server" `
   -where_column_name '@server' -where_column_value 'sergueik11' `
   -update_column_name '@id' -update_column_value 11 `
   -where_column_type_ref ([ref][System.Data.OleDb.OleDbType]::VarChar)

update_single_field `
   -connection $connection `
   -sql "UPDATE [${sheet_name}] SET [id] = @id WHERE [guid] = @guid" `
   -where_column_name '@guid' `
   -where_column_value '86eb4a11-64b9-4f58-aad7-0b82bc984253' `
   -where_column_type_ref ([ref][System.Data.OleDb.OleDbType]::VarChar) `
   -update_column_name '@id' `
   -update_column_value 2 `


$row_num = 14
$new_row_data = @{
  'id' = @{
    'value' = $row_num;
    'type' = [System.Data.OleDb.OleDbType]::Numeric;
  };
  'date' = @{
    'value' = '3/8/2015 4:00:00 PM';
    'type' = [System.Data.OleDb.OleDbType]::VarChar;
  };
  'result' = @{
    'value' = 456;
    'type' = [System.Data.OleDb.OleDbType]::Numeric;
  };
  'status' = @{
    'value' = $true;
    'type' = [System.Data.OleDb.OleDbType]::Boolean;
  };

  'guid' = @{
    'value' = ([guid]::NewGuid()).ToString();
    'type' = [System.Data.OleDb.OleDbType]::VarChar;
  };

  'server' = @{
    'value' = 'sergueik43';
    'type' = [System.Data.OleDb.OleDbType]::VarChar;
  };

}

insert_row_new `
   -connection $connection `
   -sql "Insert into [${sheet_name}] (@insert_name_part) values (@insert_value_part)" `
   -new_row_data $new_row_data


$new_row_data['id']['value']++

insert_row_new `
   -connection $connection `
   -sql "Insert into [${sheet_name}] (@insert_name_part) values (@insert_value_part)" `
   -new_row_data $new_row_data

$command.Dispose()

$connection.close()
<#
# If Office is present on the computer the following may be tested.
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

<#

using System;
using System.Data;
using System.IO;
using System.Data.OleDb;
public class Excel_Data
{

    public static void Main(string[] args)
    {
        ImportCsvFile(args[0]);
    }

    public static void ImportCsvFile(string filename)
    {
        FileInfo file = new FileInfo(filename);
        String x = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\"" +
                file.DirectoryName + "\";" +
                "Extended Properties='text;HDR=Yes;FMT=Delimited(,)';";
        Console.WriteLine(x);
        using (OleDbConnection con =
               new OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=\"" +
               file.DirectoryName + "\";" +
               "Extended Properties='text;HDR=Yes;FMT=Delimited(,)';"))
        {
            using (OleDbCommand cmd = new OleDbCommand(string.Format
                                      ("SELECT * FROM [{0}]", file.Name), con))
            {
                con.Open();

                // Using a DataReader to process the data
                using (OleDbDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        // Process the current reader entry...
                    }
                }

                // Using a DataTable to process the data
                using (OleDbDataAdapter adp = new OleDbDataAdapter(cmd))
                {
                    DataTable tbl = new DataTable("MyTable");
                    adp.Fill(tbl);

                    foreach (DataRow row in tbl.Rows)
                    {
                        // Process the current row...
                    }
                }
            }
        }
    }
}
#>
