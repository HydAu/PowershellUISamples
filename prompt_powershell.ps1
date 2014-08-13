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



$RESULT_POSITIVE = 0
$RESULT_NEGATIVE = 1
$RESULT_CANCEL = 2

$Readable = @{ 
	$RESULT_NEGATIVE = 'NO!'; 
	$RESULT_POSITIVE = 'YES!' ; 
	$RESULT_CANCEL = 'MAYBE...'
	} 

function PromptAuto(
	[String] $title, 
	[String] $message,
        [Object] $caller
	){

[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 


$f = New-Object System.Windows.Forms.Form 
$f.Text = $title


$f.Size = New-Object System.Drawing.Size(650,120) 
$f.StartPosition = 'CenterScreen'

$f.KeyPreview = $True
$f.Add_KeyDown({

	if     ($_.KeyCode -eq 'M')       { $caller.Data = $RESULT_POSITIVE }
	elseif ($_.KeyCode -eq 'A')       { $caller.Data = $RESULT_NEGATIVE }
	elseif ($_.KeyCode -eq 'Escape')  { $caller.Data = $RESULT_CANCEL }
	else                              { return }  
	$f.Close()

})

$b1 = New-Object System.Windows.Forms.Button
$b1.Location = New-Object System.Drawing.Size(50,40)
$b1.Size = New-Object System.Drawing.Size(75,23)
$b1.Text = 'Yes!'
$b1.Add_Click({ $caller.Data = $RESULT_POSITIVE; $f.Close(); })
$f.Controls.Add($b1)

$b2 = New-Object System.Windows.Forms.Button
$b2.Location = New-Object System.Drawing.Size(125,40)
$b2.Size = New-Object System.Drawing.Size(75,23)
$b2.Text = 'No!'
$b2.Add_Click({ $caller.Data = $RESULT_NEGATIVE; $f.Close(); })
$f.Controls.Add($b2)

$b3 = New-Object System.Windows.Forms.Button
$b3.Location = New-Object System.Drawing.Size(200,40)
$b3.Size = New-Object System.Drawing.Size(75,23)
$b3.Text = 'Maybe'
$b3.Add_Click({$caller.Data =  $RESULT_CANCEL ; $f.Close()})
$f.Controls.Add($b3)

$l = New-Object System.Windows.Forms.Label
$l.Location = New-Object System.Drawing.Size(10,20) 
$l.Size = New-Object System.Drawing.Size(280,20) 
$l.Text = $message 
$f.Controls.Add($l) 
$f.Topmost = $True


$caller.Data = $RESULT_CANCEL;
$f.Add_Shown( { $f.Activate() } )

[Void] $f.ShowDialog([Win32Window ] ($caller) )

$f.Dispose() 
}

Add-Type -TypeDefinition @" 

// "
using System;
using System.Windows.Forms;
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

$DebugPreference = 'Continue'
$title = 'Question' 
$message =  "Continue to Next step?"
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

PromptAuto -title $title -message $message -caller $caller
$result = $caller.Data 
write-debug ("Result is : {0} ({1})" -f $Readable.Item($result) , $result )
