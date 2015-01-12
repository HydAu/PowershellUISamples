#Copyright (c) 2014 Serguei Kouzmine
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


Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

#  http://www.codeproject.com/Articles/25575/ProgressCircle-An-Alternative-to-ProgressBar
Add-Type -TypeDefinition @"

/////////////////////////////////////////////////////////////////////////////
// ProgressCircle.cs - progress control
//
// Written by Sergio A. B. Petrovcic (sergio_petrovcic@hotmail.com)
// Copyright (c) 2008 Sergio A. B. Petrovcic.
//
// This code may be used in compiled form in any way you desire. This
// file may be redistributed by any means PROVIDING it is 
// not sold for profit without the authors written consent, and 
// providing that this notice and the authors name is included.
//
// This file is provided "as is" with no expressed or implied warranty.
// The author accepts no liability if it causes any damage to you or your
// computer whatsoever.
//
// If you find bugs, have suggestions for improvements, etc.,
// please contact the author.
//
// History (Date/Author/Description):
// ----------------------------------
//
// 2008/04/23: Sergio A. B. Petrovcic
// - Original implementation

using System;
using System.Collections.Generic;

using System.ComponentModel;

using System.Data;
using System.Diagnostics;

using System.Drawing;
using System.Drawing.Drawing2D;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace ProgressCircle
{
    public partial class ProgressCircle : UserControl
    {

        private System.ComponentModel.IContainer components = null;

        public delegate void EventHandler(object sender, string message);
        public event EventHandler m_EventIncremented;
        [Category("ProgressCircle"), Description("Event raised everytime the component is incremented. Author: Sergio Augusto Bitencourt Petrovcic")]
        public event EventHandler PCIncremented
        {
            add { m_EventIncremented += new EventHandler(value); }
            remove { m_EventIncremented -= new EventHandler(value); }
        }
        public event EventHandler m_EventCompleted;
        [Category("ProgressCircle"), Description("Event raised when the component get completed. Author: Sergio Augusto Bitencourt Petrovcic")]
        public event EventHandler PCCompleted
        {
            add { m_EventCompleted += new EventHandler(value); }
            remove { m_EventCompleted -= new EventHandler(value); }
        }

        private LinearGradientMode m_eLinearGradientMode = LinearGradientMode.Vertical;
        [Category("ProgressCircle"), Description("Gradient orientation. Author: Sergio Augusto Bitencourt Petrovcic")]
        public LinearGradientMode PCLinearGradientMode
        {
            get { return m_eLinearGradientMode; }
            set { m_eLinearGradientMode = value; }
        }
        private Color m_oColor1RemainingTime = Color.Navy;
        [Category("ProgressCircle"), Description("Color 1 of remaining time. Author: Sergio Augusto Bitencourt Petrovcic")]
        public Color PCRemainingTimeColor1
        {
            get { return m_oColor1RemainingTime; }
            set { m_oColor1RemainingTime = value; }
        }
        private Color m_oColor2RemainingTime = Color.LightSlateGray;
        [Category("ProgressCircle"), Description("Color 2 of remaining time. Author: Sergio Augusto Bitencourt Petrovcic")]
        public Color PCRemainingTimeColor2
        {
            get { return m_oColor2RemainingTime; }
            set { m_oColor2RemainingTime = value; }
        }
        private Color m_oColor1ElapsedTime = Color.IndianRed;
        [Category("ProgressCircle"), Description("Color 1 of elapsed time. Author: Sergio Augusto Bitencourt Petrovcic")]
        public Color PCElapsedTimeColor1
        {
            get { return m_oColor1ElapsedTime; }
            set { m_oColor1ElapsedTime = value; }
        }
        private Color m_oColor2ElapsedTime = Color.Gainsboro;
        [Category("ProgressCircle"), Description("Color 2 of elapsed time. Author: Sergio Augusto Bitencourt Petrovcic")]
        public Color PCElapsedTimeColor2
        {
            get { return m_oColor2ElapsedTime; }
            set { m_oColor2ElapsedTime = value; }
        }
        private int m_iTotalTime = 100;
        [Category("ProgressCircle"), Description("Total time. Author: Sergio Augusto Bitencourt Petrovcic")]
        public int PCTotalTime
        {
            get { return m_iTotalTime; }
            set { m_iTotalTime = value; }
        }
        private int m_iElapsedTime = 0;
        [Category("ProgressCircle"), Description("Elapsed time. Author: Sergio Augusto Bitencourt Petrovcic")]
        public int PCElapsedTime
        {
            get { return m_iElapsedTime; }
            set { m_iElapsedTime = value; }
        }

        public ProgressCircle()
        {
            InitializeComponent();
        }

        public void Increment(int a_iValue)
        {
            if (m_iElapsedTime > m_iTotalTime)
                return;

            if (m_iElapsedTime + a_iValue >= m_iTotalTime)
            {
                m_iElapsedTime = m_iTotalTime;
                this.Refresh();
                if (m_EventIncremented != null)
                    m_EventIncremented(this, null);
                if (m_EventCompleted != null)
                    m_EventCompleted(this, null);
            }
            else
            {
                m_iElapsedTime += a_iValue;
                this.Refresh();
                if (m_EventIncremented != null)
                    m_EventIncremented(this, null);
            }
        }
        private void ProgressCircle_Paint(object sender, PaintEventArgs e)
        {
            Rectangle t_oRectangle = new Rectangle(0, 0, this.Width, this.Height);
            Brush t_oBrushRemainingTime = new LinearGradientBrush(t_oRectangle, m_oColor1RemainingTime, m_oColor2RemainingTime, m_eLinearGradientMode);
            Brush t_oBrushElapsedTime = new LinearGradientBrush(t_oRectangle, m_oColor1ElapsedTime, m_oColor2ElapsedTime, m_eLinearGradientMode);
            e.Graphics.FillEllipse(t_oBrushRemainingTime, t_oRectangle);
            e.Graphics.FillPie(t_oBrushElapsedTime, t_oRectangle, -90f, (float)(360 * m_iElapsedTime / m_iTotalTime));
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
            this.SuspendLayout();

            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Name = "LmaProgressBar";
            this.Size = new System.Drawing.Size(104, 89);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.ProgressCircle_Paint);
            this.ResumeLayout(false);

        }


    }
}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.ComponentModel.dll'

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

# PromptToolsTrip -Title 'Floating Menu Sample Project' -caller $caller
# Write-Output $caller.Data


<#


        private void button1_Click(object sender, EventArgs e)
        {
            button1.Enabled = false;
            progressBar1.Value = 0;
            progressCircle1.PCElapsedTime = 0;
            for (int i = 0; i < 100; i++)
            {
                progressBar1.Increment(1);
                progressCircle1.Increment(1);
                System.Threading.Thread.Sleep(100);
            }
            button1.Enabled = true;
        }

        void progressCircle1_PCCompleted(object sender, string message)
        {
            MessageBox.Show("Task completed!");
        }


            this.button1 = new System.Windows.Forms.Button();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.progressCircle1 = new ProgressCircle();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(12, 44);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 0;
            this.button1.Text = "Start";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // progressBar1
            // 
            this.progressBar1.Location = new System.Drawing.Point(12, 112);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(187, 16);
            this.progressBar1.TabIndex = 2;
            // 
            // progressCircle1
            // 
            this.progressCircle1.Location = new System.Drawing.Point(105, 12);
            this.progressCircle1.Name = "progressCircle1";
            this.progressCircle1.PCElapsedTimeColor1 = System.Drawing.Color.Chartreuse;
            this.progressCircle1.PCElapsedTimeColor2 = System.Drawing.Color.Yellow;
            this.progressCircle1.PCLinearGradientMode = System.Drawing.Drawing2D.LinearGradientMode.Vertical;
            this.progressCircle1.PCRemainingTimeColor1 = System.Drawing.Color.Navy;
            this.progressCircle1.PCRemainingTimeColor2 = System.Drawing.Color.LightBlue;
            this.progressCircle1.PCTotalTime = 100;
            this.progressCircle1.Size = new System.Drawing.Size(94, 89);
            this.progressCircle1.TabIndex = 3;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(210, 140);
            this.Controls.Add(this.progressCircle1);
            this.Controls.Add(this.progressBar1);
            this.Controls.Add(this.button1);
            this.Name = "Form1";
            this.Text = "ProgressCircle";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.ProgressBar progressBar1;
        private ProgressCircle progressCircle1;

#>