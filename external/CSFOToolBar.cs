using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace CSFOToolBar
{
    /// <summary>
    /// CSFOToolBar: The toolbar containing buttons with flyout toolbar attached to
    /// </summary>
    public class CSFOToolBar : ToolStrip
    {
#region Private properties
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        public const string CONST_F = "f";                                      // Used in tag property of the button to indicate a flyout toolbar is attached to the button

        private Dictionary<ToolStripButton, ToolStrip> tsbDico = new Dictionary<ToolStripButton, ToolStrip>();  // The list of buttons with his 'flyout' toolbar
        private ToolStripButton sTsiClickedMem;                                 // Memorize which button is clicked
        private Timer tim1 = new Timer();                                       // Timer delay before displaying the flyout toolbar
        private bool firstTime = false;
        private CSFOForm floatForm;                                             // A form containing the toolbar to 'flyout'

        public enum orientation_list
        {
            Horizontal,                                                         // The flyout is always displayed horizontally
            Vertical,                                                           // The flyout is always displayed verrtically
            Same,                                                               // The flyout is always displayed in the same orientation than his parent
            Opposite                                                            // The flyout is always displayed in the opposite orientation than his parent
        }
#endregion
#region Public properties
        private Color m_CornerColor = Color.Red;
        [CategoryAttribute("Flyout"),
         DisplayNameAttribute("Corner color"),
         DescriptionAttribute("The color of the corner displayed when a button has a flyout toolbar (default: Red).")]
        public Color CornerColor
        {
            get { return m_CornerColor; }
            set { m_CornerColor = value; }
        }

        private int m_CornerSize = 6;
        [CategoryAttribute("Flyout"),
         DisplayNameAttribute("Corner size"),
         DescriptionAttribute("The size (in pixel) of the corner displayed when a button has a flyout toolbar (default: 6).")]
        public int CornerSize
        {
            get { return m_CornerSize; }
            set { m_CornerSize = value; }
        }

        private int m_Delay = 300;
        [CategoryAttribute("Flyout"),
         DisplayNameAttribute("Delay"),
         DescriptionAttribute("The delay (in ms) before the flyout toolbar is displayed (default: 300).")]
        public int Delay
        {
            get { return m_Delay; }
            set { m_Delay = value; }
        }

        private orientation_list m_Orientation = orientation_list.Horizontal;
        [CategoryAttribute("Flyout"),
         DisplayNameAttribute("Orientation"),
         DescriptionAttribute("The orientation of the flyout toolbar.\nHorizontal = flyout always horizontal (default)\nVertical = flyout always vertical\nSame = flyout has the same orientation as his parent\nOpposite = flyout has opposite orientation than his parent.")]
        public orientation_list TOrientation
        {
            get { return m_Orientation; }
            set { m_Orientation = value; }
        }
        
        private bool m_Restrict = false;
        [CategoryAttribute("Flyout"),
         DisplayNameAttribute("Restrict"),
         DescriptionAttribute("Restrict the display of the flyout toolbar to the area of the form (default: false).")]
        public bool Restrict
        {
            get { return m_Restrict; }
            set { m_Restrict = value; }
        }
#endregion
#region Constructors
        public CSFOToolBar() : this(null)
        {
        }

        public CSFOToolBar(IContainer container)
        {
            if (container != null)
            {
                container.Add(this);
            }
            InitializeComponent();
            tim1.Tick += new System.EventHandler(OnTimerEvent);
        }
#endregion
#region Protected methods
        protected override void OnMouseDown(MouseEventArgs mea)
        {
            base.OnMouseDown(mea);

            ToolStripItem tsiClicked = this.GetItemAt(mea.Location);            // Get the item clicked in the CSFOToolbar
            if (tsiClicked != null)
            {
                foreach (ToolStripButton tsbtn in tsbDico.Keys)
                {
                    if (tsiClicked.Name == tsbtn.Name)                          // If the button has a flyout toolbar, start the timer. Or if the button is in the list of buttons with flyout toolbar.
                    {
                        sTsiClickedMem = tsbtn;                                 // Memorize which button is clicked
                        tim1.Interval = m_Delay;
                        tim1.Enabled = true;
                        break;
                    }
                }
            }
        }

        protected override void OnMouseUp(MouseEventArgs mea)
        {
            tim1.Enabled = false;                                               // Kill timer if mouse click is up before end of timer
            if (floatForm != null)
            {
                floatForm.Visible = false;
            }

            base.OnMouseUp(mea);                                                // If this line is at the begining of the method, there is a problem when click on the button modified
                                                                                // In fact the flyout toolbar is displayed again (before end of timer). A bad side effect.
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);

            if (!this.firstTime)										        // To execute only once
            {
                this.Renderer = new CSFOToolBarRenderer(m_CornerSize, m_CornerColor);    // Modify the renderer. Use a custom one defined below.
                this.firstTime = true;
            }

        }

        /// <summary>
        /// On Timer Event: if we've reached here it means we clicked on the button long enough
        /// </summary>
        /// <param name="source"></param>
        /// <param name="e"></param>
        protected void OnTimerEvent(object source, EventArgs e)
        {
            tim1.Enabled = false;
            ToolStrip tlSp = ((ToolStrip)tsbDico[sTsiClickedMem]);              // Retreive the flyout toolbar to display

            floatForm = new CSFOForm(sTsiClickedMem, this, tlSp, new Point(MousePosition.X, MousePosition.Y), m_Restrict);
            floatForm.Show();
        }

#endregion
#region Public methods
        /// <summary>
        /// Attach a (flyout) toolstrip to a button
        /// </summary>
        /// <param name="tsButton">The button which the flyout toolbar is attached to</param>
        /// <param name="tsi">The flyout toolbar (a classic toolstrip)</param>
        /// <param name="index">The index of the button in the flyout toolbar used as default at start (0 based)</param>
        public void AddFlyout(ToolStripButton tsButton, ToolStrip tsi, int index)
        {
            tsi.GripStyle = ToolStripGripStyle.Hidden;
            tsi.Visible = false;

            tsbDico.Add(tsButton, tsi);
            tsButton.Tag = CSFOToolBar.CONST_F;                                 // Let's memorize there is a flyout toolbar attached to the button

            if (index < 0 || index > tsi.Items.Count)                           // Take the first button by default if index is out of bounds
            {
                index = 0;
            }
            ToolStripButton tlspBtni = new ToolStripButton();                   // To setup which button (from the flyout toolbar - tsi) will be the default one (in the CSFOToolbar) according to index
            tlspBtni = (ToolStripButton)tsi.Items[index];
            if (CSFOForm.ModifyComponentEventHandlers(tlspBtni, tsButton, "EventClick") == true) // If it the handler has been modified, let's modify some aspect of the button
            {
                tsButton.Image = tlspBtni.Image;
                tsButton.Text = tlspBtni.Text;
                tsButton.AutoToolTip = tlspBtni.AutoToolTip;
                tsButton.ToolTipText = tlspBtni.ToolTipText;
                tsButton.Invalidate();
            }
        }
#endregion
#region Overriden method(s)
        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }
#endregion
#region Component Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
        }
#endregion
    }


//---------- Internal Classe Renderer --------------------------------------------------


    /// <summary>
    /// The renderer to modify the aspect of the buttons in the toolbar
    /// This renderer is used to draw the triangle indicating the button has a flyout toolbar attached.
    /// Used ONLY by the class: CSFOToolBar
    /// </summary>
    internal class CSFOToolBarRenderer : ToolStripProfessionalRenderer          // may inherit from ToolStripRenderer, ToolStripSystemRenderer or ToolStripProfessionalRenderer.
    {
#region Private Properties
        private int m_size;                                                     // Size of the triangle drawn in pixel
        private Brush m_brush;
#endregion
#region Constructors
        public CSFOToolBarRenderer()
            : this(6, Color.Red)
        {
        }

        public CSFOToolBarRenderer(int size, Color sbc)
        {
            m_size = size;
            m_brush = new SolidBrush(sbc);
        }
#endregion

        /// <summary>
        /// To draw the red triangle in the right down corner on the background of the button
        /// </summary>
        /// <param name="e"></param>
        protected override void OnRenderButtonBackground(ToolStripItemRenderEventArgs e)
        {
            base.OnRenderButtonBackground(e);

            ToolStripButton gsb = e.Item as ToolStripButton;
            if ((String)gsb.Tag == CSFOToolBar.CONST_F)                         // If the Tag contains 'f', the button has a flyout toolbar attached
            {
                Graphics g = e.Graphics;
                Point[] pts = new Point[3];								        // Create a triangle in the right down corner
                pts[0] = new Point(gsb.Width, gsb.Height - m_size);
                pts[1] = new Point(gsb.Width, gsb.Height);
                pts[2] = new Point(gsb.Width - m_size, gsb.Height);
                g.FillPolygon(m_brush, pts);                                    // Draw the triangle on the background of the button
            }
        }
    }


//---------- Internal Classe Form --------------------------------------------------


    /// <summary>
    /// This 'form' class will contain the toolbar to "fly out"
    /// Used ONLY by the class: CSFOToolBar
    /// </summary>
    internal class CSFOForm : Form
    {
#region Private Properties
        private ToolStripButton m_prevTslpButton = null;                        // To memorize the current button to see next time if changed of button when mouse moves
        private ToolTip m_toolTip1 = new ToolTip();                             // To be able to display the tooltip of the button on which the mouse is
        private ToolStrip m_tlstp1 = new ToolStrip();                           // The associated toolstrip is necessary to display the tooltip
#endregion
#region Public Properties
        /// <summary>
        /// The button which the flyout toolbar (in a float form) is attached to
        /// </summary>
        private ToolStripButton m_tlspButton;
        public ToolStripButton TlspButton
        {
            get { return m_tlspButton; }
            set { m_tlspButton = value; }
        }
#endregion
#region Constructor(s)
        /// <summary>
        /// CSFOForm(sTsiClickedMem, this, tlSp, new Point(MousePosition.X, MousePosition.Y));
        /// </summary>
        /// <param name="tsBtn">The clicked button in the CSFOToolbar</param>
        /// <param name="c">The CSFOToolbar</param>
        /// <param name="tsBar">The toolsrtip to display in the form</param>
        /// <param name="pt">The coordinates where to display the flyout toolbar</param>
        public CSFOForm(ToolStripButton tsBtn, Control c, ToolStrip tsBar, Point pt, bool bRestrictToForm)
        {
            int offset = 1;                                                     // It is prettier not to "stick" the edge.
            int S_width;
            int S_height;

            // Personalize the form
            this.FormBorderStyle = FormBorderStyle.FixedToolWindow;             // Comment or not this line to see the difference
            this.ControlBox = false;                                            // Don't show borders nor title bar
            this.StartPosition = FormStartPosition.Manual;                      // To be able to define the position of the form according to the mouse position
            tsBar.LayoutStyle = ReturnLayoutStyle((CSFOToolBar)c);              // To define the orientation of the flyout toolbar (to do before defining the size of the form of course)
            this.ClientSize = tsBar.Size;                                       // Defining client size will also resize the form. It is necessary for the verification of the location
            this.Owner = c.FindForm();                                          // Retreive the main form of the application

            if (bRestrictToForm)
            {
                S_width = this.Owner.Right;
                S_height = this.Owner.Bottom;
            }
            else
            {
                S_width = SystemInformation.VirtualScreen.Right;                // VirtualScreen is taken into account to take the screen resolution in its entirety (in case of multiple screen)
                S_height = SystemInformation.VirtualScreen.Bottom;
            }

            if (pt.X + this.Width > S_width)                                    // Check if we exceed the width of the screen
            {
                pt.X = S_width - this.Width - offset;
            }

            if (pt.Y + this.Height > S_height)                                  // Check if we exceed the height of the screen
            {
                pt.Y = S_height - this.Height - offset;
            }
            this.Location = pt;                                                 // Setup the location of the form

            this.TlspButton = tsBtn;
            this.Controls.Add(tsBar);
            tsBar.Location = Point.Empty;
            tsBar.Visible = true;

            c.MouseMove += new MouseEventHandler(c_MouseMove);                  // Attach some methods to events of the control (the CSFOToolbar). 
            c.MouseUp += new MouseEventHandler(c_MouseUp);                      // So, those events from the CSFOToolbar are transmitted here in this form class.

            m_tlstp1 = tsBar;
        }
#endregion
#region Events
        void c_MouseMove(object sender, MouseEventArgs e)
        {
            base.OnMouseMove(e);

            ToolStripButton tsBtnFound = new ToolStripButton();

            tsBtnFound = FindButton(sender, e);
            if (tsBtnFound != null)
            {
                if (m_prevTslpButton != tsBtnFound)                             // Are we still on the same button?
                {
                    tsBtnFound.Select();                                        // To show on which button the mouse is positioned
                    m_prevTslpButton = tsBtnFound;
                    this.m_toolTip1.Show(tsBtnFound.ToolTipText,                // Display the associated tooltip
                                         this.m_tlstp1,
                                         tsBtnFound.Bounds.Left + tsBtnFound.Bounds.Width / 2,
                                         tsBtnFound.Bounds.Height + 16);        // The offset of 16 pixels is added to be sure not to be hidden by the mouse
                }
                tsBtnFound.Invalidate();
            }

            
        }

        void c_MouseUp(object sender, MouseEventArgs e)
        {
            base.OnMouseUp(e);

            ToolStripButton tsBtnFound = new ToolStripButton();

            tsBtnFound = FindButton(sender, e);                                 // Find the button when release mouse button
            if (tsBtnFound != null)
            {
                if (ModifyComponentEventHandlers(tsBtnFound, TlspButton, "EventClick") == true)     // If the handler has been modified, let's modify some aspect of the button
                {
                    this.TlspButton.Image = tsBtnFound.Image;
                    this.TlspButton.Text = tsBtnFound.Text;
                    this.TlspButton.AutoToolTip = tsBtnFound.AutoToolTip;
                    this.TlspButton.ToolTipText = tsBtnFound.ToolTipText;
                    this.TlspButton.Invalidate();
                }
            }
            this.FindForm().Owner.Focus(); ;                                    // Give back the focus to the main form to see it after released the mouse button
        }
#endregion
#region Public methods
        /// <summary>
        /// Modify the handler of a component
        /// For oldComp (a toolsrtip button), we remove his old handler
        /// and we add a new one (the one from newComp)
        /// Example of use: SwapComponentEventHandlers(tsBtnFound, TlspButton, "EventClick");
        /// </summary>
        /// <param name="newComp">Take the handler of this component</param>
        /// <param name="oldComp">Modify his handler</param>
        /// <param name="sEventName">The name of the event for which to find the handle ("EventClick")</param>
        /// <returns>True if performed correctly else false</returns>
        public static bool ModifyComponentEventHandlers(ToolStripButton newComp, ToolStripButton oldComp, String sEventName)
        {
            EventHandler handler = (EventHandler)GetDelegate(newComp, sEventName);          // Find the event handler attached to the founded button
            if (handler != null)
            {
                EventHandler oldHandler = (EventHandler)GetDelegate(oldComp, sEventName);   // Find the old event handler
                if (oldHandler != null)
                {
                    oldComp.Click -= oldHandler;                                            // Remove the old event handler from event click list
                }
                oldComp.Click += handler;                                                   // Add the new founded event hnadler
                return true;
            }
            return false;
        }
#endregion
#region Private methods
        /// <summary>
        /// To find the button at the mouse position
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="mea">mouse position</param>
        /// <returns>The button found (null if not found)</returns>
        private ToolStripButton FindButton(Object sender, MouseEventArgs mea)
        {
            Control c = new Control();                                          // c is a control casted as Toolstrip and get item which is casted as ToolStripButton
            ToolStripItem tsiItem;
            ToolStripButton tsBtn = new ToolStripButton();
            tsBtn = null;
            Point p = ((MouseEventArgs)mea).Location;
            Point mousePoint = this.PointToClient(((System.Windows.Forms.Control)sender).PointToScreen(p)); // Transform mouse coordinates to find correctly the button clicked

            c = (Control)this.GetChildAtPoint(mousePoint);                      // Find first the control at the mouse position
            if (c != null)                                                      // A control is effectively found (remark: in fact this is a toolstrip)
            {
                tsiItem = (ToolStripItem)((ToolStrip)c).GetItemAt(mousePoint);  // Find now the button in the control toolstrip on which the mouse click is 'up'
                if (tsiItem is ToolStripButton)
                {
                    tsBtn = (ToolStripButton)tsiItem;
                }
            }
            return tsBtn;
        }

        /// <summary>
        /// Get Delegate from Event's Subscription
        /// This following code makes like if we would do: control.Events.Find( control.EventClick ).handler
        /// But it is not possible (methods are not public), so we use reflexion.
        /// Source: http://www.codeproject.com/Articles/34990/Get-Delegate-from-Event-s-Subscription
        /// </summary>
        /// <param name="issuer">The component for which to find event (i.e.: tsBtnFound)</param>
        /// <param name="keyName">The event name to find (i.e.: "EventClick")</param>
        /// <returns>The handler if exist else null</returns>
        private static object GetDelegate(Component issuer, string keyName)
        {
            // Get key value for a Click Event
            Object key = issuer
                .GetType()
                .GetField(keyName, BindingFlags.Static |
                BindingFlags.NonPublic | BindingFlags.FlattenHierarchy)
                .GetValue(null);

            // Get events value to get access to subscribed delegates list
            Object events = typeof(Component)
                .GetField("events", BindingFlags.Instance | BindingFlags.NonPublic)
                .GetValue(issuer);

            // Find the Find method and use it to search up listEntry for corresponding key
            Object listEntry = typeof(EventHandlerList)
                .GetMethod("Find", BindingFlags.NonPublic | BindingFlags.Instance)
                .Invoke(events, new object[] { key });
            if (listEntry == null)
            {
                return null;
            }

            // Get handler value from listEntry 
            Object handler = listEntry
                .GetType()
                .GetField("handler", BindingFlags.Instance | BindingFlags.NonPublic)
                .GetValue(listEntry);

            return handler;
        }

        /// <summary>
        /// Define the orientation of the flyout toolbar according to the property 'TOrientation' of the CSFOToolbar
        /// </summary>
        /// <param name="csftoolbar">The CSFotoolbar to take into account for orientation of the flyout toolbar</param>
        private ToolStripLayoutStyle ReturnLayoutStyle(CSFOToolBar csftoolbar)
        {
            ToolStripLayoutStyle tsLayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow;

            switch (csftoolbar.TOrientation)
            {
                case CSFOToolBar.orientation_list.Horizontal:
                    tsLayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow;
                    break;
                case CSFOToolBar.orientation_list.Vertical:
                    tsLayoutStyle = ToolStripLayoutStyle.VerticalStackWithOverflow;
                    break;
                case CSFOToolBar.orientation_list.Same:
                    tsLayoutStyle = csftoolbar.LayoutStyle;
                    break;
                case CSFOToolBar.orientation_list.Opposite:
                    if (csftoolbar.LayoutStyle == ToolStripLayoutStyle.HorizontalStackWithOverflow)
                    {
                        tsLayoutStyle = ToolStripLayoutStyle.VerticalStackWithOverflow;
                    }
                    else if (csftoolbar.LayoutStyle == ToolStripLayoutStyle.VerticalStackWithOverflow)
                    {
                        tsLayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow;
                    }
                    else
                    {
                        tsLayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow;
                    }
                    break;
                default:
                    tsLayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow;
                    break;
            }
            return tsLayoutStyle;
        }
#endregion
    }
}