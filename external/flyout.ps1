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

param(
  [switch]$pause
)


# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}


# http://www.codeproject.com/Articles/591826/A-Flyout-Toolbar-in-Csharp

Add-Type @"
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
    public class CSFOToolBar : ToolStrip
    {
        private System.ComponentModel.IContainer components = null;

        public const string CONST_F = "f";  
		// Used in tag property of the button to indicate a flyout toolbar is attached to the button

        private Dictionary<ToolStripButton, ToolStrip> tsbDico = new Dictionary<ToolStripButton, ToolStrip>();  
		// The list of buttons with his 'flyout' toolbar
        private ToolStripButton sTsiClickedMem;                                 
		// Memorize which button is clicked
        private Timer tim1 = new Timer();                                       
		// Timer delay before displaying the flyout toolbar
        private bool firstTime = false;
        private CSFOForm floatForm;                                             
		// A form containing the toolbar to 'flyout'

        public enum orientation_list
        {
            Horizontal,                                                         // The flyout is always displayed horizontally
            Vertical,                                                           // The flyout is always displayed verrtically
            Same,                                                               // The flyout is always displayed in the same orientation than his parent
            Opposite                                                            // The flyout is always displayed in the opposite orientation than his parent
        }
		
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

		
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
        }

   }


//---------- Internal Classe Renderer --------------------------------------------------


    
    internal class CSFOToolBarRenderer : ToolStripProfessionalRenderer          // may inherit from ToolStripRenderer, ToolStripSystemRenderer or ToolStripProfessionalRenderer.
    {
        private int m_size;                                                     // Size of the triangle drawn in pixel
        private Brush m_brush;
        public CSFOToolBarRenderer()
            : this(6, Color.Red)
        {
        }

        public CSFOToolBarRenderer(int size, Color sbc)
        {
            m_size = size;
            m_brush = new SolidBrush(sbc);
        }

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

    internal class CSFOForm : Form
    {
        private ToolStripButton m_prevTslpButton = null;                        // To memorize the current button to see next time if changed of button when mouse moves
        private ToolTip m_toolTip1 = new ToolTip();                             // To be able to display the tooltip of the button on which the mouse is
        private ToolStrip m_tlstp1 = new ToolStrip();                           // The associated toolstrip is necessary to display the tooltip



        private ToolStripButton m_tlspButton;
        public ToolStripButton TlspButton
        {
            get { return m_tlspButton; }
            set { m_tlspButton = value; }
        }


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

        private ToolStripButton FindButton(Object sender, MouseEventArgs mea)
        {
            Control c = new Control();                                          // c is a control casted as Toolstrip and get item which is casted as ToolStripButton
            ToolStripItem tsiItem;
            ToolStripButton tsBtn = new ToolStripButton();
            tsBtn = null;
            Point p = ((MouseEventArgs)mea).Location;
            Point mousePoint = this.PointToClient(((System.Windows.Forms.Control)sender).PointToScreen(p)); // Transform mouse coordinates to find correctly the button clicked

            c = (Control)this.GetChildAtPoint(mousePoint);                      
			// Find first the control at the mouse position
            if (c != null)                                                      
			// A control is effectively found (remark: in fact this is a toolstrip)
            {
                tsiItem = (ToolStripItem)((ToolStrip)c).GetItemAt(mousePoint);  // Find now the button in the control toolstrip on which the mouse click is 'up'
                if (tsiItem is ToolStripButton)
                {
                    tsBtn = (ToolStripButton)tsiItem;
                }
            }
            return tsBtn;
        }

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
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'


function PromptToolsTrip {

  param(
    [string]$title,
    [string]$message,
    [object]$caller
  )


  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')


  ## TODO $script_path = $caller.ScriptDirectory
  $script_path = Get-ScriptDirectory
  $n = 1
  $help_image_path = ('{0}\color{1}.gif' -f $script_path,$n)
  $help_image = [System.Drawing.Image]::FromFile($help_image_path)
  $images = @{
    'help' = $help_image;
    'cutToolStripButton2' = $help_image;
    'pasteToolStripButton2' = $help_image;
    'copyToolStripButton2' = $help_image;
    'newToolStripButton1' = $help_image;
    'saveToolStripButton1' = $help_image;
    'printToolStripButton1' = $help_image;
  }
  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title
  $toolStripContainer1 = New-Object System.Windows.Forms.ToolStripContainer
  $toolStrip2 = New-Object System.Windows.Forms.ToolStrip
  $ToolStripButton2 = New-Object System.Windows.Forms.ToolStripButton
  $copyToolStripButton2 = New-Object System.Windows.Forms.ToolStripButton
  $pasteToolStripButton2 = New-Object System.Windows.Forms.ToolStripButton
  $toolStrip1 = New-Object System.Windows.Forms.ToolStrip
  $newToolStripButton1 = New-Object System.Windows.Forms.ToolStripButton
  $openToolStripButton1 = New-Object System.Windows.Forms.ToolStripButton
  $saveToolStripButton1 = New-Object System.Windows.Forms.ToolStripButton
  $printToolStripButton1 = New-Object System.Windows.Forms.ToolStripButton
  [System.ComponentModel.IContainer]$components = $null
  $components = New-Object -TypeName 'System.ComponentModel.Container'
  $csfoToolBar1 = New-Object CSFOToolBar.CSFOToolBar ($components)

  $newToolStripButton = New-Object System.Windows.Forms.ToolStripButton
  $toolStripSeparator = New-Object System.Windows.Forms.ToolStripSeparator
  $cutToolStripButton = New-Object System.Windows.Forms.ToolStripButton
  $toolStripSeparator1 = New-Object System.Windows.Forms.ToolStripSeparator
  $helpToolStripButton = New-Object System.Windows.Forms.ToolStripButton
  $toolStripContainer1.ContentPanel.SuspendLayout()
  $toolStripContainer1.TopToolStripPanel.SuspendLayout()
  $toolStripContainer1.SuspendLayout()
  $toolStrip2.SuspendLayout()
  $toolStrip1.SuspendLayout()
  $csfoToolBar1.SuspendLayout()
  $f.SuspendLayout()

  #  toolStripContainer1

  #  toolStripContainer1.ContentPanel
  $toolStripContainer1.ContentPanel.Controls.Add($toolStrip2)
  $toolStripContainer1.ContentPanel.Controls.Add($toolStrip1)
  $toolStripContainer1.ContentPanel.Size = New-Object System.Drawing.Size (284,237)
  $toolStripContainer1.Dock = [System.Windows.Forms.DockStyle]::Fill
  $toolStripContainer1.Location = New-Object System.Drawing.Point (0,0)
  $toolStripContainer1.Name = "toolStripContainer1"
  $toolStripContainer1.Size = New-Object System.Drawing.Size (284,262)
  $toolStripContainer1.TabIndex = 0
  $toolStripContainer1.Text = "toolStripContainer1"
  # 
  #  toolStripContainer1.TopToolStripPanel
  # 
  $toolStripContainer1.TopToolStripPanel.Controls.Add($csfoToolBar1)
  # 
  #  toolStrip2
  # 
  $toolStrip2.Dock = [System.Windows.Forms.DockStyle]::None
  $toolStrip2.Items.AddRange(@( $ToolStripButton2,$copyToolStripButton2,$pasteToolStripButton2))
  $toolStrip2.Location = New-Object System.Drawing.Point (36,78)
  $toolStrip2.Name = "toolStrip2"
  $toolStrip2.Size = New-Object System.Drawing.Size (81,25)
  $toolStrip2.TabIndex = 1
  $toolStrip2.Text = "toolStrip2"
  # 
  #  cutToolStripButton2
  # 
  $ToolStripButton2.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  $ToolStripButton2.Image = $images['cutToolStripButton2'] # cutToolStripButton2.Image
  $ToolStripButton2.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $ToolStripButton2.Name = "cutToolStripButton2"
  $ToolStripButton2.Size = New-Object System.Drawing.Size (23,22)
  $ToolStripButton2.Text = "C&ut"
  # $ToolStripButton2.Click += new System.EventHandler($ToolStripButton2_Click)
  # 
  #  copyToolStripButton2
  # 
  $copyToolStripButton2.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  $copyToolStripButton2.Image = $images['copyToolStripButton2'] # cutToolStripButton2.Image
  $copyToolStripButton2.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $copyToolStripButton2.Name = "copyToolStripButton2"
  $copyToolStripButton2.Size = New-Object System.Drawing.Size (23,22)
  $copyToolStripButton2.Text = "&Copy"
  #           $copyToolStripButton2.Click += new System.EventHandler($copyToolStripButton2_Click)
  # 
  #  pasteToolStripButton2
  # 
  $pasteToolStripButton2.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  $pasteToolStripButton2.Image = $images['pasteToolStripButton2']
  $pasteToolStripButton2.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $pasteToolStripButton2.Name = "pasteToolStripButton2"
  $pasteToolStripButton2.Size = New-Object System.Drawing.Size (23,22)
  $pasteToolStripButton2.Text = "&Paste"
  # $pasteToolStripButton2.Click += new System.EventHandler($pasteToolStripButton2_Click)
  # 
  #  toolStrip1
  # 
  $toolStrip1.Dock = [System.Windows.Forms.DockStyle]::None
  $toolStrip1.Items.AddRange(@( $newToolStripButton1,$openToolStripButton1,$saveToolStripButton1,$printToolStripButton1));
  $toolStrip1.Location = New-Object System.Drawing.Point (25,26)
  $toolStrip1.Name = "toolStrip1"
  $toolStrip1.Size = New-Object System.Drawing.Size (104,25)
  $toolStrip1.TabIndex = 0
  $toolStrip1.Text = "toolStrip1"
  # 
  #  newToolStripButton1
  # 
  $newToolStripButton1.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  $newToolStripButton1.Image = $images['newToolStripButton1']
  $newToolStripButton1.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $newToolStripButton1.Name = "newToolStripButton1"
  $newToolStripButton1.Size = New-Object System.Drawing.Size (23,22)
  $newToolStripButton1.Text = "&New"
  #$newToolStripButton1.Click += new System.EventHandler($newToolStripButton1_Click)
  # 
  #  openToolStripButton1
  # 
  $openToolStripButton1.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  # $openToolStripButton1.Image = ((System.Drawing.Image)(resources.GetObject("openToolStripButton1.Image")));
  $openToolStripButton1.Image = $null
  $openToolStripButton1.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $openToolStripButton1.Name = "openToolStripButton1"
  $openToolStripButton1.Size = New-Object System.Drawing.Size (23,22)
  $openToolStripButton1.Text = "&Open"
  #$openToolStripButton1.Click += new System.EventHandler($openToolStripButton1_Click);
  # 
  #  saveToolStripButton1
  # 
  $saveToolStripButton1.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  $saveToolStripButton1.Image = $images['saveToolStripButton1']
  $saveToolStripButton1.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $saveToolStripButton1.Name = "saveToolStripButton1";
  $saveToolStripButton1.Size = New-Object System.Drawing.Size (23,22);
  $saveToolStripButton1.Text = "&Save";
  # $saveToolStripButton1.Click += new System.EventHandler($saveToolStripButton1_Click);
  # 
  #  printToolStripButton1
  # 
  $printToolStripButton1.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  $printToolStripButton1.Image = $images['printToolStripButton1']
  $printToolStripButton1.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $printToolStripButton1.Name = "printToolStripButton1";
  $printToolStripButton1.Size = New-Object System.Drawing.Size (23,22);
  $printToolStripButton1.Text = "&Print";
  #$printToolStripButton1.Click += new System.EventHandler($printToolStripButton1_Click);
  # 
  #  csfoToolBar1
  # 
  $csfoToolBar1.CornerColor = [System.Drawing.Color]::Red
  $csfoToolBar1.CornerSize = 6
  $csfoToolBar1.Delay = 300
  $csfoToolBar1.Dock = [System.Windows.Forms.DockStyle]::None
  $csfoToolBar1.Items.AddRange(@( $newToolStripButton,$toolStripSeparator,$cutToolStripButton,$toolStripSeparator1,$helpToolStripButton))
  $csfoToolBar1.Location = New-Object System.Drawing.Point (3,0)
  $csfoToolBar1.Name = "csfoToolBar1"
  $csfoToolBar1.Restrict = $false
  $csfoToolBar1.Size = New-Object System.Drawing.Size (124,25)
  $csfoToolBar1.TabIndex = 0
  # wrong syntax
  #          $csfoToolBar1.TOrientation = [CSFOToolBar.CSFOToolBar.orientation_list]::Horizontal
  # csfoToolBar1.TOrientation = [CSFOToolBar.CSFOToolBar.orientation_list]::Horizontal
  # 
  #  newToolStripButton
  # 
  $newToolStripButton.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  # $newToolStripButton.Image = ((System.Drawing.Image)(resources.GetObject("newToolStripButton.Image")));
  $newToolStripButton.Image = $null
  $newToolStripButton.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $newToolStripButton.Name = "newToolStripButton"
  $newToolStripButton.Size = New-Object System.Drawing.Size (23,22)
  $newToolStripButton.Text = "&New"
  # 
  #  toolStripSeparator
  # 
  $toolStripSeparator.Name = "toolStripSeparator";
  $toolStripSeparator.Size = New-Object System.Drawing.Size (6,25)
  # 
  #  cutToolStripButton
  # 
  $cutToolStripButton.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image
  # $cutToolStripButton.Image = ((System.Drawing.Image)(resources.GetObject("cutToolStripButton.Image")));
  $cutToolStripButton.Image = $null
  $cutToolStripButton.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $cutToolStripButton.Name = "cutToolStripButton";
  $cutToolStripButton.Size = New-Object System.Drawing.Size (23,22)
  $cutToolStripButton.Text = "C&ut";
  # 
  #  toolStripSeparator1
  # 
  $toolStripSeparator1.Name = "toolStripSeparator1";
  $toolStripSeparator1.Size = New-Object System.Drawing.Size (6,25)
  # 
  #  helpToolStripButton
  # 
  $helpToolStripButton.DisplayStyle = [System.Windows.Forms.ToolStripItemDisplayStyle]::Image


  ## TODO $script_path = $caller.ScriptDirectory
  $script_path = Get-ScriptDirectory
  $n = 1
  $help_image_path = ('{0}\color{1}.gif' -f $script_path,$n)
  $help_image = [System.Drawing.Image]::FromFile($help_image_path)


  # $helpToolStripButton.Image = ((System.Drawing.Image)(resources.GetObject("helpToolStripButton.Image")));
  $helpToolStripButton.Image = $help_image
  $helpToolStripButton.ImageTransparentColor = [System.Drawing.Color]::Magenta
  $helpToolStripButton.Name = "helpToolStripButton"
  $helpToolStripButton.Size = New-Object System.Drawing.Size (23,22)
  $helpToolStripButton.Text = "He&lp"
  # $helpToolStripButton.Click += new System.EventHandler($helpToolStripButton_Click)
  # 
  #  Form1
  # 
  $f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6,13)
  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
  $f.ClientSize = New-Object System.Drawing.Size (284,262)
  $f.Controls.Add($toolStripContainer1)
  $f.Name = "Form1"
  $f.Text = "Form1"
  # his.Load += new System.EventHandler($f.Form1_Load)

  $toolStripContainer1.ContentPanel.ResumeLayout($false)
  $toolStripContainer1.ContentPanel.PerformLayout()
  $toolStripContainer1.TopToolStripPanel.ResumeLayout($false)
  $toolStripContainer1.TopToolStripPanel.PerformLayout()
  $toolStripContainer1.ResumeLayout($false)
  $toolStripContainer1.PerformLayout()
  $toolStrip2.ResumeLayout($false)
  $toolStrip2.PerformLayout()
  $toolStrip1.ResumeLayout($false)
  $toolStrip1.PerformLayout()
  $csfoToolBar1.ResumeLayout($false)
  $csfoToolBar1.PerformLayout()
  $f.ResumeLayout($false)


  $f.Topmost = $True

  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog([win32window ]($caller))
  $f.Dispose()
}


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

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptToolsTrip -Title 'Floating Menu Sample Project' -caller $caller
Write-Output $caller.Data

