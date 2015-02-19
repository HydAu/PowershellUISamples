using System;
using System.Collections;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Reflection;

namespace TreeTab
{
    public partial class TreeTabControl : UserControl
    {
        #region Attributes

        public static TreeTabConfig config;
        private bool isTreeExpanded;
        private TreeTabItem selectedTabItem;

        #endregion

        #region Properties

        /// <summary>
        /// Shows the current selected TreeTabItem.
        /// </summary>
        public TreeTabItem SelectedTabItem
        {
            get
            {
                return this.selectedTabItem;
            }
        }

        /// <summary>
        /// Gets or sets the status of the TreeView control.
        /// Either it is hidden or it is shown.
        /// </summary>
        public bool IsTreeExpanded
        {
            get
            {
                return isTreeExpanded;
            }
            set
            {
                if (value != isTreeExpanded)
                {
                    if (isTreeExpanded)
                        this.HideTree();
                    else
                        this.ShowTree();
                }
            }
        }

        #endregion

        #region Constructors

        /// <summary>
        /// Tries to get the config file for the control.
        /// </summary>
        public TreeTabControl()
        {
            config = new TreeTabConfig();
            this.isTreeExpanded = true;
            InitializeComponent();
            this.GotFocus += new RoutedEventHandler(this.OnGotFocus);            
        }

        /// <summary>
        /// Inherits from the main constructor and set if the TreeView control will be shown.
        /// </summary>
        /// <param name="_showTree">bool</param>
        public TreeTabControl(bool _showTree) : this()
        {                        
            this.IsTreeExpanded = _showTree;
        }

        #endregion

        #region Events

        /// <summary>
        /// Sets the current selected TreeTabItem.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">RoutedEventArgs</param>
        protected void OnGotFocus(object sender, RoutedEventArgs e)
        {
            if (e.OriginalSource.GetType() == typeof(TreeTabItem) || e.OriginalSource.GetType() == typeof(TreeTabItemGroup))
                this.selectedTabItem = (TreeTabItem)e.OriginalSource;
        }

        #endregion

        #region Methods

        #region Private Methods

        /// <summary>
        /// Creates a new TreeTabItem
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        /// <param name="_tooltip">string</param>
        /// <param name="_type">TreeItem.TREEITEM_TYPE</param>
        /// <returns>TreeTabItem</returns>
        private TreeTabItem CreateTabItem(string _id, string _headerText, bool _showCloseButton, string _tooltip, TreeItem.TREEITEM_TYPE _type)
        {
            TreeTabItem tab = this.CreateTabItem(_id, _headerText, _showCloseButton, _type);
            tab.ToolTip = _tooltip;
            return tab;
        }

        /// <summary>
        /// Creates a new TreeTabItem
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        /// <param name="_tooltip">string</param>
        /// <returns>TreeTabItem</returns>
        private TreeTabItem CreateTabItem(string _id, string _headerText, bool _showCloseButton, string _tooltip)
        {
            TreeTabItem tab = this.CreateTabItem(_id, _headerText, _showCloseButton, TreeItem.TREEITEM_TYPE.MAIN);
            tab.ToolTip = _tooltip;
            return tab;
        }

        /// <summary>
        /// Creates a new TreeTabItem
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        /// <param name="_type">TreeItem.TREEITEM_TYPE</param>
        /// <returns>TreeTabItem</returns>
        private TreeTabItem CreateTabItem(string _id, string _headerText, bool _showCloseButton, TreeItem.TREEITEM_TYPE _type)
        {
            TreeTabItem tab;
            if (_type == TreeItem.TREEITEM_TYPE.MAIN)
                tab = new TreeTabItem(_id, _headerText, _showCloseButton);
            else
                tab = new TreeTabItemGroup(_id, _headerText, _showCloseButton);
            return tab;
        }

        /// <summary>
        /// Checks if the Id is available.
        /// </summary>
        /// <param name="_id">string</param>
        /// <returns>bool</returns>
        private bool CheckId(string _id)
        {
            return (this.GetTabItemById(_id) == null);
        }

        #endregion

        #region Public Methods

        /// <summary>
        /// Hides the TreeView Control if the it is shown.
        /// </summary>
        public void HideTree()
        {
            if (this.isTreeExpanded)
            {
                this.treeView.Visibility = Visibility.Collapsed;
                this.ContentGrid.ColumnDefinitions.RemoveAt(0);
                this.isTreeExpanded = false;
            }
        }

        /// <summary>
        /// Shows the TreeView Control if it is hidden.
        /// </summary>
        public void ShowTree()
        {
            if (!this.isTreeExpanded)
            {
                ColumnDefinition col = new ColumnDefinition();
                col.Width = new GridLength(150);
                this.ContentGrid.ColumnDefinitions.Insert(0, col);
                this.treeView.Visibility = Visibility.Visible;
                this.isTreeExpanded = true;
            }
        }

        /// <summary>
        /// Adds a new TreeTabItem at the collection of the main tab container.
        /// Adds a new TreeItem at the TreeView control.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        /// <param name="_type">TreeItem.TREEITEM_TYPE</param>
        /// <param name="_tooltip">string</param>
        /// <returns>TreeTabItem</returns>
        public TreeTabItem AddTabItem(string _id, string _headerText, bool _showCloseButton, TreeItem.TREEITEM_TYPE _type, string _tooltip)
        {
            TreeTabItem tab = null;
            if (this.CheckId(_id))
            {
                tab = this.CreateTabItem(_id, _headerText, _showCloseButton, _tooltip, _type);
                TreeItem tItem = new TreeItem(_type, _headerText, _id);
                tItem.ToolTip = _tooltip;
                tItem.LinkedTabItem = tab;
                this.tabContainer.Items.Add(tab);
                this.treeView.Items.Add(tItem);
            }
            return tab;
        }

        /// <summary>
        /// Adds a new TreeTabItem at the collection of the main tab container.
        /// Adds a new TreeItem at the TreeView control.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">TreeItem.TREEITEM_TYPE</param>
        /// <param name="_type">bool</param>
        /// <returns>TreeTabItem</returns>
        public TreeTabItem AddTabItem(string _id, string _headerText, bool _showCloseButton, TreeItem.TREEITEM_TYPE _type)
        {
            TreeTabItem tab = null;
            if (this.CheckId(_id))
            {
                tab = this.CreateTabItem(_id, _headerText, _showCloseButton, _type);
                TreeItem tItem = new TreeItem(_type, _headerText, _id);
                tItem.LinkedTabItem = tab;
                this.tabContainer.Items.Add(tab);
                this.treeView.Items.Add(tItem);
            }
            return tab;
        }

        /// <summary>
        /// Adds a new TreeTabItem at the collection of a certain TreeTabItemGroup object.
        /// Adds a new TreeItem at the collection of certain TreeItem.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        /// <param name="_type">TreeItem.TREEITEM_TYPE</param>
        /// <param name="_tooltip">string</param>
        /// <param name="_parent">TreeTabItemGroup</param>
        /// <returns>TreeTabItem</returns>
        public TreeTabItem AddTabItem(string _id, string _headerText, bool _showCloseButton, TreeItem.TREEITEM_TYPE _type, string _tooltip, TreeTabItemGroup _parent)
        {
            TreeTabItem tab = null;
            if (_parent != null && this.CheckId(_id))
            {
                tab = this.CreateTabItem(_id, _headerText, _showCloseButton, _tooltip, _type);
                TreeItem tItem = new TreeItem(_type, _headerText, _id);
                tItem.ToolTip = _tooltip;
                tItem.LinkedTabItem = tab;
                _parent.Items.Add(tab);
                TreeItem tParent = this.GetTreeItemById(_parent.Id);
                tParent.Items.Add(tItem);
            }
            return tab;
        }

        /// <summary>
        /// Adds a new TreeTabItem at the collection of a certain TreeTabItemGroup object.
        /// Adds a new TreeItem at the collection of certain TreeItem.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        /// <param name="_type">TreeItem.TREEITEM_TYPE</param>
        /// <param name="_parent">TreeTabItemGroup</param>
        /// <returns>TreeTabItem</returns>
        public TreeTabItem AddTabItem(string _id, string _headerText, bool _showCloseButton, TreeItem.TREEITEM_TYPE _type, TreeTabItemGroup _parent)
        {
            TreeTabItem tab = null;
            if (_parent != null && this.CheckId(_id))
            {
                tab = this.CreateTabItem(_id, _headerText, _showCloseButton, _type);
                TreeItem tItem = new TreeItem(_type, _headerText, _id);
                tItem.LinkedTabItem = tab;
                _parent.Items.Add(tab);
                TreeItem tParent = this.GetTreeItemById(_parent.Id);
                tParent.Items.Add(tItem);
            }
            return tab;
        }

        /// <summary>
        /// Gets a already created TreeItem by its Id.
        /// </summary>
        /// <param name="_id">string</param>
        /// <returns>TreeItem</returns>
        public TreeItem GetTreeItemById(string _id)
        {
            return this.GetTreeItemById(_id, this.treeView.Items);
        }

        /// <summary>
        /// Gets a already TreeItem by its Id at specific ItemCollection.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_startItems">ItemCollection</param>
        /// <returns>TreeItem</returns>
        public TreeItem GetTreeItemById(string _id, ItemCollection _startItems)
        {
            int i = 0;
            TreeItem vItem = null;
            TreeItem currentItem = null;

            while (i < _startItems.Count && vItem == null)
            {
                currentItem = (TreeItem)_startItems[i];
                if (currentItem.Id == _id)
                    vItem = currentItem;
                else if (currentItem.HasItems)
                    vItem = this.GetTreeItemById(_id, currentItem.Items);
                i++;
            }
            return vItem;
        }

        /// <summary>
        /// Gets a already TreeTabItem by its Id.
        /// </summary>
        /// <param name="_id">string</param>
        /// <returns>TreeTabItem</returns>
        public TreeTabItem GetTabItemById(string _id)
        {
            return this.GetTabItemById(_id, this.tabContainer.Items);
        }

        /// <summary>
        /// Gets a already TreeTabItem by its Id at specific ItemCollection.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_startItems">ItemCollection</param>
        /// <returns>TreeTabItem</returns>
        public TreeTabItem GetTabItemById(string _id, ItemCollection _startItems)
        {
            int i = 0;
            TreeTabItem tItem = null;
            TreeTabItem currentItem = null;

            while (i < _startItems.Count && tItem == null)
            {
                currentItem = (TreeTabItem)_startItems[i];
                if (currentItem.Id as string == _id)
                    tItem = (TreeTabItem)currentItem;
                else if (_startItems[i].GetType() == typeof(TreeTabItemGroup))
                {
                    if (((TreeTabItemGroup)_startItems[i]).HasItems)
                        tItem = this.GetTabItemById(_id, ((TreeTabItemGroup)_startItems[i]).Items);
                }
                i++;
            }
            return tItem;
        }

        /// <summary>
        /// Closes a specific tab by its Id.
        /// </summary>
        /// <param name="_id">string</param>
        public void CloseTab(string _id)
        {
            TreeItem tItem = this.GetTreeItemById(_id);
            if (tItem != null)
                tItem.Close();
        }

        /// <summary>
        /// Closes a specific tab by passing a TreeTabItem object.
        /// </summary>
        /// <param name="_tabIem"></param>
        public void CloseTab(TreeTabItem _tabIem)
        {
            this.CloseTab(_tabIem.Id);
        }

        /// <summary>
        /// Sets the content of a specific TreeTabItem.
        /// The control content must implement the IDisposable interface.
        /// </summary>
        /// <param name="_tabId">string</param>
        /// <param name="_content">IDisposable</param>
        public void SetTabContent(string _tabId, IDisposable _content)
        {
            TreeTabItem tabItem = this.GetTabItemById(_tabId);
            if (tabItem != null)
                this.SetTabContent(tabItem, _content);
        }

        /// <summary>
        /// Sets the content of a specific TreeTabItem.
        /// The control content must implement the IDisposable interface.
        /// <param name="_tabItem">TreeTabItem</param>
        /// <param name="_content">IDisposable</param>
        public void SetTabContent(TreeTabItem _tabItem, IDisposable _content)
        {
            _tabItem.Content = _content;
        }

        #endregion

        #endregion
    }
}
