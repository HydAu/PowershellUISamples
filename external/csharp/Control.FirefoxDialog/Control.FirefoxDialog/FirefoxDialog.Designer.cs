namespace Control.FirefoxDialog
{
	partial class FirefoxDialog
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

		#region Component Designer generated code

		/// <summary> 
		/// Required method for Designer support - do not modify 
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.pagePanel = new System.Windows.Forms.Panel();
			this.leftPanel = new System.Windows.Forms.Panel();
			this.mozPane1 = new Pabo.MozBar.MozPane();
			this.bottomPanel = new System.Windows.Forms.Panel();
			this.btnApply = new System.Windows.Forms.Button();
			this.btnCancel = new System.Windows.Forms.Button();
			this.btnOK = new System.Windows.Forms.Button();
			this.leftPanel.SuspendLayout();
			((System.ComponentModel.ISupportInitialize)(this.mozPane1)).BeginInit();
			this.bottomPanel.SuspendLayout();
			this.SuspendLayout();
			// 
			// pagePanel
			// 
			this.pagePanel.Dock = System.Windows.Forms.DockStyle.Fill;
			this.pagePanel.Location = new System.Drawing.Point(104, 0);
			this.pagePanel.Name = "pagePanel";
			this.pagePanel.Size = new System.Drawing.Size(218, 139);
			this.pagePanel.TabIndex = 7;
			// 
			// leftPanel
			// 
			this.leftPanel.Controls.Add(this.mozPane1);
			this.leftPanel.Dock = System.Windows.Forms.DockStyle.Left;
			this.leftPanel.Location = new System.Drawing.Point(0, 0);
			this.leftPanel.Name = "leftPanel";
			this.leftPanel.Padding = new System.Windows.Forms.Padding(8);
			this.leftPanel.Size = new System.Drawing.Size(104, 139);
			this.leftPanel.TabIndex = 8;
			// 
			// mozPane1
			// 
			this.mozPane1.Dock = System.Windows.Forms.DockStyle.Fill;
			this.mozPane1.ImageList = null;
			this.mozPane1.Location = new System.Drawing.Point(8, 8);
			this.mozPane1.Name = "mozPane1";
			this.mozPane1.Size = new System.Drawing.Size(88, 123);
			this.mozPane1.TabIndex = 0;
			this.mozPane1.ItemClick += new Pabo.MozBar.MozItemClickEventHandler(this.mozPane1_ItemClick);
			// 
			// bottomPanel
			// 
			this.bottomPanel.Controls.Add(this.btnApply);
			this.bottomPanel.Controls.Add(this.btnCancel);
			this.bottomPanel.Controls.Add(this.btnOK);
			this.bottomPanel.Dock = System.Windows.Forms.DockStyle.Bottom;
			this.bottomPanel.Location = new System.Drawing.Point(0, 139);
			this.bottomPanel.Name = "bottomPanel";
			this.bottomPanel.Size = new System.Drawing.Size(322, 48);
			this.bottomPanel.TabIndex = 6;
			// 
			// btnApply
			// 
			this.btnApply.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnApply.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.btnApply.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnApply.Location = new System.Drawing.Point(228, 12);
			this.btnApply.Name = "btnApply";
			this.btnApply.Size = new System.Drawing.Size(75, 23);
			this.btnApply.TabIndex = 4;
			this.btnApply.Text = "&Apply";
			this.btnApply.Click += new System.EventHandler(this.btnApply_Click);
			// 
			// btnCancel
			// 
			this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
			this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnCancel.Location = new System.Drawing.Point(147, 12);
			this.btnCancel.Name = "btnCancel";
			this.btnCancel.Size = new System.Drawing.Size(75, 23);
			this.btnCancel.TabIndex = 2;
			this.btnCancel.Text = "Cancel";
			this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
			// 
			// btnOK
			// 
			this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
			this.btnOK.DialogResult = System.Windows.Forms.DialogResult.OK;
			this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.System;
			this.btnOK.Location = new System.Drawing.Point(67, 12);
			this.btnOK.Name = "btnOK";
			this.btnOK.Size = new System.Drawing.Size(75, 23);
			this.btnOK.TabIndex = 1;
			this.btnOK.Text = "OK";
			this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
			// 
			// FirefoxDialog
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.Controls.Add(this.pagePanel);
			this.Controls.Add(this.leftPanel);
			this.Controls.Add(this.bottomPanel);
			this.Name = "FirefoxDialog";
			this.Size = new System.Drawing.Size(322, 187);
			this.leftPanel.ResumeLayout(false);
			((System.ComponentModel.ISupportInitialize)(this.mozPane1)).EndInit();
			this.bottomPanel.ResumeLayout(false);
			this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.Panel pagePanel;
		private System.Windows.Forms.Panel leftPanel;
		private Pabo.MozBar.MozPane mozPane1;
		private System.Windows.Forms.Panel bottomPanel;
		private System.Windows.Forms.Button btnApply;
		private System.Windows.Forms.Button btnCancel;
		private System.Windows.Forms.Button btnOK;

	}
}
