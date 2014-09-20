
using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace Calendar
{
    /// <summary>
    /// Summary description for Calendar.
    /// </summary>
    public class Calendar : System.Windows.Forms.Form
    {
        private System.Windows.Forms.MonthCalendar monthCalendar1;
        private System.Windows.Forms.Button button1;
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;

        public Calendar()
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
         this.monthCalendar1 = new System.Windows.Forms.MonthCalendar();
         this.button1 = new System.Windows.Forms.Button();
         this.SuspendLayout();
         // 
         // monthCalendar1
         // 
         this.monthCalendar1.FirstDayOfWeek = System.Windows.Forms.Day.Thursday;
         this.monthCalendar1.Location = new System.Drawing.Point(16, 16);
         this.monthCalendar1.Name = "monthCalendar1";
         this.monthCalendar1.ShowTodayCircle = false;
         this.monthCalendar1.ShowWeekNumbers = true;
         this.monthCalendar1.TabIndex = 0;
         // 
         // button1
         // 
         this.button1.Location = new System.Drawing.Point(48, 184);
         this.button1.Name = "button1";
         this.button1.Size = new System.Drawing.Size(128, 23);
         this.button1.TabIndex = 1;
         this.button1.Text = "Selection Range";
         this.button1.Click += new System.EventHandler(this.button1_Click_1);
         // 
         // Calendar
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(232, 213);
         this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                      this.button1,
                                                                      this.monthCalendar1});
         this.Name = "Calendar";
         this.Text = "Calendar Control";
         this.Load += new System.EventHandler(this.Calendar_Load);
         this.ResumeLayout(false);

      }
        #endregion

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main() 
        {
            Application.Run(new Calendar());
        }

        private void Calendar_Load(object sender, System.EventArgs e)
        {
            string str = monthCalendar1.Text.ToString()  ; 
        }

        private void button1_Click(object sender, System.EventArgs e)
        {
        }

        private void button1_Click_1(object sender, System.EventArgs e)
        {
            // Get the selection Range.  
            SelectionRange sr = monthCalendar1.SelectionRange;
            // Get the start of Range.
            DateTime st = sr.Start;
            // Get the end of Range.
            DateTime se = sr.End ; 

            MessageBox.Show("RANGE START = " + st.ToString() + "\nRANGE END = " + se.ToString(), "Range Selection");
    
        }
    }
}
