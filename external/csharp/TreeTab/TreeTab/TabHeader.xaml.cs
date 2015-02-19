using System;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace TreeTab
{
    public partial class TabHeader : UserControl
    {
        #region Attributes

        private readonly bool showCloseButton;

        #endregion

        #region Constructor

        public TabHeader(string _headerText, bool _showCloseButton)
        {
            InitializeComponent();
            this.showCloseButton = _showCloseButton;
            this.HeaderText = _headerText;            
            if (!showCloseButton)
            {
                this.xTabHeader.Children.Remove(this.xClose);
            }
        }

        #endregion        

        #region Properties

        public bool ShowCloseButton
        {
            get { return showCloseButton; }
        }

        public string HeaderText
        {
            set
            {
                this.lblHeader.Content = value;
            }
            get
            {
                return this.lblHeader.Content.ToString();
            }
        }

        #endregion

        #region Events

        /// <summary>
        /// Closes the tab calling to the TreeTabControl's CloseTab method.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">RoutedEventArgs</param>
        private void xClose_Click(object sender, RoutedEventArgs e)
        {
            StackPanel stack = (StackPanel)((Button)e.OriginalSource).Parent;
            TabHeader header = (TabHeader) stack.Parent;
            TreeTabItem item = (TreeTabItem)header.Parent;
            
            FrameworkElement ctrl = item;            
            do
            {
                ctrl = (FrameworkElement)ctrl.Parent;
            }
            while (ctrl.Parent == null || ctrl.GetType() != typeof(TreeTabControl));

            TreeTabControl tabControl = (TreeTabControl)ctrl;
            tabControl.CloseTab(item);
        }

        #endregion
    }
}
