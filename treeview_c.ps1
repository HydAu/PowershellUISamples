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
  $treeFood = New-Object  System.Windows.Forms.TreeView 
  $components = new-object System.ComponentModel.Container 
  $f.SuspendLayout();
<#
  $f.add_Dispose({
param ([boolan] $disposing)
            if( $disposing )
            {
                if ($components -ne $null) 
                {
                    $components.Dispose()
                }
            }
           $f.Super.Dispose( $disposing )

})

#>

$treeFood.Anchor = ((([System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom) `
                -bor [System.Windows.Forms.AnchorStyles]::Left) `
                -bor [System.Windows.Forms.AnchorStyles]::Right)
            $treeFood.ImageIndex = -1
            $treeFood.Location = new-object System.Drawing.Point(4, 5)
            $treeFood.Name = "treeFood"
            $treeFood.SelectedImageIndex = -1
            $treeFood.Size = new-object System.Drawing.Size(284, 256)
            $treeFood.TabIndex = 1;
            $treeFood_AfterSelect =  $treeFood.add_AfterSelect
            $treeFood_AfterSelect.Invoke({
            param(
            [Object] $sender, 
            [System.Windows.Forms.TreeViewEventArgs] $eventargs 
            )
            if ($eventargs.Action -eq [System.Windows.Forms.TreeViewAction]::ByMouse)
            {
                write-host $eventargs.Node.FullPath
            }

})
            # new System.Windows.Forms.TreeViewEventHandler(this.treeFood_AfterSelect);
            # TreeViewExample
            $f.AutoScaleBaseSize = new-object System.Drawing.Size(5, 13)
            $f.ClientSize = new-object System.Drawing.Size(292, 266)
            $f.Controls.AddRange(@( $treeFood)) 
            $f.Name = "TreeViewExample"
            $f.Text = "TreeView Example" 
            $TreeViewExample_Load = $f.add_Load
            $TreeViewExample_Load.Invoke({
            param(
            [Object] $sender, 
            [System.EventArgs] $eventargs 
            )

            
            $node = $treeFood.Nodes.Add("Fruits") 
            $node.Nodes.Add("Apple") 
            $node.Nodes.Add("Peach") 
            $pie_node = $node.Nodes.Add("Pie") 
            $pie_node.Nodes.Add("Cheese")
            $pie_node.Nodes.Add("Strawberry")
            
            $node = $treeFood.Nodes.Add("Vegetables");
            $node.Nodes.Add("Tomato");
            $node.Nodes.Add("Eggplant");
     
})

  $f.ResumeLayout($false)

  $f.Name = 'Form1'
  $f.Text = 'TreeView Sample'
  $treeFood.ResumeLayout($false)

  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $false

  $f.Topmost = $True
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

  $f.Add_Shown( { $f.Activate() } )

  [Void] $f.ShowDialog([Win32Window ] ($caller) )

  $treeFood.Dispose()
  $f.Dispose()
  $result = $caller.Message
  $caller = $null
  return $result
}

$DebugPreference = 'Continue'
$result = PromptCheckedList ''  'Lorem ipsum dolor sit amet, consectetur adipisicing elit' 

write-debug ('Selection is : {0}' -f  , $result )

