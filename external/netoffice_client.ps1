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

# https://github.com/NetOfficeFw/NetOffice

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
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}




$shared_assemblies = @(
  'ExcelApi.dll',
  'OfficeApi.dll',
  'VBIDEApi.dll',
  'NetOffice.dll'
)
$DebugPreference = 'Continue';
$shared_assemblies_path = ('{0}\SharedAssemblies' -f (Get-ScriptDirectory))

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

Write-Output 'Start Excel and turn off msg boxes'
[NetOffice.ExcelApi.Application]$excel = New-Object NetOffice.ExcelApi.Application
$excel.DisplayAlerts = $false

Write-Output 'Add a new workbook'
[NetOffice.ExcelApi.Workbook]$workBook = $excel.Workbooks.Add()
[NetOffice.ExcelApi.Worksheet]$workSheet = [NetOffice.ExcelApi.Worksheet]$workBook.Worksheets[1]

## Get-Member : The member "Caller" is already present.
## ([System.Reflection.Assembly]::LoadWithPartialName('ExcelApi')).GetExportedTypes()
## ([System.Reflection.Assembly]::Load("C:\developer\sergueik\powershell_ui_samples\external\netoffice\sharedassemblies\ExcelApi.dll").GetExportedTypes()

Add-Type -TypeDefinition @"
using System;
using System.Drawing;
namespace ExcelExamples
{
    public class Example
    {
        public static double ToDouble(System.Drawing.Color color)
        {
            uint returnValue = color.B;
            returnValue = returnValue << 8;
            returnValue += color.G;
            returnValue = returnValue << 8;
            returnValue += color.R;
            return returnValue;
        }

    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'
function GetDefaultExtension {
  param(
   [NetOffice.ExcelApi.Application]$application
  )

  [double]$Version = [System.Convert]::ToDouble($application.Version,[System.Globalization.CultureInfo]::InvariantCulture)
  if ($Version -ge 12.00) {
    return 'xlsx' }
  else {
    return 'SSxls'
  }


}


function PutSampleData {

param (
  [NetOffice.ExcelApi.workSheet]$workSheet 
)

            $workSheet.Cells[2, 2].Value = "Datum"
            $workSheet.Cells[3, 2].Value = (Get-Date -format d) # DateTime.Now.ToShortDateString()
            $workSheet.Cells[4, 2].Value = (Get-Date -format d) 
            $workSheet.Cells[5, 2].Value = (Get-Date -format d) 
            $workSheet.Cells[6, 2].Value = (Get-Date -format d) 

            $workSheet.Cells[2, 3].Value = "Columns1"
            $workSheet.Cells[3, 3].Value = 25
            $workSheet.Cells[4, 3].Value = 33
            $workSheet.Cells[5, 3].Value = 30
            $workSheet.Cells[6, 3].Value = 22

            $workSheet.Cells[2, 4].Value = "Column2"
            $workSheet.Cells[3, 4].Value = 25
            $workSheet.Cells[4, 4].Value = 33
            $workSheet.Cells[5, 4].Value = 30
            $workSheet.Cells[6, 4].Value = 22

            $workSheet.Cells[2, 5].Value = "Column3"
            $workSheet.Cells[3, 5].Value = 25
            $workSheet.Cells[4, 5].Value = 33
            $workSheet.Cells[5, 5].Value = 30
            $workSheet.Cells[6, 5].Value = 22

            return [NetOffice.ExcelApi.Range]($workSheet.Range('$B2:$E6'))
        }



Write-Output 'Draw back color and perform the BorderAround method'
$workSheet.Range('$B2:$B5').Interior.Color = [ExcelExamples.Example]::ToDouble([System.Drawing.Color]::DarkGreen)
$workSheet.Range('$B2:$B5').BorderAround([NetOffice.ExcelApi.Enums.XlLineStyle]::xlContinuous,[NetOffice.ExcelApi.Enums.XlBorderWeight]::xlMedium,[NetOffice.ExcelApi.Enums.XlColorIndex]::xlColorIndexAutomatic)

Write-Output 'Draw back color and border the range explicitly'
$workSheet.Range('$D2:$D5').Interior.Color = [ExcelExamples.Example]::ToDouble([System.Drawing.Color]::DarkGreen)
$workSheet.Range('$D2:$D5').Borders[[NetOffice.ExcelApi.Enums.XlBordersIndex]::xlInsideHorizontal].LineStyle = [NetOffice.ExcelApi.Enums.XlLineStyle]::xlDouble
$workSheet.Range('$D2:$D5').Borders[[NetOffice.ExcelApi.Enums.XlBordersIndex]::xlInsideHorizontal].Weight = 4
$workSheet.Range('$D2:$D5').Borders[[NetOffice.ExcelApi.Enums.XlBordersIndex]::xlInsideHorizontal].Color = [ExcelExamples.Example]::ToDouble([System.Drawing.Color]::Black)

Write-Output 'Add Cells'
# Property 'Value' cannot be found on this object; make sure it exists and is settable.
$workSheet.Cells[1, 1].Value = "We have 2 simple shapes created."

Write-Output 'Add some data to display'
# [NetOffice.ExcelApi.Range]$dataRange = PutSampleData $workSheet

Write-Output 'create a nice diagram'
[NetOffice.ExcelApi.ChartObject]$chart = ([NetOffice.ExcelApi.ChartObjects]($workSheet.ChartObjects())).Add(70, 100, 375, 225)
# $chart.Chart.SetSourceData($dataRange)

Write-Output 'Save the book'
[string]$file_extension = GetDefaultExtension -application $excel
[string]$workbookFile = [System.IO.Path]::Combine((Get-ScriptDirectory),('Example01.{0}' -f $file_extension))
$workBook.SaveAs($workbookFile)

Write-Output 'Close excel and dispose reference'
$excel.Quit()
$excel.Dispose()

