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
# # http://www.codeproject.com/Articles/42437/Toggling-the-States-of-all-CheckBoxes-Inside-a-Dat

# http://www.java2s.com/Code/CSharp/GUI-Windows-Form/DataGridBinding.htm
Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
namespace DataGridBinding
{
    public class CustomDataGridColumnForm : System.Windows.Forms.Form
    {
        internal System.Windows.Forms.DataGrid grid;
        private System.ComponentModel.Container components = null;

        public CustomDataGridColumnForm()
        {
            InitializeComponent();
        }

        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if(components != null)
                {
                    components.Dispose();
                }
            }
            base.Dispose( disposing );
        }

        private void InitializeComponent()
        {
            this.grid = new System.Windows.Forms.DataGrid();
            ((System.ComponentModel.ISupportInitialize)(this.grid)).BeginInit();
            this.SuspendLayout();
            this.grid.Anchor = (((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
                | System.Windows.Forms.AnchorStyles.Left) 
                | System.Windows.Forms.AnchorStyles.Right);
            this.grid.DataMember = "";
            this.grid.HeaderForeColor = System.Drawing.SystemColors.ControlText;
            this.grid.Location = new System.Drawing.Point(10, 17);
            this.grid.Name = "grid";
            this.grid.Size = new System.Drawing.Size(272, 232);
            this.grid.TabIndex = 1;
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.ClientSize = new System.Drawing.Size(292, 266);
            this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                          this.grid});
            this.Name = "CustomDataGridColumnForm";
            this.Text = "CustomDataGridColumnForm";
            this.Load += new System.EventHandler(this.CustomDataGridColumnForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.grid)).EndInit();
            this.ResumeLayout(false);
        }

        [STAThread]
        static void Main() 
        {
            Application.Run(new CustomDataGridColumnForm());
        }

        private void CustomDataGridColumnForm_Load(object sender, System.EventArgs e)
        {
            DataSet dsStore = new DataSet();
            
           // dsStore.ReadXmlSchema(Application.StartupPath + "\\store.xsd");
              dsStore.ReadXmlSchema(Path.Combine( Directory.GetCurrentDirectory(), "store.xsd"));
//            dsStore.ReadXml(Application.StartupPath + "\\store.xml");
              dsStore.ReadXml(Path.Combine( Directory.GetCurrentDirectory(), "store.xml"));

//            dsStore.ReadXml(@"C:\developer\sergueik\powershell_ui_samples\store.xml");
            
            // Create the column collection.
            DataGridTableStyle columns = new DataGridTableStyle();
            columns.MappingName = "Products";
            
            // Create and configure the columns you want to display.
            DataGridPriceIconColumn priceCol = new DataGridPriceIconColumn(100);
            priceCol.HeaderText = "Price";
            priceCol.MappingName = "UnitCost";
            
            // Add the columns to the collection.
            columns.GridColumnStyles.Add(priceCol);
            
            // Configure the DataGrid to use these column settings.
            grid.TableStyles.Add(columns);  
            
            grid.ReadOnly = true;
            
            // Bind the grid.
            grid.DataSource = dsStore.Tables["Products"];
            
        }
    }

public class DataGridPriceIconColumn : DataGridColumnStyle
{
    public decimal NicePrice;

    public DataGridPriceIconColumn(decimal nicePrice)
    {
        this.NicePrice = nicePrice;
    }

    protected override void Abort(int rowNum)
    {
        // Do nothing.
    }

    protected override bool Commit(CurrencyManager dataSource, int rowNum)
    {
        return true;
    }

    protected override void Edit(CurrencyManager source,
        int rowNum, System.Drawing.Rectangle bounds,
        bool readOnly, string instantText, bool cellIsVisible)
    {
        // Do nothing.
    }

    protected override void Edit(CurrencyManager source,
        int rowNum, System.Drawing.Rectangle bounds, bool readOnly)
    {
        // Do nothing.
    }

    protected override void Edit(CurrencyManager source,
                            int rowNum, System.Drawing.Rectangle bounds,
                            bool readOnly, string instantText)
    {
        // Do nothing.
    }
    protected override int GetMinimumHeight()
    {
        return 20;
    }

    protected override int GetPreferredHeight(System.Drawing.Graphics g,
        object value)
    {
        return 20;
    }

    protected override System.Drawing.Size GetPreferredSize(
        System.Drawing.Graphics g, object value)
    {
        return new Size(100, 20);
    }

    protected override void Paint(System.Drawing.Graphics g,
        System.Drawing.Rectangle bounds, CurrencyManager source, int rowNum,
        System.Drawing.Brush backBrush, System.Drawing.Brush foreBrush,
        bool alignToRight)
    {
        // Clear the cell.
        g.FillRegion(backBrush, new Region(bounds));

        decimal price = (decimal)this.GetColumnValueAtRow(source, rowNum);
        Icon priceIcon;
        if (price < NicePrice)
        {
            priceIcon = new Icon(Path.Combine( Directory.GetCurrentDirectory(), "folder.ico" ));
// Application.StartupPath + "\\happy2.ico");
;
            // Draw the optional "nice price" icon.
            g.DrawIcon(priceIcon, new Rectangle(bounds.X, bounds.Y, 16, 16));
        }

        // Draw the text.
        g.DrawString(price.ToString("C"), new Font("Tahoma", (float)8.25), 
            Brushes.Black, bounds.X + 20, bounds.Y + 2);
    }

    protected override void Paint(System.Drawing.Graphics g,
        System.Drawing.Rectangle bounds, CurrencyManager source,
        int rowNum, bool alignToRight)
    {
        this.Paint(g, bounds, source, rowNum, Brushes.White, Brushes.Black,
            alignToRight);
    }

    protected override void Paint(System.Drawing.Graphics g,
        System.Drawing.Rectangle bounds, CurrencyManager source, int rowNum)
    {
        this.Paint(g, bounds, source, rowNum, Brushes.White, Brushes.Black, false);
    }
}
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll', 'System.Data.dll', 'System.Xml.dll'

$process_window = New-Object DataGridBinding.CustomDataGridColumnForm 
#   -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$process_window.show()
$process_window.DoEvents()