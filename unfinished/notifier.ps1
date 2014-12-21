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
  [switch]$test,
  [switch]$debug)


# http://www.codeproject.com/Tips/836101/Sliding-Up-Notification-Like-Skype
$shared_assemblies = @(
  'NotificationWindow.dll',
  'nunit.framework.dll'
)

$env:SHARED_ASSEMBLIES_PATH = 'c:\developer\sergueik\csharp\SharedAssemblies'
$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
popd


<#
Add-Type -TypeDefinition @"
#pragma warning disable 0649,0414,0169,0067
using System;
using System.Windows.Forms;
using System.Drawing;
using System.ComponentModel;
using System.Drawing.Drawing2D;
using System.Collections.Generic;

namespace NotificationWindow
{

    [ToolboxBitmapAttribute(typeof(PopupNotifier), "Icon.ico")]
    [DefaultEvent("Click")]
    public class PopupNotifier : Component
    {
        // Warning as Error: The event 'NotificationWindow.PopupNotifier.Click' is never used
        public event EventHandler Click;

        //  public event EventHandler Close;

        private bool disposed = false;
        private PopupNotifierForm frmPopup;
        private Timer tmrAnimation;
        private Timer tmrWait;
        private Timer timer1;

        private bool isAppearing = true;
        private bool mouseIsOn = false;
        private int maxPosition;
        private double maxOpacity;
        private int posStart;
        private int posStop;
        private double opacityStart;
        private double opacityStop;
        private System.Diagnostics.Stopwatch sw;
        public List<long> timelist = new List<long>();

        public List<long> timelist_wait = new List<long>();

        public List<string> message_type = new List<string>();
        public List<string> message_cont = new List<string>();
        public List<Image> message_image = new List<Image>();

        public List<string> message_type_wait = new List<string>();
        public List<string> message_cont_wait = new List<string>();
        public List<Image> message_image_wait = new List<Image>();


        const int wid = 220;
        const int h_t = 50;
        private int posCurrent = 0;
        bool animation_working = false;

        [Category("Header"), DefaultValue(typeof(Color), "ControlDark")]
        [Description("Color of the window header.")]
        public Color HeaderColor { get; set; }

        [Category("Appearance"), DefaultValue(typeof(Color), "Control")]
        [Description("Color of the window background.")]
        public Color BodyColor { get; set; }

        [Category("Title"), DefaultValue(typeof(Color), "Gray")]
        [Description("Color of the title text.")]
        public Color TitleColor { get; set; }

        [Category("Content"), DefaultValue(typeof(Color), "ControlText")]
        [Description("Color of the content text.")]
        public Color ContentColor { get; set; }

        [Category("Appearance"), DefaultValue(typeof(Color), "WindowFrame")]
        [Description("Color of the window border.")]
        public Color BorderColor { get; set; }

        [Category("Buttons"), DefaultValue(typeof(Color), "WindowFrame")]
        [Description("Border color of the close and options buttons when the mouse is over them.")]
        public Color ButtonBorderColor { get; set; }

        [Category("Buttons"), DefaultValue(typeof(Color), "Highlight")]
        [Description("Background color of the close and options buttons when the mouse is over them.")]
        public Color ButtonHoverColor { get; set; }

        [Category("Content"), DefaultValue(typeof(Color), "HotTrack")]
        [Description("Color of the content text when the mouse is hovering over it.")]
        public Color ContentHoverColor { get; set; }

        [Category("Appearance"), DefaultValue(50)]
        [Description("Gradient of window background color.")]
        public int GradientPower { get; set; }

        [Category("Content")]
        [Description("Font of the content text.")]
        public Font ContentFont { get; set; }

        [Category("Header")]
        [Description("Font of the title.")]
        public Font HeaderFont { get; set; }


        [Category("Title")]
        [Description("Font of the title.")]
        public Font TitleFont { get; set; }

        [Category("Image")]
        [Description("Size of the icon image.")]
        public Size ImageSize
        {
            get
            {
                if (imageSize.Width == 0)
                {
                    if (Image != null)
                    {
                        return Image.Size;
                    }
                    else
                    {
                        return new Size(0, 0);
                    }
                }
                else
                {
                    return imageSize;
                }
            }
            set { imageSize = value; }
        }

        public void ResetImageSize()
        {
            imageSize = Size.Empty;
        }

        private bool ShouldSerializeImageSize()
        {
            return (!imageSize.Equals(Size.Empty));
        }

        private Size imageSize = new Size(0, 0);

        [Category("Image")]
        [Description("Icon image to display.")]
        public Image Image { get; set; }

        [Category("Header"), DefaultValue(true)]
        [Description("Whether to show a 'grip' image within the window header.")]
        public bool ShowGripText { get; set; }

        [Category("Header")]
        [Description("Title text to display.")]
        public string HeaderText { get; set; }


        [Category("Header")]
        [Description("Padding of title text.")]
        public Padding HeaderPadding { get; set; }

        [Category("Behavior"), DefaultValue(true)]
        [Description("Whether to scroll the window or only fade it.")]
        public bool Scroll { get; set; }

        [Category("Content")]
        [Description("Content text to display.")]
        public string ContentText { get; set; }

        [Category("Title")]
        [Description("Title text to display.")]
        public string TitleText { get; set; }



        [Category("Title")]
        [Description("Padding of title text.")]
        public Padding TitlePadding { get; set; }

        private void ResetTitlePadding()
        {
            TitlePadding = Padding.Empty;
        }

        private bool ShouldSerializeTitlePadding()
        {
            return (!TitlePadding.Equals(Padding.Empty));
        }

        [Category("Content")]
        [Description("Padding of content text.")]
        public Padding ContentPadding { get; set; }

        private void ResetContentPadding()
        {
            ContentPadding = Padding.Empty;
        }

        private bool ShouldSerializeContentPadding()
        {
            return (!ContentPadding.Equals(Padding.Empty));
        }

        [Category("Image")]
        [Description("Padding of icon image.")]
        public Padding ImagePadding { get; set; }

        private void ResetImagePadding()
        {
            ImagePadding = Padding.Empty;
        }

        private bool ShouldSerializeImagePadding()
        {
            return (!ImagePadding.Equals(Padding.Empty));
        }

        [Category("Header"), DefaultValue(9)]
        [Description("Height of window header.")]
        public int HeaderHeight { get; set; }

        [Category("Buttons"), DefaultValue(true)]
        [Description("Whether to show the close button.")]
        public bool ShowCloseButton { get; set; }

        [Category("Buttons"), DefaultValue(false)]
        [Description("Whether to show the options button.")]
        public bool ShowOptionsButton { get; set; }

        [Category("Behavior")]
        [Description("Context menu to open when clicking on the options button.")]
        public ContextMenuStrip OptionsMenu { get; set; }

        [Category("Behavior"), DefaultValue(3000)]
        [Description("Time in milliseconds the window is displayed.")]
        public int Delay { get; set; }

        [Category("Behavior"), DefaultValue(1000)]
        [Description("Time in milliseconds needed to make the window appear or disappear.")]
        public int AnimationDuration { get; set; }

        [Category("Behavior"), DefaultValue(10)]
        [Description("Interval in milliseconds used to draw the animation.")]
        public int AnimationInterval { get; set; }

        [Category("Appearance")]
        [Description("Size of the window.")]
        public Size Size { get; set; }

        public PopupNotifier()
        {
            // set default values

            HeaderColor = SystemColors.ControlDark;
            BodyColor = SystemColors.Control;
            TitleColor = System.Drawing.Color.Gray;
            ContentColor = SystemColors.ControlText;
            BorderColor = SystemColors.WindowFrame;
            ButtonBorderColor = SystemColors.WindowFrame;
            ButtonHoverColor = SystemColors.Highlight;
            ContentHoverColor = SystemColors.HotTrack;
            GradientPower = 50;
            ContentFont = SystemFonts.DialogFont;
            TitleFont = SystemFonts.CaptionFont;
            ShowGripText = true;
            Scroll = true;
            TitlePadding = new Padding(0);
            ContentPadding = new Padding(0);
            ImagePadding = new Padding(0);
            HeaderHeight = 9;
            ShowCloseButton = true;
            ShowOptionsButton = false;
            Delay = 3000;
            AnimationInterval = 20;
            AnimationDuration = 1000;
            Size = new Size(400, 100);

            frmPopup = new PopupNotifierForm(this);
            frmPopup.TopMost = true;
            frmPopup.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            frmPopup.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            frmPopup.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            frmPopup.MouseEnter += new EventHandler(frmPopup_MouseEnter);
            frmPopup.MouseLeave += new EventHandler(frmPopup_MouseLeave);
            frmPopup.MouseClick += new MouseEventHandler(frmPopup_MouseClick);

            //    frmPopup.CloseClick += new EventHandler(frmPopup_CloseClick);
            //    frmPopup.LinkClick += new EventHandler(frmPopup_LinkClick);
            //    frmPopup.ContextMenuOpened += new EventHandler(frmPopup_ContextMenuOpened);
            //   frmPopup.ContextMenuClosed += new EventHandler(frmPopup_ContextMenuClosed);

            tmrAnimation = new Timer();
            tmrAnimation.Tick += new EventHandler(tmAnimation_Tick);

            tmrWait = new Timer();
            tmrWait.Tick += new EventHandler(tmWait_Tick);

            timer1 = new Timer();
            timer1.Tick += new EventHandler(timer1_Tick);
            timer1.Enabled = false;

        }

        private void frmPopup_MouseClick(Object sender, MouseEventArgs e)
        {


            if (e.X > frmPopup.Width - 5 - 16 & e.X < frmPopup.Width - 5 & e.Y > 2 & e.Y < 18)
            {
                Hide();
            }
        }


        private long getcurrenttime()
        {
            return (DateTime.Now.ToFileTime() / 10000000);
        }

        /// <summary>
        /// Show the notification window if it is not already visible.
        /// If the window is currently disappearing, it is shown again.
        /// </summary>
        int fresh_count = 0;
        int pop_show_time = 5;   //sec
        bool do_once = true;
        private Object thisLock = new Object();
        List<Image> image_type = new List<Image>();

        public void popup(string strTitle, string strContent, int nTimeToShow, int nTimeToStay, int nTimeToHide, int notify, Image imageshow)
        {
          

            System.Diagnostics.Debug.WriteLine("New message to show");

            isAppearing = true;
            if (do_once == true)
            {
                timer1.Enabled = false;
                frmPopup.Opacity = 1;
                frmPopup.Show();
                do_once = false;
                animation_working = false;

            }

            //       tmrAnimation.Stop();



            if (timelist.Count > 4)
            {

                timelist_wait.Add(getcurrenttime());
                message_cont_wait.Add(strTitle);
                message_type_wait.Add(strContent);
                message_image_wait.Add(imageshow);


            }
            else
            {



                timelist.Add(pop_show_time + getcurrenttime());
                message_type.Add(strTitle);
                message_cont.Add(strContent);
                message_image.Add(imageshow);

            }



            frmPopup.cont_post = timelist.Count;
            frmPopup.timelist_data = timelist;
            frmPopup.message_cont_show = message_cont;
            frmPopup.message_type_show = message_type;
            frmPopup.message_image_show = message_image;




            if (timer1.Enabled != true)
            {
                timer1.Enabled = true;
                timer1.Interval = pop_show_time * (1000);  //milisecond

            }

          

            if (timelist_wait.Count == 0)
            {
                refreshform(true);
            }

          


        }

        private void refreshform(bool anim)
        {

            //   tmrAnimation.Stop();

            Size = new Size(wid, 20 + (h_t * timelist.Count));

            System.Diagnostics.Debug.WriteLine(timelist.Count);
            if (anim == false)
            {
                //while going down content need to be refreshed first then and then displayed on screen 
                frmPopup.Refresh();
                frmPopup.Size = Size;
            }
            else
            {
                //while animation is on form size refresh not require 
                frmPopup.Size = Size;
            }

            frmPopup.painting_require = false;

            if (Scroll == true & anim == true)
            {
                if (animation_working == true)
                {
                    posStart = posCurrent;
                    System.Diagnostics.Debug.WriteLine("Postion start ");
                    System.Diagnostics.Debug.WriteLine(posStart);

                    posStop = Screen.PrimaryScreen.WorkingArea.Bottom - (frmPopup.Height);

                }
                else
                {
                    posStart = Screen.PrimaryScreen.WorkingArea.Bottom - (h_t * (timelist.Count - 1) + 20);
                    posStop = Screen.PrimaryScreen.WorkingArea.Bottom - (frmPopup.Height);
                }
            }
            else
            {
                posStart = Screen.PrimaryScreen.WorkingArea.Bottom - (frmPopup.Height);
                posStop = Screen.PrimaryScreen.WorkingArea.Bottom - (frmPopup.Height);
            }

            opacityStart = 1;
            opacityStop = 1;
            
            frmPopup.Location = new Point(Screen.PrimaryScreen.WorkingArea.Right - frmPopup.Size.Width - 1, posStart);
            System.Diagnostics.Debug.WriteLine("value at refresh");
            System.Diagnostics.Debug.WriteLine(frmPopup.Location.Y.ToString());



            if (anim == true)
            {
                animation_working = true;
                frmPopup.Opacity = 1;
                tmrAnimation.Interval = AnimationInterval;
                tmrAnimation.Start();
                sw = System.Diagnostics.Stopwatch.StartNew();
                System.Diagnostics.Debug.WriteLine("Animation started.");
            }
            else
            {
                frmPopup.Opacity = 1;
            }

            frmPopup.painting_require = true;
            // referesh require to fill netw
        }



        private Object timerLock = new Object();

        private void timer1_Tick(object sender, EventArgs e)
        {

            timer1.Enabled = false;


            if (timelist.Count > 0)
            {

                for (int i = 0; i < timelist.Count; i++)
                {
                    if (timelist[i] <= getcurrenttime())
                    {

                        timelist.RemoveAt(i);
                        message_cont.RemoveAt(i);
                        message_type.RemoveAt(i);
                        message_image.RemoveAt(i);


                        i--;
                    }
                }
                System.Diagnostics.Debug.WriteLine("Current timeout removed list count" + timelist.Count);
                int temp_count = 5 - timelist.Count;
                for (int j = 0; j < temp_count; j++)
                {
                    if (timelist_wait.Count > 0)
                    {

                        timelist.Add(getcurrenttime() + pop_show_time);
                        message_type.Add(message_cont_wait[0]);
                        message_cont.Add(message_type_wait[0]);
                        message_image.Add(message_image_wait[0]);

                        System.Diagnostics.Debug.WriteLine("waiting list count" + timelist_wait.Count);
                        System.Diagnostics.Debug.WriteLine(message_cont_wait[0]);
                        timelist_wait.RemoveAt(0);
                        message_cont_wait.RemoveAt(0);
                        message_type_wait.RemoveAt(0);
                        message_image_wait.RemoveAt(0);

                    }
                    else
                    {
                        break;
                    }

                }

                if (timelist.Count > 0)
                {

                    System.Diagnostics.Debug.WriteLine("showing list count" + timelist.Count);
                    int temp = (int)(timelist[0] - getcurrenttime()); ;

                    if (temp > 0)
                    {
                        System.Diagnostics.Debug.WriteLine("Next timeout of list update system" + temp);
                        timer1.Interval = (temp * 1000);
                        timer1.Enabled = true;
                    }

                    else
                    {

                        timer1.Interval = 1;
                        timer1.Enabled = true;
                    }


                }

                else
                {

                    //none

                }



            }

            else
            {
                //none
            }

            frmPopup.cont_post = timelist.Count;
            frmPopup.timelist_data = timelist;
            frmPopup.message_cont_show = message_cont;
            frmPopup.message_type_show = message_type;
            frmPopup.message_image_show = message_image;

            System.Diagnostics.Debug.WriteLine("refresh from function called" + timelist.Count);
          
            refreshform(false);   
            // while coming down downpart is cut and then bought down cause flicks
         
            // Clearing form
            //  frmPopup.Show();
            if (timelist.Count == 0)
            {

                animation_working = false;
                sw.Reset();
                tmrAnimation.Stop();
                do_once = true;
                frmPopup.Hide();
                System.Diagnostics.Debug.WriteLine("from hide call");
                isAppearing = false;
            }



            //  listBox1.DataSource = null;

            //   listBox1.DataSource = timelist;

        }

        public void Hide()
        {
            frmPopup.painting_require = false;
      //      System.Diagnostics.Debug.WriteLine("Animation stopped.");
       //     System.Diagnostics.Debug.WriteLine("Wait timer stopped.");

            tmrWait.Stop();

            animation_working = false;
            sw.Reset();
            tmrAnimation.Stop();
            do_once = true;
            frmPopup.Hide();
        //    System.Diagnostics.Debug.WriteLine("from hide call");
            isAppearing = false;
            frmPopup.cont_post = 0;
            frmPopup.timelist_data.Clear();
            frmPopup.message_cont_show.Clear();
            frmPopup.message_type_show.Clear();
            timelist.Clear(); ;
            timelist_wait.Clear();

            message_type.Clear();
            message_cont.Clear();
            message_image.Clear();

            message_type_wait.Clear();
            message_cont_wait.Clear();
            message_image_wait.Clear();
        }

        private void tmAnimation_Tick(object sender, EventArgs e)
        {
            frmPopup.painting_require = false;
           
                long elapsed = sw.ElapsedMilliseconds;

                posCurrent = (int)(posStart + ((posStop - posStart) * elapsed / AnimationDuration));
                bool neg = (posStop - posStart) < 0;
                if ((neg && posCurrent < posStop) ||
                    (!neg && posCurrent > posStop))
                {
                    posCurrent = posStop;
                }



                frmPopup.increasehight(posCurrent);
                frmPopup.Top = posCurrent;
                frmPopup.painting_require = true;

        //        System.Diagnostics.Debug.WriteLine(frmPopup.Top);


                if (elapsed > AnimationDuration)
                {

                    animation_working = false;
                    sw.Reset();
                    tmrAnimation.Stop();
               //     System.Diagnostics.Debug.WriteLine("Animation stopped.");

                }
            

        }

        private void tmWait_Tick(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Wait timer elapsed.");
            tmrWait.Stop();
            tmrAnimation.Interval = AnimationInterval;
            tmrAnimation.Start();
            sw.Stop();
            sw.Start();
            System.Diagnostics.Debug.WriteLine("Animation started.");
        }

        private void frmPopup_MouseLeave(object sender, EventArgs e)
        {

            if (frmPopup.Visible)
            {
                timer1.Start();
            }


            /*  System.Diagnostics.Debug.WriteLine("MouseLeave");
            if (frmPopup.Visible && (OptionsMenu == null || !OptionsMenu.Visible))
            {
                tmrWait.Interval = Delay;
                tmrWait.Start();
                System.Diagnostics.Debug.WriteLine("Wait timer started.");
            }
            mouseIsOn = false;
           */
        }

        private void frmPopup_MouseEnter(object sender, EventArgs e)
        {

            if (isAppearing)
            {
                timer1.Stop();
            }

            /*
            System.Diagnostics.Debug.WriteLine("MouseEnter");
            if (!isAppearing)
            {
                frmPopup.Top = maxPosition;
                frmPopup.Opacity = maxOpacity;
                tmrAnimation.Stop();
                System.Diagnostics.Debug.WriteLine("Animation stopped.");
            }

            tmrWait.Stop();
            System.Diagnostics.Debug.WriteLine("Wait timer stopped.");

            mouseIsOn = true;
             */
        }

        protected override void Dispose(bool disposing)
        {
            if (!disposed)
            {
                if (disposing && frmPopup != null)
                {
                    frmPopup.Dispose();
                }
                disposed = true;
            }
            base.Dispose(disposing);
        }
    }

    public class PopupNotifierForm : System.Windows.Forms.Form
    {
        public event EventHandler LinkClick;

        public event EventHandler CloseClick;

        internal event EventHandler ContextMenuOpened;
        internal event EventHandler ContextMenuClosed;

        private bool mouseOnClose = false;
        private bool mouseOnLink = false;
        private bool mouseOnOptions = false;
        private int heightOfTitle;
        private bool mouseinside = false;
        public bool painting_require = false;

        private bool gdiInitialized = false;
        private Rectangle rcBody;
        private Rectangle rcHeader;
        private Rectangle rcForm;
        private Rectangle RectClose1;
        private LinearGradientBrush brushBody;
        private LinearGradientBrush brushHeader;
        private Brush brushButtonHover;
        private Pen penButtonBorder;
        private Pen penContent;
        private Pen penBorder;
        private Brush brushForeColor;
        private Brush brushLinkHover;
        private Brush brushContent;
        private Brush brushTitle;
        public Boolean paintreq = false;

        Dictionary<string,string> _item = new Dictionary<string,string>();
      //  public List<string> _item = new List<string>();
        public int cont_post;
        public int frm_hight = 70;
        public int frm_wide = 220;
        int spacing = 50;
        public List<long> timelist_data = new List<long>();
        public List<string> message_type_show = new List<string>();
        public List<string> message_cont_show = new List<string>();
        public List<Image> message_image_show = new List<Image>();
        

        public PopupNotifierForm(PopupNotifier parent)
        {
            Parent = parent;
            this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
            this.SetStyle(ControlStyles.ResizeRedraw, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            this.SetStyle(ControlStyles.UserPaint, true);
            this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            this.ShowInTaskbar = false;

            this.VisibleChanged += new EventHandler(PopupNotifierForm_VisibleChanged);
            this.MouseMove += new MouseEventHandler(PopupNotifierForm_MouseMove);
            this.MouseUp += new MouseEventHandler(PopupNotifierForm_MouseUp);
           this.Paint += new PaintEventHandler(PopupNotifierForm_Paint);
           this.MouseEnter += new EventHandler(PopupNotifierForm_MouseEnter);
            this.MouseLeave +=new EventHandler(PopupNotifierForm_MouseLeave);
         
           
            //this.Paint -= new PaintEventHandler(PopupNotifierForm_Paint);
        }

        private void PopupNotifierForm_MouseEnter(object sender, EventArgs e)
        {
            mouseinside = true;
            Invalidate();
        }

        private void PopupNotifierForm_MouseLeave(object sender, EventArgs e)
        {

            mouseinside = false;
            Invalidate();
        }
        private void PopupNotifierForm_VisibleChanged(object sender, EventArgs e)
        {
            if (this.Visible)
            {
                mouseOnClose = false;
                mouseOnLink = false;
                mouseOnOptions = false;
            }
        }

        private void InitializeComponent()
        {
            this.SuspendLayout();
            this.ClientSize = new System.Drawing.Size(392, 66);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "PopupNotifierForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.TopMost = true;
            this.ResumeLayout(false);
           

        }

        public new PopupNotifier Parent { get; set; }

        private int AddValueMax255(int input, int add)
        {
            return (input + add < 256) ? input + add : 255;
        }

        private int DedValueMin0(int input, int ded)
        {
            return (input - ded > 0) ? input - ded : 0;
        }

        private Color GetDarkerColor(Color color)
        {
            return System.Drawing.Color.FromArgb(255, DedValueMin0((int)color.R, Parent.GradientPower), DedValueMin0((int)color.G, Parent.GradientPower), DedValueMin0((int)color.B, Parent.GradientPower));
        }

        private Color GetLighterColor(Color color)
        {
            return System.Drawing.Color.FromArgb(255, AddValueMax255((int)color.R, Parent.GradientPower), AddValueMax255((int)color.G, Parent.GradientPower), AddValueMax255((int)color.B, Parent.GradientPower));
        }

        private RectangleF RectContentText
        {
            get
            {
                if (Parent.Image != null)
                {
                    return new RectangleF(
                        Parent.ImagePadding.Left + Parent.ImageSize.Width + Parent.ImagePadding.Right + Parent.ContentPadding.Left,
                        Parent.HeaderHeight + Parent.TitlePadding.Top + heightOfTitle + Parent.TitlePadding.Bottom + Parent.ContentPadding.Top,
                        this.Width - Parent.ImagePadding.Left - Parent.ImageSize.Width - Parent.ImagePadding.Right - Parent.ContentPadding.Left - Parent.ContentPadding.Right - 16 - 5,
                        this.Height - Parent.HeaderHeight - Parent.TitlePadding.Top - heightOfTitle - Parent.TitlePadding.Bottom - Parent.ContentPadding.Top - Parent.ContentPadding.Bottom - 1);
                }
                else
                {
                    return new RectangleF(
                        Parent.ContentPadding.Left,
                        Parent.HeaderHeight + Parent.TitlePadding.Top + heightOfTitle + Parent.TitlePadding.Bottom + Parent.ContentPadding.Top,
                        this.Width - Parent.ContentPadding.Left - Parent.ContentPadding.Right - 16 - 5,
                        this.Height - Parent.HeaderHeight - Parent.TitlePadding.Top - heightOfTitle - Parent.TitlePadding.Bottom - Parent.ContentPadding.Top - Parent.ContentPadding.Bottom - 1);
                }
            }
        }

        private Rectangle RectClose
        {
            get { return new Rectangle(this.Width - 5 - 16, Parent.HeaderHeight + 3, 16, 16); }
        }
        private Rectangle RectOptions
        {
            get { return new Rectangle(this.Width - 5 - 16, Parent.HeaderHeight + 3 + 16 + 5, 16, 16); }
        }

        private void PopupNotifierForm_MouseMove(object sender, MouseEventArgs e)
        {
            if (Parent.ShowCloseButton)
            {
                mouseOnClose = RectClose1.Contains(e.X, e.Y);
            }
            if (Parent.ShowOptionsButton)
            {
                mouseOnOptions = RectOptions.Contains(e.X, e.Y);
            }
            mouseOnLink = RectContentText.Contains(e.X, e.Y);
            Invalidate();
        }

        private void PopupNotifierForm_MouseUp(object sender, MouseEventArgs e)
        {
            if (e.Button == System.Windows.Forms.MouseButtons.Left)
            {
                if (RectClose.Contains(e.X, e.Y) && (CloseClick != null))
                {
                    CloseClick(this, EventArgs.Empty);
                }
                if (RectContentText.Contains(e.X, e.Y) && (LinkClick != null))
                {
                    LinkClick(this, EventArgs.Empty);
                }
                if (RectOptions.Contains(e.X, e.Y) && (Parent.OptionsMenu != null))
                {
                    if (ContextMenuOpened != null)
                    {
                        ContextMenuOpened(this, EventArgs.Empty);
                    }
                    Parent.OptionsMenu.Show(this, new Point(RectOptions.Right - Parent.OptionsMenu.Width, RectOptions.Bottom));
                    Parent.OptionsMenu.Closed += new ToolStripDropDownClosedEventHandler(OptionsMenu_Closed);
                }
            }
        }
        private void OptionsMenu_Closed(object sender, ToolStripDropDownClosedEventArgs e)
        {
            Parent.OptionsMenu.Closed -= new ToolStripDropDownClosedEventHandler(OptionsMenu_Closed);

            if (ContextMenuClosed != null)
            {
                ContextMenuClosed(this, EventArgs.Empty);
            }
        }

        private void DisposeGDIObjects()
        {
            if (gdiInitialized)
            {
                brushBody.Dispose();
                brushHeader.Dispose();
                brushButtonHover.Dispose();
                penButtonBorder.Dispose();
                penContent.Dispose();
                penBorder.Dispose();
                brushForeColor.Dispose();
                brushLinkHover.Dispose();
                brushContent.Dispose();
                brushTitle.Dispose();
            }
        }
        private void PopupNotifierForm_Paint(object sender, PaintEventArgs e)
        {
            if (true == painting_require)
            {

                // draw window
                if (cont_post == 1)
                {
                    rcBody = new Rectangle(0, 0, this.Width, frm_hight);
                    rcHeader = new Rectangle(0, 0, this.Width, Parent.HeaderHeight);
                    rcForm = new Rectangle(0, 0, this.Width - 1, (frm_hight - 1));
                    //     RectClose1 = new Rectangle(this.Width - 5 - 16, Parent.HeaderHeight + 3 , 16, 16);
                    RectClose1 = new Rectangle(this.Width - 5 - 16, 2, 16, 16);
                    //frmPopup_CloseClick

                }

                else
                {
                    rcBody = new Rectangle(0, 0, this.Width, ((cont_post) * 75));
                    rcHeader = new Rectangle(0, 0, this.Width, Parent.HeaderHeight);
                    //  RectClose1 = new Rectangle(this.Width - 5 - 16, Parent.HeaderHeight + 3, 16, 16);
                    RectClose1 = new Rectangle(this.Width - 5 - 16, 2, 16, 16);

                }

                Brush brushBody = new SolidBrush(Parent.BodyColor);
                Brush brushHeader = new SolidBrush(Parent.HeaderColor);
                e.Graphics.FillRectangle(brushBody, rcBody);
                e.Graphics.FillRectangle(brushHeader, rcHeader);

             //   System.Diagnostics.Debug.WriteLine("paint called");
                for (int i = 0; i < cont_post; i++)
                {
                    showcontent(e, _item, i);
                }
            }
              
        }

        public void increasehight(int current_heightvalue)
        {
            this.Height = Screen.PrimaryScreen.WorkingArea.Bottom - current_heightvalue ;
        }

        bool paint_once = true;

        private void showcontent(PaintEventArgs e, Dictionary<string, string> _item, int cont_position)
        {
            brushButtonHover = new SolidBrush(Parent.ButtonHoverColor);
            penButtonBorder = new Pen(Parent.ButtonBorderColor);
            penContent = new Pen(Parent.ContentColor, 2);
            penBorder = new Pen(Parent.BorderColor);
            brushForeColor = new SolidBrush(ForeColor);
            brushLinkHover = new SolidBrush(Parent.ContentHoverColor);
            brushContent = new SolidBrush(Parent.ContentColor);
            brushTitle = new SolidBrush(Parent.TitleColor);
            Pen pen_divde = new Pen( Color.White);
            gdiInitialized = true;

          
            //Dispatcher Test
            if (Parent.ShowGripText)
            {
                e.Graphics.DrawString(Parent.HeaderText, Parent.HeaderFont, brushTitle, (int)((rcHeader.X)), (int)(rcHeader.Y) + 2);
            }


            //paint of close button
            if (Parent.ShowCloseButton)
            {
                
                if (mouseOnClose)
                {
                    e.Graphics.FillRectangle(brushButtonHover, RectClose1);
                    e.Graphics.DrawRectangle(penButtonBorder, RectClose1);
                }

                if (mouseinside == true)
                {
                    e.Graphics.DrawLine(penContent, RectClose1.Left + 4, RectClose1.Top + 4, RectClose1.Right - 4, RectClose1.Bottom - 4);
                    e.Graphics.DrawLine(penContent, RectClose1.Left + 4, RectClose1.Bottom - 4, RectClose1.Right - 4, RectClose1.Top + 4);

                }
            }
               
            if (Parent.Image != null)
            {
                e.Graphics.DrawImage(message_image_show[cont_position], Parent.ImagePadding.Left, Parent.HeaderHeight + Parent.ImagePadding.Top + (spacing * cont_position), Parent.ImageSize.Width, Parent.ImageSize.Height);
            }

            heightOfTitle = (int)e.Graphics.MeasureString("A", Parent.TitleFont).Height;
            int titleX = Parent.TitlePadding.Left;
            if (Parent.Image != null)
            {
                titleX += Parent.ImagePadding.Left + Parent.ImageSize.Width + Parent.ImagePadding.Right;
            }
           
            e.Graphics.DrawString(message_type_show[cont_position], Parent.TitleFont, brushTitle, titleX + 5, Parent.HeaderHeight + Parent.TitlePadding.Top + (spacing * cont_position));
            int temp_string_length = message_cont_show[cont_position].Length;
            if (temp_string_length < 25)
            {
                e.Graphics.DrawString(message_cont_show[cont_position].Substring(0,25), Parent.ContentFont, brushContent, titleX + 5, Parent.HeaderHeight + 18 + Parent.TitlePadding.Top + (spacing * cont_position));
            }
            else
            {
                e.Graphics.DrawString(message_cont_show[cont_position].Substring(0, 25).Trim(), Parent.ContentFont, brushContent, titleX + 5, Parent.HeaderHeight + 18 + Parent.TitlePadding.Top + (spacing * cont_position));
         
                e.Graphics.DrawString(message_cont_show[cont_position].Substring(26).Trim(), Parent.ContentFont, brushContent, titleX + 5, Parent.HeaderHeight + 28 + Parent.TitlePadding.Top + (spacing * cont_position));
          

            }
            //   e.Graphics.DrawString(Parent.ContentText, Parent.ContentFont, brushContent, RectContentText);
            if (cont_position > 0)
            {
                Point start_point = new Point(Parent.ImagePadding.Left, 19+ (50 * cont_position));
                Point end_point = new Point(Parent.ImagePadding.Left + 200,19 + (50 * cont_position));
                e.Graphics.DrawLine(pen_divde, start_point, end_point);
            }
        }

       
        protected override void Dispose(bool disposing)
        {
           
            base.Dispose(disposing);
        }
    }
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'
#>
$helper = New-Object -TypeName 'NotificationWindow.PopupNotifier'

$helper.AnimationDuration = 250
$helper.AnimationInterval = 1
$helper.BodyColor = [System.Drawing.SystemColors]::GradientActiveCaption
$helper.BorderColor = [System.Drawing.Color]::Aqua
$helper.ButtonBorderColor = [System.Drawing.Color]::FromArgb([int]([byte]192),[int]([byte]255),[int]([byte]255))
$helper.ContentFont = New-Object System.Drawing.Font ("Tahoma",8)
$helper.ContentPadding = New-Object System.Windows.Forms.Padding (0,17,0,0)
$helper.ContentText = $null
$helper.GradientPower = 300
$helper.HeaderColor = [System.Drawing.Color]::SteelBlue
$helper.HeaderFont = New-Object System.Drawing.Font ("Bookman Old Style",`
     9.75,`
     [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic),`
     [System.Drawing.GraphicsUnit]::Point,[byte]0)
$helper.HeaderHeight = 20
$helper.HeaderPadding = New-Object System.Windows.Forms.Padding (0)
$helper.HeaderText = "Header Text"
#  $helper.Image = global::try_pop_up.Properties.Resources]::DispatcherIcon
$helper.ImagePadding = New-Object System.Windows.Forms.Padding (10,13,0,0)
$helper.ImageSize = New-Object System.Drawing.Size (30,30)
$helper.OptionsMenu = $null
# $helper.Scroll = $false
# $helper.ShowCloseButton = $false
$helper.Size = New-Object System.Drawing.Size (220,75)
$helper.TitleColor = [System.Drawing.Color]::Black;
$helper.TitleFont = New-Object System.Drawing.Font ("Segoe UI",`
     9.75,`
     [System.Drawing.FontStyle]::Bold,`
     [System.Drawing.GraphicsUnit]::Point,`
     [byte]0)
$helper.TitlePadding = New-Object System.Windows.Forms.Padding (0,2,0,0)
$helper.TitleText = "Hello"


$helper.TitleText = "Hello"
$helper.ContentText = "content text"
$helper.ShowCloseButton = $true
$helper.ShowOptionsButton = $false
$helper.ShowGripText = $true
$helper.Delay = 5000
$helper.AnimationInterval = 1
$helper.AnimationDuration = 400
$helper.Scroll = $true
$helper.ShowCloseButton = $true

$helper.popup("Message Type 0","Message Detail Message Detail Message Detail 0",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())
$helper.popup("Message Type 2","Message Detail Message Detail Message Detail",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())
$helper.popup("Message Type 1","Message Detail Message Detail Message Detail",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())
$helper.popup("Message Type 3","Message Detail Message Detail Message Detail",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())
$helper.popup("Message Type 4","Message Detail Message Detail Message Detail",10,10,10,10,[System.Drawing.Image]([System.Drawing.SystemIcons]::Error).ToBitmap())

# popupNotifier1.popup("Message Type" , "Message Detail Message Detail Message Detail ", 10, 10, 10, 10, Properties.Resources._1);
