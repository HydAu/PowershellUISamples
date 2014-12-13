# http://www.java2s.com/Code/CSharp/GUI-Windows-Form/ToolStripMenuIteminaction.htm




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


  # Separator 
  $dash = new-object -typename System.Windows.Forms.ToolStripSeparator

  #  aboutToolStripMenuItem
  $about_m1.Name = "aboutToolStripMenuItem"
  $about_m1.Text = "About"

  $eventMethod_about_m1 = $about_m1.add_click
  $eventMethod_about_m1.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $who = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(("We are processing {0}." -f $who))
      $caller.Data= $sender.Text
    })




  #  exitToolStripMenuItem
  $exit_m1.Name = "exitToolStripMenuItem"
  $exit_m1.Text = "Exit"

  $eventMethod_exit_m1 = $exit_m1.add_click
  $eventMethod_exit_m1.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      $who = $sender.Text
      [System.Windows.Forms.MessageBox]::Show(("We are processing {0}." -f $who))
      $caller.Data= $sender.Text
      $f.Close()
    })



  #  fileToolStripMenuItem1
  $file_m1.DropDownItems.AddRange(@( $about_m1, $dash, $exit_m1))
  $file_m1.Name = "fileToolStripMenuItem1"
  $file_m1.Text = "File"

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

