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

$DebugPreference = "Continue"
$RESULT_POSITIVE = 0
$RESULT_NEGATIVE = 1
$RESULT_CANCEL = 2

$Readable = @{ 
	$RESULT_NEGATIVE = 'NO!'; 
	$RESULT_POSITIVE = 'YES!' ; 
	$RESULT_CANCEL = 'MAYBE...'
	} 




function promptForContinueAuto(
	[String] $title, 
	[String] $message, 
	[Boolean] $ui = $false, 
	[Object] $caller= $null
	)
{
        $result = 2   
        if ($ui) {
		$result = PromptAuto -title  $title -message $message -caller  $caller
        } else {
	$manual = New-Object System.Management.Automation.Host.ChoiceDescription "&Manual", `
	    "Manually perform this step, then select Manual for the process to continue to the next step."

	$auto = New-Object System.Management.Automation.Host.ChoiceDescription "&Auto", `
	    "Perform step with powershell script and continue to the next step."
		
	$cancelprocessing = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", `
	    "Perform step with powershell script and continue to the next step."

	$callerptions = [System.Management.Automation.Host.ChoiceDescription[]]($manual, $auto, $cancelprocessing)

	$result = $host.ui.PromptForChoice($title, $message, $callerptions, 0) 
        }


	write-debug  "Result  = ${result}"

	switch ($result)
	{
		0{return $false}
		1{return  $true}
		2{Write-Host `n"Process Halted At Step: " $title`n
		break}
	}	
}



function PromptAuto(
	[String] $title, 
	[String] $message, 
	[Object] $caller = $null 
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

if ($caller -eq $null ){
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
}

$caller.Data = $RESULT_CANCEL;
$f.Add_Shown( { $f.Activate() } )

[Void] $f.ShowDialog([Win32Window ] ($caller) )


return $caller.Data
}

# -- main program -- 

$process_window = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)


$title = 'Question' 
$message =  "Continue to Next step?"


$result = promptForContinueAuto  $title $message $true $process_window 

write-debug ("Result is : {0} ({1})" -f $Readable.Item($process_window.Data) , $process_window.Data )
