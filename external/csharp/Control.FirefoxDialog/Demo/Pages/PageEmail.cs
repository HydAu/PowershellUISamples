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

namespace Demo
{
	public partial class PageEmail : Control.FirefoxDialog.PropertyPage
	{
		public PageEmail()
		{
			InitializeComponent();
		}

		public override void OnInit()
		{
			MessageBox.Show("PageEmail.OnInit Called.\n\nPut your loading logic here.\nNote that this method is called only Once!", "Control.FirefoxDialog");
		}

		public override void OnSetActive()
		{
			MessageBox.Show("PageEmail.OnSetActive Called.\n\nPut code that you wish to call whenever Email tab become active.\nNote that this method will be every time Email is activated!", "Control.FirefoxDialog");
		}

		public override void OnApply()
		{
			MessageBox.Show("PageEmail.OnApply Called.\n\nPut your saving logic here.\nIt will be called when you hit Apply button.", "Control.FirefoxDialog");
		}
	}
}
