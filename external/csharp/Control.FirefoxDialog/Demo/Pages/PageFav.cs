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
	public partial class PageFav : Control.FirefoxDialog.PropertyPage
	{
		public PageFav()
		{
			InitializeComponent();
		}

		public override void OnInit()
		{
			this.txtName.Text = "My User Name";
			this.txtPwd.Text = "password";
			this.chkRememberMe.Checked = true;
		}

		public override void OnSetActive()
		{
		}

		public override void OnApply()
		{
		}
	}
}
