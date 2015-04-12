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


# http://msdn.microsoft.com/en-us/library/system.windows.forms.control.dodragdrop%28v=vs.100%29.aspx
# modified to System.Windows.Forms.Panel

Add-Type -TypeDefinition @"

using System;
using System.Drawing;
using System.Windows.Forms;
using System.Collections;
using System.Collections.Generic;
using System.Text;
public class DragNDrop : Panel
{
    private string _message;
    public string Message
    {
        get
        {
            _message = "";
            List<string> _items = new List<string>();
            foreach (object _item in ListDragTarget.Items)
            {
                _items.Add(_item.ToString());
            }
            _message = String.Join(",", _items.ToArray());
            return _message;
        }
        set { _message = value; }
    }

    private System.Windows.Forms.ListBox ListDragSource;
    private System.Windows.Forms.ListBox ListDragTarget;
    private System.Windows.Forms.CheckBox UseCustomCursorsCheck;
    private System.Windows.Forms.Label DropLocationLabel;

    private int indexOfItemUnderMouseToDrag;
    private int indexOfItemUnderMouseToDrop;

    private Rectangle dragBoxFromMouseDown;
    private Point screenOffset;

    private Cursor MyNoDropCursor;
    private Cursor MyNormalCursor;

    /// The main entry point for the application.

    public DragNDrop(String message)
    {
        _message = message;
        String[] items = _message.Split(new Char[] { ',', ' ' });
        this.ListDragSource = new System.Windows.Forms.ListBox();
        this.ListDragTarget = new System.Windows.Forms.ListBox();
        this.UseCustomCursorsCheck = new System.Windows.Forms.CheckBox();
        this.DropLocationLabel = new System.Windows.Forms.Label();

        this.SuspendLayout();

        // ListDragSource
        this.ListDragSource.Items.AddRange(items);
        this.ListDragSource.Location = new System.Drawing.Point(10, 17);
        this.ListDragSource.Size = new System.Drawing.Size(120, 225);
        this.ListDragSource.MouseDown += new System.Windows.Forms.MouseEventHandler(this.ListDragSource_MouseDown);
        this.ListDragSource.QueryContinueDrag += new System.Windows.Forms.QueryContinueDragEventHandler(this.ListDragSource_QueryContinueDrag);
        this.ListDragSource.MouseUp += new System.Windows.Forms.MouseEventHandler(this.ListDragSource_MouseUp);

        this.ListDragSource.MouseMove += new System.Windows.Forms.MouseEventHandler(this.ListDragSource_MouseMove);
        this.ListDragSource.GiveFeedback += new System.Windows.Forms.GiveFeedbackEventHandler(this.ListDragSource_GiveFeedback);

        // ListDragTarget
        this.ListDragTarget.AllowDrop = true;
        this.ListDragTarget.Location = new System.Drawing.Point(154, 17);
        this.ListDragTarget.Size = new System.Drawing.Size(120, 225);
        this.ListDragTarget.DragOver += new System.Windows.Forms.DragEventHandler(this.ListDragTarget_DragOver);
        this.ListDragTarget.DragDrop += new System.Windows.Forms.DragEventHandler(this.ListDragTarget_DragDrop);
        this.ListDragTarget.DragEnter += new System.Windows.Forms.DragEventHandler(this.ListDragTarget_DragEnter);
        this.ListDragTarget.DragLeave += new System.EventHandler(this.ListDragTarget_DragLeave);

        // UseCustomCursorsCheck
        this.UseCustomCursorsCheck.Location = new System.Drawing.Point(10, 243);
        this.UseCustomCursorsCheck.Size = new System.Drawing.Size(137, 24);
        this.UseCustomCursorsCheck.Text = "Use Custom Cursors";

        // DropLocationLabel
        this.DropLocationLabel.Location = new System.Drawing.Point(154, 245);
        this.DropLocationLabel.Size = new System.Drawing.Size(137, 24);
        this.DropLocationLabel.Text = "None";

        // Form1
        this.ClientSize = new System.Drawing.Size(292, 270);
        this.Controls.AddRange(new System.Windows.Forms.Control[] {this.ListDragSource,
                                                        this.ListDragTarget, this.UseCustomCursorsCheck,
                                                        this.DropLocationLabel});
        this.Text = "drag-and-drop Example";

        this.ResumeLayout(false);

    }

    private void ListDragSource_MouseDown(object sender, System.Windows.Forms.MouseEventArgs e)
    {
        // Get the index of the item the mouse is below.
        indexOfItemUnderMouseToDrag = ListDragSource.IndexFromPoint(e.X, e.Y);

        if (indexOfItemUnderMouseToDrag != ListBox.NoMatches)
        {

            // Remember the point where the mouse down occurred. The DragSize indicates
            // the size that the mouse can move before a drag event should be started.                
            Size dragSize = SystemInformation.DragSize;

            // Create a rectangle using the DragSize, with the mouse position being
            // at the center of the rectangle.
            dragBoxFromMouseDown = new Rectangle(new Point(e.X - (dragSize.Width / 2),
                                                           e.Y - (dragSize.Height / 2)), dragSize);
        }
        else
            // Reset the rectangle if the mouse is not over an item in the ListBox.
            dragBoxFromMouseDown = Rectangle.Empty;

    }

    private void ListDragSource_MouseUp(object sender, System.Windows.Forms.MouseEventArgs e)
    {
        // Reset the drag rectangle when the mouse button is raised.
        dragBoxFromMouseDown = Rectangle.Empty;
    }

    private void ListDragSource_MouseMove(object sender, System.Windows.Forms.MouseEventArgs e)
    {

        if ((e.Button & MouseButtons.Left) == MouseButtons.Left)
        {


            // If the mouse moves outside the rectangle, start the drag.
            if (dragBoxFromMouseDown != Rectangle.Empty &&
                !dragBoxFromMouseDown.Contains(e.X, e.Y))
            {

                // Create custom cursors for the drag-and-drop operation.
                try
                {
                    MyNormalCursor = new Cursor(@"C:\Windows\Cursors\lnodrop.cur");
                    MyNoDropCursor = new Cursor(@"C:\Windows\Cursors\larrow.cur");
                    DropLocationLabel.Text = "!!!";


                }
                catch (Exception ex)
                {
                    // An error occurred while attempting to load the cursors, so use
                    // standard cursors.
                    DropLocationLabel.Text = ex.Message;

                    UseCustomCursorsCheck.Checked = false;
                }
                finally
                {

                    // The screenOffset is used to account for any desktop bands 
                    // that may be at the top or left side of the screen when 
                    // determining when to cancel the drag drop operation.
                    screenOffset = SystemInformation.WorkingArea.Location;

                    // Proceed with the drag-and-drop, passing in the list item.                    
                    DragDropEffects dropEffect = ListDragSource.DoDragDrop(ListDragSource.Items[indexOfItemUnderMouseToDrag], DragDropEffects.All | DragDropEffects.Link);

                    // If the drag operation was a move then remove the item.
                    if (dropEffect == DragDropEffects.Move)
                    {
                        ListDragSource.Items.RemoveAt(indexOfItemUnderMouseToDrag);

                        // Selects the previous item in the list as long as the list has an item.
                        if (indexOfItemUnderMouseToDrag > 0)
                            ListDragSource.SelectedIndex = indexOfItemUnderMouseToDrag - 1;

                        else if (ListDragSource.Items.Count > 0)
                            // Selects the first item.
                            ListDragSource.SelectedIndex = 0;
                    }

                    // Dispose of the cursors since they are no longer needed.
                    if (MyNormalCursor != null)
                        MyNormalCursor.Dispose();

                    if (MyNoDropCursor != null)
                        MyNoDropCursor.Dispose();
                }
            }
        }
    }
    private void ListDragSource_GiveFeedback(object sender, System.Windows.Forms.GiveFeedbackEventArgs e)
    {
        // Use custom cursors if the check box is checked.
        if (UseCustomCursorsCheck.Checked)
        {

            // Sets the custom cursor based upon the effect.
            e.UseDefaultCursors = false;
            if ((e.Effect & DragDropEffects.Move) == DragDropEffects.Move)
                Cursor.Current = MyNormalCursor;
            else
                Cursor.Current = MyNoDropCursor;
        }

    }
    private void ListDragTarget_DragOver(object sender, System.Windows.Forms.DragEventArgs e)
    {

        // Determine whether string data exists in the drop data. If not, then
        // the drop effect reflects that the drop cannot occur.
        if (!e.Data.GetDataPresent(typeof(System.String)))
        {

            e.Effect = DragDropEffects.None;
            DropLocationLabel.Text = "None - no string data.";
            return;
        }

        // Set the effect based upon the KeyState.
        if ((e.KeyState & (8 + 32)) == (8 + 32) &&
            (e.AllowedEffect & DragDropEffects.Link) == DragDropEffects.Link)
        {
            // KeyState 8 + 32 = CTL + ALT

            // Link drag-and-drop effect.
            e.Effect = DragDropEffects.Link;

        }
        else if ((e.KeyState & 32) == 32 &&
          (e.AllowedEffect & DragDropEffects.Link) == DragDropEffects.Link)
        {

            // ALT KeyState for link.
            e.Effect = DragDropEffects.Link;

        }
        else if ((e.KeyState & 4) == 4 &&
          (e.AllowedEffect & DragDropEffects.Move) == DragDropEffects.Move)
        {

            // SHIFT KeyState for move.
            e.Effect = DragDropEffects.Move;

        }
        else if ((e.KeyState & 8) == 8 &&
          (e.AllowedEffect & DragDropEffects.Copy) == DragDropEffects.Copy)
        {

            // CTL KeyState for copy.
            e.Effect = DragDropEffects.Copy;

        }
        else if ((e.AllowedEffect & DragDropEffects.Move) == DragDropEffects.Move)
        {

            // By default, the drop action should be move, if allowed.
            e.Effect = DragDropEffects.Move;

        }
        else
            e.Effect = DragDropEffects.None;

        // Get the index of the item the mouse is below. 

        // The mouse locations are relative to the screen, so they must be 
        // converted to client coordinates.

        indexOfItemUnderMouseToDrop =
            ListDragTarget.IndexFromPoint(ListDragTarget.PointToClient(new Point(e.X, e.Y)));

        // Updates the label text.
        if (indexOfItemUnderMouseToDrop != ListBox.NoMatches)
        {

            DropLocationLabel.Text = "Drops before item #" + (indexOfItemUnderMouseToDrop + 1);
        }
        else
            DropLocationLabel.Text = "Drops at the end.";

    }
    private void ListDragTarget_DragDrop(object sender, System.Windows.Forms.DragEventArgs e)
    {
        // Ensure that the list item index is contained in the data.
        if (e.Data.GetDataPresent(typeof(System.String)))
        {

            Object item = (object)e.Data.GetData(typeof(System.String));

            // Perform drag-and-drop, depending upon the effect.
            if (e.Effect == DragDropEffects.Copy ||
                e.Effect == DragDropEffects.Move)
            {

                // Insert the item.
                if (indexOfItemUnderMouseToDrop != ListBox.NoMatches)
                    ListDragTarget.Items.Insert(indexOfItemUnderMouseToDrop, item);
                else
                    ListDragTarget.Items.Add(item);

            }
        }
        // Reset the label text.
        DropLocationLabel.Text = "None";
    }
    private void ListDragSource_QueryContinueDrag(object sender, System.Windows.Forms.QueryContinueDragEventArgs e)
    {
        // Cancel the drag if the mouse moves off the form.
        ListBox lb = sender as ListBox;

        if (lb != null)
        {

            Form f = lb.FindForm();

            // Cancel the drag if the mouse moves off the form. The screenOffset
            // takes into account any desktop bands that may be at the top or left
            // side of the screen.
            if (((Control.MousePosition.X - screenOffset.X) < f.DesktopBounds.Left) ||
                ((Control.MousePosition.X - screenOffset.X) > f.DesktopBounds.Right) ||
                ((Control.MousePosition.Y - screenOffset.Y) < f.DesktopBounds.Top) ||
                ((Control.MousePosition.Y - screenOffset.Y) > f.DesktopBounds.Bottom))
            {

                e.Action = DragAction.Cancel;
            }
        }
    }
    private void ListDragTarget_DragEnter(object sender, System.Windows.Forms.DragEventArgs e)
    {
        // Reset the label text.
        DropLocationLabel.Text = "None";
    }
    private void ListDragTarget_DragLeave(object sender, System.EventArgs e)
    {
        // Reset the label text.
        DropLocationLabel.Text = "None";
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'

Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Drawing;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _script_directory;
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

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'


# http://msdn.microsoft.com/en-us/library/system.windows.forms.control.dodragdrop%28v=vs.100%29.aspx


function PromptWithDragDropNish {
  param
  (

    [string]$title,
    [object]$caller
  )

  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')


  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $panel = New-Object DragNDrop ($caller.Message)

  $f.ClientSize = New-Object System.Drawing.Size (288,248)
  $f.Controls.AddRange(@( $panel))
  $f.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
  $f.MaximizeBox = $false
  $f.Name = "Form1"
  $f.Text = "Playing with drag and drop"

  $panel.ResumeLayout($false)
  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'
  $f.KeyPreview = $false

  if ($caller -eq $null) {
    $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
  }

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window]($caller))
  $result = $panel.Message
  $panel.Dispose()
  $f.Dispose()

  $caller = $null

  return $result
}

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"))
  }
}

$DebugPreference = 'Continue'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$caller.ScriptDirectory = Get-ScriptDirectory
$data = @(
  'one','two','three','four','five',
  'six','seven','nine','ten','eleven'
)
$caller.Message = $data -join ','
$result = PromptWithDragDropNish 'Items' $caller

# write-debug ('Selection is : {0}' -f  , $result )

$result -split ',' | Format-Table -AutoSize

