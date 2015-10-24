namespace PowershellRunner
{
    partial class AsyncPowershellRunnerForm
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
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.textBoxScript = new System.Windows.Forms.TextBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.label1 = new System.Windows.Forms.Label();
            this.comboBoxSampleScripts = new System.Windows.Forms.ComboBox();
            this.buttonStopScript = new System.Windows.Forms.Button();
            this.buttonStartScript = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.listBoxOutput = new System.Windows.Forms.ListBox();
            this.timerOutput = new System.Windows.Forms.Timer(this.components);
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.groupBox1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.groupBox2);
            this.splitContainer1.Size = new System.Drawing.Size(557, 369);
            this.splitContainer1.SplitterDistance = 209;
            this.splitContainer1.TabIndex = 0;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.textBoxScript);
            this.groupBox1.Controls.Add(this.panel1);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(8, 8, 8, 0);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(8);
            this.groupBox1.Size = new System.Drawing.Size(557, 209);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Script";
            // 
            // textBoxScript
            // 
            this.textBoxScript.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBoxScript.Font = new System.Drawing.Font("Lucida Console", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textBoxScript.Location = new System.Drawing.Point(8, 21);
            this.textBoxScript.MaxLength = 0;
            this.textBoxScript.Multiline = true;
            this.textBoxScript.Name = "textBoxScript";
            this.textBoxScript.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textBoxScript.Size = new System.Drawing.Size(541, 143);
            this.textBoxScript.TabIndex = 0;
            this.textBoxScript.WordWrap = false;
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.comboBoxSampleScripts);
            this.panel1.Controls.Add(this.buttonStopScript);
            this.panel1.Controls.Add(this.buttonStartScript);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panel1.Location = new System.Drawing.Point(8, 164);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(541, 37);
            this.panel1.TabIndex = 2;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F);
            this.label1.Location = new System.Drawing.Point(4, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(78, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "Sample scripts:";
            // 
            // comboBoxSampleScripts
            // 
            this.comboBoxSampleScripts.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxSampleScripts.FormattingEnabled = true;
            this.comboBoxSampleScripts.Location = new System.Drawing.Point(93, 12);
            this.comboBoxSampleScripts.Name = "comboBoxSampleScripts";
            this.comboBoxSampleScripts.Size = new System.Drawing.Size(246, 21);
            this.comboBoxSampleScripts.TabIndex = 3;
            // 
            // buttonStopScript
            // 
            this.buttonStopScript.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonStopScript.Location = new System.Drawing.Point(446, 6);
            this.buttonStopScript.Name = "buttonStopScript";
            this.buttonStopScript.Size = new System.Drawing.Size(95, 31);
            this.buttonStopScript.TabIndex = 2;
            this.buttonStopScript.Text = "Sto&p Script";
            this.buttonStopScript.UseVisualStyleBackColor = true;
            this.buttonStopScript.Click += new System.EventHandler(this.buttonStopScript_Click);
            // 
            // buttonStartScript
            // 
            this.buttonStartScript.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonStartScript.Location = new System.Drawing.Point(345, 6);
            this.buttonStartScript.Name = "buttonStartScript";
            this.buttonStartScript.Size = new System.Drawing.Size(95, 31);
            this.buttonStartScript.TabIndex = 1;
            this.buttonStartScript.Text = "&Start Script";
            this.buttonStartScript.UseVisualStyleBackColor = true;
            this.buttonStartScript.Click += new System.EventHandler(this.buttonStartScript_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.listBoxOutput);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox2.Location = new System.Drawing.Point(0, 0);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(8);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(8);
            this.groupBox2.Size = new System.Drawing.Size(557, 156);
            this.groupBox2.TabIndex = 1;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Output";
            // 
            // listBoxOutput
            // 
            this.listBoxOutput.Dock = System.Windows.Forms.DockStyle.Fill;
            this.listBoxOutput.Font = new System.Drawing.Font("Lucida Console", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.listBoxOutput.FormattingEnabled = true;
            this.listBoxOutput.HorizontalScrollbar = true;
            this.listBoxOutput.ItemHeight = 11;
            this.listBoxOutput.Location = new System.Drawing.Point(8, 21);
            this.listBoxOutput.Name = "listBoxOutput";
            this.listBoxOutput.ScrollAlwaysVisible = true;
            this.listBoxOutput.Size = new System.Drawing.Size(541, 125);
            this.listBoxOutput.TabIndex = 1;
            // 
            // timerOutput
            // 
            this.timerOutput.Enabled = true;
            this.timerOutput.Tick += new System.EventHandler(this.timerOutput_Tick);
            // 
            // FormPowerShellSample
            // 
            this.AllowDrop = true;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(557, 369);
            this.Controls.Add(this.splitContainer1);
            this.Name = "FormPowerShellSample";
            this.Text = "Asynchronous PowerShell Scripting";
            this.DragDrop += new System.Windows.Forms.DragEventHandler(this.FormPowerShellSample_DragDrop);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FormPowerShellSample_FormClosing);
            this.DragEnter += new System.Windows.Forms.DragEventHandler(this.FormPowerShellSample_DragEnter);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox textBoxScript;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button buttonStartScript;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button buttonStopScript;
        private System.Windows.Forms.ListBox listBoxOutput;
        private System.Windows.Forms.Timer timerOutput;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ComboBox comboBoxSampleScripts;
    }
}

