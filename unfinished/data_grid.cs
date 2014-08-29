using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;

[Serializable]  // Don't forget this!
public class Student
{
    // Make public for eazy access...
    public string lastName, firstName, from;
    public Student(string lastName, string firstName, string from)
    {
        this.lastName = lastName;
        this.from = from;
        this.firstName = firstName;
    }
}
public enum ActivityLevel
{
    None = 0,
    Low,
    Average,
    High,
    Great
}


public class mainForm : System.Windows.Forms.Form
{

    private System.Windows.Forms.DataGridView grdActivity;
    private SolidBrush cNone, cLow, cAverage, cHigh, cGreat;
    private SolidBrush _headerBrush = new SolidBrush(Color.Wheat);
    private SolidBrush[] _brushes;

    public mainForm()
    {
        InitializeComponent();
        CenterToScreen();
        UpdateGrid();
    }
    private void InitializeComponent()
    {

        this.grdActivity = new System.Windows.Forms.DataGridView();
        this.grdActivity.AllowUserToAddRows = false;
        this.grdActivity.AllowUserToDeleteRows = false;
        this.grdActivity.AllowUserToResizeColumns = false;
        this.grdActivity.AllowUserToResizeRows = false;
        this.grdActivity.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) | System.Windows.Forms.AnchorStyles.Right)));
        this.grdActivity.Location = new System.Drawing.Point(3, 3);
        this.grdActivity.MultiSelect = false;
        this.grdActivity.Name = "grdActivity";
        this.grdActivity.ReadOnly = true;
        this.grdActivity.RowHeadersVisible = false;
        // this.grdActivity.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal;
        this.grdActivity.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
        this.grdActivity.Size = new System.Drawing.Size(190, 40);
        this.grdActivity.TabIndex = 0;

        ((System.ComponentModel.ISupportInitialize)(this.grdActivity)).BeginInit();


        for (int i = 0; i < 5; i++)
        {
            var column = new DataGridViewTextBoxColumn();
            column.HeaderText = "";
            grdActivity.Columns.Add(column);
            column.Width = 40;
            column.SortMode = DataGridViewColumnSortMode.NotSortable;
        }
        this.grdActivity.RowCount = 3;
        this.grdActivity.RowHeadersVisible = false;

        for (int i = 0; i < 3; i++)
        {
            this.grdActivity.Rows[i].Height = 40;
        }
        // defines acivity colors and displays them in color legend grid
        cNone = new SolidBrush(Color.WhiteSmoke);
        cLow = new SolidBrush(Color.FromArgb(214, 230, 133));
        cAverage = new SolidBrush(Color.FromArgb(140, 198, 101));
        cHigh = new SolidBrush(Color.FromArgb(68, 163, 64));
        cGreat = new SolidBrush(Color.FromArgb(30, 104, 35));
        Color c = GetActivityColor(ActivityLevel.Low);
        for (int w = 0; w < 5; w++)
        {
            for (int d = 0; d < 3; d++)
            {

                grdActivity[w, d].Style.BackColor = c;
            }
        }

        this.grdActivity.CellFormatting += new System.Windows.Forms.DataGridViewCellFormattingEventHandler(this.ActivityGridCellFormatting);
        // this.grdActivity.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.grdActivity_CellContentClick);
        this.grdActivity.CellPainting += new System.Windows.Forms.DataGridViewCellPaintingEventHandler(this.ActivityGridCellPainting);
//http://www.codeproject.com/Articles/154680/A-customizable-NET-WinForms-Message-Box
        this.AutoScaleBaseSize = new System.Drawing.Size(3, 3);
        this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
        this.Controls.AddRange(new System.Windows.Forms.Control[] { this.grdActivity });
        this.ClientSize = new System.Drawing.Size(220, 40);
        this.Text = "";
        ((System.ComponentModel.ISupportInitialize)(this.grdActivity)).EndInit();
        this.MinimumSize = new System.Drawing.Size(220, 40);
        this.AutoSize = true;
        this.PerformLayout();
        this.ResumeLayout(false);


    }

    private void ActivityGridCellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
    {
        if (e.RowIndex < 0 || e.ColumnIndex < 0)
            return;
        e.Value = string.Empty;
        e.FormattingApplied = true;
    }


    public static void Main(string[] args)
    {
        Application.Run(new mainForm());
    }

    private void UpdateGrid()
    {

    }

    private Color GetActivityColor(ActivityLevel activity)
    {
        Color c = cNone.Color;
        switch (activity)
        {
            case ActivityLevel.Low:
                c = cLow.Color;
                break;
            case ActivityLevel.Average:
                c = cAverage.Color;
                break;
            case ActivityLevel.High:
                c = cHigh.Color;
                break;
            case ActivityLevel.Great:
                c = cGreat.Color;
                break;
        }
        return c;
    }


    private void ActivityGridCellPainting(object sender, DataGridViewCellPaintingEventArgs e)
    {
        if (e.ColumnIndex < 0)
            return;
        if (e.RowIndex >= 0)
        {
            //    var date = (DateTime?) grdActivity[e.ColumnIndex, e.RowIndex].Value;
            //    if (!date.HasValue || date < dtpStart.Value || date > dtpEnd.Value)
            e.CellStyle.BackColor = cNone.Color;
            return;
        }
        e.CellStyle.BackColor =
        e.CellStyle.SelectionBackColor = _headerBrush.Color;

        e.PaintBackground(e.ClipBounds, false);

        // DrawHeaderCell(e.Graphics, e.ClipBounds, e.CellBounds, e.CellStyle.Font, grdActivity.Columns[e.ColumnIndex].HeaderText);

        e.Handled = true;
    }


}
