#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# http://www.codeguru.com/csharp/csharp/cs_graphics/chartsandgraphing/article.php/c6145/Creating-Simple-Charts-and-Graphs.htm
Add-Type -TypeDefinition @"
//"
using System;
using System.Drawing;
using System.Drawing.Imaging;
// http://msdn.microsoft.com/en-us/library/system.drawing.imaging%28v=vs.100%29.aspx
namespace CodeGuru.SampleCode
{
/// <summary>
/// Draw a pie chart using the given information.
/// </summary>
public class PieChart
{
public Bitmap Draw(Color bgColor, int width, int height,
decimal[] vals)
{
// Create a new image and erase the background
Bitmap bitmap = new Bitmap(width,height,
PixelFormat.Format32bppArgb);
Graphics graphics = Graphics.FromImage(bitmap);
SolidBrush brush = new SolidBrush(bgColor);
graphics.FillRectangle(brush, 0, 0, width, height);
brush.Dispose();

// Create brushes for coloring the pie chart
SolidBrush[] brushes = new SolidBrush[10];
brushes[0] = new SolidBrush(Color.Yellow);
brushes[1] = new SolidBrush(Color.Green);
brushes[2] = new SolidBrush(Color.Blue);
brushes[3] = new SolidBrush(Color.Cyan);
brushes[4] = new SolidBrush(Color.Magenta);
brushes[5] = new SolidBrush(Color.Red);
brushes[6] = new SolidBrush(Color.Black);
brushes[7] = new SolidBrush(Color.Gray);
brushes[8] = new SolidBrush(Color.Maroon);
brushes[9] = new SolidBrush(Color.LightBlue);

// Sum the inputs to get the total
decimal total = 0.0m;
foreach( decimal val in vals )
total += val;

// Draw the pie chart
float start = 0.0f;
float end = 0.0f;
decimal current = 0.0m;
for( int i = 0; i < vals.Length; i++ )
{
current += vals[i];
start = end;
end = (float) (current / total) * 360.0f;
graphics.FillPie(brushes[i % 10], 0.0f, 0.0f, width,
height, start, end - start);
}

// Clean up the brush resources
foreach( SolidBrush cleanBrush in brushes )
cleanBrush.Dispose();

return bitmap;
}
}
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'

function PieChart { 
param  (
  [object]$caller
) 

  $f = New-Object System.Windows.Forms.Form
  $f.MaximizeBox = $false
  $f.MinimizeBox = $false
( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

  $panel = New-Object System.Windows.Forms.Panel
  $button = New-Object System.Windows.Forms.Button
  $textbox = New-Object System.Windows.Forms.TextBox
  $f.SuspendLayout()
  $panel.SuspendLayout()
  $panel.ForeColor = [System.Drawing.Color]::Black
  $panel.Location = New-Object System.Drawing.Point (0,0)
  $panel.Name = 'panel'
  $panel.Size = New-Object System.Drawing.Size (250,27)
  $panel.TabIndex = 3
  $o = New-Object -TypeName 'CodeGuru.SampleCode.PieChart' -ArgumentList @()
  
  [System.Drawing.Bitmap]$bitmap = o.Draw()
  $panel.Controls.Add($bitmap)

  $f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
  $f.BackColor = [System.Drawing.Color]::White
  $f.Controls.Add($panel)
  $f.Name = "PasswordEye"
  $f.Size = New-Object System.Drawing.Size (256,136)
  $panel.ResumeLayout($false)
  $panel.PerformLayout()
  $f.ResumeLayout($false)
  #  [void]$f.ShowDialog([win32window ]($caller))
  [void]$f.ShowDialog()
  $f.Dispose()


}

$DebugPreference = 'Continue'
$title = 'Basic Pie Chart'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
PieChart

