#Copyright (c) 2016 Serguei Kouzmine
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


// https://msdn.microsoft.com/en-us/library/system.windows.forms.treeView1.checkboxes%28v=vs.110%29.aspx
// http://www.lidorsystems.com/support/articles/treeview-threestate.aspx

using System;
using System.Drawing;
using System.Windows.Forms;

public class TreeViewSample: System.Windows.Forms.Panel
{
    private TreeView treeView1;
    private Button showCheckedNodesButton;
    private TreeViewCancelEventHandler checkForCheckedChildren;
    private bool isDrawing = false;
    public TreeViewSample()
    {
        treeView1 = new TreeView();
        showCheckedNodesButton = new Button();
        checkForCheckedChildren =
            new TreeViewCancelEventHandler(CheckForCheckedChildrenHandler);

        this.SuspendLayout();

        // Initialize treeView1.
        treeView1.Location = new Point(0, 25);
        treeView1.Size = new Size(292, 248);
        treeView1.Anchor = AnchorStyles.Top | AnchorStyles.Left |
            AnchorStyles.Bottom | AnchorStyles.Right;
        treeView1.CheckBoxes = true;

        // http://www.codeproject.com/Questions/611278/howplustoplusaddpluscheckboxplusinpluschildnodespl
        // http://dotnetfollower.com/wordpress/2011/05/winforms-treeview-hide-checkbox-of-treenode/
        // treeView1.DrawMode = TreeViewDrawMode.OwnerDrawAll;

        // treeView1.DrawNode += treeView_DrawNode;
        // Add nodes to treeView1.
        TreeNode node;
        for (int x = 0; x < 3; ++x)
        {
            // Add a root node.
            node = treeView1.Nodes.Add(String.Format("Node{0}", x * 4));
            // 
            for (int y = 1; y < 4; ++y)
            {
                // Add a node as a child of the previously added node.
                node = node.Nodes.Add(String.Format("Node{0}", x * 4 + y));
            }
        }

        // Set the checked state of one of the nodes to
        // demonstrate the showCheckedNodesButton button behavior.
        treeView1.Nodes[1].Nodes[0].Nodes[0].Checked = true;

        // Initialize showCheckedNodesButton.
        showCheckedNodesButton.Size = new Size(144, 24);
        showCheckedNodesButton.Text = "Show Checked Nodes";
        showCheckedNodesButton.Click +=
            new EventHandler(showCheckedNodesButton_Click);

        // Initialize the form.
        this.ClientSize = new Size(292, 273);
        this.Controls.AddRange(new Control[] { showCheckedNodesButton, treeView1 });
        // add AfterCheck event handler  
        treeView1.AfterCheck += treeView1_AfterCheck;

        this.ResumeLayout(false);
    }
/*
    [STAThreadAttribute()]
    static void Main()
    {
        Application.Run(new TreeViewSample());
    }
*/
    private void showCheckedNodesButton_Click(object sender, EventArgs e)
    {
        // Disable redrawing of treeView1 to prevent flickering 
        // while changes are made.
        treeView1.BeginUpdate();

        // Collapse all nodes of treeView1.
        treeView1.CollapseAll();

        // Add the checkForCheckedChildren event handler to the BeforeExpand event.
        treeView1.BeforeExpand += checkForCheckedChildren;

        // Expand all nodes of treeView1. Nodes without checked children are 
        // prevented from expanding by the checkForCheckedChildren event handler.
        treeView1.ExpandAll();

        // Remove the checkForCheckedChildren event handler from the BeforeExpand 
        // event so manual node expansion will work correctly.
        treeView1.BeforeExpand -= checkForCheckedChildren;

        // Enable redrawing of treeView1.
        treeView1.EndUpdate();
    }


    private void treeView_DrawNode(object sender, DrawTreeNodeEventArgs e)
    {
        // http://stackoverflow.com/questions/5626031/tri-state-checkboxes-in-winforms-treeview
        // https://msdn.microsoft.com/en-us/library/system.windows.forms.drawtreenodeeventargs.node%28v=vs.110%29.aspx
        // https://developer.xamarin.com/api/type/System.Windows.Forms.DrawTreeNodeEventHandler/
        // http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=6&cad=rja&uact=8&ved=0ahUKEwir-56i95_KAhVMpx4KHaeaDXIQFgg_MAU&url=http%3A%2F%2Fstackoverflow.com%2Fquestions%2F5626031%2Ftri-state-checkboxes-in-winforms-treeview&usg=AFQjCNHDv9ekArYnuIbNiOCnW1XbRwTyLw&bvm=bv.111396085,d.dmo
        // TODO : draw all levels 
        if (e.Node.Parent == null)
        {
            int d = (int)(0.2 * e.Bounds.Height);
            Rectangle rect = new Rectangle(d + treeView1.Margin.Left, d + e.Bounds.Top, e.Bounds.Height - d * 2, e.Bounds.Height - d * 2);
            e.Graphics.FillRectangle(new SolidBrush(Color.FromKnownColor(KnownColor.Control)), rect);
            e.Graphics.DrawRectangle(Pens.Silver, rect);
            StringFormat sf = new StringFormat() { LineAlignment = StringAlignment.Center, Alignment = StringAlignment.Center };
            e.Graphics.DrawString(e.Node.IsExpanded ? "-" : "+", treeView1.Font, new SolidBrush(Color.Blue), rect, sf);
            //Draw the dotted line connecting the expanding/collapsing button and the node Text
            using (Pen dotted = new Pen(Color.Black) { DashStyle = System.Drawing.Drawing2D.DashStyle.Dot })
            {
                e.Graphics.DrawLine(dotted, new Point(rect.Right + 1, rect.Top + rect.Height / 2), new Point(rect.Right + 4, rect.Top + rect.Height / 2));
            }
            //Draw text
            sf.Alignment = StringAlignment.Near;
            Rectangle textRect = new Rectangle(e.Bounds.Left + rect.Right + 4, e.Bounds.Top, e.Bounds.Width - rect.Right - 4, e.Bounds.Height);
            if (e.Node.IsSelected)
            {
                SizeF textSize = e.Graphics.MeasureString(e.Node.Text, treeView1.Font);
                e.Graphics.FillRectangle(new SolidBrush(SystemColors.Highlight), new RectangleF(textRect.Left, textRect.Top, textSize.Width, textRect.Height));
            }
            e.Graphics.DrawString(e.Node.Text, treeView1.Font, new SolidBrush(treeView1.ForeColor), textRect, sf);
        }
        else e.DrawDefault = true;
    }

    private void checkNodes(TreeNode node, bool isChecked)
    {
        foreach (TreeNode child in node.Nodes)
        {
            child.Checked = isChecked;
            //  https://msdn.microsoft.com/en-us/library/system.winTreeNode.Checked
            //  to support CheckState
            //  https://msdn.microsoft.com/en-us/library/system.windows.forms.checkstate%28v=vs.110%29.aspx
            //  one has to draw the node fully oneself
            checkNodes(child, isChecked);
        }
    }

    // https://msdn.microsoft.com/en-us/library/system.windows.forms.treeView1.aftercheck%28v=vs.110%29.aspx
    private void treeView1_AfterCheck(object sender, TreeViewEventArgs e)
    {

        // http://stackoverflow.com/questions/5478984/treeview-with-checkboxes-in-c-sharp
        if (isDrawing) return;
        isDrawing = true;
        try
        {
            checkNodes(e.Node, e.Node.Checked);
        }
        finally
        {
            isDrawing = false;
        }
    }

    // Prevent expansion of a node that does not have any checked child nodes.
    private void CheckForCheckedChildrenHandler(object sender,
        TreeViewCancelEventArgs e)
    {
        if (!HasCheckedChildNodes(e.Node)) e.Cancel = true;
    }

    // Returns a value indicating whether the specified 
    // TreeNode has checked child nodes.
    private bool HasCheckedChildNodes(TreeNode node)
    {
        if (node.Nodes.Count == 0) return false;
        foreach (TreeNode childNode in node.Nodes)
        {
            if (childNode.Checked) return true;
            // Recursively check the children of the current child node.
            if (HasCheckedChildNodes(childNode)) return true;
        }
        return false;
    }
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Data.dll','System.Drawing.dll'



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


function PromptTreeView
{
  param(
    [string]$title,
    [object]$caller = $null
  )

  @( 'System.Drawing','System.Collections.Generic','System.Collections','System.ComponentModel','System.Text','System.Data','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title
  $t = New-Object TreeViewSample
  $components = New-Object System.ComponentModel.Container
  $t.Size = New-Object System.Drawing.Size (284,256)

  $f.SuspendLayout()
  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
  $f.ClientSize = New-Object System.Drawing.Size (292,266)
  $f.Controls.Add($t)
  $f.ResumeLayout($false)
  $f.Topmost = $True
  if ($caller -eq $null) {
    $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
  }
  # TODO: convert $t_AfterSelect = $t.add_AfterSelect
  # $caller.Message +=
  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window]($caller))

  $t.Dispose()
  $f.Dispose()
  # return $caller.MEssage

}

$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$result = PromptTreeView 'Treeview' $caller

Write-Debug ('Selection is : {0}' -f $result)
