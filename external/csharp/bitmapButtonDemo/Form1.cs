using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace BitmapButton
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.Button bitmapButton;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Button btnEnable;
		private System.Windows.Forms.Button btnDisable;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			bitmapButton=new BitmapButton();
			bitmapButton.Location=new Point(232, 32);
			bitmapButton.Size=new Size(32, 32);
			bitmapButton.TabIndex=0;
			bitmapButton.Text="&Down";
			bitmapButton.Image=new Bitmap("downArrow.bmp");
			bitmapButton.Click+=new EventHandler(BitmapButton_Click);
			Controls.Add(bitmapButton);
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
			this.label1 = new System.Windows.Forms.Label();
			this.btnEnable = new System.Windows.Forms.Button();
			this.btnDisable = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// label1
			// 
			this.label1.Location = new System.Drawing.Point(16, 32);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(216, 32);
			this.label1.TabIndex = 2;
			this.label1.Text = "Click on the button or press Alt-D---->";
			this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// btnEnable
			// 
			this.btnEnable.Location = new System.Drawing.Point(32, 88);
			this.btnEnable.Name = "btnEnable";
			this.btnEnable.TabIndex = 3;
			this.btnEnable.Text = "&Enable";
			this.btnEnable.Click += new System.EventHandler(this.btnEnable_Click);
			// 
			// btnDisable
			// 
			this.btnDisable.Location = new System.Drawing.Point(32, 120);
			this.btnDisable.Name = "btnDisable";
			this.btnDisable.TabIndex = 4;
			this.btnDisable.Text = "D&isable";
			this.btnDisable.Click += new System.EventHandler(this.btnDisable_Click);
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(312, 271);
			this.Controls.Add(this.btnDisable);
			this.Controls.Add(this.btnEnable);
			this.Controls.Add(this.label1);
			this.Name = "Form1";
			this.Text = "Form1";
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}

		private void btnEnable_Click(object sender, System.EventArgs e)
		{
			bitmapButton.Enabled=true;
		}

		private void btnDisable_Click(object sender, System.EventArgs e)
		{
			bitmapButton.Enabled=false;
		}

		private void BitmapButton_Click(object sender, EventArgs e)
		{
			MessageBox.Show("Clicked");
		}

	}
}
