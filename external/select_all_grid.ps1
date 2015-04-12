#Copyright (c) 2015 Serguei Kouzmine
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


# http://www.codeproject.com/Articles/42437/Toggling-the-States-of-all-CheckBoxes-Inside-a-Dat

Add-Type @"

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

    public class SelectAllGrid : Panel
    {
        int TotalCheckBoxes = 0;
        int TotalCheckedCheckBoxes = 0;
        CheckBox HeaderCheckBox = null;
        bool IsHeaderCheckBoxClicked = false;
        private System.Windows.Forms.DataGridView dgvSelectAll;
        private System.Windows.Forms.DataGridViewCheckBoxColumn chkBxSelect;
        private System.Windows.Forms.DataGridViewTextBoxColumn txtBxRandomNo;
        private System.Windows.Forms.DataGridViewTextBoxColumn txtBxDate;
        private System.Windows.Forms.DataGridViewTextBoxColumn txtBxTime;

        public SelectAllGrid(){
            this.dgvSelectAll = new System.Windows.Forms.DataGridView();
            this.chkBxSelect = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.txtBxRandomNo = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.txtBxDate = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.txtBxTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.SuspendLayout();
            // 
            // dgvSelectAll
            // 
            this.dgvSelectAll.AllowUserToAddRows = false;
            this.dgvSelectAll.AllowUserToDeleteRows = false;
            this.dgvSelectAll.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSelectAll.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.chkBxSelect,
            this.txtBxRandomNo,
            this.txtBxDate,
            this.txtBxTime});
            this.dgvSelectAll.Location = new System.Drawing.Point(12, 12);
            this.dgvSelectAll.Name = "dgvSelectAll";
            this.dgvSelectAll.Size = new System.Drawing.Size(443, 245);
            this.dgvSelectAll.TabIndex = 0;
            // 
            // chkBxSelect
            // 
            this.chkBxSelect.DataPropertyName = "IsChecked";
            this.chkBxSelect.HeaderText = "";
            this.chkBxSelect.Name = "chkBxSelect";
            this.chkBxSelect.Width = 50;
            // 
            // txtBxRandomNo
            // 
            this.txtBxRandomNo.DataPropertyName = "RandomNo";
            this.txtBxRandomNo.HeaderText = "Random No";
            this.txtBxRandomNo.Name = "txtBxRandomNo";
            this.txtBxRandomNo.ReadOnly = true;
            this.txtBxRandomNo.Width = 150;
            // 
            // txtBxDate
            // 
            this.txtBxDate.DataPropertyName = "Date";
            this.txtBxDate.HeaderText = "Date";
            this.txtBxDate.Name = "txtBxDate";
            this.txtBxDate.ReadOnly = true;
            // 
            // txtBxTime
            // 
            this.txtBxTime.DataPropertyName = "Time";
            this.txtBxTime.HeaderText = "Time";
            this.txtBxTime.Name = "txtBxTime";
            this.txtBxTime.ReadOnly = true;
            // 
            // GridSelectAll
            // 

            this.ClientSize = new System.Drawing.Size(469, 267);
            this.Controls.Add(this.dgvSelectAll);
            this.Name = "frmSelectAll";
            this.Text = "Select All Demo";
            // https://msdn.microsoft.com/en-us/library/system.windows.forms.panel_events%28v=vs.110%29.aspx
            AddHeaderCheckBox();

            HeaderCheckBox.KeyUp += new KeyEventHandler(HeaderCheckBox_KeyUp);
            HeaderCheckBox.MouseClick += new MouseEventHandler(HeaderCheckBox_MouseClick);
            dgvSelectAll.CellValueChanged += new DataGridViewCellEventHandler(dgvSelectAll_CellValueChanged);
            dgvSelectAll.CurrentCellDirtyStateChanged += new EventHandler(dgvSelectAll_CurrentCellDirtyStateChanged);
            dgvSelectAll.CellPainting += new DataGridViewCellPaintingEventHandler(dgvSelectAll_CellPainting);

            BindGridView();

            this.ResumeLayout(false);

        }

        private void BindGridView()
        {
            dgvSelectAll.DataSource = GetDataSource();

            TotalCheckBoxes = dgvSelectAll.RowCount;
            TotalCheckedCheckBoxes = 0;
        }
        // http://www.codeproject.com/Articles/20733/How-to-Populate-a-DataGridView-Control-using-OleDb
        private DataTable GetDataSource()
        {
            DataTable dTable = new DataTable();

            DataRow dRow = null;
            DateTime dTime;
            Random rnd = new Random();

            dTable.Columns.Add("IsChecked", System.Type.GetType("System.Boolean"));
            dTable.Columns.Add("RandomNo");
            dTable.Columns.Add("Date");
            dTable.Columns.Add("Time");

            for (int n = 0; n < 10; ++n)
            {
                dRow = dTable.NewRow();
                dTime = DateTime.Now;

                dRow["IsChecked"] = "false";
                dRow["RandomNo"] = rnd.NextDouble();
                dRow["Date"] = dTime.ToString("MM/dd/yyyy");
                dRow["Time"] = dTime.ToString("hh:mm:ss tt");

                dTable.Rows.Add(dRow);
                dTable.AcceptChanges();
            }

            return dTable;
        }

        private void dgvSelectAll_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            if (!IsHeaderCheckBoxClicked)
                RowCheckBoxClick((DataGridViewCheckBoxCell)dgvSelectAll[e.ColumnIndex, e.RowIndex]);
        }

        private void dgvSelectAll_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            if (dgvSelectAll.CurrentCell is DataGridViewCheckBoxCell)
                dgvSelectAll.CommitEdit(DataGridViewDataErrorContexts.Commit);
        }

        private void HeaderCheckBox_MouseClick(object sender, MouseEventArgs e)
        {
            HeaderCheckBoxClick((CheckBox)sender);
        }

        private void HeaderCheckBox_KeyUp(object sender, KeyEventArgs e)
        {
            if(e.KeyCode == Keys.Space)
                HeaderCheckBoxClick((CheckBox)sender);
        }

        private void dgvSelectAll_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.RowIndex == -1 && e.ColumnIndex == 0)
                    ResetHeaderCheckBoxLocation(e.ColumnIndex, e.RowIndex);
        }

        private void AddHeaderCheckBox()
        {
            HeaderCheckBox = new CheckBox();

            HeaderCheckBox.Size = new Size(15, 15);

            //Add the CheckBox into the DataGridView
            this.dgvSelectAll.Controls.Add(HeaderCheckBox);
        }

        private void ResetHeaderCheckBoxLocation(int ColumnIndex, int RowIndex)
        {
            //Get the column header cell bounds
            Rectangle oRectangle = this.dgvSelectAll.GetCellDisplayRectangle(ColumnIndex, RowIndex, true);

            Point oPoint = new Point();

            oPoint.X = oRectangle.Location.X + (oRectangle.Width - HeaderCheckBox.Width) / 2 + 1;
            oPoint.Y = oRectangle.Location.Y + (oRectangle.Height - HeaderCheckBox.Height) / 2 + 1;

            //Change the location of the CheckBox to make it stay on the header
            HeaderCheckBox.Location = oPoint;
        }

        private void HeaderCheckBoxClick(CheckBox HCheckBox)
        {
            IsHeaderCheckBoxClicked = true;

            foreach (DataGridViewRow Row in dgvSelectAll.Rows)
                ((DataGridViewCheckBoxCell)Row.Cells["chkBxSelect"]).Value = HCheckBox.Checked;

            dgvSelectAll.RefreshEdit();

            TotalCheckedCheckBoxes = HCheckBox.Checked ? TotalCheckBoxes : 0;

            IsHeaderCheckBoxClicked = false;
        }

        private void RowCheckBoxClick(DataGridViewCheckBoxCell RCheckBox)
        {
            if (RCheckBox != null)
            {
                //Modifiy Counter;            
                if ((bool)RCheckBox.Value && TotalCheckedCheckBoxes < TotalCheckBoxes)
                    TotalCheckedCheckBoxes++;
                else if (TotalCheckedCheckBoxes > 0)
                    TotalCheckedCheckBoxes--;

                //Change state of the header CheckBox.
                if (TotalCheckedCheckBoxes < TotalCheckBoxes)
                    HeaderCheckBox.Checked = false;
                else if (TotalCheckedCheckBoxes == TotalCheckBoxes)
                    HeaderCheckBox.Checked = true;
            }
        }
    }


"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.Xml.dll'


function SelectAllGrid {

  param(
    [string]$title,
    [string]$message
  )


  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $f.Size = New-Object System.Drawing.Size (470,235)
  $f.AutoScaleDimensions = New-Object System.Drawing.SizeF(6.0, 13.0)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
  $f.StartPosition = 'CenterScreen'


  $r = New-Object -TypeName 'SelectAllGrid' -ArgumentList ([System.Windows.Forms.UserControl]$u)
  $r.Size = $f.Size

  $f.Controls.Add($r)
  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog()
  $f.Dispose()
}
$script:Data = $null
SelectAllGrid -Title 'Selection Grid Sample Project'
Write-Output $script:Data

# Microsoft GIF Animator