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

    private System.Windows.Forms.MenuItem menuItemClear;
    private System.Windows.Forms.MenuItem menuItemOpen;
    private System.Windows.Forms.MenuItem menuItemSave;
    private System.Windows.Forms.MenuItem menuItemExit;
    private System.Windows.Forms.MenuItem menuItemNewStudent;
    private System.Windows.Forms.MenuItem menuItem1;
    private System.Windows.Forms.MainMenu mainMenu;
    private System.Windows.Forms.DataGrid studentDataGrid;
    private System.Windows.Forms.DataGridView grdActivity;
    private SolidBrush cNone, cLow, cAverage, cHigh, cGreat;
    private SolidBrush _headerBrush = new SolidBrush(Color.Wheat);
    private SolidBrush[] _brushes;
    // private PeriodHistory _history;

    private ArrayList arTheStudents;

    public mainForm()
    {
        InitializeComponent();
        CenterToScreen();

        arTheStudents = new ArrayList();
        arTheStudents.Add(new Student("A", "A1", "A2"));
        arTheStudents.Add(new Student("B", "B1", "B2"));
        arTheStudents.Add(new Student("C", "C1", "C2"));
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
        this.grdActivity.Location = new System.Drawing.Point(12, 37);
        this.grdActivity.MultiSelect = false;
        this.grdActivity.Name = "grdActivity";
        this.grdActivity.ReadOnly = true;
        this.grdActivity.RowHeadersVisible = false;
        this.grdActivity.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal;
        this.grdActivity.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
        this.grdActivity.Size = new System.Drawing.Size(210, 180);
        this.grdActivity.TabIndex = 0;

        for (int i = 0; i < 5; i++)
        {
            var column = new DataGridViewTextBoxColumn();
            column.HeaderText = "";
            grdActivity.Columns.Add(column);
            column.Width = 40;
            column.SortMode = DataGridViewColumnSortMode.NotSortable;
        }
        this.grdActivity.RowCount = 3;

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

        this.menuItem1 = new System.Windows.Forms.MenuItem();
        this.studentDataGrid = new System.Windows.Forms.DataGrid();
        this.menuItemExit = new System.Windows.Forms.MenuItem();
        this.menuItemNewStudent = new System.Windows.Forms.MenuItem();
        this.menuItemOpen = new System.Windows.Forms.MenuItem();
        this.menuItemSave = new System.Windows.Forms.MenuItem();
        this.mainMenu = new System.Windows.Forms.MainMenu();
        this.menuItemClear = new System.Windows.Forms.MenuItem();
//      ((System.ComponentModel.ISupportInitialize)(this.studentDataGrid)).BeginInit();
     ((System.ComponentModel.ISupportInitialize)(this.grdActivity)).BeginInit();
        this.menuItem1.Index = 0;
        this.menuItem1.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {this.menuItemNewStudent,
this.menuItemClear,
this.menuItemOpen,
this.menuItemSave,
this.menuItemExit});
        this.menuItem1.Text = "&File";
        this.studentDataGrid.AlternatingBackColor = System.Drawing.Color.White;
        this.studentDataGrid.BackColor = System.Drawing.Color.White;
        this.studentDataGrid.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
        this.studentDataGrid.CaptionBackColor = System.Drawing.Color.Teal;
        this.studentDataGrid.CaptionFont = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Bold);
        this.studentDataGrid.CaptionForeColor = System.Drawing.Color.White;
        this.studentDataGrid.CaptionText = "Students";
        this.studentDataGrid.DataMember = "";
        this.studentDataGrid.FlatMode = true;
        this.studentDataGrid.Font = new System.Drawing.Font("Tahoma", 8F);
        this.studentDataGrid.ForeColor = System.Drawing.Color.Black;
        /*

                c = GetActivityColor(daylyStats.Activity);

            grdActivity[w, day].Style.BackColor = c;

        */
        this.studentDataGrid.GridLineColor = System.Drawing.Color.Silver;
        this.studentDataGrid.HeaderBackColor = System.Drawing.Color.Black;
        this.studentDataGrid.HeaderFont = new System.Drawing.Font("Tahoma", 8F);
        this.studentDataGrid.HeaderForeColor = System.Drawing.Color.White;
        this.studentDataGrid.LinkColor = System.Drawing.Color.Purple;
        this.studentDataGrid.LinkHoverColor = System.Drawing.Color.Fuchsia;
        this.studentDataGrid.Location = new System.Drawing.Point(8, 40);
        this.studentDataGrid.ParentRowsBackColor = System.Drawing.Color.Gray;
        this.studentDataGrid.ParentRowsForeColor = System.Drawing.Color.White;
        this.studentDataGrid.SelectionBackColor = System.Drawing.Color.Maroon;
        this.studentDataGrid.SelectionForeColor = System.Drawing.Color.White;
        this.studentDataGrid.Size = new System.Drawing.Size(416, 144);
        this.studentDataGrid.TabIndex = 0;
        this.menuItemExit.Index = 4;
        this.menuItemExit.Text = "E&xit";
        this.menuItemExit.Click += new System.EventHandler(this.menuItemExit_Click);
        this.menuItemNewStudent.DefaultItem = true;
        this.menuItemNewStudent.Index = 0;
        this.menuItemNewStudent.Text = "&Make New Student";
        this.menuItemNewStudent.Click += new System.EventHandler(this.menuItemNewStudent_Click);
        this.menuItemOpen.Index = 2;
        this.menuItemOpen.Text = "&Open Student File";
        this.menuItemOpen.Click += new System.EventHandler(this.menuItemOpen_Click);
        this.menuItemSave.Index = 3;
        this.menuItemSave.Text = "&Save Student File";
        this.menuItemSave.Click += new System.EventHandler(this.menuItemSave_Click);
        this.mainMenu.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] { this.menuItem1 });
        this.menuItemClear.Index = 1;
        this.menuItemClear.Text = "&Clear All Students";
        this.menuItemClear.Click += new System.EventHandler(this.menuItem2_Click);
        this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
        this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
        this.ClientSize = new System.Drawing.Size(434, 195);
//        this.Controls.AddRange(new System.Windows.Forms.Control[] { this.studentDataGrid });
        this.Controls.AddRange(new System.Windows.Forms.Control[] { this.grdActivity});
//        this.Menu = this.mainMenu;
        this.Text = "Student Logger Application";
        ((System.ComponentModel.ISupportInitialize)(this.studentDataGrid)).EndInit();

    }

    protected void menuItem2_Click(object sender, System.EventArgs e)
    {
        arTheStudents.Clear();
        UpdateGrid();
    }

    protected void menuItemExit_Click(object sender, System.EventArgs e)
    {
        Application.Exit();
    }

    protected void menuItemSave_Click(object sender, System.EventArgs e)
    {
        // Configure look and feel of save dlg.
        SaveFileDialog mySaveFileDialog = new SaveFileDialog();
        mySaveFileDialog.InitialDirectory = ".";
        mySaveFileDialog.Filter = "student files (*.student)|*.student|All files (*.*)|*.*";
        mySaveFileDialog.FilterIndex = 1;
        mySaveFileDialog.RestoreDirectory = true;
        mySaveFileDialog.FileName = "studentDoc";

        if (mySaveFileDialog.ShowDialog() == DialogResult.OK)
        {
            Stream myStream = null;
            if ((myStream = mySaveFileDialog.OpenFile()) != null)
            {
                BinaryFormatter myBinaryFormat = new BinaryFormatter();
                myBinaryFormat.Serialize(myStream, arTheStudents);
                myStream.Close();
            }
        }
    }

    protected void menuItemOpen_Click(object sender, System.EventArgs e)
    {
        OpenFileDialog myOpenFileDialog = new OpenFileDialog();
        myOpenFileDialog.InitialDirectory = ".";
        myOpenFileDialog.Filter = "student files (*.student)|*.student|All files (*.*)|*.*";
        myOpenFileDialog.FilterIndex = 1;
        myOpenFileDialog.RestoreDirectory = true;

        if (myOpenFileDialog.ShowDialog() == DialogResult.OK)
        {
            arTheStudents.Clear();
            Stream myStream = null;
            if ((myStream = myOpenFileDialog.OpenFile()) != null)
            {
                BinaryFormatter myBinaryFormat = new BinaryFormatter();
                arTheStudents = (ArrayList)myBinaryFormat.Deserialize(myStream);
                myStream.Close();
                UpdateGrid();
            }
        }
    }

    protected void menuItemNewStudent_Click(object sender, System.EventArgs e)
    {
        AddStudentDlg d = new AddStudentDlg();
        if (d.ShowDialog() == DialogResult.OK)
        {
            arTheStudents.Add(d.theStudent);
            UpdateGrid();
        }
    }

    public static void Main(string[] args)
    {
        Application.Run(new mainForm());
    }

    private void UpdateGrid()
    {
        if (arTheStudents != null)
        {
            DataTable inventory = new DataTable("StudentList");

            // Create DataColumn objects.
            DataColumn firstName = new DataColumn("First Name");
            DataColumn lastName = new DataColumn("Last Name");
            DataColumn from = new DataColumn("From");

            // Add columns to data table.
            inventory.Columns.Add(lastName);
            inventory.Columns.Add(firstName);
            inventory.Columns.Add(from);

            // Iterate over the array list to make rows.
            foreach (Student c in arTheStudents)
            {
                DataRow newRow;
                newRow = inventory.NewRow();
                newRow["Last Name"] = c.lastName;
                newRow["First Name"] = c.firstName;
                newRow["From"] = c.from;
                inventory.Rows.Add(newRow);
            }

            // Now bind this data table to the grid.
            studentDataGrid.DataSource = inventory;
        }
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

}


public class AddStudentDlg : System.Windows.Forms.Form
{
    private System.ComponentModel.Container components;
    private System.Windows.Forms.ListBox listColor;
    private System.Windows.Forms.ListBox listMake;
    private System.Windows.Forms.TextBox txtName;
    private System.Windows.Forms.Label label3;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Button btnCancel;
    private System.Windows.Forms.Button btnOK;

    // Make public for easy access
    public Student theStudent = null;

    public AddStudentDlg()
    {
        InitializeComponent();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            if (components != null)
            {
                components.Dispose();
            }
        }
        base.Dispose(disposing);
    }



    private void InitializeComponent()
    {
        this.components = new System.ComponentModel.Container();
        this.label1 = new System.Windows.Forms.Label();
        this.label3 = new System.Windows.Forms.Label();
        this.btnOK = new System.Windows.Forms.Button();
        this.label2 = new System.Windows.Forms.Label();
        this.listColor = new System.Windows.Forms.ListBox();
        this.btnCancel = new System.Windows.Forms.Button();
        this.listMake = new System.Windows.Forms.ListBox();
        this.txtName = new System.Windows.Forms.TextBox();

        label1.Location = new System.Drawing.Point(8, 24);
        label1.Text = "First Name";
        label1.Size = new System.Drawing.Size(88, 24);
        label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 10, System.Drawing.FontStyle.Bold);
        label1.TabIndex = 2;
        label3.Location = new System.Drawing.Point(8, 104);
        label3.Text = "Color";
        label3.Size = new System.Drawing.Size(80, 24);
        label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 10, System.Drawing.FontStyle.Bold);
        label3.TabIndex = 4;
        btnOK.Location = new System.Drawing.Point(24, 144);
        btnOK.DialogResult = System.Windows.Forms.DialogResult.OK;
        btnOK.Size = new System.Drawing.Size(104, 24);
        btnOK.TabIndex = 0;
        btnOK.Text = "OK";
        btnOK.Click += new System.EventHandler(this.btnOK_Click);
        label2.Location = new System.Drawing.Point(8, 64);
        label2.Text = "Make";
        label2.Size = new System.Drawing.Size(88, 24);
        label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 10, System.Drawing.FontStyle.Bold);
        label2.TabIndex = 3;
        listColor.Location = new System.Drawing.Point(112, 96);
        listColor.Size = new System.Drawing.Size(200, 30);
        listColor.TabIndex = 7;
        listColor.Items.AddRange(new object[6] { "A", "B", "C", "D", "E", "F" });
        btnCancel.Location = new System.Drawing.Point(184, 144);
        btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        btnCancel.Size = new System.Drawing.Size(112, 24);
        btnCancel.TabIndex = 1;
        btnCancel.Text = "Cancel";
        listMake.Location = new System.Drawing.Point(112, 48);
        listMake.Size = new System.Drawing.Size(200, 30);
        listMake.TabIndex = 6;
        listMake.Items.AddRange(new object[3] { "a", "b", "c" });
        txtName.Location = new System.Drawing.Point(112, 16);
        txtName.TabIndex = 5;
        txtName.Size = new System.Drawing.Size(200, 20);
        this.Text = "Add Student Dialog";
        this.MaximizeBox = false;
        this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
        this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
        this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
        this.ControlBox = false;
        this.MinimizeBox = false;
        this.ClientSize = new System.Drawing.Size(322, 183);
/*        this.Controls.Add(this.listColor);
        this.Controls.Add(this.listMake);
        this.Controls.Add(this.txtName);
        this.Controls.Add(this.label3);
        this.Controls.Add(this.label2);
        this.Controls.Add(this.label1);
        this.Controls.Add(this.btnCancel);
        this.Controls.Add(this.btnOK);
*/
    }

    protected void btnOK_Click(object sender, System.EventArgs e)
    {
        theStudent = new Student(txtName.Text, listMake.Text, listColor.Text);
    }
}
