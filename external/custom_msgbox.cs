using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

// http://www.codeproject.com/Tips/827370/Custom-Message-Box-DLL
// open a class library project in your Visual Studio and add 2 references in solution explorer
// system.windows.form and system.drawing.
// First, make an enum by adding a cs file to your solution 
// remove the class name given by default and write Enum just below namespace like given below.

namespace nameMSGBOX
{
#region Enums
public enum MSGICON
    {
        Error,
        Information,
        Warning,
        Question,
    }
public enum MSGBUTTON
    {
        None,
        OK,
        YesNo,
        YesNoCancel,
        RetryCancle,
        AbortRetryIgnore
    }
public enum MSGRESPONSE
    {
        None,
        Yes,
        No,
        OK,
        Abort,
        Retry,
        Ignore,
        Cancel
    }
 #endregion
}
// now write the codes for your class which will be generating the messagebox.
using System;
using System.Collections.Generic;
using System.Drawing.Imaging;
using System.Text;
using System.Windows.Forms;
using System.Drawing;
using System.Drawing.Design;
using System.ComponentModel;
using System.Reflection;
namespace nameMSGBOX
{
    public class MSGBOX
    {
     #region initialize controls
     public Form frm = new Form();
     internal Button btnDetails = new Button();
     Button btnOK = new Button();
     Button btnYes = new Button();
     Button btnNo = new Button();
     Button btnCancel = new Button();
     Button btnAbort = new Button();
     Button btnRetry = new Button();
     Button btnIgnore = new Button();
     TextBox txtDescription = new TextBox();
     PictureBox icnPicture = new PictureBox();
     Panel formpanel = new Panel();
     Label lblmessage = new Label();
     static MSGRESPONSE msgresponse = new MSGRESPONSE();
     #endregion initialize controls

     #region DrawingFunction
     internal void DrawBox()
        {
            //draw panel
            frm.Controls.Add(formpanel);
            formpanel.Dock = DockStyle.Fill;
            //draw picturebox
            icnPicture.Height = 36;
            icnPicture.Width = 40;
            icnPicture.Location = new Point(10, 11);
            formpanel.Controls.Add(icnPicture);
          //drawing textbox
            txtDescription.Multiline = true;
            txtDescription.Height = 183;
            txtDescription.Width = 464;
            txtDescription.Location = new Point(6, 143);
            txtDescription.BorderStyle = BorderStyle.Fixed3D;
            txtDescription.ScrollBars = ScrollBars.Both;
            txtDescription.ReadOnly = true;
            formpanel.Controls.Add(txtDescription);

        //drawing detail button
            btnDetails.Height = 24;
            btnDetails.Width = 80;
            btnDetails.Location = new Point(6, 114);
            btnDetails.Tag = "exp";
            btnDetails.Text = "Show Details";
            formpanel.Controls.Add(btnDetails);
            this.btnDetails.Click += new EventHandler(this.btnDetails_click);
            lblmessage.Location = new Point(64, 22);
            lblmessage.AutoSize = true;
            formpanel.Controls.Add(lblmessage);
            frm.Height = 360;
            frm.Width = 483;

            //set form layout
            frm.StartPosition = FormStartPosition.CenterScreen;
            frm.FormBorderStyle = FormBorderStyle.FixedSingle;
            frm.MaximizeBox = false;
            frm.MinimizeBox = false;
            frm.FormClosing += new FormClosingEventHandler(frm_FormClosing);
            frm.BackColor = System.Drawing.SystemColors.ButtonFace;

         //messagebox icon
            frm.Icon = ((System.Drawing.Icon)(nameMSGBOX.Properties.Resources.P));
            if (btnDetails.Tag.ToString() == "exp")
            {
                frm.Height = frm.Height - txtDescription.Height - 6;
                btnDetails.Tag = "col";
                btnDetails.Text = "Show Details";
            }
        }

         /// <summary>
        /// adding message button
       /// </summary>
      /// <param name="mYmEsSaGeBuTtOn">messagebutton</param>
         private void AddButton(MSGBUTTON MSGBTN)
        {
            switch (MSGBTN)
            {
               case MSGBUTTON.OK:
                    {
                        btnOK.Width = 80;
                        btnOK.Height = 24;
                        btnOK.Location = new Point(391, 114);
                        btnOK.Text = "OK";
                        formpanel.Controls.Add(btnOK);
                        btnOK.Click += new EventHandler(Return_Response);
                    }
                    break;
               
                case MSGBUTTON.YesNo:
                    {
                        //btnNo
                        btnNo.Width = 80;
                        btnNo.Height = 24;
                        btnNo.Location = new Point(391, 114);
                        btnNo.Text = "No";
                        formpanel.Controls.Add(btnNo);
                        btnNo.Click += new EventHandler(Return_Response);
                        //btnYes
                        btnYes.Width = 80;
                        btnYes.Height = 24;
                        btnYes.Location = new Point(btnNo.Location.X - btnNo.Width - 2, 114);
                        btnYes.Text = "Yes";
                        formpanel.Controls.Add(btnYes);
                        btnYes.Click += new EventHandler(Return_Response);
                    }
                    break;
              
               case MSGBUTTON.YesNoCancel:
                    {
                        //btnCancle
                        btnCancel.Width = 80;
                        btnCancel.Height = 24;
                        btnCancel.Location = new Point(391, 114);
                        btnCancel.Text = "Cancel";
                        formpanel.Controls.Add(btnCancel);
                        btnCancel.Click += new EventHandler(Return_Response);
                        //btnNo
                        btnNo.Width = 80;
                        btnNo.Height = 24;
                        btnNo.Location = new Point(btnCancel.Location.X - btnCancel.Width - 2, 114);
                        btnNo.Text = "No";
                        formpanel.Controls.Add(btnNo);
                        btnNo.Click += new EventHandler(Return_Response);
                        //btnYes
                        btnYes.Width = 80;
                        btnYes.Height = 24;
                        btnYes.Location = new Point(btnNo.Location.X - btnNo.Width - 2, 114);
                        btnYes.Text = "Yes";
                        formpanel.Controls.Add(btnYes);
                        btnYes.Click += new EventHandler(Return_Response);
                    }
                    break;

                  case MSGBUTTON.RetryCancle:
                    {
                        //button cancel
                        btnCancel.Width = 80;
                        btnCancel.Height = 24;
                        btnCancel.Location = new Point(391, 114);
                        btnCancel.Text = "Cancel";
                        formpanel.Controls.Add(btnCancel);
                        btnCancel.Click += new EventHandler(Return_Response);
                        //button Retry
                        btnRetry.Width = 80;
                        btnRetry.Height = 24;
                        btnRetry.Location = new Point(btnCancel.Location.X - btnCancel.Width - 2, 114);
                        btnRetry.Text = "Retry";
                        formpanel.Controls.Add(btnRetry);
                        btnRetry.Click += new EventHandler(Return_Response);
                    }
                    break;

                    case MSGBUTTON.AbortRetryIgnore:
                    {
                        //button Ignore
                        btnIgnore.Width = 80;
                        btnIgnore.Height = 24;
                        btnIgnore.Location = new Point(391, 114);
                        btnIgnore.Text = "Ignore";
                        formpanel.Controls.Add(btnIgnore);
                        btnIgnore.Click += new EventHandler(Return_Response);
                        //button Retry
                        btnRetry.Width = 80;
                        btnRetry.Height = 24;
                        btnRetry.Location = new Point(btnIgnore.Location.X - btnIgnore.Width - 2, 114);
                        btnRetry.Text = "Retry";
                        formpanel.Controls.Add(btnRetry);
                        btnRetry.Click += new EventHandler(Return_Response);
                        //button Abort
                        btnAbort.Width = 80;
                        btnAbort.Height = 24;
                        btnAbort.Location = new Point(btnRetry.Location.X - btnRetry.Width - 2, 114);
                        btnAbort.Text = "Abort";
                        formpanel.Controls.Add(btnAbort);
                        btnAbort.Click += new EventHandler(Return_Response);
                    }
                    break;

                   case MSGBUTTON.None:
                    {
                        btnOK.Width = 80;
                        btnOK.Height = 24;
                        btnOK.Location = new Point(391, 114);
                        btnOK.Text = "OK";
                        formpanel.Controls.Add(btnOK);
                        btnOK.Click += new EventHandler(Return_Response);
                    }
                    break;
            }
        }

        /// <summary>
        /// adding message icon
        /// </summary>
        /// <param name="MSGICON">icon</param>
        internal void AddIconImage(MSGICON MSGICON)
        {
            switch (MSGICON)
            {
                case MSGICON.Error:
                    icnPicture.Image = SystemIcons.Error.ToBitmap();  //Error is key name in 
                            //imagelist control which uniqly identified images in ImageList control.
                    break;
                case MSGICON.Information:
                    icnPicture.Image = SystemIcons.Information.ToBitmap();
                    break;
                case MSGICON.Question:
                    icnPicture.Image = SystemIcons.Question.ToBitmap();
                    break;
                case MSGICON.Warning:
                    icnPicture.Image = SystemIcons.Warning.ToBitmap();
                    break;
                default:
                    icnPicture.Image = SystemIcons.Information.ToBitmap();
                    break;
            }
        }

     #endregion DrawingFunction

   #region EVents
        /// <summary>
        /// detail button click
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnDetails_click(object sender, EventArgs e)
        {
            if (btnDetails.Tag.ToString() == "col")
            {
                frm.Height = frm.Height + txtDescription.Height + 6;
                btnDetails.Tag = "exp";
                btnDetails.Text = "Hide Details";
                txtDescription.WordWrap = true;
                //txtDescription.Focus();
                //txtDescription.SelectionLength = 0;
            }
            else if (btnDetails.Tag.ToString() == "exp")
            {
                frm.Height = frm.Height - txtDescription.Height - 6;
                btnDetails.Tag = "col";
                btnDetails.Text = "Show Details";
            }
        }

          /// <summary>
         /// form closing event
        /// </summary>
       /// <param name="sender"></param>
      /// <param name="e"></param>
        private void frm_FormClosing(object sender, EventArgs e)
        {
            if (msgresponse == MSGRESPONSE.None)
            {
                msgresponse = MSGRESPONSE.Cancel;
            }
        }

        /// <summary>
        /// event to return dialogue result
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
         private void Return_Response(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string buttonText = btn.Text;
            if (buttonText == "Yes")
            {
                msgresponse = MSGRESPONSE.Yes;
            }
            else if (buttonText == "No")
            {
                msgresponse = MSGRESPONSE.No;
            }
            else if (buttonText == "Cancel")
            {
                msgresponse = MSGRESPONSE.Cancel;
            }
           else if (buttonText == "OK")
            {
                msgresponse = MSGRESPONSE.OK;
            }
          else if (buttonText == "Abort")
            {
                msgresponse = MSGRESPONSE.Abort;
            }
         else if (buttonText == "Retry")
            {
                msgresponse = MSGRESPONSE.Retry;
            }
         else if (buttonText == "Ignore")
            {
                msgresponse = MSGRESPONSE.Ignore;
            }
         else
            {
                msgresponse = MSGRESPONSE.Cancel;
            }
         frm.Dispose();
        }
       #endregion Events

      #region Overloaded Show message to display message box.
      // <summary>
        /// Show method is overloaded which is used to display message
        /// and this is static method so that we don't need to create 
        /// object of this class to call this method.
        /// </summary>
        /// <param name="messageText">Message Text</param>
 public static MSGRESPONSE Show(string messageText)
        {
            MSGBOX frmMessage = new MSGBOX();
            frmMessage.SetMessageText(messageText, "", null);
            frmMessage.AddIconImage(MSGICON.Information);
            frmMessage.AddButton(MSGBUTTON.OK);
            frmMessage.DrawBox();
            frmMessage.frm.ShowDialog();
            return msgresponse;
        }

  /// <summary>
        /// Show method is overloaded which is used to display message
        /// and this is static method so that we don't need to create 
        /// object of this class to call this method.
        /// </summary>
        /// <param name="messageText">Message Text</param>
        /// <param name="messageTitle">Message Title</param>
        /// <param name="description">Additional Description i.e Stack Trace</param>
    public static MSGRESPONSE Show(string messageText, string messageTitle, string description)
        {
            MSGBOX frmMessage = new MSGBOX();
            frmMessage.SetMessageText(messageText, messageTitle, description);
            frmMessage.AddIconImage(MSGICON.Information);
            frmMessage.AddButton(MSGBUTTON.OK);
            frmMessage.DrawBox();
            frmMessage.frm.ShowDialog();
            return msgresponse;
        }

     /// <summary>
        /// Show method is overloaded which is used to display message
        /// and this is static method so that we don't need to create 
        /// object of this class to call this method.
        /// </summary>
        /// <param name="messageText">Message Text</param>
        /// <param name="messageTitle">Message Title</param>
        /// <param name="description">Additional Description i.e Stack Trace</param>
        /// <param name="mYmEsSaGeIcOn">Message Icon</param>
        /// <param name="mYmEsSaGeBuTtOn">Message Button</param>
      public static MSGRESPONSE Show(string messageText, 
          string messageTitle, string description, MSGICON IcOn, MSGBUTTON btn)
        {
            MSGBOX frmMessage = new MSGBOX();
            frmMessage.SetMessageText(messageText, messageTitle, description);
            //frmMessage.Text = messageTitle;
            frmMessage.AddIconImage(IcOn);
            frmMessage.AddButton(btn);
            frmMessage.DrawBox();
            frmMessage.frm.ShowDialog();
            return msgresponse;
        }

    /// <summary>
        /// exception message box
        /// </summary>
        /// <param name="messageText"></param>
        /// <param name="Title"></param>
        /// <param name="Description"></param>
         public static MSGRESPONSE ShowException(Exception ex)
        {
            MSGBOX frmMessage = new MSGBOX();
            frmMessage.SetMessageText(ex.Message, ex.Message, ex.StackTrace);
            //frmMessage.Text = messageTitle;
            frmMessage.AddIconImage(MSGICON.Error);
            frmMessage.AddButton(MSGBUTTON.OK);
            frmMessage.DrawBox();
            frmMessage.frm.ShowDialog();
            return msgresponse;
        }
     #endregion Overloaded Show message to display message box.

 #region Private Methodes to set messagebox Display
        private void SetMessageText(string messageText, string Title, string Description)
        {
            this.lblmessage.Text = messageText;
            if (!string.IsNullOrEmpty(Description))
            {
                this.txtDescription.Text = Description;
            }
            else
            {
                btnDetails.Visible = false;
            }
            if (!string.IsNullOrEmpty(Title))
            {
                frm.Text = Title;
            }
            else
            {
                frm.Text = "Your Message Box From DLL";
            }
        }
        #endregion Private Methodes to set messagebox Display
    }
}