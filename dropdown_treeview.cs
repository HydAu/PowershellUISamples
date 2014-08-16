using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Runtime.Serialization;

// http://www.codeproject.com/Articles/14544/A-TreeView-Control-with-ComboBox-Dropdown-Nodes
namespace  DropDownTreeViewExample
{

   public class DropDownTreeViewExample : System.Windows.Forms.Form
    {
        internal System.Windows.Forms.TreeView treeFood;
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;

        public DropDownTreeViewExample()
        {
            //
            // Required for Windows Form Designer support
            //
            InitializeComponent();

            //
            // TODO: Add any constructor code after InitializeComponent call
            //
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose( bool disposing )
        {
            if( disposing )
            {
                if (components != null) 
                {
                    components.Dispose();
                }
            }
            base.Dispose( disposing );
        }

        #region Windows Form Designer generated code
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.treeFood = new DropDownTreeView();
            this.SuspendLayout();
            // 
            // treeFood
            // 
            this.treeFood.Anchor = (((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
                | System.Windows.Forms.AnchorStyles.Left) 
                | System.Windows.Forms.AnchorStyles.Right);
            this.treeFood.ImageIndex = -1;
            this.treeFood.Location = new System.Drawing.Point(4, 5);
            this.treeFood.Name = "treeFood";
            this.treeFood.SelectedImageIndex = -1;
            this.treeFood.Size = new System.Drawing.Size(284, 256);
            this.treeFood.TabIndex = 1;
            this.treeFood.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.treeFood_AfterSelect);
            // 
            // DropDownTreeViewExample
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.ClientSize = new System.Drawing.Size(292, 266);
            this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                          this.treeFood});
            this.Name = "DropDownTreeViewExample";
            this.Text = "TreeView Example";
            this.Load += new System.EventHandler(this.DropDownTreeViewExample_Load);
            this.ResumeLayout(false);

        }
        #endregion

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main() 
        {
            Application.Run(new DropDownTreeViewExample());
        }

        private void DropDownTreeViewExample_Load(object sender, System.EventArgs e)
        {

DropDownTreeNode tn1 = new DropDownTreeNode("Credentials");
tn1.ComboBox.Items.Add("LocalService");
tn1.ComboBox.Items.Add("LocalSystem ");
tn1.ComboBox.Items.Add("NetworkService");
tn1.ComboBox.SelectedIndex = 0;
tn1.ComboBox.DropDownClosed += new System.EventHandler(this.treeFood_AfterComboboxSelect);
TreeNode tn3 = new TreeNode("Test Node 1");
DropDownTreeNode tn2 = new DropDownTreeNode("Install");
string[] installs = new string[]{"Typical", "Compact", "Custom"};
tn2.ComboBox.Items.AddRange(installs);
tn2.ComboBox.DropDownClosed += new System.EventHandler(this.treeFood_AfterComboboxSelect);
// Legal!  This is how you would normally do it.
 treeFood.Nodes.Add(tn3);

treeFood.Nodes.Add(tn1);
// Also legal!  Through inheritance, a DropDownTreeNode is a TreeNode.
treeFood.Nodes.Add(tn2);

        }

        private void treeFood_AfterComboboxSelect(Object sender, System.EventArgs e)
        {
                System.Windows.Forms.ComboBox x = (System.Windows.Forms.ComboBox) sender;
// sender.SelectedText
                MessageBox.Show(x.SelectedItem.ToString());
        }


        private void treeFood_AfterSelect(object sender, System.EventArgs e)
        {
/*
           if (e.Action == TreeViewAction.ByMouse)
            {
                MessageBox.Show(e.Node.FullPath);
            } 
*/
        }

    }

    /// <summary>
    /// A class that inherits from TreeNode that lets you specify a ComboBox to be shown
    /// at the TreeNode's position
    /// </summary>
    public class DropDownTreeNode : TreeNode
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeNode"/> class.
        /// </summary>
        public DropDownTreeNode()
            : base()
        {            
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeNode"/> class.
        /// </summary>
        /// <param name="text">The text.</param>
        public DropDownTreeNode(string text)
            : base(text)
        {            
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeNode"/> class.
        /// </summary>
        /// <param name="text">The text.</param>
        /// <param name="children">The children.</param>
        public DropDownTreeNode(string text, TreeNode[] children)
            : base(text, children)
        {            
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeNode"/> class.
        /// </summary>
        /// <param name="serializationInfo">A <see cref="T:System.Runtime.Serialization.SerializationInfo"></see> containing the data to deserialize the class.</param>
        /// <param name="context">The <see cref="T:System.Runtime.Serialization.StreamingContext"></see> containing the source and destination of the serialized stream.</param>
        public DropDownTreeNode(SerializationInfo serializationInfo, StreamingContext context)
            : base(serializationInfo, context)
        {            
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeNode"/> class.
        /// </summary>
        /// <param name="text">The text.</param>
        /// <param name="imageIndex">Index of the image.</param>
        /// <param name="selectedImageIndex">Index of the selected image.</param>
        public DropDownTreeNode(string text, int imageIndex, int selectedImageIndex)
            : base(text, imageIndex, selectedImageIndex)
        {            
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeNode"/> class.
        /// </summary>
        /// <param name="text">The text.</param>
        /// <param name="imageIndex">Index of the image.</param>
        /// <param name="selectedImageIndex">Index of the selected image.</param>
        /// <param name="children">The children.</param>
        public DropDownTreeNode(string text, int imageIndex, int selectedImageIndex, TreeNode[] children)
            : base(text, imageIndex, selectedImageIndex, children)
        {            
        }
        #endregion


        #region Property - ComboBox
        private ComboBox m_ComboBox = new ComboBox();
        /// <summary>
        /// Gets or sets the ComboBox.  Lets you access all of the properties of the internal ComboBox.
        /// </summary>
        /// <example>
        /// For example,
        /// <code>
        /// DropDownTreeNode node1 = new DropDownTreeNode("Some text");
        /// node1.ComboBox.Items.Add("Some text");
        /// node1.ComboBox.Items.Add("Some more text");
        /// node1.IsDropDown = true; 
        /// </code>
        /// </example>
        /// <value>The combo box.</value>
        public ComboBox ComboBox
        {
            get
            {
                this.m_ComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
                return this.m_ComboBox;
            }
            set
            {
                this.m_ComboBox = value;
                this.m_ComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            }
        } 
        #endregion  
    }

    /// <summary>
    /// Provides the usual TreeView control with the ability to edit the labels of the nodes
    /// by using a drop-down ComboBox.
    /// </summary>
    public class DropDownTreeView : TreeView
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="T:DropDownTreeView"/> class.
        /// </summary>
        public DropDownTreeView()
            : base()
        {
        }
        #endregion


        // We'll use this variable to keep track of the current node that is being edited.
        // This is set to something (non-null) only if the node's ComboBox is being displayed.
        private DropDownTreeNode m_CurrentNode = null;


        /// <summary>
        /// Occurs when the <see cref="E:System.Windows.Forms.TreeView.NodeMouseClick"></see> event is fired
        /// -- that is, when a node in the tree view is clicked.
        /// </summary>
        /// <param name="e">A <see cref="T:System.Windows.Forms.TreeNodeMouseClickEventArgs"></see> that contains the event data.</param>
        protected override void OnNodeMouseClick(TreeNodeMouseClickEventArgs e)
        {            
            // Are we dealing with a dropdown node?
            if (e.Node is DropDownTreeNode)
            {
                this.m_CurrentNode = (DropDownTreeNode)e.Node;

                // Need to add the node's ComboBox to the TreeView's list of controls for it to work
                this.Controls.Add(this.m_CurrentNode.ComboBox);                                        

                // Set the bounds of the ComboBox, with a little adjustment to make it look right
                this.m_CurrentNode.ComboBox.SetBounds(
                    this.m_CurrentNode.Bounds.X - 1,
                    this.m_CurrentNode.Bounds.Y - 2,
                    this.m_CurrentNode.Bounds.Width + 25,
                    this.m_CurrentNode.Bounds.Height);

                // Listen to the SelectedValueChanged event of the node's ComboBox
                this.m_CurrentNode.ComboBox.SelectedValueChanged += new EventHandler(ComboBox_SelectedValueChanged);
                this.m_CurrentNode.ComboBox.DropDownClosed += new EventHandler(ComboBox_DropDownClosed);
                
                // Now show the ComboBox
                this.m_CurrentNode.ComboBox.Show();
                this.m_CurrentNode.ComboBox.DroppedDown = true;
            }
            base.OnNodeMouseClick(e);
        }


        /// <summary>
        /// Handles the SelectedValueChanged event of the ComboBox control.
        /// Hides the ComboBox if an item has been selected in it.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="T:System.EventArgs"/> instance containing the event data.</param>
        void ComboBox_SelectedValueChanged(object sender, EventArgs e)
        {
            HideComboBox();
            

        }


        /// <summary>
        /// Handles the DropDownClosed event of the ComboBox control.
        /// Hides the ComboBox if the user clicks anywhere else on the TreeView or adjusts the scrollbars, or scrolls the mouse wheel.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="T:System.EventArgs"/> instance containing the event data.</param>
        void ComboBox_DropDownClosed(object sender, EventArgs e)
        {
            HideComboBox();
            MessageBox.Show(this.SelectedNode.Text.ToString());
        }


        /// <summary>
        /// Handles the <see cref="E:System.Windows.Forms.Control.MouseWheel"></see> event.
        /// Hides the ComboBox if the user scrolls the mouse wheel.
        /// </summary>
        /// <param name="e">A <see cref="T:System.Windows.Forms.MouseEventArgs"></see> that contains the event data.</param>
        protected override void OnMouseWheel(MouseEventArgs e)
        {
            HideComboBox();
            base.OnMouseWheel(e);
        }


        /// <summary>
        /// Method to hide the currently-selected node's ComboBox
        /// </summary>
        private void HideComboBox()
        {
            if (this.m_CurrentNode != null)
            {
                // Unregister the event listener
                this.m_CurrentNode.ComboBox.SelectedValueChanged -= ComboBox_SelectedValueChanged;
                this.m_CurrentNode.ComboBox.DropDownClosed -= ComboBox_DropDownClosed;                                

                // Copy the selected text from the ComboBox to the TreeNode
                this.m_CurrentNode.Text = this.m_CurrentNode.ComboBox.Text;

                // Hide the ComboBox
                this.m_CurrentNode.ComboBox.Hide();
                this.m_CurrentNode.ComboBox.DroppedDown = false;

                // Remove the control from the TreeView's list of currently-displayed controls
                this.Controls.Remove(this.m_CurrentNode.ComboBox);

                // And return to the default state (no ComboBox displayed)
                this.m_CurrentNode = null;
            }
        
        }        
    }

}
