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



namespace Dino.Tools.WebMonitor
{
    public class FakeChartForm1 : Form
    {
        private IContainer components = null;
        private ArrayList aSeries1 = new ArrayList();
        public Chart chart1;
        public FakeChartForm1 ()
        {
            InitializeComponent();
        }
/*
        private double demo_function(int i)
        {
            var f1 = 59894 - (8128 * i) + (262 * i * i) - (1.6 * i * i * i);
            return f1;
        }
*/
        public void Form1_LoadData(object sender, EventArgs e){ 
             aSeries1 = new ArrayList { -10, 20, 40, -20, 10,30,34 };
        }
    
        public void Form1_Load(object sender, EventArgs e)
        {
            chart1.Series.Clear();
            var series1 = new System.Windows.Forms.DataVisualization.Charting.Series
            {
                Name = "Series1",
                Color = System.Drawing.Color.Green,
                IsVisibleInLegend = false,
                IsXValueIndexed = true,
                ChartType = SeriesChartType.Line
            };

/*

            this.chart1.Series.Add(series1);

            for (int i=0; i < 100; i++)
            {
                series1.Points.AddXY(i, demo_function(i));
            }

*/
//            ArrayList aSeries1 = new ArrayList { -10, 20, 40, -20, 10 };
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

            chart1.Invalidate();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
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
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 262);
            this.Controls.Add(this.chart1);
            this.Name = "Form1";
            this.Text = "FakeChart";
            // want to pass the data 
            // this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            this.ResumeLayout(false);
        }

    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.DataVisualization.dll','System.Windows.Forms.DataVisualization.Design.dll','System.Windows.Forms.dll','System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.Xml.dll','System.ComponentModel.dll'

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$o = new-object -TypeName 'Dino.Tools.WebMonitor.FakeChartForm1'
$o.Size = new-object System.Drawing.Size(797, 267);

$o.ResumeLayout($false)
$o.PerformLayout()

$o.Add_Shown({ $o.Activate() })
$o.KeyPreview = $True

# $o.Form1_LoadData($null, $null)
# $o.Form1_Load($null, $null)
[void]$o.ShowDialog()

$o.Dispose()


