# http://www.java2s.com/Code/CSharp/GUI-Windows-Form/ToolStripMenuIteminaction.htm
<#

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

public class Form1 : Form
{
    private System.Windows.Forms.MenuStrip menuStrip1;
    private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem1;
    private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem formatToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem colorToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem blackToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem blueToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem redToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem greenToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem fontToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem timesToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem courierToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem comicToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem boldToolStripMenuItem;
    private System.Windows.Forms.ToolStripMenuItem italicToolStripMenuItem;
    private System.Windows.Forms.ToolStripSeparator dashToolStripMenuItem;
    private System.Windows.Forms.Label displayLabel;

  public Form1() {
        InitializeComponent();
  }
    private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
    {
      MessageBox.Show("First Line\nSecond Line",
         "About", MessageBoxButtons.OK, MessageBoxIcon.Information );
    }

   private void exitToolStripMenuItem_Click(object sender, EventArgs e)
   {
      Application.Exit();
   }

   private void ClearColor()
   {
      blackToolStripMenuItem.Checked = false;
      blueToolStripMenuItem.Checked = false;
      redToolStripMenuItem.Checked = false;
      greenToolStripMenuItem.Checked = false;
   } 
   private void blackToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearColor();
      displayLabel.ForeColor = Color.Black;
      blackToolStripMenuItem.Checked = true;
   }
   private void blueToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearColor();
      displayLabel.ForeColor = Color.Blue;
      blueToolStripMenuItem.Checked = true;
   }
   private void redToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearColor();

      displayLabel.ForeColor = Color.Red;
      redToolStripMenuItem.Checked = true;
   }
   private void greenToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearColor();
      displayLabel.ForeColor = Color.Green;
      greenToolStripMenuItem.Checked = true;
   }
   private void ClearFont()
   {
      timesToolStripMenuItem.Checked = false;
      courierToolStripMenuItem.Checked = false;
      comicToolStripMenuItem.Checked = false;
   }
   private void timesToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearFont();

      timesToolStripMenuItem.Checked = true;
      displayLabel.Font = new Font( 
         "Times New Roman", 14, displayLabel.Font.Style );
   }
   private void courierToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearFont();

      courierToolStripMenuItem.Checked = true;
      displayLabel.Font = new Font(
         "Courier", 14, displayLabel.Font.Style );
   }
   private void comicToolStripMenuItem_Click(object sender, EventArgs e)
   {
      ClearFont();
      comicToolStripMenuItem.Checked = true;
      displayLabel.Font = new Font(
         "Comic Sans MS", 14, displayLabel.Font.Style );
   }
   private void boldToolStripMenuItem_Click(object sender, EventArgs e)
   {
      boldToolStripMenuItem.Checked = !boldToolStripMenuItem.Checked;
      displayLabel.Font = new Font(
         displayLabel.Font.FontFamily, 14,
         displayLabel.Font.Style ^ FontStyle.Bold );
   }
   private void italicToolStripMenuItem_Click(object sender, EventArgs e)
   {
      italicToolStripMenuItem.Checked = !italicToolStripMenuItem.Checked;

      displayLabel.Font = new Font(
         displayLabel.Font.FontFamily, 14,
         displayLabel.Font.Style ^ FontStyle.Italic );
   } 
   private void InitializeComponent()
   {
     this.menuStrip1 = new System.Windows.Forms.MenuStrip();
     this.fileToolStripMenuItem1 = new System.Windows.Forms.ToolStripMenuItem();
     this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.formatToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.colorToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.blackToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.blueToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.redToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.greenToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.fontToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.timesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.courierToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.comicToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.dashToolStripMenuItem = new System.Windows.Forms.ToolStripSeparator();
     this.boldToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.italicToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
     this.displayLabel = new System.Windows.Forms.Label();
     this.menuStrip1.SuspendLayout();
     this.SuspendLayout();
     // 
     // menuStrip1
     // 
     this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
        this.fileToolStripMenuItem1,
        this.formatToolStripMenuItem});
     this.menuStrip1.Location = new System.Drawing.Point(0, 0);
     this.menuStrip1.Name = "menuStrip1";
     this.menuStrip1.Size = new System.Drawing.Size(326, 24);
     this.menuStrip1.TabIndex = 4;
     this.menuStrip1.Text = "menuStrip1";
     // 
     // fileToolStripMenuItem1
     // 
     this.fileToolStripMenuItem1.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
        this.aboutToolStripMenuItem,
        this.exitToolStripMenuItem});
     this.fileToolStripMenuItem1.Name = "fileToolStripMenuItem1";
     this.fileToolStripMenuItem1.Text = "File";
     // 
     // aboutToolStripMenuItem
     // 
     this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
     this.aboutToolStripMenuItem.Text = "About";
     this.aboutToolStripMenuItem.Click += new System.EventHandler(this.aboutToolStripMenuItem_Click);
     // 
     // exitToolStripMenuItem
     // 
     this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
     this.exitToolStripMenuItem.Text = "Exit";
     this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
     // 
     // formatToolStripMenuItem
     // 
     this.formatToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
        this.colorToolStripMenuItem,
        this.fontToolStripMenuItem});
     this.formatToolStripMenuItem.Name = "formatToolStripMenuItem";
     this.formatToolStripMenuItem.Text = "Format";
     // 
     // colorToolStripMenuItem
     // 
     this.colorToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
        this.blackToolStripMenuItem,
        this.blueToolStripMenuItem,
        this.redToolStripMenuItem,
        this.greenToolStripMenuItem});
     this.colorToolStripMenuItem.Name = "colorToolStripMenuItem";
     this.colorToolStripMenuItem.Text = "Color";
     // 
     // blackToolStripMenuItem
     // 
     this.blackToolStripMenuItem.Name = "blackToolStripMenuItem";
     this.blackToolStripMenuItem.Text = "Black";
     this.blackToolStripMenuItem.Click += new System.EventHandler(this.blackToolStripMenuItem_Click);
     // 
     // blueToolStripMenuItem
     // 
     this.blueToolStripMenuItem.Name = "blueToolStripMenuItem";
     this.blueToolStripMenuItem.Text = "Blue";
     this.blueToolStripMenuItem.Click += new System.EventHandler(this.blueToolStripMenuItem_Click);
     // 
     // redToolStripMenuItem
     // 
     this.redToolStripMenuItem.Name = "redToolStripMenuItem";
     this.redToolStripMenuItem.Text = "Red";
     this.redToolStripMenuItem.Click += new System.EventHandler(this.redToolStripMenuItem_Click);
     // 
     // greenToolStripMenuItem
     // 
     this.greenToolStripMenuItem.Name = "greenToolStripMenuItem";
     this.greenToolStripMenuItem.Text = "Green";
     this.greenToolStripMenuItem.Click += new System.EventHandler(this.greenToolStripMenuItem_Click);
     // 
     // fontToolStripMenuItem
     // 
     this.fontToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
        this.timesToolStripMenuItem,
        this.courierToolStripMenuItem,
        this.comicToolStripMenuItem,
        this.dashToolStripMenuItem,
        this.boldToolStripMenuItem,
        this.italicToolStripMenuItem});
     this.fontToolStripMenuItem.Name = "fontToolStripMenuItem";
     this.fontToolStripMenuItem.Text = "Font";
     // 
     // timesToolStripMenuItem
     // 
     this.timesToolStripMenuItem.Name = "timesToolStripMenuItem";
     this.timesToolStripMenuItem.Text = "Times New Roman";
     this.timesToolStripMenuItem.Click += new System.EventHandler(this.timesToolStripMenuItem_Click);
     // 
     // courierToolStripMenuItem
     // 
     this.courierToolStripMenuItem.Name = "courierToolStripMenuItem";
     this.courierToolStripMenuItem.Text = "Courier";
     this.courierToolStripMenuItem.Click += new System.EventHandler(this.courierToolStripMenuItem_Click);
     // 
     // comicToolStripMenuItem
     // 
     this.comicToolStripMenuItem.Name = "comicToolStripMenuItem";
     this.comicToolStripMenuItem.Text = "Comic Sans";
     this.comicToolStripMenuItem.Click += new System.EventHandler(this.comicToolStripMenuItem_Click);
     // 
     // dashToolStripMenuItem
     // 
     this.dashToolStripMenuItem.Name = "dashToolStripMenuItem";
     // 
     // boldToolStripMenuItem
     // 
     this.boldToolStripMenuItem.Name = "boldToolStripMenuItem";
     this.boldToolStripMenuItem.Text = "Bold";
     this.boldToolStripMenuItem.Click += new System.EventHandler(this.boldToolStripMenuItem_Click);
     // 
     // italicToolStripMenuItem
     // 
     this.italicToolStripMenuItem.Name = "italicToolStripMenuItem";
     this.italicToolStripMenuItem.Text = "Italic";
     this.italicToolStripMenuItem.Click += new System.EventHandler(this.italicToolStripMenuItem_Click);
     // 
     // displayLabel
     // 
     this.displayLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
     this.displayLabel.Location = new System.Drawing.Point(12, 39);
     this.displayLabel.Name = "displayLabel";
     this.displayLabel.Size = new System.Drawing.Size(293, 89);
     this.displayLabel.TabIndex = 7;
     this.displayLabel.Text = "Text";
     // 
     // MenuTest
     // 
     this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
     this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
     this.ClientSize = new System.Drawing.Size(326, 169);
     this.Controls.Add(this.menuStrip1);
     this.Controls.Add(this.displayLabel);
     this.Name = "MenuTest";
     this.Text = "MenuTest";
     this.menuStrip1.ResumeLayout(false);
     this.ResumeLayout(false);
     this.PerformLayout();

  }

  [STAThread]
  static void Main()
  {
    Application.EnableVisualStyles();
    Application.Run(new Form1());
  }

}


           
#>





function PromptToolsTrip {

  param(
    [string]$title,
    [string]$message,
    [object]$caller
  )


  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $f.Size = New-Object System.Drawing.Size (470,135)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow


  $f.StartPosition = 'CenterScreen'

  $menustrip1 = New-Object -TypeName 'System.Windows.Forms.MenuStrip'
  $file_m1 = New-Object -TypeName 'System.Windows.Forms.ToolStripMenuItem'
  $about_m1 = New-Object -TypeName 'System.Windows.Forms.ToolStripMenuItem'
  $exit_m1 = New-Object -TypeName 'System.Windows.Forms.ToolStripMenuItem'
  $dl = New-Object -TypeName 'System.Windows.Forms.Label'
  $menustrip1.SuspendLayout()
  $f.SuspendLayout()

  #  menuStrip1
  $menustrip1.Items.AddRange(@( $file_m1))
  $menustrip1.Location = New-Object System.Drawing.Point (0,0)
  $menustrip1.Name = "menuStrip1"
  $menustrip1.Size = New-Object System.Drawing.Size (326,24)
  $menustrip1.TabIndex = 0
  $menustrip1.Text = "menuStrip1"

  #  fileToolStripMenuItem1
  $file_m1.DropDownItems.AddRange(@( $about_m1,$exit_m1))
  $file_m1.Name = "fileToolStripMenuItem1"
  $file_m1.Text = "File"

  #  aboutToolStripMenuItem
  $about_m1.Name = "aboutToolStripMenuItem"
  $about_m1.Text = "About"
  # $about_m1.Click += new-Object -typename 'System.EventHandler($about_m1_Click);

  #  exitToolStripMenuItem
  $exit_m1.Name = "exitToolStripMenuItem"
  $exit_m1.Text = "Exit"
  # $exit_m1.Click += new-Object -typename 'System.EventHandler($exit_m1_Click)
  [int]$FontSize = 14
  $dl.Font  = New-Object System.Drawing.Font("Microsoft Sans Serif",$FontSize,1,3,1)
  # $dl.Font = new-Object System.Drawing.Font("Microsoft Sans Serif", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)))
  $dl.Location = New-Object System.Drawing.Point (12,39)
  $dl.Name = "displayLabel"
  $dl.Size = New-Object System.Drawing.Size (293,89)
  $dl.TabIndex = 7
  $dl.Text = "Text"


  #  MenuTest
  $f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6,13)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.ClientSize = New-Object System.Drawing.Size (326,169)
  $f.Controls.Add($menustrip1)
  $f.Controls.Add($dl)
  $f.Name = "MenuTest"
  $f.Text = "MenuTest"
  $menustrip1.ResumeLayout($false)
  $f.ResumeLayout($false)
  $f.PerformLayout()

  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}


Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptToolsTrip -Title 'Floating Menu Sample Project' -caller $caller
Write-Output $caller.Data

