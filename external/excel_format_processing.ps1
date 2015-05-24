
# $DebugPreference = 'Continue'

param(
  [switch]$save,
  [switch]$pause
)
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
  }
}

function custom_pause {

  param([bool]$fullstop)
  # Do not close Excel when script is run from Powershell ISE

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }

}

function extract_match {

  param(
    [string]$source,
    [string]$capturing_match_expression,
    [string]$label,
    [System.Management.Automation.PSReference]$result_ref = ([ref]$null)

  )
  Write-Debug ('Extracting from {0}' -f $source)
  $local:results = {}
  $local:results = $source | where { $_ -match $capturing_match_expression } |
  ForEach-Object { New-Object PSObject -prop @{ Media = $matches[$label]; } }
  if ($local:results -ne $null) {
    Write-Debug 'extract_match:'
    Write-Debug $local:results
  }
  $result_ref.Value = $local:results.Media
}

function close_connections {
  #####################################################################
  # Close connections to Excel
  # set interactive to false so no save buttons are shown
  param(
    [object]$Excel)
  $Excel.DisplayAlerts = $false
  $Excel.ScreenUpdating = $false
  $Excel.Visible = $false
  $Excel.UserControl = $false
  $Excel.Interactive = $false

}

function release_com_object {
  ## close all com objects
  param([object]$com_object_ref)
  [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$com_object_ref) -gt 0)
  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
}

function read_cell_color {
# Formatting Text / Numbers Colours
# http://theolddogscriptingblog.wordpress.com/2009/08/04/adding-color-to-excel-the-powershell-way/
# 
param(
[object]$ExcelWorkSheet,
$test_column = 6
)
$update_column = 7
for ($row = 1; $row -lt $rows; $row++) {
 # Read Cell attribute
  write-output $ExcelWorkSheet.Cells.item($row,$test_column).Font.ColorIndex 
  #####################################################################
  # Read Cell
  $cell_text = $ExcelWorkSheet.Cells.item($row,$test_column).Text
  $cell_value2 =  $ExcelWorkSheet.Cells.item($row,$test_column).Value2
  write-output $cell_text
#####################################################################
# Update / Insert / Delete Value in a Cell
$ExcelWorkSheet.Cells.item($row,$update_column ).Value2 = "New Value"


}
}


$shared_assemblies = @(
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd


# http://blogs.technet.com/b/heyscriptingguy/archive/2014/09/14/weekend-scripter-manipulating-word-and-excel-with-powershell.aspx

$ExcelPath = ('{0}\{1}' -f (Get-ScriptDirectory),'TestConfiguration.xlsx')
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Excel.DisplayAlerts = $False

#####################################################################
## Load Excel  file
$sheet_name = 'TestConfiguration'
$ExcelWordBook = $Excel.Workbooks.Open($ExcelPath)
#####################################################################
# Change to a different Worksheet
$ExcelWorkSheet = $Excel.WorkSheets.item($sheet_name)

#####################################################################
# Find Last Used Column or Row
$columns = $ExcelWorkSheet.UsedRange.columns.count
$rows = $ExcelWorkSheet.UsedRange.rows.count

read_cell_color $ExcelWorkSheet
#####################################################################
# Auto-Sizing Columns / Rows
[void]$ExcelWorkSheet.Cells.EntireColumn.Autofit()


#####################################################################
# Clear all formatting on a sheet
$tableRange = $ExcelWorkSheet.UsedRange
$tableRange.ClearFormats()
# read_cell_color $ExcelWorkSheet

if (($PSBoundParameters['save']).IsPresent) {
  ## save the workbook
  ## Exception calling "Save" with "0" argument(s): "Exception from HRESULT: 0x800A03EC"
  $ExcelWordBook.Save()
}

## quit the workbook
$Excel.Quit()
close_connections $Excel
## close all object references
release_com_object $ExcelWorkSheet
release_com_object $ExcelWordBook
release_com_object $Excel
custom_pause
return

#####################################################################
# Open New Excel Workbook / WorkSheet
# $ExcelWordBook = $Excel.Workbooks.Add()
# $ExcelWorkSheet = $ExcelWordBook.WorkSheets.Add()
# $ExcelWorkSheet = $Excel.WorkSheets.item("Sheet 2")


#####################################################################
# Delete Row / Column
# [void]$ExcelWorkSheet.Cells.item(1,1).EntireColumn.Delete()
# [void]$ExcelWorkSheet.Cells.item(1,1).EntireRow.Delete()


#####################################################################
# Sorting
# $table = $ExcelWorkSheet.ListObjects | where DisplayName -EQ "User_Table"
# $table.Sort.SortFields.clear()
# $table.Sort.SortFields.Add($table.Range.columns.item(1))
# $table.Sort.apply()


#####################################################################
# Using Excel Table Styles
## formatting http://activelydirect.blogspot.co.uk/2011/03/write-excel-spreadsheets-fast-in.html
#
# $listObject = $ExcelWorkSheet.ListObjects.Add([Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange,$ExcelWorkSheet.UsedRange,$null,[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes,$null)
# $listObject.Name = "User Table"
# $listObject.TableStyle = "TableStyleLight10"

#####################################################################
# Formatting a Column
# $ExcelWorkSheet.columns.item($formatcolNum).NumberFormat = "yyyy/mm/dd"

#####################################################################
# Format Text / Numbers Bold
# $ExcelWorkSheet.Cells.item(1,1).Font.Bold = $True

#####################################################################
# Add Hyperlink to cell
# $link = "http://www.microsoft.com/technet/scriptcenter"
# $r = $ExcelWorkSheet.Range("A2")
# [void]$ExcelWorkSheet.Hyperlinks.Add($r,$link)

#####################################################################
# Add Comment to Cell
# $ExcelWorkSheet.Range("D2").AddComment("Autor Name: `rThis is my comment")

#####################################################################
# Add a Picture to a Comment
# $image = "C:\test\Pictures\Kittys\gotyou.jpg"
# $ExcelWorkSheet.Range("C1").AddComment()
# $ExcelWorkSheet.Range("d3").Comment.Shape.Fill.UserPicture($image)

#####################################################################
# Fix Location and Size of comment
# $ExcelWorkSheet.Range("D3").Comment.Shape.Left = 100
# $ExcelWorkSheet.Range("D3").Comment.Shape.Top = 100
# $ExcelWorkSheet.Range("D3").Comment.Shape.Width = 100
# $ExcelWorkSheet.Range("D3").Comment.Shape.Height = 100

#####################################################################
# Making a Comment/s visible
# $comments = $ExcelWorkSheet.comments
# foreach ($c in $comments) {
#   $c.Visible = 1
# }

#####################################################################
# Add a Formula
# $formula = "=8*8"
# $ExcelWorkSheet.Cells.item(1,1).Formula = $formula

