Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
// inline callback class 
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;

    public int Data
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


function PromptAuto(
	[String] $title, 
	[String] $message, 
	[Object] $caller = $null 
	){

#  http://www.java2s.com/Code/CSharp/GUI-Windows-Form/Radiobuttoncheckchangedevent.htm


[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections') 
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Data') 

$f = New-Object System.Windows.Forms.Form 
$f.Text = $title
$groupBox1 = New-Object System.Windows.Forms.GroupBox;
$checkBox1 = New-Object System.Windows.Forms.CheckBox;
$checkBox2 = New-Object System.Windows.Forms.CheckBox ;
$checkBox3 = New-Object System.Windows.Forms.CheckBox ;
$radioButton1     = New-Object System.Windows.Forms.RadioButton;
$radioButton2     = New-Object System.Windows.Forms.RadioButton;
$radioButton3     = New-Object System.Windows.Forms.RadioButton;
$button1  = New-Object System.Windows.Forms.Button;

$components =  New-Object System.ComponentModel.Container;

$groupBox1.SuspendLayout();
$f.SuspendLayout();
             
            # groupBox1
             
<#            $groupBox1.Controls.AddRange( New-Object System.Windows.Forms.Control[] @(
                                                                                    $radioButton1,
                                                                                    $radioButton2,
                                                                                    $radioButton3 ));
#>
# $groupBox1.Controls.Add($radioButton1)
# $groupBox1.Controls.Add($radioButton2)
# $groupBox1.Controls.Add($radioButton3)
            $groupBox1.Location = New-Object System.Drawing.Point(8, 120);
            $groupBox1.Name = "groupBox1";
            $groupBox1.Size = New-Object System.Drawing.Size(120, 144);
            $groupBox1.TabIndex = 0;
            $groupBox1.TabStop = false;
            $groupBox1.Text = "Color";


            # this.groupBox1.Enter += New-Object System.EventHandler(this.groupBox1_Enter);

            # checkBox1
             
            $checkBox1.Location = New-Object System.Drawing.Point(8, 8);
            $checkBox1.Name = "checkBox1";
            $checkBox1.TabIndex = 1;
            $checkBox1.Text = "Circle";
             
            # checkBox2
             
            $checkBox2.Location = New-Object System.Drawing.Point(8, 40);
            $checkBox2.Name = "checkBox2";
            $checkBox2.TabIndex = 2;
            $checkBox2.Text = "Rectangle";
             
            # checkBox3
             
            $checkBox3.Location = New-Object System.Drawing.Point(8, 72);
            $checkBox3.Name = "checkBox3";
            $checkBox3.TabIndex = 3;
            $checkBox3.Text = "String";
            
<#
            // radioButton1
            // 
            $radioButton1.Location = New-Object System.Drawing.Point(8, 32);
            $radioButton1.Name = "radioButton1";
            $radioButton1.TabIndex = 4;
            $radioButton1.Text = "Red";
            $radioButton1.CheckedChanged += System.EventHandler(this.radioButton1_CheckedChanged);
            // 
            // radioButton2
            // 
            this.radioButton2.Location = New-Object System.Drawing.Point(8, 64);
            this.radioButton2.Name = "radioButton2";
            this.radioButton2.TabIndex = 5;
            this.radioButton2.Text = "Green";
            // 
            // radioButton3
            // 
            this.radioButton3.Location = New-Object System.Drawing.Point(8, 96);
            this.radioButton3.Name = "radioButton3";
            this.radioButton3.TabIndex = 6;
            this.radioButton3.Text = "Blue";
#>
             
            # button1
             
            $button1.Location = New-Object System.Drawing.Point(8, 280);
            $button1.Name = "button1";
            $button1.Size = New-Object System.Drawing.Size(112, 32);
            $button1.TabIndex = 4;
            $button1.Text = "Draw";
            # this.button1.Click += New-Object  System.EventHandler(this.button1_Click);
             
            # Form1
            
            $f.AutoScaleBaseSize = New-Object System.Drawing.Size(5, 13);
            $f.ClientSize = New-Object System.Drawing.Size(408, 317);
<#
            $groupBox1.Controls.AddRange( New-Object System.Windows.Forms.Control[]@(
                                                                          $button1,
                                                                          $checkBox3,
                                                                          $checkBox2,
                                                                          $checkBox1,
                                                                          $groupBox1));
#>
 $f.Controls.Add($button1)
 $f.Controls.Add($checkBox3)
 $f.Controls.Add($checkBox2)
 $f.Controls.Add($checkBox1)
 $f.Controls.Add($groupBox1)

            $f.Name = "Form1";
            $f.Text = "CheckBox and RadioButton Sample";
#            $f.groupBox1.ResumeLayout($false);
            $f.ResumeLayout($false);




$RESULT_MANUAL = 0
$RESULT_AUTOMATIC = 1
$RESULT_CANCEL = 2
$Readable = @{ 
	$RESULT_AUTOMATIC = 'AUTOMATIC'; 
	$RESULT_MANUAL = 'MANUAL' ; 
	$RESULT_CANCEL = 'CANCEL'
	} 

# $f.Size = New-Object System.Drawing.Size(650,120) 
$f.StartPosition = 'CenterScreen'

$f.KeyPreview = $True

<#$f.Add_KeyDown({

	if     ($_.KeyCode -eq 'M')       { $caller.Data = $RESULT_MANUAL }
	elseif ($_.KeyCode -eq 'A')       { $caller.Data = $RESULT_AUTOMATIC }
	elseif ($_.KeyCode -eq 'Escape')  { $caller.Data = $RESULT_CANCEL }
	else                              { return }  
	$f.Close()

})
#>
<# 
$b1 = New-Object System.Windows.Forms.Button
$b1.Location = New-Object System.Drawing.Size(50,40)
$b1.Size = New-Object System.Drawing.Size(75,23)
$b1.Text = 'Manual'
$b1.Add_Click({ $caller.Data = $RESULT_MANUAL; $f.Close(); })
$f.Controls.Add($b1)

$b2 = New-Object System.Windows.Forms.Button
$b2.Location = New-Object System.Drawing.Size(125,40)
$b2.Size = New-Object System.Drawing.Size(75,23)
$b2.Text = 'Automatic'
$b2.Add_Click({ $caller.Data = $RESULT_AUTOMATIC; $f.Close(); })
$f.Controls.Add($b2)

$b3 = New-Object System.Windows.Forms.Button
$b3.Location = New-Object System.Drawing.Size(200,40)
$b3.Size = New-Object System.Drawing.Size(75,23)
$b3.Text = 'Cancel'
$b3.Add_Click({$caller.Data =  $RESULT_CANCEL ; $f.Close()})
$f.Controls.Add($b3)

$l = New-Object System.Windows.Forms.Label
$l.Location = New-Object System.Drawing.Size(10,20) 
$l.Size = New-Object System.Drawing.Size(280,20) 
$l.Text = $message 
$f.Controls.Add($l) 
#>
$f.Topmost = $True
<#
if ($caller -eq $null ){
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
}
#>

$f.Add_Shown( { $f.Activate() } )

[Void] $f.ShowDialog([Win32Window ] ($caller) )

        }
           
PromptAuto