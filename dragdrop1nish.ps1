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
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _script_directory;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
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

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

# http://www.codeproject.com/Articles/2006/Drag-and-Drop-between-list-boxes-Beginner-s-Tutori
# This simplified example is not working because the Drag and Drop sender control is not evaluated properly
# A more elaborated example is required.
# http://msdn.microsoft.com/en-us/library/system.windows.forms.control.dodragdrop%28v=vs.100%29.aspx



function PromptWithDragDropNish(
[String] $title, 
        [Object] $caller
){

[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 


$f = New-Object System.Windows.Forms.Form 
$f.Text = $title

$listBox1 = new-object  System.Windows.Forms.ListBox 

$listBox2 =  new-object System.Windows.Forms.ListBox 

$label1 = new-object System.Windows.Forms.Label 

$components = new-object System.ComponentModel.Container
$listBox1.SuspendLayout()
$listBox2.SuspendLayout()
# $tab_contol1.SuspendLayout()


$f.SuspendLayout()


$listBox1.Items.Add("Nish [BusterBoy]")

$listBox1.Items.Add("Colin Davies")

$listBox1.Items.Add("Paul Watson")



$listBox1.Items.Add("David Wulff")

$listBox1.Items.Add("Christian Graus")

$listBox1.Items.Add("Chris Maunder")



$listBox1.Items.Add("Tweety")

$listBox1.Items.Add("Qomi")

$listBox1.Items.Add("Lauren")





$listBox1.Font =  new-object System.Drawing.Font('Microsoft Sans Serif', 11, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]0);

$listBox1.ItemHeight = 24

$listBox1.Location =  new-object System.Drawing.Point(32, 16)

$listBox1.Name = "listBox1" 

$listBox1.Size = new-object System.Drawing.Size(176, 196) 

$listBox1.TabIndex = 0 

# $listBox1.MouseDown += new System.Windows.Forms.MouseEventHandler($listBox1_MouseDown) 



#  listBox2



$listBox2.AllowDrop = true;

$listBox2.Font = new-object System.Drawing.Font('Microsoft Sans Serif', 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]0);

$listBox2.ItemHeight = 24 

$listBox2.Location = new-object System.Drawing.Point(344, 16)

$listBox2.Name = "listBox2" 

$listBox2.Size =  new-object  System.Drawing.Size(176, 196)

$listBox2.TabIndex = 1

# $listBox2.DragOver += new System.Windows.Forms.DragEventHandler($listBox2_DragOver) 

# $listBox2.DragDrop += new System.Windows.Forms.DragEventHandler($listBox2_DragDrop)

 

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



$f.AutoScaleBaseSize = new-object  System.Drawing.Size(5, 13)

$f.ClientSize = new-object  System.Drawing.Size(568, 278)

$f.Controls.AddRange(@(   $label1,   $listBox2,   $listBox1)) 

$f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

$f.MaximizeBox = $false

$f.Name = "Form1"

$f.Text = "Playing with drag and drop"

$listBox1.ResumeLayout($false)
$listBox2.ResumeLayout($false)
$f.ResumeLayout($false)

$f.StartPosition = 'CenterScreen'
$f.KeyPreview = $false

$handler_listbox1_mousedown = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.MouseEventArgs] $eventargs  
    )

if ($listBox1.Items.Count -eq 0) {

  return
}
$indexOfItemUnderMouseToDrag = $listBox1.IndexFromPoint($eventargs.X,$eventargs.Y)
$list_item = $listBox1.Items[$indexOfItemUnderMouseToDrag]

$s = $list_item.ToString() 
# [System.Windows.Forms.DragDropEffects] $dde1= [System.Windows.Forms.Control]::DoDragDrop($sender, [System.Windows.Forms.DragDropEffects]::All )

# [System.Windows.Forms.DragDropEffects] $dde1= $listBox1.DoDragDrop($list_item, (  [System.Windows.Forms.DragDropEffects]::All -bor [System.Windows.Forms.DragDropEffects]::Link ) )
[System.Windows.Forms.DragDropEffects] $dde1= $listBox1.DoDragDrop($s, (  [System.Windows.Forms.DragDropEffects]::All -bor [System.Windows.Forms.DragDropEffects]::Link ) )

if ($dde1 -eq [System.Windows.Forms.DragDropEffects]::All ) {

  $listBox1.Items.RemoveAt($listBox1.IndexFromPoint($eventargs.X,$eventargs.Y))

}



}


$handler_listBox2_DragDrop = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.DragEventArgs] $eventargs  
    )

  if($eventargs.Data.GetDataPresent([System.Windows.Forms.DataFormats]::StringFormat)) {

    $str= $eventargs.Data.GetData([System.Windows.Forms.DataFormats]::StringFormat)

    $listBox2.Items.Add($str) 

  }


}
$handler_listBox2_DragOver = {
  param ( 
    [Object]  $sender, 
    [System.Windows.Forms.DragEventArgs] $eventargs  
    )

  $eventargs.Effect= [System.Windows.Forms.DragDropEffects]::All
}

[System.Management.Automation.PSMethod] $event_listBox2_DragDrop = $listBox2.Add_DragDrop
[System.Management.Automation.PSMethod] $event_listBox2_DragOver = $listBox2.Add_DragOver
[System.Management.Automation.PSMethod] $event_listbox1_mousedown = $listBox1.Add_MouseDown

$event_listBox2_DragDrop.Invoke( $handler_listBox2_DragDrop  )
$event_listBox2_DragOver.Invoke( $handler_listBox2_DragOver  )
$event_listbox1_mousedown.Invoke( $handler_listbox1_mousedown  )

 $f.Topmost = $True
if ($caller -eq $null ){
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
}

  $f.Add_Shown( { $f.Activate() } )

  [Void] $f.ShowDialog([Win32Window ] ($caller) )

  $listBox1.Dispose()
  $listBox2.Dispose()
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

