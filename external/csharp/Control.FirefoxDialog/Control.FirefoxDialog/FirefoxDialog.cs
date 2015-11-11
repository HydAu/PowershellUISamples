/*--------------------------------------------------------------------------------------
 * Author: Rafey
 * 
 * Comments: Firefox Option Dialog User Control for .NET Win Apps
 * 
 * Email: syedrafey@gmail.com
 * 
 -------------------------------------------------------------------------------------*/
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;

namespace Control.FirefoxDialog
{
	public partial class FirefoxDialog : UserControl
	{
		#region Data Members
		PropertyPage activePage = null;

		private Dictionary<string, PageProp> pages = new Dictionary<string, PageProp>();
		
		#endregion

		public FirefoxDialog()
		{
			InitializeComponent();
		}

		#region Private
		private void AddPage(Pabo.MozBar.MozItem item, PropertyPage page)
		{
			PageProp pageProp = new PageProp();

			pageProp.Page = page;
			pageProp.MozItem = item;

			this.mozPane1.Items.Add(item);

			this.pages.Add(item.Name, pageProp);
		}

		private Pabo.MozBar.MozItem GetMozItem(string text)
		{
			return this.GetMozItem(text, this.ImageList == null ? 0 : this.pages.Count);
		}

		private Pabo.MozBar.MozItem GetMozItem(string text, int imageIndex)
		{
			Pabo.MozBar.MozItem item = new Pabo.MozBar.MozItem();

			item.Name = "mozItem" + this.pages.Count + 1;

			item.Text = text;

			if (imageIndex < this.ImageList.Images.Count)
			{
				item.Images.NormalImage = this.ImageList.Images[imageIndex];
			}

			return item;
		}

		#region Activate Page
		private void mozPane1_ItemClick(object sender, Pabo.MozBar.MozItemClickEventArgs e)
		{
			this.ActivatePage(e.MozItem);
		}

		private bool ActivatePage(Pabo.MozBar.MozItem item)
		{
			if (!this.pages.ContainsKey(item.Name))
			{
				return false;
			}

			PageProp pageProp = this.pages[item.Name];

			PropertyPage page = pageProp.Page;

			if (activePage != null)
			{
				activePage.Visible = false;
			}

			activePage = page;

			if (activePage != null)
			{
				this.mozPane1.SelectByName(item.Name);

				activePage.Visible = true;

				if (!page.IsInit)
				{
					page.OnInit();

					page.IsInit = true;
				}

				activePage.OnSetActive();
			}

			return true;
		}

		#endregion
		
		#endregion

		#region Public Interface

		#region Properties
		public Dictionary<string, PageProp> Pages
		{
			get { return pages; }
		}

		public ImageList ImageList
		{
			get { return this.mozPane1.ImageList; }
			set { this.mozPane1.ImageList = value; }
		}
		#endregion

		#region Methods
		public void AddPage(string text, PropertyPage page)
		{
			this.AddPage(this.GetMozItem(text), page);
		}

		public void AddPage(string text, int imageIndex, PropertyPage page)
		{
			this.AddPage(this.GetMozItem(text, imageIndex), page);
		}

		public void Init()
		{
			foreach (PageProp pageProp in pages.Values)
			{
				PropertyPage page = pageProp.Page;

				pagePanel.Controls.Add(page);
				page.Dock = DockStyle.Fill;
				page.Visible = false;
			}

			if (this.pages.Count != 0)
			{
				ActivatePage(this.mozPane1.Items[0]);
			}
		}  
		#endregion

		#endregion

		#region Dialog Buttons
		private void btnOK_Click(object sender, EventArgs e)
		{
			this.Apply();

			this.Close();
		}

		private void btnCancel_Click(object sender, EventArgs e)
		{
			this.Close();
		}

		private void btnApply_Click(object sender, EventArgs e)
		{
			this.Apply();
		}

		private void Apply()
		{
			foreach (PageProp pageProp in pages.Values)
			{
				if (pageProp.Page.IsInit)
				{
					pageProp.Page.OnApply();
				}
			}
		}

		private void Close()
		{
			if (this.ParentForm != null)
			{
				this.ParentForm.Close();
			}
		}
		#endregion
	}
}
