namespace ServiceMonitor
{
    partial class ServiceSettings
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ServiceSettings));
            this.lstServices = new System.Windows.Forms.ListBox();
            this.lstSelectedServices = new System.Windows.Forms.ListBox();
            this.btnOk = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnRight = new System.Windows.Forms.Button();
            this.btnLeft = new System.Windows.Forms.Button();
            this.lbServices = new System.Windows.Forms.Label();
            this.lbServicesSelected = new System.Windows.Forms.Label();
            this.chkStartup = new System.Windows.Forms.CheckBox();
            this.lbProfile = new System.Windows.Forms.Label();
            this.cbxProfiles = new System.Windows.Forms.ComboBox();
            this.btnRename = new System.Windows.Forms.Button();
            this.btnNew = new System.Windows.Forms.Button();
            this.btnDelete = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // lstServices
            // 
            this.lstServices.FormattingEnabled = true;
            this.lstServices.Location = new System.Drawing.Point(12, 71);
            this.lstServices.Name = "lstServices";
            this.lstServices.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
            this.lstServices.Size = new System.Drawing.Size(250, 290);
            this.lstServices.TabIndex = 0;
            this.lstServices.DoubleClick += new System.EventHandler(this.LstServicesDoubleClick);
            // 
            // lstSelectedServices
            // 
            this.lstSelectedServices.FormattingEnabled = true;
            this.lstSelectedServices.Location = new System.Drawing.Point(322, 71);
            this.lstSelectedServices.Name = "lstSelectedServices";
            this.lstSelectedServices.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended;
            this.lstSelectedServices.Size = new System.Drawing.Size(250, 290);
            this.lstSelectedServices.TabIndex = 0;
            this.lstSelectedServices.DoubleClick += new System.EventHandler(this.LstSelectedServicesDoubleClick);
            // 
            // btnOk
            // 
            this.btnOk.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOk.Location = new System.Drawing.Point(412, 374);
            this.btnOk.Name = "btnOk";
            this.btnOk.Size = new System.Drawing.Size(75, 23);
            this.btnOk.TabIndex = 1;
            this.btnOk.Text = "OK";
            this.btnOk.UseVisualStyleBackColor = true;
            this.btnOk.Click += new System.EventHandler(this.BtnOkClick);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.Location = new System.Drawing.Point(497, 374);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.BtnCancelClick);
            // 
            // btnRight
            // 
            this.btnRight.Image = global::ServiceMonitor.Properties.Resources.ArrowRight;
            this.btnRight.Location = new System.Drawing.Point(274, 185);
            this.btnRight.Name = "btnRight";
            this.btnRight.Size = new System.Drawing.Size(35, 25);
            this.btnRight.TabIndex = 3;
            this.btnRight.UseVisualStyleBackColor = true;
            this.btnRight.Click += new System.EventHandler(this.BtnRightClick);
            // 
            // btnLeft
            // 
            this.btnLeft.Image = global::ServiceMonitor.Properties.Resources.ArrowLeft;
            this.btnLeft.Location = new System.Drawing.Point(274, 222);
            this.btnLeft.Name = "btnLeft";
            this.btnLeft.Size = new System.Drawing.Size(35, 25);
            this.btnLeft.TabIndex = 3;
            this.btnLeft.UseVisualStyleBackColor = true;
            this.btnLeft.Click += new System.EventHandler(this.BtnLeftClick);
            // 
            // lbServices
            // 
            this.lbServices.AutoSize = true;
            this.lbServices.Location = new System.Drawing.Point(12, 46);
            this.lbServices.Name = "lbServices";
            this.lbServices.Size = new System.Drawing.Size(51, 13);
            this.lbServices.TabIndex = 4;
            this.lbServices.Text = "Services:";
            // 
            // lbServicesSelected
            // 
            this.lbServicesSelected.AutoSize = true;
            this.lbServicesSelected.Location = new System.Drawing.Point(322, 46);
            this.lbServicesSelected.Name = "lbServicesSelected";
            this.lbServicesSelected.Size = new System.Drawing.Size(101, 13);
            this.lbServicesSelected.TabIndex = 4;
            this.lbServicesSelected.Text = "Monitored Services:";
            // 
            // chkStartup
            // 
            this.chkStartup.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.chkStartup.AutoSize = true;
            this.chkStartup.Location = new System.Drawing.Point(15, 377);
            this.chkStartup.Name = "chkStartup";
            this.chkStartup.Size = new System.Drawing.Size(209, 17);
            this.chkStartup.TabIndex = 5;
            this.chkStartup.Text = "Start automatically on Windows startup";
            this.chkStartup.UseVisualStyleBackColor = true;
            // 
            // lbProfile
            // 
            this.lbProfile.AutoSize = true;
            this.lbProfile.Location = new System.Drawing.Point(12, 16);
            this.lbProfile.Name = "lbProfile";
            this.lbProfile.Size = new System.Drawing.Size(39, 13);
            this.lbProfile.TabIndex = 6;
            this.lbProfile.Text = "Profile:";
            // 
            // cbxProfiles
            // 
            this.cbxProfiles.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbxProfiles.FormattingEnabled = true;
            this.cbxProfiles.Location = new System.Drawing.Point(61, 13);
            this.cbxProfiles.Name = "cbxProfiles";
            this.cbxProfiles.Size = new System.Drawing.Size(121, 21);
            this.cbxProfiles.TabIndex = 7;
            this.cbxProfiles.SelectedIndexChanged += new System.EventHandler(this.CbxProfilesSelectedIndexChanged);
            // 
            // btnRename
            // 
            this.btnRename.Location = new System.Drawing.Point(189, 13);
            this.btnRename.Name = "btnRename";
            this.btnRename.Size = new System.Drawing.Size(73, 23);
            this.btnRename.TabIndex = 8;
            this.btnRename.Text = "Rename";
            this.btnRename.UseVisualStyleBackColor = true;
            this.btnRename.Click += new System.EventHandler(this.BtnRenameClick);
            // 
            // btnNew
            // 
            this.btnNew.Location = new System.Drawing.Point(268, 13);
            this.btnNew.Name = "btnNew";
            this.btnNew.Size = new System.Drawing.Size(55, 23);
            this.btnNew.TabIndex = 9;
            this.btnNew.Text = "New";
            this.btnNew.UseVisualStyleBackColor = true;
            this.btnNew.Click += new System.EventHandler(this.BtnNewClick);
            // 
            // btnDelete
            // 
            this.btnDelete.Location = new System.Drawing.Point(329, 13);
            this.btnDelete.Name = "btnDelete";
            this.btnDelete.Size = new System.Drawing.Size(55, 23);
            this.btnDelete.TabIndex = 9;
            this.btnDelete.Text = "Delete";
            this.btnDelete.UseVisualStyleBackColor = true;
            this.btnDelete.Click += new System.EventHandler(this.BtnDeleteClick);
            // 
            // ServiceSettings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(584, 409);
            this.Controls.Add(this.btnDelete);
            this.Controls.Add(this.btnNew);
            this.Controls.Add(this.btnRename);
            this.Controls.Add(this.cbxProfiles);
            this.Controls.Add(this.lbProfile);
            this.Controls.Add(this.chkStartup);
            this.Controls.Add(this.lbServicesSelected);
            this.Controls.Add(this.lbServices);
            this.Controls.Add(this.btnLeft);
            this.Controls.Add(this.btnRight);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOk);
            this.Controls.Add(this.lstSelectedServices);
            this.Controls.Add(this.lstServices);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "ServiceSettings";
            this.Text = "Configuration";
            this.Resize += new System.EventHandler(this.ServiceSettingsResize);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ListBox lstServices;
        private System.Windows.Forms.ListBox lstSelectedServices;
        private System.Windows.Forms.Button btnOk;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnRight;
        private System.Windows.Forms.Button btnLeft;
        private System.Windows.Forms.Label lbServices;
        private System.Windows.Forms.Label lbServicesSelected;
        private System.Windows.Forms.CheckBox chkStartup;
        private System.Windows.Forms.Label lbProfile;
        private System.Windows.Forms.ComboBox cbxProfiles;
        private System.Windows.Forms.Button btnRename;
        private System.Windows.Forms.Button btnNew;
        private System.Windows.Forms.Button btnDelete;
    }
}