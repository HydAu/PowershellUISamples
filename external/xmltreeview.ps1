#Copyright (c) 2015 Serguei Kouzmine
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


# will copy paste ?
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

Add-Type -TypeDefinition @"

using System;
using System.IO;
using System.Drawing;
using System.Windows.Forms;
using System.ComponentModel;
using System.Drawing.Printing;
using System.Xml;
using System.Threading;
using System.Collections;

namespace Modified.Tom.XmlControls
{
    internal class InnerTextBox : TextBox, IXmlControl
    {
        private XmlTreeView parent = null;
        private string draggedFile = string.Empty;
        private PrintDocument printDocument1 = new PrintDocument();
        private int startPos;
        private int xPos;
        private Font printFont = new Font( "Arial", 10 );
        private bool caseSensitive;
        private string criterion;
        private int printableWidth;
        private float fontHeight;
        private float linesPerPage;
        private bool closingHandlerAssigned;

        internal InnerTextBox(XmlTreeView container)
        {
            parent = container;
            ReadOnly = true;
            Multiline = true;
            Dock = DockStyle.Fill;
            ScrollBars = ScrollBars.Both;
        }

        public void Search( object sender, EventArgs e )
        {
            if ( Text.Length > 0 )
            {
                new SearchDlg( this ).Show();
            }
        }

        public void StartSearch( string criterion, bool caseSensitive )
        {
            startPos = 0;
            this.caseSensitive = caseSensitive;
            this.criterion = caseSensitive ? criterion : criterion.ToUpper();
        }

        public void Next()
        {
            int foundPos = 0;
            SelectionLength = 0;
            string internalText = caseSensitive ? Text : Text.ToUpper();

            if ( internalText.Length > 0 )
            {
                if ( ( foundPos = internalText.IndexOf( criterion, startPos ) ) > -1 )
                {
                    SelectionStart = foundPos;
                    SelectionLength = criterion.Length;
                    startPos = foundPos + criterion.Length;
                    Focus();
                }
                else
                {
                    MessageBox.Show( "End of text reached !", XmlTreeView.MessageBoxTitle );
                    startPos = 0;
                }
            }
        }

        public void Print( object sender, EventArgs e )
        {
            if ( Text.Length > 0 && parent.PrintDialog.ShowDialog() == DialogResult.OK )
            {
                printDocument1.Print();
            }
        }
        
        public void PrintPage( object sender, PrintPageEventArgs e )
        {
            int linesPrinted = 0;
            float yPos = 0;
            bool endOfPageReached = false;
            string textToDraw = string.Empty;

            if (fontHeight == 0.0)
            {    // nothing initialized yet
                fontHeight = printFont.GetHeight( e.Graphics );
                linesPerPage = e.MarginBounds.Height / fontHeight;
                printableWidth = Text.Length / ((int) (e.Graphics.MeasureString( Text, printFont ).Width / e.MarginBounds.Width));
            }

            do 
            {
                if ( xPos < Text.Length - 1 )
                {
                    textToDraw = xPos + printableWidth < Text.Length - 1 ? Text.Substring( xPos, printableWidth ) : Text.Substring( xPos );
                    e.Graphics.DrawString( textToDraw, printFont, Brushes.Black, e.MarginBounds.Left, yPos, new StringFormat() );
                    yPos += fontHeight;
                    xPos += printableWidth;
                    ++linesPrinted;
                }

                if ( xPos >= Text.Length || linesPrinted >= linesPerPage )
                {
                    endOfPageReached = true;
                }
            } while ( textToDraw.Length > 0 && !endOfPageReached );

            e.HasMorePages = ( xPos < Text.Length - 1 );
        }

        public PrintDocument PrintDocument
        {
            get
            {
                return printDocument1;
            }
        }

        public void Edit(object sender, System.EventArgs e)
        {
            if ( !closingHandlerAssigned )
            {
                Form parentForm = FindForm();
                parentForm.Closing += new CancelEventHandler( parent.form_Closing );
                closingHandlerAssigned = true;
            }

            ReadOnly = false;
        }

        public void Delete(object sender, System.EventArgs e)
        {
            Text = Text.Remove( SelectionStart, SelectionLength );
        }

        public void Copy(object sender, System.EventArgs e)
        {
            Copy();
        }

        public void Paste(object sender, System.EventArgs e)
        {
            IDataObject dataObject = Clipboard.GetDataObject();

            if ( dataObject.GetDataPresent( DataFormats.Text ) )
            {
                parent.Xml = (string) dataObject.GetData( DataFormats.Text );
            }
        }

        public void Save(object sender, System.EventArgs e)
        {
            if ( Text.Length > 0 && parent.SaveDialog.ShowDialog() == DialogResult.OK )
            {
                using ( StreamWriter sw = new StreamWriter( parent.SaveDialog.FileName ) )
                {
                    sw.Write( Xml );
                    parent.fileXml = Xml;
                    parent.filePath = parent.SaveDialog.FileName;
                }
            }
        }

        public string Xml
        {
            get
            {
                return Text;
            }
            set
            {
                Text = value;
            }
        }

        protected override void OnKeyUp( KeyEventArgs e )
        {
            base.OnKeyUp( e );

            if ( e.Control && e.KeyCode == Keys.C )
            {
                Copy( null, null );
            }    
            else if ( e.Control && e.KeyCode == Keys.V )
            {
                Paste( null, null );
            }
            else if ( e.Control && e.KeyCode == Keys.F )
            {
                Search( null, null );
            }
            else if ( e.Control && e.KeyCode == Keys.P )
            {
                Print( null, null );
            }
            else if ( e.Control && e.KeyCode == Keys.S )
            {
                Save( null, null );
            }
            else if ( e.KeyCode == Keys.Delete )
            {
                Delete( null, null );
            }
            else if ( e.KeyCode == Keys.Insert )
            {
                Edit( null, null );
            }
        }

        protected override void OnDragEnter( DragEventArgs e )
        {
            base.OnDragEnter( e );

            if ( e.Data.GetDataPresent( DataFormats.FileDrop ) )
            {
                e.Effect = DragDropEffects.Copy;
                draggedFile = (string) ( (object[]) e.Data.GetData( DataFormats.FileDrop ) )[0];
            }
        }

        protected override void OnDragDrop( DragEventArgs e )
        {
            base.OnDragDrop( e );

            if ( draggedFile.Length > 0 )
            {
                using ( StreamReader fs = new StreamReader( draggedFile ) )
                {
                    parent.fileXml = fs.ReadToEnd();
                    parent.Xml = parent.fileXml;
                    parent.filePath = draggedFile;
                }

                draggedFile = string.Empty;
            }
        }
    }

    internal class InnerXmlTreeView : TreeView, IXmlControl
    {
        private XmlDocument document = null;
        private XmlTreeView parent = null;
        private string draggedFile = string.Empty;
        private static TreeNode CurrentNode = null;
        private ArrayList foundList = new ArrayList( 100 );
        private bool foundNode;
        private string searchText;
        private bool caseSensitive;
        private Font printFont = new Font( "Arial", 10 );
        private float linesPerPage = 0;
        private float yPos =  0;
        private int count = 0;
        private string indent = string.Empty;
        private float leftMargin = 0;
        private float topMargin = 0;
        private bool endOfPageReached = false;
        private ArrayList printedNodes = new ArrayList( 1000 );
        private PrintPageEventArgs eventArgs = null;
        private TextBox editBox;
        private XmlTreeNode editingNode;
        private PrintDocument printDocument1 = new PrintDocument();
        private bool closingHandlerAssigned;

        public InnerXmlTreeView(XmlTreeView container)
        {
            parent = container;
            AllowDrop = true;
            Dock = System.Windows.Forms.DockStyle.Fill;
            ImageIndex = -1;
            SelectedImageIndex = -1;
            Size = new System.Drawing.Size(150, 130);
            TabIndex = 0;
            document = new XmlDocument();
            ShowLines = false;
        }

        public void Search( object sender, EventArgs e )
        {
            if ( Nodes.Count > 0 )
            {
                new SearchDlg( this ).Show();
            }
        }

        public void StartSearch( string criterion, bool caseSensitive )
        {
            foundList.Clear();
            this.caseSensitive = caseSensitive;
            searchText = caseSensitive ? criterion : criterion.ToUpper();
        }

        public void Next()
        {
            SelectedNode.BackColor = Color.Empty;
            foundNode = false;

            RecurseTreeNodes( Nodes );

            if ( !foundNode )
            {
                MessageBox.Show( "End of tree reached !", XmlTreeView.MessageBoxTitle );
                foundList.Clear();
            }
        }

        public void Print( object sender, EventArgs e )
        {
            if ( Nodes.Count > 0 && parent.PrintDialog.ShowDialog() == DialogResult.OK )
            {
                printedNodes.Clear();
                printDocument1.Print();
            }
        }

        public void PrintPage( object sender, PrintPageEventArgs e ) 
        {
            yPos = 0;
            count = 0;
            endOfPageReached = false;
            eventArgs = e;
            eventArgs.HasMorePages = false;
            leftMargin = eventArgs.MarginBounds.Left;
            topMargin = eventArgs.MarginBounds.Top;
            linesPerPage = eventArgs.MarginBounds.Height / printFont.GetHeight( eventArgs.Graphics );

            // Iterate over the file, printing each line.
            RecursePrintTreeNodes( Nodes );
        }

        public PrintDocument PrintDocument
        {
            get
            {
                return printDocument1;
            }
        }

        public void Edit(object sender, System.EventArgs e)
        {
            if ( Nodes.Count > 0 && SelectedNode != null && parent.LabelEdit )
            {
                editingNode = (XmlTreeNode) SelectedNode;

                if ( editingNode.ConnectedXmlElement != null )
                {
                    if ( !closingHandlerAssigned )
                    {
                        Form parentForm = FindForm();
                        parentForm.Closing += new CancelEventHandler( parent.form_Closing );
                        closingHandlerAssigned = true;
                    }

                    int height = editingNode.Bounds.Height;
                    int width =  editingNode.Bounds.Width;
                    int left = editingNode.Bounds.Left;
                    int top = editingNode.Bounds.Top;

                    editingNode.ExpandAll();

                    if ( editingNode.ConnectedXmlElement.HasChildNodes && editingNode.ConnectedXmlElement.FirstChild.NodeType != XmlNodeType.Text )
                    {
                        height = editingNode.NextNode.Bounds.Bottom - editingNode.Bounds.Top;
                        width = Width - left;
                    }

                    editBox = new TextBox();
                    editBox.Multiline = true;
                    editBox.BorderStyle = BorderStyle.FixedSingle;
                    editBox.ScrollBars = ScrollBars.Both;
                    editBox.Leave += new EventHandler( editBox_Leave );
                    editBox.KeyUp += new KeyEventHandler( editBox_KeyUp );
                    editBox.SetBounds( left, top, width, height );
                    editingNode.RecurseSubNodes( editingNode.Parent );
                    editBox.Text = editingNode.SelfAndChildren;
                    Controls.Add( editBox );
                    editBox.Focus();
                }
            }
        }

        public void Copy(object sender, System.EventArgs e)
        {
            if ( Nodes.Count > 0 )
            {
                Clipboard.SetDataObject( Xml, true );
            }
        }

        public void Paste(object sender, System.EventArgs e)
        {
            IDataObject dataObject = Clipboard.GetDataObject();

            if ( dataObject.GetDataPresent( DataFormats.Text ) )
            {
                parent.Xml = (string) dataObject.GetData( DataFormats.Text );
            }
        }

        public void Delete(object sender, System.EventArgs e)
        {
            if ( Nodes.Count > 0 && null != SelectedNode && parent.LabelEdit )
            {
                string tmp = Xml;

                try
                {
                    XmlNode elemToRemove = ( (XmlTreeNode) SelectedNode ).ConnectedXmlElement;

                    if ( null != elemToRemove )
                    {
                        elemToRemove.ParentNode.RemoveChild( elemToRemove );
                    
                        if ( SelectedNode.NextNode.Text.Equals( "</" + elemToRemove.Name + ">" ) )
                        {
                            SelectedNode.NextNode.Remove();
                        }

                        SelectedNode.Remove();
                    }
                }
                catch 
                {
                    MessageBox.Show( "Cannot delete this node ! Rolling back...", XmlTreeView.MessageBoxTitle );
                    parent.Xml = tmp;
                }
            }     
        }

        public void Save(object sender, System.EventArgs e)
        {
            if ( Nodes.Count > 0 && parent.SaveDialog.ShowDialog() == DialogResult.OK )
            {
                using ( StreamWriter sw = new StreamWriter( parent.SaveDialog.FileName ) )
                {
                    sw.Write( Xml );
                    parent.fileXml = Xml;
                    parent.filePath = parent.SaveDialog.FileName;
                }
            }
        }

        public string Xml
        {
            get
            {
                return document.OuterXml;
            }
            set
            {
                if ( value.Length > 0 )
                {
                    LoadXml( value );
                }
            }
        }

        private void editBox_Leave( object sender, EventArgs e )
        {
            if ( Controls.Contains( editBox ) )
            {
                editBox.Leave -= new EventHandler( editBox_Leave ); 
                editBox.KeyUp -= new KeyEventHandler( editBox_KeyUp ); 
                Controls.Remove( editBox );
                editingNode.Text = editBox.Text;
                editBox.Dispose();
            }
        }

        private void editBox_KeyUp( object sender, KeyEventArgs e )
        {
            if ( e.KeyCode == Keys.Escape )
            {
                editBox.Leave -= new EventHandler( editBox_Leave ); 
                editBox.KeyUp -= new KeyEventHandler( editBox_KeyUp ); 
                Controls.Remove( editBox );
                editBox.Dispose();
            }
        }

        private void RecursePrintTreeNodes( TreeNodeCollection coll )
        {
            if ( !endOfPageReached )
            {
                foreach ( TreeNode node in coll )
                {
                    if ( endOfPageReached )
                    {
                        break;
                    }

                    if ( !printedNodes.Contains( node ) )
                    {
                        string textToDraw = indent + node.Text;
                        float textWidthPx = 0;

                        yPos = topMargin + ( count * printFont.GetHeight() );

                        if ( ( textWidthPx = eventArgs.Graphics.MeasureString( textToDraw, printFont ).Width ) > eventArgs.MarginBounds.Width )
                        {
                            int startPos = 0;
                            float pixPerChar = textWidthPx / textToDraw.Length;
                            int maxCharsPerLine = (int)( eventArgs.MarginBounds.Width / pixPerChar );

                            while ( ( startPos + maxCharsPerLine ) < textToDraw.Length )
                            {
                                eventArgs.Graphics.DrawString( textToDraw.Substring( startPos, maxCharsPerLine ), printFont, Brushes.Black, leftMargin, yPos, new StringFormat() );
                                startPos += maxCharsPerLine;
                                yPos += printFont.GetHeight();
                                ++count;
                            }

                            eventArgs.Graphics.DrawString( textToDraw.Substring( startPos ), printFont, Brushes.Black, leftMargin, yPos, new StringFormat() );
                        }
                        else
                        {
                            eventArgs.Graphics.DrawString( textToDraw, printFont, Brushes.Black, leftMargin, yPos, new StringFormat() );
                        }

                        ++count;
                        printedNodes.Add( node );
                    }
                    
                    if ( endOfPageReached = ( count >= linesPerPage ) )
                    {
                        eventArgs.HasMorePages = true;
                        break;
                    }

                    if ( node.Nodes.Count > 0 )
                    {
                        indent += "    ";
                        RecursePrintTreeNodes( node.Nodes );
                    }
                }
            }

            if ( indent.Length > 0 )
            {
                indent = indent.Substring( 0, indent.Length - 4 );
            }
        }

        private void RecurseTreeNodes( TreeNodeCollection nodes )
        {
            if ( !foundNode )
            {
                string nodeText = null;

                foreach ( TreeNode node in nodes )
                {
                    if ( foundNode )
                    {
                        break;
                    }

                    nodeText = caseSensitive ? node.Text : node.Text.ToUpper();

                    if ( nodeText.IndexOf( searchText ) > -1  && !foundList.Contains( node ) )
                    {
                        SelectedNode = node;
                        SelectedNode.BackColor = Color.Blue;
                        foundList.Add( node );
                        foundNode = true;
                        break;
                    }

                    if ( node.Nodes.Count > 0 )
                    {
                        RecurseTreeNodes( node.Nodes );
                    }
                }
            }
        }

        private void LoadXml( string xml )
        {
            SuspendLayout();
            document.LoadXml( xml );

            Nodes.Clear();

            if ( xml.StartsWith( "<?" ) )
            {
                Nodes.Add( new XmlTreeNode( xml.Substring( 0, xml.IndexOf( "?>" ) + 2 ), null ) );
            }

            RecurseAndAssignNodes( document.DocumentElement );

            ExpandAll();
            ResumeLayout( false );
        }

        private void RecurseAndAssignNodes( XmlNode elem )
        {
            string attrs = string.Empty;
            XmlTreeNode addedNode = null;

            if ( elem.NodeType == XmlNodeType.Element )
            {
                foreach ( XmlAttribute attr in elem.Attributes )
                {
                    attrs += " " + attr.Name + "=\"" + attr.Value + "\"";
                }
            }

            if ( elem.Equals( document.DocumentElement ) )
            {
                addedNode = new XmlTreeNode( "<" + elem.Name + attrs + ">", elem );
                Nodes.Add( addedNode );
                InnerXmlTreeView.CurrentNode = addedNode;
                Nodes.Add( new XmlTreeNode( "</" + elem.Name + ">", null ) );
            }
            else if ( elem.HasChildNodes && elem.ChildNodes[0].NodeType == XmlNodeType.Text )
            {
                addedNode = new XmlTreeNode( "<" + elem.Name + attrs + ">" + elem.InnerText + "</" + elem.Name + ">", elem );
                InnerXmlTreeView.CurrentNode.Nodes.Add( addedNode );
                InnerXmlTreeView.CurrentNode = addedNode;
            }
            else if ( elem is XmlElement && ( (XmlElement) elem ).IsEmpty )
            {
                addedNode = new XmlTreeNode( "<" + elem.Name + attrs + "/>", elem );
                InnerXmlTreeView.CurrentNode.Nodes.Add( addedNode );
                InnerXmlTreeView.CurrentNode = addedNode;
            }
            else
            {
                addedNode = new XmlTreeNode( "<" + elem.Name + attrs + ">", elem );
                InnerXmlTreeView.CurrentNode.Nodes.Add( addedNode );
                InnerXmlTreeView.CurrentNode = addedNode;
                InnerXmlTreeView.CurrentNode.Parent.Nodes.Add( new XmlTreeNode( "</" + elem.Name + ">", null ) );
            }

            foreach ( XmlNode child in elem.ChildNodes )
            {
                if ( child.NodeType == XmlNodeType.Element )
                {
                    RecurseAndAssignNodes( child );
                }
                else if ( child.NodeType == XmlNodeType.Comment )
                {
                    InnerXmlTreeView.CurrentNode.Nodes.Add( new XmlTreeNode( child.OuterXml, child ) );
                }
            }

            if ( InnerXmlTreeView.CurrentNode.Parent != null )
            {
                InnerXmlTreeView.CurrentNode = InnerXmlTreeView.CurrentNode.Parent;
            }
        }

        protected override void OnKeyUp( KeyEventArgs e )
        {
            base.OnKeyUp( e );

            if ( e.Control && e.KeyCode == Keys.C )
            {
                Copy( null, null );
            }    
            else if ( e.Control && e.KeyCode == Keys.V )
            {
                Paste( null, null );
            }
            else if ( e.Control && e.KeyCode == Keys.F )
            {
                Search( null, null );
            }
            else if ( e.Control && e.KeyCode == Keys.P )
            {
                Print( null, null );
            }
            else if ( e.Control && e.KeyCode == Keys.S )
            {
                Save( null, null );
            }
            else if ( e.KeyCode == Keys.Delete )
            {
                Delete( null, null );
            }
            else if ( e.KeyCode == Keys.Insert )
            {
                Edit( null, null );
            }
        }

        protected override void OnDragEnter( DragEventArgs e )
        {
            base.OnDragEnter( e );

            if ( e.Data.GetDataPresent( DataFormats.FileDrop ) )
            {
                e.Effect = DragDropEffects.Copy;
                draggedFile = (string) ( (object[]) e.Data.GetData( DataFormats.FileDrop ) )[0];
            }
        }

        protected override void OnDragDrop( DragEventArgs e )
        {
            base.OnDragDrop( e );

            if ( draggedFile.Length > 0 )
            {
                using ( StreamReader fs = new StreamReader( draggedFile ) )
                {
                    parent.fileXml = fs.ReadToEnd();
                    parent.Xml = parent.fileXml;
                    parent.filePath = draggedFile;
                }

                draggedFile = string.Empty;
            }
        }

        protected override void OnDoubleClick( EventArgs e )
        {
            if ( SelectedNode.Parent != null && ( (XmlTreeNode) SelectedNode ).ConnectedXmlElement != null )
            {
                Edit( null, null );
            }
            else
            {
                MessageBox.Show( "Sorry, cannot edit this node !", XmlTreeView.MessageBoxTitle );
            }
        }
    }

    internal interface IXmlControl
    {
        string Xml { get; set; }

        void Search( object sender, EventArgs e );
        void StartSearch( string criterion, bool caseSensitive );
        void Next();

        void Print( object sender, EventArgs e );
        void PrintPage( object sender, PrintPageEventArgs e );
        PrintDocument PrintDocument { get; }

        void Edit(object sender, System.EventArgs e);
        void Delete(object sender, System.EventArgs e);
        void Copy(object sender, System.EventArgs e);
        void Paste(object sender, System.EventArgs e);

        void Save(object sender, System.EventArgs e);
    }

    internal class SearchDlg : System.Windows.Forms.Form
    {
        private System.Windows.Forms.TextBox searchTextBox;
        private System.Windows.Forms.Button goBtn;
        private System.Windows.Forms.Button cancelBtn;
        private System.Windows.Forms.Label label1;
        private IXmlControl iterator;
        private System.Windows.Forms.RadioButton caseSensitiveRBtn;
        private System.Windows.Forms.RadioButton caseInsensitiveRBtn;

        private System.ComponentModel.Container components = null;

        internal SearchDlg( IXmlControl iterator )
        {
            this.iterator = iterator;
            InitializeComponent();
            searchTextBox.Focus();
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
            this.searchTextBox = new System.Windows.Forms.TextBox();
            this.goBtn = new System.Windows.Forms.Button();
            this.cancelBtn = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.caseSensitiveRBtn = new System.Windows.Forms.RadioButton();
            this.caseInsensitiveRBtn = new System.Windows.Forms.RadioButton();
            this.SuspendLayout();
            // 
            // searchTextBox
            // 
            this.searchTextBox.Location = new System.Drawing.Point(24, 24);
            this.searchTextBox.Name = "searchTextBox";
            this.searchTextBox.Size = new System.Drawing.Size(240, 20);
            this.searchTextBox.TabIndex = 0;
            this.searchTextBox.Text = "";
            this.searchTextBox.TextChanged += new System.EventHandler(this.searchTextBox_TextChanged);
            this.searchTextBox.KeyUp += new System.Windows.Forms.KeyEventHandler(this.searchTextBox_KeyUp);
            // 
            // goBtn
            // 
            this.goBtn.Location = new System.Drawing.Point(48, 80);
            this.goBtn.Name = "goBtn";
            this.goBtn.TabIndex = 1;
            this.goBtn.Text = "Go !";
            this.goBtn.Click += new System.EventHandler(this.goBtn_Click);
            // 
            // cancelBtn
            // 
            this.cancelBtn.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.cancelBtn.Location = new System.Drawing.Point(168, 80);
            this.cancelBtn.Name = "cancelBtn";
            this.cancelBtn.TabIndex = 2;
            this.cancelBtn.Text = "Cancel";
            this.cancelBtn.Click += new System.EventHandler(this.cancelBtn_Click);
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(24, 8);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(64, 16);
            this.label1.TabIndex = 3;
            this.label1.Text = "Search for :";
            // 
            // caseSensitiveRBtn
            // 
            this.caseSensitiveRBtn.Location = new System.Drawing.Point(154, 48);
            this.caseSensitiveRBtn.Name = "caseSensitiveRBtn";
            this.caseSensitiveRBtn.TabIndex = 4;
            this.caseSensitiveRBtn.Text = "case sensitive";
            this.caseSensitiveRBtn.CheckedChanged += new System.EventHandler(this.caseSensitiveRBtn_CheckedChanged);
            // 
            // caseInsensitiveRBtn
            // 
            this.caseInsensitiveRBtn.Checked = true;
            this.caseInsensitiveRBtn.Location = new System.Drawing.Point(30, 48);
            this.caseInsensitiveRBtn.Name = "caseInsensitiveRBtn";
            this.caseInsensitiveRBtn.TabIndex = 5;
            this.caseInsensitiveRBtn.TabStop = true;
            this.caseInsensitiveRBtn.Text = "case insensitive";
            // 
            // SearchDlg
            // 
            this.AcceptButton = this.goBtn;
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.CancelButton = this.cancelBtn;
            this.ClientSize = new System.Drawing.Size(288, 118);
            this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                          this.caseInsensitiveRBtn,
                                                                          this.caseSensitiveRBtn,
                                                                          this.label1,
                                                                          this.cancelBtn,
                                                                          this.goBtn,
                                                                          this.searchTextBox});
            this.MaximizeBox = false;
            this.MaximumSize = new System.Drawing.Size(296, 152);
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(296, 152);
            this.Name = "SearchDlg";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Search";
            this.TopMost = true;
            this.ResumeLayout(false);

        }
        private void cancelBtn_Click(object sender, System.EventArgs e)
        {
            Close();
        }

        private void goBtn_Click(object sender, System.EventArgs e)
        {
            iterator.Next();
            searchTextBox.Focus();
        }

        private void searchTextBox_TextChanged(object sender, System.EventArgs e)
        {
            iterator.StartSearch( searchTextBox.Text, caseSensitiveRBtn.Checked );
        }

        private void caseSensitiveRBtn_CheckedChanged(object sender, System.EventArgs e)
        {
            iterator.StartSearch( searchTextBox.Text, caseSensitiveRBtn.Checked );
        }

        private void searchTextBox_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
        {
            if ( e.KeyCode == Keys.F3 )
            {
                goBtn_Click( null, null );
            }
        }
    }

    internal class XmlTreeNode : TreeNode
    {
        private XmlNode elem = null;
        private string childrenXml = string.Empty;
        private string indent = string.Empty;
        private bool hitEnd = false;
        private bool hitStart = false;

        internal XmlTreeNode( string text, XmlNode elem ) : base( text )
        {
            this.elem = elem;
        }
        internal XmlNode ConnectedXmlElement
        {
            get
            {
                return elem;
            }
        }

        internal string SelfAndChildren
        {
            get
            {
                return childrenXml;
            }
        }

        public new string Text
        {
            get
            {
                return base.Text;
            }
            set
            {
                if ( value != null && value.Length > 0 )
                {
                    try
                    {
                        if ( value != childrenXml )
                        {
                            XmlDocumentFragment frag = elem.OwnerDocument.CreateDocumentFragment();
                            frag.InnerXml = value;
                            elem.ParentNode.ReplaceChild( frag, elem );
                            InnerXmlTreeView innerView = (InnerXmlTreeView) TreeView;
                            innerView.Xml = innerView.Xml;
                        }
                    }
                    catch (XmlException xEx) 
                    {
                        MessageBox.Show( xEx.Message, XmlTreeView.MessageBoxTitle );
                    }
                    finally
                    {
                        childrenXml = string.Empty;
                        hitEnd = false;
                    }
                }
            }
        }
        internal void RecurseSubNodes( TreeNode entryNode )
        {
            foreach( TreeNode node in entryNode.Nodes )
            {
                if ( this.Equals( node ) )
                {
                    hitStart = true;
                }

                if( !hitEnd && hitStart )
                {
                    hitEnd = ( node.Text.EndsWith( "</" + elem.Name + ">" ) && hitStart ) || ( ( (XmlTreeNode) node).ConnectedXmlElement != null && ( (XmlTreeNode) node).ConnectedXmlElement.NodeType == XmlNodeType.Comment );

                    childrenXml += indent + node.Text + Environment.NewLine;

                    if ( node.Nodes.Count > 0 )
                    {
                        indent += "    ";
                        RecurseSubNodes( node );
                    }
                }
            }

            if ( indent.Length > 3 )
            {
                indent = indent.Substring( 0, indent.Length - 4 );
            }
        }
    }

    [ToolboxBitmap(typeof(XmlTreeView), "Tom.XmlControls.XmlTreeView.bmp")]
    public class XmlTreeView : System.Windows.Forms.UserControl
    {
        private System.Windows.Forms.ContextMenu popUpMenu;
        private System.Windows.Forms.MenuItem printMenuItem;
        private System.Windows.Forms.MenuItem searchMenuItem;
        private System.Windows.Forms.MenuItem deleteMenuItem;
        private System.Windows.Forms.PrintDialog printDialog1;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
        private System.Windows.Forms.MenuItem saveMenuItem;
        private System.Windows.Forms.MenuItem pasteMenuItem;
        private System.Windows.Forms.MenuItem copyMenuItem;
        private System.Windows.Forms.MenuItem editMenuItem;
        private Tom.XmlControls.IXmlControl xmlControl;
        private string content = string.Empty;
        internal string fileXml = string.Empty;
        internal string filePath = string.Empty;
        public const string MessageBoxTitle = "XmlTreeView";

        private System.ComponentModel.Container components = null;
        public XmlTreeView()
        {
            // This call is required by the Windows.Forms Form Designer.
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
            this.popUpMenu = new System.Windows.Forms.ContextMenu();
            this.printMenuItem = new System.Windows.Forms.MenuItem();
            this.searchMenuItem = new System.Windows.Forms.MenuItem();
            this.deleteMenuItem = new System.Windows.Forms.MenuItem();
            this.saveMenuItem = new System.Windows.Forms.MenuItem();
            this.pasteMenuItem = new System.Windows.Forms.MenuItem();
            this.copyMenuItem = new System.Windows.Forms.MenuItem();
            this.editMenuItem = new System.Windows.Forms.MenuItem();
            this.printDialog1 = new System.Windows.Forms.PrintDialog();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.SuspendLayout();
            // 
            // popUpMenu
            // 
            this.popUpMenu.MenuItems.AddRange(new System.Windows.Forms.MenuItem[] {
                                                                                      this.printMenuItem,
                                                                                      this.searchMenuItem,
                                                                                      this.deleteMenuItem,
                                                                                      this.saveMenuItem,
                                                                                      this.pasteMenuItem,
                                                                                      this.copyMenuItem,
                                                                                      this.editMenuItem});
            // 
            // printMenuItem
            // 
            this.printMenuItem.Index = 0;
            this.printMenuItem.Text = "&Print";
            // 
            // searchMenuItem
            // 
            this.searchMenuItem.Index = 1;
            this.searchMenuItem.Text = "&Search";
            // 
            // deleteMenuItem
            // 
            this.deleteMenuItem.Index = 2;
            this.deleteMenuItem.Text = "&Delete";
            // 
            // saveMenuItem
            // 
            this.saveMenuItem.Index = 3;
            this.saveMenuItem.Text = "S&ave As...";
            // 
            // pasteMenuItem
            // 
            this.pasteMenuItem.Index = 4;
            this.pasteMenuItem.Text = "Past&e";
            // 
            // copyMenuItem
            // 
            this.copyMenuItem.Index = 5;
            this.copyMenuItem.Text = "&Copy";
            // 
            // editMenuItem
            // 
            this.editMenuItem.Index = 6;
            this.editMenuItem.Text = "Ed&it";
            // 
            // saveFileDialog1
            // 
            this.saveFileDialog1.Filter = "XML-Files|*.xml";

            this.Name = "XmlTreeView";
            this.Size = new System.Drawing.Size(150, 130);
            this.ResumeLayout(false);

        }
        private void DeregisterEvents(IXmlControl control)
        {
            if ( null != control )
            {
                this.printMenuItem.Click -= new System.EventHandler(control.Print);
                this.searchMenuItem.Click -= new System.EventHandler(control.Search);
                this.deleteMenuItem.Click -= new System.EventHandler(control.Delete);
                this.saveMenuItem.Click -= new System.EventHandler(control.Save);
                this.pasteMenuItem.Click -= new System.EventHandler(control.Paste);
                this.copyMenuItem.Click -= new System.EventHandler(control.Copy);
                this.editMenuItem.Click -= new System.EventHandler(control.Edit);
                this.printDialog1.Document.PrintPage -= new System.Drawing.Printing.PrintPageEventHandler(control.PrintPage);
            }
        }

        private void RegisterEvents(IXmlControl control)
        {
            if ( null != control )
            {
                this.printMenuItem.Click += new System.EventHandler(control.Print);
                this.searchMenuItem.Click += new System.EventHandler(control.Search);
                this.deleteMenuItem.Click += new System.EventHandler(control.Delete);
                this.saveMenuItem.Click += new System.EventHandler(control.Save);
                this.pasteMenuItem.Click += new System.EventHandler(control.Paste);
                this.copyMenuItem.Click += new System.EventHandler(control.Copy);
                this.editMenuItem.Click += new System.EventHandler(control.Edit);
                this.printDialog1.Document = control.PrintDocument;
                this.printDialog1.Document.PrintPage += new System.Drawing.Printing.PrintPageEventHandler(control.PrintPage);
            }
        }
        internal void form_Closing( object sender, CancelEventArgs e )
        {
            if ( !content.Equals( Xml ) )
            {
                if ( MessageBox.Show( "Save changes?", XmlTreeView.MessageBoxTitle, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button1 ) == DialogResult.Yes )
                {
                    if ( saveFileDialog1.ShowDialog() == DialogResult.OK )
                    {
                        using ( StreamWriter sw = new StreamWriter( saveFileDialog1.FileName ) )
                        {
                            sw.Write( Xml );
                        }
                    }
                }
            }
        }
        public string Xml
        {
            get
            {
                string result = string.Empty;

                if ( Controls.Count > 0 )
                {
                    result = ((IXmlControl) Controls[0]).Xml;
                }

                return result;
            }
            set
            {
                Controls.Clear();

                try
                {
                    DeregisterEvents( xmlControl );

                    xmlControl = new InnerXmlTreeView(this);
                    xmlControl.Xml = value;
                    content = xmlControl.Xml;

                    RegisterEvents( xmlControl );
                }
                catch
                {
                    Controls.Clear();
                    
                    DeregisterEvents( xmlControl );

                    MessageBox.Show( "Invalid XML-data !", XmlTreeView.MessageBoxTitle );
                    xmlControl = new InnerTextBox(this);
                    xmlControl.Xml = value;

                    RegisterEvents( xmlControl );
                }

                ( (Control) xmlControl ).ContextMenu = this.popUpMenu;

                Controls.Add( (Control) xmlControl );
            }
        }

        public string XmlFile
        {
            get
            {
                if ( fileXml != Xml )
                {
                    filePath = string.Empty;
                }

                return filePath;
            }

            set
            {
                if ( null != value && value.Length > 0 )
                {
                    using ( StreamReader fs = new StreamReader( value ) )
                    {
                        fileXml = fs.ReadToEnd();
                        Xml = fileXml;
                        filePath = value;
                    }
                }
            }
        }

        internal PrintDialog PrintDialog
        {
            get
            {
                return printDialog1;
            }
        }

        internal SaveFileDialog SaveDialog
        {
            get
            {
                return saveFileDialog1;
            }
        }

        [DefaultValue(true)]
        public bool LabelEdit
        {
            get
            {
                return deleteMenuItem.Enabled && editMenuItem.Enabled;
            }
            set
            {
                editMenuItem.Enabled = deleteMenuItem.Enabled = value;
            }
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll','System.Xml.dll'

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }


$shared_assemblies = @(
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd


$extra_assemblies = @(
'XmlTreeView.dll'
)

$extra_assemblies_path  = 'C:\developer\sergueik\csharp\xmltreeview\bin\Debug'

if (($env:EXTRA_ASSEMBLIES_PATH -ne $null) -and ($env:EXTRA_ASSEMBLIES_PATH -ne '')) {
   $extra_assemblies_path = $env:extra_ASSEMBLIES_PATH
}

pushd $extra_assemblies_path

$extra_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd

$f = New-Object -TypeName 'System.Windows.Forms.Form'
$f.Text = $title
$f.SuspendLayout()
$o = new-object -typeName 'Modified.Tom.XmlControls.XmlTreeView'
# $o | get-member
$o.ClientSize = New-Object System.Drawing.Size (610,440)
$o.XmlFile = 'C:\developer\sergueik\powershell_ui_samples\external\powershell_script_triggered_by_event.xml'

#  Form1
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (610,440)
$f.Controls.Add($o)
$f.Name = "Form1"
$f.Text = "XmlTreeView"
$f.ResumeLayout($false)

$f.Topmost = $True

$f.Add_Shown({ $f.Activate() })

[void]$f.ShowDialog([win32window]($caller))

$f.Dispose()

