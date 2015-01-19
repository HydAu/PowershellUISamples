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

<#
DDControl.Designer.cs
DDControl.cs
#>
# $DebugPreference = 'Continue'

param(
  [switch]$pause
)

#  http://www.codeproject.com/Tips/590903/How-to-Create-a-Dropdown-Button-Control
# 
Add-Type -TypeDefinition @"


using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace Dropdown_Button {

    public delegate void ItemClickedDelegate(object sender, ToolStripItemClickedEventArgs e);

    public class DDControl : UserControl {



        public event ItemClickedDelegate ItemClickedEvent;

        #region Members

        public List<string> LstOfValues = new List<string>();

        #endregion

        #region Constructors
# line 30 
        public DDControl() {
            InitializeComponent();
        }

        #endregion

        #region Methods

        public void FillControlList(List<string> lst) {
            LstOfValues = lst;
            SetMyButtonProperties();
        }

        private void ShowDropDown() {
            ContextMenuStrip contextMenuStrip = new ContextMenuStrip();
            //get the path of the image
            string imgPath = GetFilePath();
            //adding contextMenuStrip items acconrding to LstOfValues count
            for (int i = 0; i < LstOfValues.Count - 1; i++) {
                //add the item
                contextMenuStrip.Items.Add(LstOfValues[i]);
                //add the image
                if (File.Exists(imgPath + @"icon" + i + ".bmp")) {
                    contextMenuStrip.Items[i].Image = Image.FromFile(imgPath + @"icon" + i + ".bmp");
                }
            }
            //adding ItemClicked event to contextMenuStrip
            contextMenuStrip.ItemClicked += contextMenuStrip_ItemClicked;
            //show menu strip control
            contextMenuStrip.Show(btnDropDown, new Point(0, btnDropDown.Height));
        }

        private void SetMyButtonProperties() {
            // Assign an image to the button.
            string imgPath = GetFilePath();
            btnDropDown.Image = Image.FromFile(imgPath + @"arrow.png");
            // Align the image right of the button
            btnDropDown.ImageAlign = ContentAlignment.MiddleRight;
            //Align the text left of the button.
            btnDropDown.TextAlign = ContentAlignment.MiddleLeft;
        }

        private string GetFilePath() {
            //string path = string.Empty;
            //foreach (string value in Application.StartupPath.Split('\\')) {
            //    if (value == "bin") {
            //        break;
            //    }
            //    path += value + "\\";
            //}
            //return path;
            string value = Application.StartupPath.Substring(Application.StartupPath.IndexOf(@"bin", System.StringComparison.Ordinal));
            return Application.StartupPath.Replace(value, string.Empty);

        }


        #endregion

        #region Events

        private void btnDropDown_Click(object sender, EventArgs e) {
            try {
                ShowDropDown();
            }
            catch (Exception ex) {
                MessageBox.Show(ex.ToString());
            }
        }

        void contextMenuStrip_ItemClicked(object sender, ToolStripItemClickedEventArgs e) {
            try {
                ToolStripItem item = e.ClickedItem;
                //set the text of the button
                btnDropDown.Text = item.Text;
                if (ItemClickedEvent != null) {
                    ItemClickedEvent(sender, e);
                }
            }
            catch (Exception ex) {
                MessageBox.Show(ex.ToString());
            }
        }

        #endregion

        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.btnDropDown = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnDropDown
            // 
            this.btnDropDown.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnDropDown.Location = new System.Drawing.Point(3, 0);
            this.btnDropDown.Name = "btnDropDown";
            this.btnDropDown.Size = new System.Drawing.Size(116, 23);
            this.btnDropDown.TabIndex = 0;
            this.btnDropDown.UseVisualStyleBackColor = true;
            this.btnDropDown.Click += new System.EventHandler(this.btnDropDown_Click);
            // 
            // DDControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.btnDropDown);
            this.Name = "DDControl";
            this.Size = new System.Drawing.Size(122, 24);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnDropDown;


    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'
