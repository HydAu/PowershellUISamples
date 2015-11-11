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
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace Demo
{
	public partial class Form1 : Form
	{
		public Form1()
		{
			InitializeComponent();
		}

		private void Form1_Load(object sender, EventArgs e)
		{
			this.firefoxDialog1.ImageList = this.imageList1;

			this.firefoxDialog1.AddPage("Main", new PageMain());
			this.firefoxDialog1.AddPage("Email", new PageEmail());
			this.firefoxDialog1.AddPage("Internet", new PageInternet());
			this.firefoxDialog1.AddPage("Spell", new PageSpell());
			this.firefoxDialog1.AddPage("Favourites", new PageFav());

			this.firefoxDialog1.Init();
		}
	}
}