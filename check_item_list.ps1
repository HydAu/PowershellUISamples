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

function PromptCheckedList
{
     Param(
	[String] $title, 
	[String] $message)

  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Generic') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Text') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Data') 
  $f = New-Object System.Windows.Forms.Form 
  $f.Text = $title

  $i = new-object System.Windows.Forms.CheckedListBox
  $d = new-object System.Windows.Forms.ListBox
  $d.SuspendLayout()
  $i.SuspendLayout()
  $f.SuspendLayout()
  $i.Font = new-object System.Drawing.Font('Microsoft Sans Serif', 11, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, 0);
  $i.FormattingEnabled = $true;
  $i.Items.AddRange(( $message -split '[ ,]+' ));

  $i.Location = New-Object System.Drawing.Point(17, 12)
  $i.Name = 'inputCheckedListBox'
  $i.Size = New-Object System.Drawing.Size(202, 188)
  $i.TabIndex = 0
  $i.TabStop = $false
  $event_handler = {  
       param(
            [Object] $sender, 
            [System.Windows.Forms.ItemCheckEventArgs ] $eventargs 
         )
         $item = $i.SelectedItem
         if ( $eventargs.NewValue -eq  [System.Windows.Forms.CheckState]::Checked ) { 
            $d.Items.Add( $item );
         } else {
            $d.Items.Remove( $item );
         }
  }
  $i.Add_ItemCheck($event_handler) 

  $d.Font = New-Object System.Drawing.Font('Verdana', 11)
  $d.FormattingEnabled = $true
  $d.ItemHeight = 20;
  $d.Location =  New-Object System.Drawing.Point(236, 12);
  $d.Name = 'displayListBox';
  $d.Size = New-Object System.Drawing.Size(190, 184);
  $d.TabIndex = 1;

  $b  = New-Object System.Windows.Forms.Button
  $b.Location = New-Object System.Drawing.Point(8, 280)
  $b.Name = 'button1'
  $b.Size = New-Object System.Drawing.Size(112, 32)
  $b.TabIndex = 4
  $b.Text = 'Done'


  $b.Add_Click({
    $shapes = @()    
    foreach ($o in $d.Items){
      $shapes += $o
    } 
    $caller.Message =  [String]::Join(';', $shapes )
    $f.Close()
 })
     
  $f.AutoScaleBaseSize = New-Object System.Drawing.Size(5, 13)
  $f.ClientSize = New-Object System.Drawing.Size(408, 317)
  $components =  New-Object System.ComponentModel.Container

  $f.Controls.AddRange( @( $i, $d, $b))

  $f.Name = 'Form1'
  $f.Text = 'CheckListBox Sample'
  $i.ResumeLayout($false)
  $d.ResumeLayout($false)

  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True

  $f.Topmost = $True
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

  $f.Add_Shown( { $f.Activate() } )

  [Void] $f.ShowDialog([Win32Window ] ($caller) )
  $F.Dispose()
  $result = $caller.Message
  $caller = $null
  return $result
}

$DebugPreference = 'Continue'
$result = PromptCheckedList ''  'Lorem ipsum dolor sit amet, consectetur adipisicing elit' 

write-debug ('Selection is : {0}' -f  , $result )
