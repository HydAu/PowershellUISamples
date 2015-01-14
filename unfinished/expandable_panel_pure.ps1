Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

$f = New-Object -TypeName 'System.Windows.Forms.Form'
$f.Text = $title
$f.SuspendLayout()
$p = New-Object System.Windows.Forms.Panel
$pnlMenu = New-Object System.Windows.Forms.Panel
$p_3 = New-Object System.Windows.Forms.Panel
$b_8 = New-Object System.Windows.Forms.Button
$b_9 = New-Object System.Windows.Forms.Button
$b_10 = New-Object System.Windows.Forms.Button
$g_3 = New-Object System.Windows.Forms.Button
$p_2 = New-Object System.Windows.Forms.Panel
$b_4 = New-Object System.Windows.Forms.Button
$b_5 = New-Object System.Windows.Forms.Button
$b_6 = New-Object System.Windows.Forms.Button
$g_2 = New-Object System.Windows.Forms.Button
$p_1 = New-Object System.Windows.Forms.Panel
$b_3 = New-Object System.Windows.Forms.Button
$b_2 = New-Object System.Windows.Forms.Button
$g_1 = New-Object System.Windows.Forms.Button
$lblMenu = New-Object System.Windows.Forms.Label
$pnlMenu.SuspendLayout()
$p_3.SuspendLayout()
$p_2.SuspendLayout()
$p_1.SuspendLayout()
$p.SuspendLayout()
#  
#  pnlMenu
#  
$pnlMenu.Controls.Add($p_3)
$pnlMenu.Controls.Add($p_2)
$pnlMenu.Controls.Add($p_1)
$pnlMenu.Controls.Add($lblMenu)
$pnlMenu.Dock = [System.Windows.Forms.DockStyle]::Left
$pnlMenu.Location = New-Object System.Drawing.Point (0,0)
$pnlMenu.Name = "pnlMenu"
$pnlMenu.Size = New-Object System.Drawing.Size (200,449)
$pnlMenu.TabIndex = 1
#  
#  pnlMenuGroup3
#  
$p_3.Controls.Add($b_8)
$p_3.Controls.Add($b_9)
$p_3.Controls.Add($b_10)
$p_3.Controls.Add($g_3)
$p_3.Dock = [System.Windows.Forms.DockStyle]::Top
$p_3.Location = New-Object System.Drawing.Point (0,231)
$p_3.Name = "pnlMenuGroup3"
$p_3.Size = New-Object System.Drawing.Size (200,109)
$p_3.TabIndex = 3
#  
#  button8
#  
$b_8.BackColor = [System.Drawing.Color]::Silver
$b_8.Dock = [System.Windows.Forms.DockStyle]::Top
$b_8.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_8.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_8.Location = New-Object System.Drawing.Point (0,75)
$b_8.Name = "button8"
$b_8.Size = New-Object System.Drawing.Size (200,25)
$b_8.TabIndex = 3
$b_8.Text = "Sub Menu 3"
$b_8.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_8.UseVisualStyleBackColor = $false
#  
#  button9
#  
$b_9.BackColor = [System.Drawing.Color]::Silver
$b_9.Dock = [System.Windows.Forms.DockStyle]::Top
$b_9.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_9.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_9.Location = New-Object System.Drawing.Point (0,50)
$b_9.Name = "button9"
$b_9.Size = New-Object System.Drawing.Size (200,25)
$b_9.TabIndex = 2
$b_9.Text = "Sub Menu 2"
$b_9.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_9.UseVisualStyleBackColor = $false
#  
#  button10
#  
$b_10.BackColor = [System.Drawing.Color]::Silver
$b_10.Dock = [System.Windows.Forms.DockStyle]::Top
$b_10.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_10.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_10.Location = New-Object System.Drawing.Point (0,25)
$b_10.Name = "button10"
$b_10.Size = New-Object System.Drawing.Size (200,25)
$b_10.TabIndex = 1
$b_10.Text = "Sub Menu 1"
$b_10.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_10.UseVisualStyleBackColor = $false
#  
#  btnMenuGroup3
#  
$g_3.BackColor = [System.Drawing.Color]::Gray
$g_3.Dock = [System.Windows.Forms.DockStyle]::Top
$g_3.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$g_3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$g_3.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$g_3.Location = New-Object System.Drawing.Point (0,0)
$g_3.Name = "btnMenuGroup3"
$g_3.Size = New-Object System.Drawing.Size (200,25)
$g_3.TabIndex = 0
$g_3.Text = "Menu Group 3"
$g_3.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$g_3.UseVisualStyleBackColor = $false
# $g_3.Click += new-Object  System.EventHandler($g_3_Click)
#  
#  pnlMenuGroup2
#  
$p_2.Controls.Add($b_4)
$p_2.Controls.Add($b_5)
$p_2.Controls.Add($b_6)
$p_2.Controls.Add($g_2)
$p_2.Dock = [System.Windows.Forms.DockStyle]::Top
$p_2.Location = New-Object System.Drawing.Point (0,127)
$p_2.Name = "pnlMenuGroup2"
$p_2.Size = New-Object System.Drawing.Size (200,104)
$p_2.TabIndex = 2
#  
#  button4
#  
$b_4.BackColor = [System.Drawing.Color]::Silver
$b_4.Dock = [System.Windows.Forms.DockStyle]::Top
$b_4.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_4.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_4.Location = New-Object System.Drawing.Point (0,75)
$b_4.Name = "button4"
$b_4.Size = New-Object System.Drawing.Size (200,25)
$b_4.TabIndex = 3
$b_4.Text = "Sub Menu 3"
$b_4.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_4.UseVisualStyleBackColor = $false
#  
#  button5
#  
$b_5.BackColor = [System.Drawing.Color]::Silver
$b_5.Dock = [System.Windows.Forms.DockStyle]::Top
$b_5.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_5.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_5.Location = New-Object System.Drawing.Point (0,50)
$b_5.Name = "button5"
$b_5.Size = New-Object System.Drawing.Size (200,25)
$b_5.TabIndex = 2
$b_5.Text = "Sub Menu 2"
$b_5.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_5.UseVisualStyleBackColor = $false
#  
#  button6
#  
$b_6.BackColor = [System.Drawing.Color]::Silver
$b_6.Dock = [System.Windows.Forms.DockStyle]::Top
$b_6.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_6.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_6.Location = New-Object System.Drawing.Point (0,25)
$b_6.Name = "button6"
$b_6.Size = New-Object System.Drawing.Size (200,25)
$b_6.TabIndex = 1
$b_6.Text = "Sub Menu 1"
$b_6.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_6.UseVisualStyleBackColor = $false
#  
#  btnMenuGroup2
#  
$g_2.BackColor = [System.Drawing.Color]::Gray
$g_2.Dock = [System.Windows.Forms.DockStyle]::Top
$g_2.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$g_2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$g_2.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$g_2.Location = New-Object System.Drawing.Point (0,0)
$g_2.Name = "btnMenuGroup2"
$g_2.Size = New-Object System.Drawing.Size (200,25)
$g_2.TabIndex = 0
$g_2.Text = "Menu Group 2"
$g_2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$g_2.UseVisualStyleBackColor = $false
# $g_2.Click += new-Object  System.EventHandler($g_2_Click)
#  
#  pnlMenuGroup1
#  
$p_1.Controls.Add($b_3)
$p_1.Controls.Add($b_2)
$p_1.Controls.Add($g_1)
$p_1.Dock = [System.Windows.Forms.DockStyle]::Top
$p_1.Location = New-Object System.Drawing.Point (0,23)
$p_1.Name = "pnlMenuGroup1"
$p_1.Size = New-Object System.Drawing.Size (200,104)
$p_1.TabIndex = 1
#  
#  button3
#  
$b_3.BackColor = [System.Drawing.Color]::Silver
$b_3.Dock = [System.Windows.Forms.DockStyle]::Top
$b_3.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_3.Location = New-Object System.Drawing.Point (0,75)
$b_3.Name = "button3"
$b_3.Size = New-Object System.Drawing.Size (200,25)
$b_3.TabIndex = 3
$b_3.Text = "Sub Menu 3"
$b_3.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_3.UseVisualStyleBackColor = $false
#  
#  button2
#  
$b_2.BackColor = [System.Drawing.Color]::Silver
$b_2.Dock = [System.Windows.Forms.DockStyle]::Top
$b_2.FlatAppearance.BorderColor = [System.Drawing.Color]::DarkGray
$b_2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$b_2.Location = New-Object System.Drawing.Point (0,50)
$b_2.Name = "button2"
$b_2.Size = New-Object System.Drawing.Size (200,25)
$b_2.TabIndex = 2
$b_2.Text = "Sub Menu 2"
$b_2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$b_2.UseVisualStyleBackColor = $false
#  
#  btnMenuGroup1
#  
$g_1.BackColor = [System.Drawing.Color]::Gray
$g_1.Dock = [System.Windows.Forms.DockStyle]::Top
$g_1.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$g_1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$g_1.ImageAlign = [System.Drawing.ContentAlignment]::MiddleRight
$g_1.Location = New-Object System.Drawing.Point (0,0)
$g_1.Name = "btnMenuGroup1"
$g_1.Size = New-Object System.Drawing.Size (200,25)
$g_1.TabIndex = 0
$g_1.Text = "Menu Group 1"
$g_1.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$g_1.UseVisualStyleBackColor = $false
# $g_1.Click += new-Object  System.EventHandler($g_1_Click)
#  
#  lblMenu
#  
$lblMenu.BackColor = [System.Drawing.Color]::DarkGray
$lblMenu.Dock = [System.Windows.Forms.DockStyle]::Top
$lblMenu.ForeColor = [System.Drawing.Color]::White
$lblMenu.Location = New-Object System.Drawing.Point (0,0)
$lblMenu.Name = "lblMenu"
$lblMenu.Size = New-Object System.Drawing.Size (200,23)
$lblMenu.TabIndex = 0
$lblMenu.Text = "Main Menu"
$lblMenu.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter


$p.ClientSize = New-Object System.Drawing.Size (200,449)
$p.Controls.Add($pnlMenu)
$p_1.Height = 25
$p_2.Height = 25
$p_3.Height = 25

$g_1.Image =
$g_2.Image =
$g_3.Image = New-Object System.Drawing.Bitmap ("C:\developer\sergueik\powershell_ui_samples\unfinished\down.png")

$pnlMenu.ResumeLayout($false)
$p_3.ResumeLayout($false)
$p_2.ResumeLayout($false)
$p_1.ResumeLayout($false)
$p.ResumeLayout($false)


$f.Controls.Add($p)
#  Form1
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (210,140)
$f.Controls.Add($c1)
$f.Controls.Add($p)
$f.Controls.Add($b1)
$f.Name = "Form1"
$f.Text = "ProgressCircle"
$f.ResumeLayout($false)

$f.Topmost = $True

$f.Add_Shown({ $f.Activate() })

[void]$f.ShowDialog([win32window]($caller))

$f.Dispose()


<#
            pnlMenuGroup1.Height = 25;
            pnlMenuGroup2.Height = 25;
            pnlMenuGroup3.Height = 25;

            btnMenuGroup1.Image =
            btnMenuGroup2.Image =
            btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
        }

        private void btnMenuGroup1_Click(object sender, EventArgs e)
        {

            if (pnlMenuGroup1.Height == 25)
            {
                pnlMenuGroup1.Height = (25 * 3) + 2;
                btnMenuGroup1.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\up.png");
            }
            else
            {
                pnlMenuGroup1.Height = 25;
                btnMenuGroup1.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
            }
/*       */ // # 342 

            System.Windows.Forms.Button sender2 =  (System.Windows.Forms.Button ) sender ;
        }

        private void btnMenuGroup2_Click(object sender, EventArgs e)
        {
            if (pnlMenuGroup2.Height == 25)
            {
                pnlMenuGroup2.Height = (25 * 5) + 2;
                btnMenuGroup2.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\up.png");
            }
            else
            {
                pnlMenuGroup2.Height = 25;
                btnMenuGroup2.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
            }
        }

        private void btnMenuGroup3_Click(object sender, EventArgs e)
        {
            if (pnlMenuGroup3.Height == 25)
            {
                pnlMenuGroup3.Height = (25 * 6) + 2;
                btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\up.png");
            }
            else
            {
                pnlMenuGroup3.Height = 25;
                btnMenuGroup3.Image = new Bitmap(@"C:\developer\sergueik\powershell_ui_samples\unfinished\down.png");
            }
        }

    }


#>
