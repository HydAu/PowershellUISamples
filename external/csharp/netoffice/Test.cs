using System;
using System.Collections.Generic;
using System.Drawing;
using System.Reflection;
using System.Text;
using System.IO;

using System.Globalization;

using NetOffice;
using NetOffice.ExcelApi;
using NetOffice.ExcelApi.Enums;

namespace ExcelExamples
{
    public class Example
    {

        public static void Main()
        {
            // start excel and turn off msg boxes
            NetOffice.ExcelApi.Application excelApplication = new NetOffice.ExcelApi.Application();
            excelApplication.DisplayAlerts = false;

            // add a new workbook
            NetOffice.ExcelApi.Workbook workBook = excelApplication.Workbooks.Add();
            NetOffice.ExcelApi.Worksheet workSheet = (NetOffice.ExcelApi.Worksheet)workBook.Worksheets[1];

            // draw back color and perform the BorderAround method
            workSheet.Range("$B2:$B5").Interior.Color = ToDouble(Color.DarkGreen);
            workSheet.Range("$B2:$B5").BorderAround(XlLineStyle.xlContinuous, XlBorderWeight.xlMedium, XlColorIndex.xlColorIndexAutomatic);

            // draw back color and border the range explicitly
            workSheet.Range("$D2:$D5").Interior.Color = ToDouble(Color.DarkGreen);
            workSheet.Range("$D2:$D5").Borders[XlBordersIndex.xlInsideHorizontal].LineStyle = XlLineStyle.xlDouble;
            workSheet.Range("$D2:$D5").Borders[XlBordersIndex.xlInsideHorizontal].Weight = 4;
            workSheet.Range("$D2:$D5").Borders[XlBordersIndex.xlInsideHorizontal].Color = ToDouble(Color.Black);

            workSheet.Cells[1, 1].Value = "We have 2 simple shapes created.";


            // we need some data to display
            NetOffice.ExcelApi.Range dataRange = PutSampleData(workSheet);

            // create a nice diagram
            NetOffice.ExcelApi.ChartObject chart = ((NetOffice.ExcelApi.ChartObjects)workSheet.ChartObjects()).Add(70, 100, 375, 225);
            chart.Chart.SetSourceData(dataRange);




            // save the book 
            string fileExtension = GetDefaultExtension(excelApplication);            
            string workbookFile = Path.Combine( Directory.GetCurrentDirectory(),string.Format("Example01{0}", fileExtension));
            workBook.SaveAs(workbookFile);

            // close excel and dispose reference
            excelApplication.Quit();
            excelApplication.Dispose();

        }
        

        /// <summary>
        /// Translate a color to double
        /// </summary>
        /// <param name="color">expression to convert</param>
        /// <returns>color</returns>
        private static double ToDouble(System.Drawing.Color color)
        {
            uint returnValue = color.B;
            returnValue = returnValue << 8;
            returnValue += color.G;
            returnValue = returnValue << 8;
            returnValue += color.R;
            return returnValue;
        }

        /// <summary>
        /// returns the valid file extension for the instance. for example ".xls" or ".xlsx"
        /// </summary>
        /// <param name="application">the instance</param>
        /// <returns>the extension</returns>
        private static string GetDefaultExtension(NetOffice.ExcelApi.Application application)
        {
            double Version = Convert.ToDouble(application.Version, CultureInfo.InvariantCulture);
            if (Version >= 12.00)
                return ".xlsx";
            else
                return ".xls";
        }

        private static NetOffice.ExcelApi.Range PutSampleData(NetOffice.ExcelApi.Worksheet workSheet)
        {
            workSheet.Cells[2, 2].Value = "Datum";
            workSheet.Cells[3, 2].Value = DateTime.Now.ToShortDateString();
            workSheet.Cells[4, 2].Value = DateTime.Now.ToShortDateString();
            workSheet.Cells[5, 2].Value = DateTime.Now.ToShortDateString();
            workSheet.Cells[6, 2].Value = DateTime.Now.ToShortDateString();

            workSheet.Cells[2, 3].Value = "Columns1";
            workSheet.Cells[3, 3].Value = 25;
            workSheet.Cells[4, 3].Value = 33;
            workSheet.Cells[5, 3].Value = 30;
            workSheet.Cells[6, 3].Value = 22;

            workSheet.Cells[2, 4].Value = "Column2";
            workSheet.Cells[3, 4].Value = 25;
            workSheet.Cells[4, 4].Value = 33;
            workSheet.Cells[5, 4].Value = 30;
            workSheet.Cells[6, 4].Value = 22;

            workSheet.Cells[2, 5].Value = "Column3";
            workSheet.Cells[3, 5].Value = 25;
            workSheet.Cells[4, 5].Value = 33;
            workSheet.Cells[5, 5].Value = 30;
            workSheet.Cells[6, 5].Value = 22;

            return workSheet.Range("$B2:$E6");
        }


    }
}
