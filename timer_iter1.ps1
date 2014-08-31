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


/*
Professional Windows GUI Programming Using C#
by Jay Glynn, Csaba Torok, Richard Conway, Wahid Choudhury, 
   Zach Greenvoss, Shripad Kulkarni, Neil Whitlow

Publisher: Peer Information
ISBN: 1861007663
*/
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace MyClock
{
    /// <summary>
    /// Summary description for MyClockForm.
    /// </summary>
    public class MyClockForm : System.Windows.Forms.Form
    {
        public System.Timers.Timer timer1;
        private System.Windows.Forms.Label label1;
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;

        public MyClockForm()
        {
            //
            // Required for Windows Form Designer support
            //
            InitializeComponent();

            //
            // TODO: Add any constructor code after InitializeComponent call
            //
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if (components != null) 
                {
                    components.Dispose();
                }
            }
            base.Dispose( disposing );
        }

        #region Windows Form Designer generated code
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
         this.timer1 = new System.Timers.Timer();
         this.label1 = new System.Windows.Forms.Label();
         ((System.ComponentModel.ISupportInitialize)(this.timer1)).BeginInit();
         this.SuspendLayout();
         // 
         // timer1
         // 
         this.timer1.Enabled = true;
         this.timer1.SynchronizingObject = this;
         this.timer1.Elapsed += new System.Timers.ElapsedEventHandler(this.OnTimerElapsed);
         // 
         // label1
         // 
         this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
         this.label1.ForeColor = System.Drawing.SystemColors.Highlight;
         this.label1.Location = new System.Drawing.Point(24, 8);
         this.label1.Name = "label1";
         this.label1.Size = new System.Drawing.Size(224, 48);
         this.label1.TabIndex = 0;
         this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
         // 
         // MyClockForm
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(292, 69);
         this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                      this.label1});
         this.Name = "MyClockForm";
         this.Text = "My Clock";
         this.Load += new System.EventHandler(this.MyClockForm_Load);
         ((System.ComponentModel.ISupportInitialize)(this.timer1)).EndInit();
         this.ResumeLayout(false);

      }
        #endregion

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main() 
        {
            Application.Run(new MyClockForm());
        }

        private void MyClockForm_Load(object sender, System.EventArgs e)
        {
            // Set the interval time ( 1000 ms == 1 sec )
            // after which the timer function is activated
            timer1.Interval = 1000 ;
            // Start the Timer
            timer1.Start();
            // Enable the timer. The timer starts now
            timer1.Enabled = true ; 
        }

        private void OnTimerElapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            // The interval has elapsed and this timer function is called after 1 second
            // Update the time now.
            label1.Text = DateTime.Now.ToString();
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.ComponentModel.dll'

$clock = New-Object MyClock.MyClockForm
$clock.ShowDialog()

