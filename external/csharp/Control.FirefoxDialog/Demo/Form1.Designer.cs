namespace Demo
{
	partial class Form1
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
			this.imageList1 = new System.Windows.Forms.ImageList(this.components);
			this.firefoxDialog1 = new Control.FirefoxDialog.FirefoxDialog();
			this.SuspendLayout();
			// 
			// imageList1
			// 
			this.imageList1.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageList1.ImageStream")));
			this.imageList1.TransparentColor = System.Drawing.Color.Transparent;
			this.imageList1.Images.SetKeyName(0, "General.ico");
			this.imageList1.Images.SetKeyName(1, "Email.ico");
			this.imageList1.Images.SetKeyName(2, "Internet.ico");
			this.imageList1.Images.SetKeyName(3, "Spell.ico");
			this.imageList1.Images.SetKeyName(4, "Favourites.ico");
			// 
			// firefoxDialog1
			// 
			this.firefoxDialog1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.firefoxDialog1.ImageList = null;
			this.firefoxDialog1.Location = new System.Drawing.Point(0, 0);
			this.firefoxDialog1.Name = "firefoxDialog1";
			this.firefoxDialog1.Size = new System.Drawing.Size(552, 393);
			this.firefoxDialog1.TabIndex = 0;
			// 
			// Form1
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(552, 393);
			this.Controls.Add(this.firefoxDialog1);
			this.Name = "Form1";
			this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
			this.Text = "Firefox Options Dialog";
			this.Load += new System.EventHandler(this.Form1_Load);
			this.ResumeLayout(false);

		}

		#endregion

		private Control.FirefoxDialog.FirefoxDialog firefoxDialog1;
		private System.Windows.Forms.ImageList imageList1;




	}
}

