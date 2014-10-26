 // http://msdn.microsoft.com/en-us/library/ms172532%28v=vs.90%29.aspx
using System;
using System.Drawing;
using System.Windows.Forms;

namespace PictureButton
{
    public class PictureButtonDemo : System.Windows.Forms.Form


    {
        int clickCount = 0;

        // Create a bitmap object and fill it with the specified color.    
        // To make it look like a custom image, draw an ellipse in it.
        Bitmap MakeBitmap(Color color, int width, int height)
        {
            Bitmap bmp = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bmp);
            g.FillRectangle(new SolidBrush(color), 0, 0, bmp.Width, bmp.Height);
            g.DrawEllipse(new Pen(Color.DarkGray), 3, 3, width - 6, height - 6);
            g.Dispose();

            return bmp;
        }

        // Create a new PictureButton control and hook up its properties. 
        public PictureButtonDemo()
        {
            InitializeComponent();

            // Display the OK close button. 
            this.MinimizeBox = false;

            PictureButton button = new PictureButton();
            button.Parent = this;
            button.Bounds = new Rectangle(10, 30, 150, 30);
            button.ForeColor = Color.White;
            button.BackgroundImage = MakeBitmap(Color.Blue, button.Width, button.Height);
            button.PressedImage = MakeBitmap(Color.LightBlue, button.Width, button.Height);
            button.Text = "click me";
            button.Click +=new EventHandler(button_Click);
        }

        protected override void Dispose( bool disposing )
        {
            base.Dispose( disposing );
        }

        private void InitializeComponent()
        {
            this.Text = "Picture Button Demo";
        }

        static void Main() 
        {
            Application.Run(new PictureButtonDemo());
        }

        // Since PictureButton inherits from Control, we can just use the default 
        // Click event that Control supports. 
        private void button_Click(object sender, EventArgs e)
        {
            this.Text = "Click Count = " + ++this.clickCount;
        }
    }

    // This code shows a simple way to have a  
    // button-like control that has a background image. 
    public class PictureButton : Control
    {
protected override void Dispose( bool disposing )
        {
            base.Dispose( disposing );
        }

        Image backgroundImage, pressedImage;
        bool pressed = false;

        // Property for the background image to be drawn behind the button text. 
        public override Image BackgroundImage
        {
            get
            {
                return this.backgroundImage;
            }
            set
            {
                this.backgroundImage = value;
            }
        }

        // Property for the background image to be drawn behind the button text when 
        // the button is pressed. 
        public Image PressedImage
        {
            get
            {
                return this.pressedImage;
            }
            set
            {
                this.pressedImage = value;
            }
        }

        // When the mouse button is pressed, set the "pressed" flag to true  
        // and invalidate the form to cause a repaint.  The .NET Compact Framework  
        // sets the mouse capture automatically. 
        protected override void OnMouseDown(MouseEventArgs e)
        {
            this.pressed = true;
            this.Invalidate();
            base.OnMouseDown (e);
        }

        // When the mouse is released, reset the "pressed" flag 
        // and invalidate to redraw the button in the unpressed state. 
        protected override void OnMouseUp(MouseEventArgs e)
        {
            this.pressed = false;
            this.Invalidate();
            base.OnMouseUp (e);
        }

        // Override the OnPaint method to draw the background image and the text. 
        protected override void OnPaint(PaintEventArgs e)
        {
            if(this.pressed && this.pressedImage != null)
                e.Graphics.DrawImage(this.pressedImage, 0, 0);
            else
                e.Graphics.DrawImage(this.backgroundImage, 0, 0);

            // Draw the text if there is any. 
            if(this.Text.Length > 0)
            {
                SizeF size = e.Graphics.MeasureString(this.Text, this.Font);

                // Center the text inside the client area of the PictureButton.
                e.Graphics.DrawString(this.Text,
                    this.Font,
                    new SolidBrush(this.ForeColor),
                    (this.ClientSize.Width - size.Width) / 2,
                    (this.ClientSize.Height - size.Height) / 2);
            }

            // Draw a border around the outside of the  
            // control to look like Pocket PC buttons.
            e.Graphics.DrawRectangle(new Pen(Color.Black), 0, 0, 
                this.ClientSize.Width - 1, this.ClientSize.Height - 1);

            base.OnPaint(e);
        }
    }


    public class TimerPanel : System.Windows.Forms.Panel
    {
        private string _message;

        public System.Timers.Timer timer1;
        private System.ComponentModel.Container components = null;

        public TimerPanel()
        {
            //
            // Required for Windows Form Designer support
            //

            InitializeComponent();

            //
            // TODO: Add any constructor code after InitializeComponent call
            //
        }

        public string Message
        {
            get { 
                return _message; 
           }
           set { _message = value; }
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
            timer1.Stop();

            base.Dispose( disposing );
        }

        private void InitializeComponent()
        {
         this.timer1 = new System.Timers.Timer();
         ((System.ComponentModel.ISupportInitialize)(this.timer1)).BeginInit();
         this.SuspendLayout();
         // 
         // timer1
         // 
         this.timer1.Enabled = true;
         this.timer1.SynchronizingObject = this;
         this.timer1.Elapsed += new System.Timers.ElapsedEventHandler(this.OnTimerElapsed);

         ((System.ComponentModel.ISupportInitialize)(this.timer1)).EndInit();
         this.ResumeLayout(false);

      }

        private void R
(object sender, System.EventArgs e)
        {
            // Set the interval time ( 1000 ms == 1 sec )
            // after which the timer function is activated
            timer1.Interval = 1000 ;
            // Start the Timer
            timer1.Start();
            // Enable the timer. The timer starts now
            timer1.Enabled = true ; 
        }
        private void OnTimerElapsed(object sender, System.Timers.ElapsedEventArgs e)
        {

        }

    }

}