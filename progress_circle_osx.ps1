#Copyright (c) 2015 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


param(
  [switch]$debug
)
# http://www.codeproject.com/Articles/39235/Circular-Progress-Control-Mac-OS-X-style

Add-Type -TypeDefinition @"

// "

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;

namespace ProgressControl
{
    public partial class CircularProgressControl : UserControl
    {

        private const int DEFAULT_INTERVAL = 60;
        private readonly Color DEFAULT_TICK_COLOR = Color.FromArgb(58, 58, 58);
        private const int DEFAULT_TICK_WIDTH = 2;
        private const int MINIMUM_INNER_RADIUS = 4;
        private const int MINIMUM_OUTER_RADIUS = 8;
        private Size MINIMUM_CONTROL_SIZE = new Size(28, 28);
        private const int MINIMUM_PEN_WIDTH = 2;


        public enum Direction
        {
            CLOCKWISE,
            ANTICLOCKWISE
        }


        private int m_Interval;
        Pen m_Pen = null;
        PointF m_CentrePt = new PointF();
        int m_InnerRadius = 0;
        int m_OuterRadius = 0;
        int m_StartAngle = 0;
        int m_AlphaStartValue = 0;
        int m_SpokesCount = 0;
        int m_AngleIncrement = 0;
        int m_AlphaDecrement = 0;
        Timer m_Timer = null;

        public int Interval
        {
            get
            {
                return m_Interval;
            }
            set
            {
                if (value > 0)
                {
                    m_Interval = value;
                }
                else
                {
                    m_Interval = DEFAULT_INTERVAL;
                }
            }
        }
        public Color TickColor { get; set; }
        public Direction Rotation { get; set; }
        private bool m_clockwise;
        public bool Clockwise 
        {
            get
            {
                return m_clockwise;
            }
            set
            {
                m_clockwise = value;
                if (m_clockwise){ 
                   this.Rotation = Direction.CLOCKWISE;
                } else { 
                   this.Rotation = Direction.ANTICLOCKWISE;
                 }
            }
        }

        public int StartAngle
        {
            get
            {
                return m_StartAngle;
            }
            set
            {
                m_StartAngle = value;
            }
        }

        public CircularProgressControl()
        {
            this.DoubleBuffered = true;

            
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = Color.Transparent;
            this.TickColor = DEFAULT_TICK_COLOR;
            this.MinimumSize = MINIMUM_CONTROL_SIZE;
            this.Interval = DEFAULT_INTERVAL;
            this.Rotation = Direction.CLOCKWISE;
            this.StartAngle = 270;
            m_SpokesCount = 12;
            m_AlphaStartValue = 255;
            m_AngleIncrement = (int)(360/m_SpokesCount);
            m_AlphaDecrement = (int)((m_AlphaStartValue - 15) / m_SpokesCount);

            m_Pen = new Pen(TickColor, DEFAULT_TICK_WIDTH);
            m_Pen.EndCap = System.Drawing.Drawing2D.LineCap.Round;
            m_Pen.StartCap = System.Drawing.Drawing2D.LineCap.Round;
            m_Timer = new Timer();
            m_Timer.Interval = this.Interval;
            m_Timer.Tick += new EventHandler(OnTimerTick);
        }

        void OnTimerTick(object sender, EventArgs e)
        {
            if (Rotation == Direction.CLOCKWISE)
            {
                m_StartAngle += m_AngleIncrement;

                if (m_StartAngle >= 360)
                    m_StartAngle = 0;
            }
            else if (Rotation == Direction.ANTICLOCKWISE)
            {
                m_StartAngle -= m_AngleIncrement;

                if (m_StartAngle <= -360)
                    m_StartAngle = 0;
            }

            Invalidate();
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            // All the paintin will be handled by us.
            //base.OnPaint(e);

            e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;

            // Since the Rendering of the spokes is dependent upon the current size of the 
            // control, the following calculation needs to be done within the Paint eventhandler.
            int alpha = m_AlphaStartValue;
            int angle = m_StartAngle;
            // Calculate the location around which the spokes will be drawn
            int width = (this.Width < this.Height) ? this.Width : this.Height;
            m_CentrePt = new PointF(this.Width / 2, this.Height / 2);
            // Calculate the width of the pen which will be used to draw the spokes
            m_Pen.Width = (int)(width / 15);
            if (m_Pen.Width < MINIMUM_PEN_WIDTH)
                m_Pen.Width = MINIMUM_PEN_WIDTH;
            // Calculate the inner and outer radii of the control. The radii should not be less than the
            // Minimum values
            m_InnerRadius = (int)(width * (140 / (float)800));
            if (m_InnerRadius < MINIMUM_INNER_RADIUS)
                m_InnerRadius = MINIMUM_INNER_RADIUS;
            m_OuterRadius = (int)(width * (250 / (float)800));
            if (m_OuterRadius < MINIMUM_OUTER_RADIUS)
                m_OuterRadius = MINIMUM_OUTER_RADIUS;

            // Render the spokes
            for (int i = 0; i < m_SpokesCount; i++)
            {
                PointF pt1 = new PointF(m_InnerRadius * (float)Math.Cos(ConvertDegreesToRadians(angle)), m_InnerRadius * (float)Math.Sin(ConvertDegreesToRadians(angle)));
                PointF pt2 = new PointF(m_OuterRadius * (float)Math.Cos(ConvertDegreesToRadians(angle)), m_OuterRadius * (float)Math.Sin(ConvertDegreesToRadians(angle)));

                pt1.X += m_CentrePt.X;
                pt1.Y += m_CentrePt.Y;
                pt2.X += m_CentrePt.X;
                pt2.Y += m_CentrePt.Y;
                m_Pen.Color = Color.FromArgb(alpha, this.TickColor);
                e.Graphics.DrawLine(m_Pen, pt1, pt2);

                if (Rotation == Direction.CLOCKWISE)
                {
                    angle -= m_AngleIncrement;
                }
                else if (Rotation == Direction.ANTICLOCKWISE)
                {
                    angle += m_AngleIncrement;
                }

                //if (i < 5)
                //    alpha -= 45;
                alpha -= m_AlphaDecrement;
            }
        }

        private double ConvertDegreesToRadians(int degrees)
        {
            return ((Math.PI / (double)180) * degrees);
        }

        public void Start()
        {
            if (m_Timer != null)
            {
                m_Timer.Interval = this.Interval;
                m_Timer.Enabled = true;
            }
        }

        public void Stop()
        {
            if (m_Timer != null)
            {
                m_Timer.Enabled = false;
            }
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'


@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
$f = New-Object System.Windows.Forms.Form
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.BackColor = [System.Drawing.Color]::LightGray
$f.ClientSize = New-Object System.Drawing.Size (170,140)

$button1 = New-Object System.Windows.Forms.Button
$cbc1 = New-Object ProgressControl.CircularProgressControl
$cbc2 = New-Object ProgressControl.CircularProgressControl
$f.SuspendLayout()

$button1.Location = New-Object System.Drawing.Point (70,80)
$button1.Name = "button1"
$button1.Size = New-Object System.Drawing.Size (75,23)
$button1.TabIndex = 0
$button1.Text = "Start"
$button1.UseVisualStyleBackColor = true
$button1.add_click.Invoke({
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )
    if ($button1.Text -eq "Start")
    {
      $button1.Text = 'Stop'
      $cbc1.Start()
      $cbc2.Start()
    }
    else
    {
      $button1.Text = 'Start'
      $cbc1.Stop()
      $cbc2.Stop()
    }
  })


$cbc1.BackColor = [System.Drawing.Color]::Transparent
$cbc1.Interval = 60
$cbc1.Location = New-Object System.Drawing.Point (10,20)
$cbc1.MinimumSize = New-Object System.Drawing.Size (56,56)
$cbc1.Name = "circularProgressControl1"
$cbc1.Clockwise = $true
$cbc1.Size = New-Object System.Drawing.Size (56,56)
$cbc1.StartAngle = 270
$cbc1.TabIndex = 1
$cbc1.TickColor = [System.Drawing.Color]::DarkBlue

$cbc2.BackColor = [System.Drawing.Color]::Transparent
$cbc2.Interval = 60
$cbc2.Location = New-Object System.Drawing.Point (10,80)
$cbc2.MinimumSize = New-Object System.Drawing.Size (56,56)
$cbc2.Name = "$cbc2"
$cbc2.Clockwise = $false
$cbc2.Size = New-Object System.Drawing.Size (56,56)
$cbc2.StartAngle = 270
$cbc2.TabIndex = 2
$cbc2.TickColor = [System.Drawing.Color]::Yellow

$f.Controls.Add($cbc2)
$f.Controls.Add($button1)
$f.Controls.Add($cbc1)
$f.Name = "Form1"
$f.Text = 'OS X Progress Control'
$f.ResumeLayout($false)

[void]$f.ShowDialog()

