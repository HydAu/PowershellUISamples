Add-type -TypeDefinition  @"

#pragma warning disable 0628
// http://stackoverflow.com/questions/10622674/chart-creating-dynamically-in-net-c-sharp
// http://www.emoticode.net/c-sharp/datavisualization-charting-chart-simple-example.html
// https://social.msdn.microsoft.com/Forums/vstudio/en-US/fb6fef67-3427-4b6a-a24b-d768b7986153/create-a-waterfall-chart-with-ms-chart-control-need-help?forum=MSWinWebChart
// http://www.codeproject.com/Articles/168056/Windows-Charting-Application
// https://msdn.microsoft.com/en-us/library/system.windows.forms.datavisualization.charting.chart%28v=vs.110%29.aspx
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

namespace agie_WaterfallSample
{
    public partial class Form1 : Panel
    {
        public Chart chart1;
        private void InitializeComponent()
        {
            chart1 = new Chart();
/*
            ArrayList aSeries1 = new ArrayList { -10, 20, 40, -20, 10 };
            ArrayList aSeries2 = new ArrayList();
            // THE SECOND SERIES MUST START FROM ZERO
            aSeries2.Add(0);

            //THIS IS FOR THE TOTAL COLUMN
            double nSumSeries1 = 0;

            Console.Error.WriteLine("Series2");
            for (int nIndex = 0; nIndex < aSeries1.Count; nIndex++)
            {
                Console.Error.WriteLine(aSeries2[nIndex]);
                //COUNT UP FOR THE TOTAL COLUMN
                nSumSeries1 += Convert.ToDouble(aSeries1[nIndex]);
                //ADDS THE RESULTS IN THE SECOND SERIES  
                aSeries2.Add(nSumSeries1);

            }

            chart1.Series.Clear();
            //THE LAST COLUMN IS THE TOTAL COLUMN TO SHOW ON THE END OF THE CHART
            aSeries1.Add(nSumSeries1 * -1);


            //CREATES THE FIRST SERIE TO SHOW THE VALUES AS RANGE_COLUMNS
            chart1.Series.Add("Series1");
            chart1.Series["Series1"].ChartType = SeriesChartType.RangeColumn;
            chart1.Series["Series1"].Color = Color.Yellow;
            chart1.Series["Series1"].YValuesPerPoint = 2;
            chart1.Series["Series1"]["PointWidth"] = "1.0";

            // NO GRIDLINES
            // chart1.ChartAreas[0].AxisX.MajorGrid.Enabled = false;
            // chart1.ChartAreas[0].AxisY.MajorGrid.Enabled = false;

            //CREATES THE SECOND SERIES TO SHOW THE CONNECTION LINE BETWEEN THE COLUMNS 
            chart1.Series.Add("Series2");
            chart1.Series["Series2"].ChartType = SeriesChartType.RangeColumn;
            chart1.Series["Series2"].Color = Color.Black;
            chart1.Series["Series2"].YValuesPerPoint = 2;
            chart1.Series["Series2"]["PointWidth"] = "1.0";

            //LIST OF VALUES FOR THE SECOND SERIES (LINES BETWEEN THE COLUMNS)
            ArrayList aSeriesEndPoints = new ArrayList();

            Console.Error.WriteLine("Series1 Values:");
            for (int nIndex = 0; nIndex < aSeries2.Count; nIndex++)
            {
                //CREATES THE COLUMNS FOR THE FIRST SERIES WITH TWO Y-COORDS(STARTPOINT, ENDPOINT)
                chart1.Series["Series1"].Points.InsertXY(nIndex, nIndex, aSeries2[nIndex], Convert.ToDouble(aSeries2[nIndex]) + Convert.ToDouble(aSeries1[nIndex]));
                Console.Error.WriteLine("StartPoint:" + aSeries2[nIndex] + "; EndPoint: " + (Convert.ToDouble(aSeries2[nIndex]) + Convert.ToDouble(aSeries1[nIndex])));

                //FILL THE ENDPOINTS IN THE LIST
                aSeriesEndPoints.Add((Convert.ToDouble(aSeries2[nIndex]) + Convert.ToDouble(aSeries1[nIndex])));

            }

            // THIS IS A TEST - I USE TO ADD SOME PIXEL (0.1) TO ANOTHER LIST FOR THE SECOND SERIES
            ArrayList aSeriesEndPointsCopy = new ArrayList();

            for (int nIndex = 0; nIndex < aSeriesEndPoints.Count; nIndex++)
            {
                switch (System.Math.Sign(Convert.ToDouble(aSeriesEndPoints[nIndex])))
                {
                    case 0:
                        aSeriesEndPointsCopy.Add(Convert.ToDouble(aSeriesEndPoints[nIndex]) + 0.1);
                        break;

                    case 1:
                        aSeriesEndPointsCopy.Add(Convert.ToDouble(aSeriesEndPoints[nIndex]) + 0.1);
                        break;

                    case -1:
                        aSeriesEndPointsCopy.Add(Convert.ToDouble(aSeriesEndPoints[nIndex]) - 0.1);
                        break;
                }
            }

            Console.Error.WriteLine("Series2 Value:");
            //AT LEAST I INSERT THE POINTS FOR THE SECOND SERIES (LINES BETWEEN THE COLUMNS)
            for (int nIndex = 0; nIndex < aSeriesEndPoints.Count - 1; nIndex++)
            {
                chart1.Series["Series2"].Points.InsertXY(nIndex, nIndex, Convert.ToDouble(aSeriesEndPoints[nIndex]), Convert.ToDouble(aSeriesEndPointsCopy[nIndex]));
                Console.Error.WriteLine("StartPoint:" + (Convert.ToDouble(aSeriesEndPoints[nIndex])) + "; EndPoint: " + (Convert.ToDouble(aSeriesEndPointsCopy[nIndex])));
            }
*/
/*
	    // Data arrays.
	    string[] seriesArray = { "Cats", "Dogs" };
	    int[] pointsArray = { 1, 2 };

	    // Set palette.
	    this.chart1.Palette = ChartColorPalette.SeaGreen;

	    // Set title.
	    this.chart1.Titles.Add("Pets");

	    // Add series.
	    for (int i = 0; i < seriesArray.Length; i++)
	    {
		// Add series.
		Series series = this.chart1.Series.Add(seriesArray[i]);

		// Add point.
		series.Points.Add(pointsArray[i]);
	    }

*/

/*
            chart1.Size = new System.Drawing.Size(797, 267);
this.chart1.Dock = System.Windows.Forms.DockStyle.Fill;
            chart1.Show();
            this.Controls.Add(chart1);
((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            this.ResumeLayout(false);
*/
//  this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea1 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend1 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            this.chart1 = new System.Windows.Forms.DataVisualization.Charting.Chart();
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).BeginInit();
            this.SuspendLayout();
            //
            // chart1
            //
            chartArea1.Name = "ChartArea1";
            this.chart1.ChartAreas.Add(chartArea1);
            this.chart1.Dock = System.Windows.Forms.DockStyle.Fill;
            legend1.Name = "Legend1";
            this.chart1.Legends.Add(legend1);
            this.chart1.Location = new System.Drawing.Point(0, 50);
            this.chart1.Name = "chart1";
            // this.chart1.Size = new System.Drawing.Size(284, 212);
            this.chart1.TabIndex = 0;
            this.chart1.Text = "chart1";
            //
            // Form1
            //
            // this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            // this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            // this.ClientSize = new System.Drawing.Size(284, 262);
            this.Controls.Add(this.chart1);
            this.Name = "Form1";
            this.Text = "FakeChart";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            this.ResumeLayout(false);
        }
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // TEST VALUES
        }
    }
}
"@ -ReferencedAssemblies 'System.Windows.Forms.DataVisualization.dll','System.Windows.Forms.DataVisualization.Design.dll','System.Windows.Forms.dll','System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.Xml.dll','System.ComponentModel.dll'
@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object System.Windows.Forms.Form
$f.MaximizeBox = $false
$f.MinimizeBox = $false
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (957,487)
$f.SuspendLayout()
$o = new-object -TypeName 'agie_WaterfallSample.Form1'
$o.Size = $f.Size
$o.chart1.Size = new-object System.Drawing.Size(797, 267);
$f.Controls.Add($o)

$o.ResumeLayout($false)
$f.ResumeLayout($false)
$f.PerformLayout()

$f.Add_Shown({ $f.Activate() })
$f.KeyPreview = $True

[void]$f.ShowDialog()

$f.Dispose()


