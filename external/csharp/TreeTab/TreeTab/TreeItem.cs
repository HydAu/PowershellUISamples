using System;
using System.Collections;
using System.Collections.Generic;
using System.Windows.Controls;
using System.Configuration;

namespace TreeTab
{
    public class TreeItem : TreeViewItem
    {
        #region Enums

        public enum TREEITEM_TYPE
        {
            MAIN,
            GROUP
        }

        
        #endregion

        #region Constants

        const string CLOSE = "Close";
        const string EXPAND = "Expand";
        const string COLLAPSE = "Collapse";
        const string SHOW = "Show";

        #endregion

        #region Attributes

        private readonly TREEITEM_TYPE type;
        private readonly string id;

        private TreeTabItem linkedTabItem;
        private bool canExpand;
        private bool canClose;
        private bool canSelect;        

        #endregion

        #region Properties

        /// <summary>
        /// Gets the Id of the object
        /// </summary>
        public string Id
        {
            get
            {
                return this.id;
            }
        }

        /// <summary>
        /// Gets or sets the TreeTabItem object linked to this item.
        /// </summary>
        public TreeTabItem LinkedTabItem
        {
            get
            {
                return this.linkedTabItem;
            }
            set
            {
                this.AddLinkedTabItem(value);
            }
        }


        #endregion

        #region Constructors

        /// <summary>
        /// Overloads the main constructor of the object adding the tooltip.
        /// </summary>
        /// <param name="_type">TREEITEM_TYPE</param>
        /// <param name="_tag">string</param>
        /// <param name="_tooltip">string</param>
        /// <param name="_id">string</param>
        public TreeItem(TREEITEM_TYPE _type, string _tag, string _tooltip, string _id) : this(_type, _tag, _id)
        {
            this.ToolTip = _tooltip;
        }

        /// <summary>
        /// Constructor if the object.
        /// </summary>
        /// <param name="_type">TREEITEM_TYPE</param>
        /// <param name="_tag">string</param>
        /// <param name="_id">string</param>
        public TreeItem(TREEITEM_TYPE _type, string _tag, string _id)
        {
            this.type = _type;
            this.id = _id;
            this.Tag = _tag;
            this.Header = _tag;            
            this.Loaded += new System.Windows.RoutedEventHandler(Load);
            this.MouseDoubleClick += new System.Windows.Input.MouseButtonEventHandler(DoubleClick);
        }

        #endregion

        #region Events

        /// <summary>
        /// Shows the tab when the item is selected by getting a double click.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">System.Windows.Input.MouseButtonEventArgs</param>
        public void DoubleClick(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            this.ShowTab();
        }

        /// <summary>
        /// Shows the tab when the context menu item for showing the tab is selected.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">System.Windows.RoutedEventArgs</param>
        public void MenuShowTabClick(object sender, System.Windows.RoutedEventArgs e)
        {
            this.ShowTab();
        }
        
        /// <summary>
        /// Adds context menus to the parent item when the item is loaded.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">System.Windows.RoutedEventArgs</param>
        private void Load(object sender, System.Windows.RoutedEventArgs e)
        {
            if (this.Parent.GetType() == typeof(TreeItem))
            {
                TreeItem iParent = (TreeItem)this.Parent;
                if (iParent.Items.Count > 0 && !iParent.canExpand)
                {                    
                    iParent.AddExpandedMenus();
                }
            }
        }          

        /// <summary>
        /// Close the linked tab when the context menu item for closing is selected
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">System.Windows.RoutedEventArgs</param>
        private void ClickCloseTreeItem(object sender, System.Windows.RoutedEventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// Expands the item showing its children.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">System.Windows.RoutedEventArgs</param>
        private void ClickExpandTreeItem(object sender, System.Windows.RoutedEventArgs e)
        {
            MenuItem mItem = (MenuItem)sender;
            TreeViewItem tItem = ((TreeViewItem)((ContextMenu)((MenuItem)e.Source).Parent).PlacementTarget);
            tItem.IsExpanded = true;
            tItem.Items.Refresh();
        }

        /// <summary>
        /// Collapses the item hiding its children.
        /// </summary>
        /// <param name="sender">object</param>
        /// <param name="e">System.Windows.RoutedEventArgs</param>
        private void ClickCollapseTreeItem(object sender, System.Windows.RoutedEventArgs e)
        {
            MenuItem mItem = (MenuItem)sender;
            TreeViewItem tItem = ((TreeViewItem)((ContextMenu)((MenuItem)e.Source).Parent).PlacementTarget);
            tItem.IsExpanded = false;
            tItem.Items.Refresh();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Shows the linked tab.
        /// </summary>
        private void ShowTab()
        {
            if (this.linkedTabItem != null)
            {
                TabControl tabContainer = (TabControl)this.linkedTabItem.Parent;
                tabContainer.SelectedItem = this.linkedTabItem;
            }
        }

        /// <summary>
        /// Adds the context menu item for closing.
        /// </summary>
        private void AddCloseMenu()
        {
            if (!this.canClose && this.linkedTabItem.CanClose)
            {
                MenuItem mItem = new MenuItem();
                if (this.ContextMenu == null)
                    this.ContextMenu = new ContextMenu();
                
                mItem.Header = CLOSE;
                mItem.Name = CLOSE;
                mItem.Click += new System.Windows.RoutedEventHandler(this.ClickCloseTreeItem);
                this.AddContextMenuItem(mItem);
                this.ContextMenu.Items.Insert(this.ContextMenu.Items.Count - 1, new Separator());
                this.canClose = true;
            }
        }

        /// <summary>
        /// Adds a context menu item.
        /// </summary>
        /// <param name="_mItem">MenuItem</param>
        public void AddContextMenuItem(MenuItem _mItem)
        {
            if (TreeTabControl.config.ShowDefaultIcons)
                _mItem.Icon = TreeTabControl.config.GetIconById(_mItem.Name, 16, 16);
            this.ContextMenu.Items.Add(_mItem);
        }

        /// <summary>
        /// Adds a context menu item at the first position of the array.
        /// </summary>
        /// <param name="_mItem">MenuItem</param>
        public void InsertContextMenuItem(MenuItem _mItem)
        {
            if (TreeTabControl.config.ShowDefaultIcons)
                _mItem.Icon = TreeTabControl.config.GetIconById(_mItem.Name, 16, 16);
            this.ContextMenu.Items.Insert(0, _mItem);
        }


        /// <summary>
        /// Closes the linked tab item and removes itself from the parent's collection.
        /// </summary>
        public void Close()
        {
            ItemCollection iCol;
            if (this.Parent.GetType() == typeof(TreeItem))
                iCol = ((TreeItem)this.Parent).Items;            
            else            
                iCol = ((TreeView)this.Parent).Items;            

            this.RemoveLinkedTabItem();
            iCol.Remove(this);
        }

        /// <summary>
        /// Adds the linked tab item to the object and creates the context menu items.
        /// </summary>
        /// <param name="_tabItem">TreeTabItem</param>
        public void AddLinkedTabItem(TreeTabItem _tabItem)
        {
            this.linkedTabItem = _tabItem;
            this.AddSelectTabMenu();
            this.AddCloseMenu();
        }

        /// <summary>
        /// Removes the linked tab item of the object.
        /// </summary>
        public void RemoveLinkedTabItem()
        {
            if (this.linkedTabItem.Parent != null)
            {
                this.linkedTabItem.Close();
                if (this.Parent.GetType() == typeof(TreeItem))
                {
                    TreeItem tParent = (TreeItem)this.Parent;
                    if (tParent.Items.Count == 1)
                        tParent.RemoveExpandedMenus();
                }
            }
            this.linkedTabItem = null;
        }

        /// <summary>
        /// Adds the context menu item of selection.
        /// </summary>
        public void AddSelectTabMenu()
        {
            if (!this.canSelect)
            {
                if (this.ContextMenu == null)
                    this.ContextMenu = new ContextMenu();

                MenuItem mItem;
                mItem = new MenuItem();
                mItem.Header = SHOW;
                mItem.Name = SHOW;
                mItem.Click += new System.Windows.RoutedEventHandler(this.MenuShowTabClick);
                this.ContextMenu.Items.Add(mItem);
                this.canSelect = true;
            }
        }

        /// <summary>
        /// Adds the expanding and collapsing context menu items.
        /// </summary>
        public void AddExpandedMenus()
        {
            if (this.ContextMenu == null)
                this.ContextMenu = new ContextMenu();

            MenuItem mItem;
            mItem = new MenuItem();
            mItem.Header = EXPAND;
            mItem.Name = EXPAND;
            mItem.Click += new System.Windows.RoutedEventHandler(this.ClickExpandTreeItem);            
            this.InsertContextMenuItem(mItem);

            mItem = new MenuItem();
            mItem.Header = COLLAPSE;
            mItem.Name = COLLAPSE;
            mItem.Click += new System.Windows.RoutedEventHandler(this.ClickCollapseTreeItem);
            this.InsertContextMenuItem(mItem);

            this.canExpand = true;
        }

        /// <summary>
        /// Removes the expanding and collapsing context menu items.
        /// </summary>
        public void RemoveExpandedMenus()
        {
            if (this.ContextMenu != null && this.ContextMenu.HasItems)
            {
                MenuItem mItem;
                while (this.ContextMenu.Items.MoveCurrentToNext())
                {
                    if (this.ContextMenu.Items.CurrentItem.GetType() == typeof(MenuItem))
                    {
                        mItem = (MenuItem)this.ContextMenu.Items.CurrentItem;
                        if (mItem.Name == EXPAND || mItem.Name == COLLAPSE)
                        {
                            this.ContextMenu.Items.Remove(mItem);
                            this.ContextMenu.Items.MoveCurrentToFirst();
                        }
                    }
                }
                if (this.ContextMenu.Items.Count == 0)
                    this.ContextMenu = null;
            }
            this.canExpand = false;
        }

        #endregion

    }
}
