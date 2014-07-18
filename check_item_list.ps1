Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string Message
    {
        get { return _message; }
        set { _message = value; }
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

# http://www.java2s.com/Code/CSharp/GUI-Windows-Form/CheckedListBoxItemCheckevent.htm

function PromptAuto(
	[String] $title, 
	[String] $message, 
	[Object] $caller = $null 
	){



  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Generic') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Text') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Data') 
  $f = New-Object System.Windows.Forms.Form 
  $f.Text = $title

  $input_checked_list_box = new-object System.Windows.Forms.CheckedListBox
  $display_list_box = new-object System.Windows.Forms.ListBox
  $display_list_box.SuspendLayout()
  $input_checked_list_box.SuspendLayout()
  $f.SuspendLayout()
  $font =   new-object System.Drawing.Font("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, 0);
  # $font = New-Object System.Drawing.Font('Verdana', 12)
  $input_checked_list_box.Font = $font
  $input_checked_list_box.FormattingEnabled = $true;
  $input_checked_list_box.Items.AddRange(@(
            "A",
            "B",
            "C",
            "D",
            "E",
            "F",
            "G",
            "H"));

  $input_checked_list_box.Location = New-Object System.Drawing.Point(17, 12)
  $input_checked_list_box.Name = 'inputCheckedListBox'
  $input_checked_list_box.Size = New-Object System.Drawing.Size(202, 188)
  $input_checked_list_box.TabIndex = 0
  $input_checked_list_box.TabStop = $false
 $handler = { 
 param(
   [Object] $sender, 
   [System.Windows.Forms.ItemCheckEventArgs ] $eventargs 
  )
         $item = $input_checked_list_box.SelectedItem
         if ( $eventargs.NewValue -eq  [System.Windows.Forms.CheckState]::Checked ) { 
            $display_list_box.Items.Add( $item );
} 
         else {
            $display_list_box.Items.Remove( $item );
      }
}
  $input_checked_list_box.Add_ItemCheck($handler) 

  # this.inputCheckedListBox.ItemCheck += new System.Windows.Forms.ItemCheckEventHandler(this.inputCheckedListBox_ItemCheck);

  $font = New-Object System.Drawing.Font('Verdana', 12)
  $display_list_box.Font = $font
  $display_list_box.FormattingEnabled = $true
  $display_list_box.ItemHeight = 20;
  $display_list_box.Location =  New-Object System.Drawing.Point(236, 12);
  $display_list_box.Name = "displayListBox";
  $display_list_box.Size = New-Object System.Drawing.Size(190, 184);
  $display_list_box.TabIndex = 1;

<#

    
      private void inputCheckedListBox_ItemCheck(object sender, ItemCheckEventArgs e )
      {
         string item = inputCheckedListBox.SelectedItem.ToString();

         if ( e.NewValue == CheckState.Checked )
            displayListBox.Items.Add( item );
         else
            displayListBox.Items.Remove( item );
      }
#>
<#
  $button1.Add_Click({

  $color = ''
  $shapes = @()     
  foreach ($o in @($radioButton1, $radioButton2, $radioButton3)){
  if ($o.Checked){
      $color = $o.Text}
  }
  foreach ($o in @($checkBox1, $checkBox2, $checkBox3)){
  if ($o.Checked){
      $shapes += $o.Text}

  }
  $g = [System.Drawing.Graphics]::FromHwnd($f.Handle)
  $rc = New-Object System.Drawing.Rectangle(150, 50, 250, 250)
  $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
  $g.FillRectangle($brush, $rc)
  $font = New-Object System.Drawing.Font('Verdana', 12)
  $col = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
  $str = [String]::Join(';', $shapes )
  $pos1 = New-Object System.Drawing.PointF(160, 60)
  $pos2 = New-Object System.Drawing.PointF(160, 80)

  $g.DrawString($color, $font, $col , $pos1)
  $g.DrawString($str, $font, $col , $pos2)
  start-sleep 1

  $caller.Message =  ('color:{0} shapes:{1}' -f $color , $str)

  $f.Close()
 })
#>
   
  # Form1
  
  $f.AutoScaleBaseSize = New-Object System.Drawing.Size(5, 13)
  $f.ClientSize = New-Object System.Drawing.Size(408, 317)
  $f.Controls.AddRange( @(
     $input_checked_list_box,
     $display_list_box))

  $f.Name = 'Form1'
  $f.Text = 'CheckBox and RadioButton Sample'
  $input_checked_list_box.ResumeLayout($false)
  $display_list_box.ResumeLayout($false)

  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True

  $f.Topmost = $True
  if ($caller -eq $null ){
    $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
  }

  $f.Add_Shown( { $f.Activate() } )

  [Void] $f.ShowDialog([Win32Window ] ($caller) )
  $F.Dispose()
  write-output $caller.Message
  return $caller.Data
}

$DebugPreference = 'Continue'
$process_window = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptAuto "" "" $process_window

write-output @('->', $process_window.Data) 

  if($process_window.Data -ne $RESULT_CANCEL) {
    write-debug ('Selection is : {0}' -f  , $process_window.Message )
  } else { 
    write-debug ('Result is : {0} ({1})' -f $Readable.Item($process_window.Data) , $process_window.Data )
  }
