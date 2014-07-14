Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
// inline callback class 
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string Message
    {
        get { return _message; }
        set { _message = value; }
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

#  http://www.java2s.com/Code/CSharp/GUI-Windows-Form/Radiobuttoncheckchangedevent.htm
function PromptAuto(
	[String] $title, 
	[String] $message, 
	[Object] $caller = $null 
	){

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
            $str = "";
             
            # groupBox1
             
            $groupBox1.Controls.AddRange(  @(
                                                                                    $radioButton1,
                                                                                    $radioButton2,
                                                                                    $radioButton3 ));
            $groupBox1.Location = New-Object System.Drawing.Point(8, 120);
            $groupBox1.Name = "groupBox1";
            $groupBox1.Size = New-Object System.Drawing.Size(120, 144);
            $groupBox1.TabIndex = 0;
            $groupBox1.TabStop = false;
            $groupBox1.Text = "Color";


            # $groupBox1.Enter += New-Object System.EventHandler({ } );

            $groupBox1.Add_Enter({ 

} );
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
            $checkBox3.Text = "Triangle";
            
            # radioButton1
             
            $radioButton1.Location = New-Object System.Drawing.Point(8, 32);
            $radioButton1.Name = "radioButton1";
            $radioButton1.TabIndex = 4;
            $radioButton1.Text = "Red";
            # $b3.Add_Click({$caller.Data =  $RESULT_CANCEL ; $f.Close()})
            $radioButton1.Add_CheckedChanged({$caller.Data =  $RESULT_CANCEL ; });
             
            # radioButton2
             
            $radioButton2.Location = New-Object System.Drawing.Point(8, 64);
            $radioButton2.Name = "radioButton2";
            $radioButton2.TabIndex = 5;
            $radioButton2.Text = "Green";
             
            # radioButton3
             
            $radioButton3.Location = New-Object System.Drawing.Point(8, 96);
            $radioButton3.Name = "radioButton3";
            $radioButton3.TabIndex = 6;
            $radioButton3.Text = "Blue";
             
            # button1
             
            $button1.Location = New-Object System.Drawing.Point(8, 280);
            $button1.Name = "button1";
            $button1.Size = New-Object System.Drawing.Size(112, 32);
            $button1.TabIndex = 4;
            $button1.Text = "Draw";

            # this.button1.Click += New-Object  System.EventHandler(this.button1_Click);
            $button1.Add_Click({

            # $g = Graphics.FromHwnd($f.Handle);
            # $rc = New-Object Rectangle(150, 50, 250, 250);
            $str = '';             
            if($radioButton1.Checked)
            {
                $str = $radioButton1.Text;
            }
            if($radioButton2.Checked)
            {
                $str =$radioButton2.Text;
            }
            if($radioButton3.Checked)
            {
                $str =$radioButton3.Text;
            }

            if ($checkBox1.Checked)
            {
                $str += $checkBox1.Text;
            }
            if ($checkBox2.Checked)
            {
                $str += $checkBox2.Text;
            }
            if ($checkBox3.Checked)
            {
                $str += $checkBox3.Text;
              #  $g.FillRectangle(New-Object SolidBrush(Color.White), rc);
              #  $g.DrawString($str, New-Object Font("Verdana", 12), New-Object SolidBrush(Color.Black), rc);
            }

            $caller.Message = $str; 
            $f.Close();
 })
             
            # Form1
            
            $f.AutoScaleBaseSize = New-Object System.Drawing.Size(5, 13);
            $f.ClientSize = New-Object System.Drawing.Size(408, 317);
            $f.Controls.AddRange( @(
                                                                          $button1,
                                                                          $checkBox3,
                                                                          $checkBox2,
                                                                          $checkBox1,
                                                                          $groupBox1));

            $f.Name = "Form1";
            $f.Text = "CheckBox and RadioButton Sample";
            # $f.groupBox1.ResumeLayout($false);
            $f.ResumeLayout($false);




$RESULT_MANUAL = 0
$RESULT_AUTOMATIC = 1
$RESULT_CANCEL = 2
$Readable = @{ 
	$RESULT_AUTOMATIC = 'AUTOMATIC'; 
	$RESULT_MANUAL = 'MANUAL' ; 
	$RESULT_CANCEL = 'CANCEL'
	} 

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

$f.Topmost = $True
if ($caller -eq $null ){
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
}

$f.Add_Shown( { $f.Activate() } )

[Void] $f.ShowDialog([Win32Window ] ($caller) )

# NOTE: set $DebugPreference = "Continue" to reveal debug messages
# write-debug ("Result is : {0} ({1})" -f $Readable.Item($caller.Data) , $caller.Data )
write-output ("Selection is : {0}" -f  ,$caller.Message )

return $caller.Data

        }
           
PromptAuto