using System;
using System.Windows.Forms;

namespace ServiceMonitor
{
    public partial class InputText : Form
    {
        public string Title
        {
            get { return Text; }
            set { Text = value; }
        }
        public string TextLabel
        {
            get { return lbText.Text; }
            set { lbText.Text = value; }
        }
        public string TextValue
        {
            get { return txtValue.Text; }
            set { txtValue.Text = value; }
        }

        public InputText()
        {
            InitializeComponent();
        }

        private void BtnOkClick(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
        }

        private void BtnCancelClick(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
        }

        private void TxtValueKeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                BtnOkClick(sender, new EventArgs());
            }
        }
    }
}
