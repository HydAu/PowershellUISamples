using System;
using System.Collections;
using System.Windows.Controls;

namespace TreeTab
{
    public class TreeTabItemGroup : TreeTabItem
    {
        #region Attributes

        private TabControl container;

        #endregion

        #region Properties

        /// <summary>
        /// Gets a boolean indicating wheter the item has children.
        /// </summary>
        public bool HasItems
        {
            get
            {
                return this.container.HasItems;
            }
        }

        /// <summary>
        /// Gets the ItemCollection of the item.
        /// </summary>
        public ItemCollection Items
        {
            get
            {
                return this.container.Items;
            }
        }

        #endregion

        #region Contructors

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_headerText">string</param>
        /// <param name="_showCloseButton">bool</param>
        public TreeTabItemGroup(string _id, string _headerText, bool _showCloseButton) : base(_id, _headerText, _showCloseButton)
        {
            this.type = TreeItem.TREEITEM_TYPE.GROUP;
            this.CreateControls();
        }

        #endregion

        #region Methods

        /// <summary>
        /// Adds the content for the container.
        /// </summary>
        private void CreateControls()
        {
            TreeTabIGroupGrid g = new TreeTabIGroupGrid();            
            this.container = new TabControl();
            this.container.Name = "TabContainer";
            g.Children.Add(this.container);
            this.Content = g;
        }

        #endregion
    }
}
