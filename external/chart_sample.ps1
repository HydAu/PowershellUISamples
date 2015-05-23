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
        public Chart chart1;
        public FakeChartForm1 ()
        {
            InitializeComponent();
        }

        private double demo_function(int i)
        {
            var f1 = 59894 - (8128 * i) + (262 * i * i) - (1.6 * i * i * i);
            return f1;
        }

        private void Form1_Load(object sender, EventArgs e)
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

            this.chart1.Series.Add(series1);

            for (int i=0; i < 100; i++)
            {
                series1.Points.AddXY(i, demo_function(i));
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
            this.Load += new System.EventHandler(this.Form1_Load);
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

[void]$o.ShowDialog()

$o.Dispose()


