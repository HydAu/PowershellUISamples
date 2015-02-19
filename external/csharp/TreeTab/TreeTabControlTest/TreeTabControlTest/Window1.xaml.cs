using System;
using System.Collections.Generic;
using System.Linq;
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
using TreeTab;
using TreeTabControlTest;

namespace TreeTabTest
{
    public partial class Window1 : Window
    {
        public Window1()
        {
            InitializeComponent();
        }

        private void btnAddTab1_Click(object sender, RoutedEventArgs e)
        {
            this.treeTab.AddTabItem("one", "Main Tab", false, TreeItem.TREEITEM_TYPE.MAIN);
        }

        private void btnAddTab2_Click(object sender, RoutedEventArgs e)
        {
            this.treeTab.AddTabItem("two", "Group Tab", true, TreeItem.TREEITEM_TYPE.GROUP);
        }

        private void btnAddTab3_Click(object sender, RoutedEventArgs e)
        {
            TreeTabItemGroup tParent = (TreeTabItemGroup) this.treeTab.GetTabItemById("two");
            TreeTabItem tItem = this.treeTab.AddTabItem("tree", "Child Group 1", true, TreeItem.TREEITEM_TYPE.MAIN, tParent);
            TreeTabIGroupGrid grid = new TreeTabIGroupGrid();
            grid.Children.Add(new Example());
            this.treeTab.SetTabContent(tItem, grid);
            this.treeTab.AddTabItem("four", "Child Group 2", true, TreeItem.TREEITEM_TYPE.MAIN, tParent);
            this.treeTab.AddTabItem("five", "Child Group 3", true, TreeItem.TREEITEM_TYPE.MAIN, tParent);
        }

        private void btnAddTab4_Click(object sender, RoutedEventArgs e)
        {
            this.treeTab.AddTabItem("six", "Group without close", false, TreeItem.TREEITEM_TYPE.GROUP, "This tab cannot be closed!");
        }

        private void btnAddTab5_Click(object sender, RoutedEventArgs e)
        {
            this.treeTab.AddTabItem("seven", "Child Group 1", true, TreeItem.TREEITEM_TYPE.MAIN, "I belong to my parent!", (TreeTabItemGroup) this.treeTab.GetTabItemById("six"));
        }

        private void btnCollapseTree_Click(object sender, RoutedEventArgs e)
        {
            this.treeTab.HideTree();
        }

        private void btnExpandTree_Click(object sender, RoutedEventArgs e)
        {
            this.treeTab.ShowTree();
        }
    }
}
