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

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Drawing;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _idx;
    private string _script_directory;
    private System.Drawing.Rectangle _rect; 
    public System.Drawing.Rectangle Rect
    {
        get { return _rect; }
        set { _rect = value; }
    }
    public int Idx
    {
        get { return _idx; }
        set { _idx = value; }
    }

    public string ScriptDirectory
    {
        get { return _script_directory; }
        set { _script_directory = value; }
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

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll'


# http://msdn.microsoft.com/en-us/library/system.windows.forms.control.dodragdrop%28v=vs.100%29.aspx


function PromptWithDragDropNish {
param
(

[String] $title, 
        [Object] $caller
)

[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 


$f = New-Object System.Windows.Forms.Form 
$f.Text = $title

$list_drag_source = new-object  System.Windows.Forms.ListBox 

$list_drag_target =  new-object System.Windows.Forms.ListBox 

$label1 = new-object System.Windows.Forms.Label 

$components = new-object System.ComponentModel.Container
$list_drag_source.SuspendLayout()
$list_drag_target.SuspendLayout()

# provide full path to cursor direcroty  to load cursor from 
$MyNoDropCursor = new-object System.Windows.Forms.Cursor('C:\Windows\Cursors\larrow.cur') 
$MyNormalCursor = new-object System.Windows.Forms.Cursor('C:\Windows\Cursors\lnodrop.cur') 

# $tab_contol1.SuspendLayout()
$f.SuspendLayout()

$custom_cursor_checkbox = new-object System.Windows.Forms.CheckBox

$list_drag_source.Items.AddRange(@("one", "two", "three", "four",  "five", "six", "seven", "eight", "nine", "ten") )
$list_drag_source.Font =  new-object System.Drawing.Font('Microsoft Sans Serif', 11, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]0);
$list_drag_source.ItemHeight = 24
$list_drag_source.Location = new-object System.Drawing.Point(32, 16)
$list_drag_source.Name = "drag_source" 
$list_drag_source.Size = new-object System.Drawing.Size(176, 196) 
$list_drag_source.TabIndex = 0 



#  listBox2



$list_drag_target.AllowDrop = true;
$list_drag_target.Font = new-object System.Drawing.Font('Microsoft Sans Serif', 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]0);
$list_drag_target.ItemHeight = 24 
$list_drag_target.Location = new-object System.Drawing.Point(344, 16)
$list_drag_target.Name = "drag_target" 
$list_drag_target.Size =  new-object  System.Drawing.Size(176, 196)
$list_drag_target.TabIndex = 1

 

#  label1

$label1.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$label1.Font =  new-object System.Drawing.Font('Microsoft Sans Serif', 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]0);
$label1.Location = new-object  System.Drawing.Point(88, 224)
$label1.Name = "label1";
$label1.Size = new-object  System.Drawing.Size(328, 40) 
$label1.TabIndex = 2;
$label1.Text = "Drag and drop names from the list box on the left to the list box on the right";
$label1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter



# Form1


$caller.Idx = $idx =  [System.Windows.Forms.ListBox]::NoMatches
$f.AutoScaleBaseSize = new-object  System.Drawing.Size(5, 13)
$f.ClientSize = new-object  System.Drawing.Size(568, 278)
$f.Controls.AddRange(@(   $label1,   $list_drag_target,   $list_drag_source)) 
$f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$drag_box = [System.Drawing.Rectangle]::Empty
$f.MaximizeBox = $false
$f.Name = "Form1"
$f.Text = "Playing with drag and drop"

$list_drag_source.ResumeLayout($false)
$list_drag_target.ResumeLayout($false)
$f.ResumeLayout($false)

$f.StartPosition = 'CenterScreen'
$f.KeyPreview = $false

$handler_drag_source_MouseDown = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.MouseEventArgs] $eventargs  
    )

if ($list_drag_source.Items.Count -eq 0) {

  return
}
  $t = $label1.Text;

$caller.Idx =   $idx = $list_drag_source.IndexFromPoint($eventargs.X, $eventargs.Y)
  $drag_item = $list_drag_source.Items[$idx]

  if ($idx -ne [System.Windows.Forms.ListBox]::NoMatches) {
     # Remember the point where the mouse down occurred. The DragSize indicates
     # the size that the mouse can move before a drag event should be started.    
     $dragSize = [System.Windows.Forms.SystemInformation]::DragSize
     # Create a rectangle using the DragSize, with the mouse position being
     # at the center of the rectangle.
     $x = $eventargs.X - ($dragSize.Width /2 )
     $y = $eventargs.Y- ($dragSize.Height /2)
     $p = new-object System.Drawing.Point($x , $y  )
     $drag_box = new-object System.Drawing.Rectangle( $p , $dragSize)
     $caller.Rect =      $drag_box 
     $label1.Text = ("Drag and drop item[{0}] ?" -f $idx) 

   } else {
     # Reset the rectangle if the mouse is not over an item in the ListBox.
     $drag_box = [System.Drawing.Rectangle]::Empty
   }

}

$handler_drag_target_DragDrop = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.DragEventArgs] $eventargs  
    )

  if($eventargs.Data.GetDataPresent([System.Windows.Forms.DataFormats]::StringFormat)) {

    $str= $eventargs.Data.GetData([System.Windows.Forms.DataFormats]::StringFormat)
    $label1.Text = "DSDDDD"
    $list_drag_target.Items.Add($str) 

  }


}

$handler_drag_target_DragOver = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.DragEventArgs] $eventargs  
    )

     if ( -not $eventargs.Data.GetDataPresent([System.Windows.Forms.DataFormats]::StringFormat)) {

                $eventargs.Effect = [System.Windows.Forms.DragDropEffects]::None
                $label1.Text = "None - no string data." 
                return 
      } else {
                $label1.Text  = "Drops at the end." 
   }

#  $eventargs.Effect = [System.Windows.Forms.DragDropEffects]::All
}

$handler_list_drag_source_QueryContinueDrag = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.QueryContinueDragEventArgs] $eventargs  
    )
}


$handler_drag_source_MouseMove = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.MouseEventArgs] $eventargs 
    )

$label1.Text = $eventargs.Button.ToString()
if (($eventargs.Button -band [System.Windows.Forms.MouseButtons]::Left) -eq [System.Windows.Forms.MouseButtons]::Left) {
$label1.Text = (  "idx = {0}" -f $caller.Idx )
$drag_box  = $caller.Rect 
if (( $drag_box -ne [System.Drawing.Rectangle]::Empty ) -and  
                    -not $drag_box.Contains($eventargs.X, $eventargs.Y)) {

$label1.Text = '# cursor'
}

}
$idx = $caller.Idx
if ($idx  -ne [System.Windows.Forms.ListBox]::NoMatches){

  $drag_item = $list_drag_source.Items[$idx]

[System.Windows.Forms.DragDropEffects] $dde1 = $list_drag_source.DoDragDrop($drag_item, ([System.Windows.Forms.DragDropEffects]::All  -bor [System.Windows.Forms.DragDropEffects]::Link  ) )
if ($dde1 -eq [System.Windows.Forms.DragDropEffects]::All ) {

  $list_drag_source.Items.RemoveAt($list_drag_source.IndexFromPoint($eventargs.X,$eventargs.Y))

}

}
}

[System.Management.Automation.PSMethod] $event_MouseDown = $list_drag_source.Add_MouseDown
[System.Management.Automation.PSMethod] $event_MouseMove  = $list_drag_source.Add_MouseMove 

[System.Management.Automation.PSMethod] $event_DragDrop = $list_drag_target.Add_DragDrop
[System.Management.Automation.PSMethod] $event_DragOver = $list_drag_target.Add_DragOver



$event_DragDrop.Invoke( $handler_drag_target_DragDrop  )
$event_DragOver.Invoke( $handler_drag_target_DragOver  )
$event_MouseMove.Invoke( $handler_drag_source_MouseMove  )
$event_MouseDown.Invoke( $handler_drag_source_MouseDown  )


 $f.Topmost = $True


if ($caller -eq $null ){
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
}

  $f.Add_Shown( { $f.Activate() } )

  [Void] $f.ShowDialog([Win32Window ] ($caller) )

  $list_drag_source.Dispose()
  $list_drag_target.Dispose()
  $f.Dispose()
  $result = $caller.Message
  $caller = $null
  return $result
}

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

$DebugPreference = 'Continue'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$caller.ScriptDirectory = Get-ScriptDirectory
$result = PromptWithDragDropNish 'Items'  $caller 

write-debug ('Selection is : {0}' -f  , $result )



