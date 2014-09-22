# http://www.java2s.com/Tutorial/CSharp/0460__GUI-Windows-Forms/DomainUpDownselecteditemchangedevent.htmhttp://www.java2s.com/Tutorial/CSharp/0460__GUI-Windows-Forms/DomainUpDownselecteditemchangedevent.htm
Add-Type -TypeDefinition @"

//  "

using System;
using System.Drawing;
using System.Windows.Forms;

public class NumericUpDowns : Form
{
  NumericUpDown nupdwnH;
  NumericUpDown nupdwnM;
  public NumericUpDowns()
  {
    Size = new Size(480,580);

    nupdwnH = new NumericUpDown();
    nupdwnH.Parent = this;
    nupdwnH.Location = new Point(50, 50);
    nupdwnH.Size = new Size(40,20);
    nupdwnH.Value = 1;
    nupdwnH.Minimum = 0;
    nupdwnH.Maximum = 59;
    nupdwnH.Increment = 1;    //  decimal
    nupdwnH.DecimalPlaces = 0;
    nupdwnH.ReadOnly = true;
    nupdwnH.TextAlign = HorizontalAlignment.Right;
    nupdwnH.ValueChanged += new EventHandler(nupdwnH_OnValueChanged);

    nupdwnM = new NumericUpDown();
    nupdwnM.Parent = this;
    nupdwnM.Location = new Point(30, 50);
    nupdwnM.Size = new Size(40,20);
    nupdwnM.Value = 1;
    nupdwnM.Minimum = 0;
    nupdwnM.Maximum = 59;
    nupdwnM.Increment = 1;    //  decimal
    nupdwnM.DecimalPlaces = 0;
    nupdwnM.ReadOnly = true;
    nupdwnM.TextAlign = HorizontalAlignment.Right;
    nupdwnM.ValueChanged += new EventHandler(nupdwnM_OnValueChanged);

  }  

  private void nupdwnH_OnValueChanged(object sender, EventArgs e)
  {
    Console.WriteLine(nupdwnH.Value);
  }

  private void nupdwnM_OnValueChanged(object sender, EventArgs e)
  {
    Console.WriteLine(nupdwnM.Value);
  }
 
 public static void Main() 
  {
    Application.Run(new NumericUpDowns());
  }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll', 'System.Drawing.dll'

$test = new-Object -TypeName 'NumericUpDowns'
