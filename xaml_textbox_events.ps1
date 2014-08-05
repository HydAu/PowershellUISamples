#Copyright (c) 2014 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#requires -version 2
Add-Type -AssemblyName PresentationFramework

$so = [hashtable]::Synchronized(@{ 
    'Result'  = '';
	'Window'  = [System.Windows.Window] $null ;
	'TextBox' = [System.Windows.Controls.TextBox] $null ;
	})
$so.Result = ''
$rs =[runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so', $so)          
$run_script = [PowerShell]::Create().AddScript({   

Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Example with TextBox" Height="100" Width="300">
    <StackPanel Height="100" Width="300">
          <TextBlock FontSize="14" FontWeight="Bold" 
                   Text="A spell-checking TextBox:"/>
        <TextBox AcceptsReturn="True" AcceptsTab="True" FontSize="14" 
                 Margin="5" SpellCheck.IsEnabled="True" TextWrapping="Wrap" x:Name="textbox">
            
        </TextBox>

  </StackPanel>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$so.Window  = $target
$handler = {
	param ( 
    [Object]  $sender, 
    [System.Windows.Controls.TextChangedEventArgs] $eventargs  
	)
	$so.Result  = $sender.Text
}
$control = $target.FindName("textbox")
$so.TextBox = $control 

$event = $control.Add_TextChanged
$event.Invoke( $handler )

$target.ShowDialog() | out-null 
})

function send_text { 
    Param (
        $content,
        [switch] $append
    )
	# WARNING - uncommenting the following line leads to exception  
	# "The calling thread cannot access this object because a different thread owns it."
	# $so.Textbox = $so.Window.FindName("textbox")

    # NOTE - host-specific method signature:
    $so.Textbox.Dispatcher.invoke([System.Action]{
       
        if ($PSBoundParameters['append_content']) {
            $so.TextBox.AppendText($content)
        } else {
            $so.TextBox.Text = $content
        }
		$so.Result = $so.TextBox.Text 
    }, 'Normal')
}

function close_dialog { 
    $so.Window.Dispatcher.invoke([action]{
       $so.Window.Close()
    }, 'Normal')
}

$run_script.Runspace = $rs
Clear-Host

$data = $run_script.BeginInvoke()

# TODO - synchronize properly
# http://stackoverflow.com/questions/10330446/how-to-know-when-a-control-or-window-has-been-rendered-drawn-in-wpf
start-sleep 1
write-host $so.Result
send_text -Content 'The qick red focks jumped over the lasy brown dog.'
$cnt = 10
[bool] $done = $false
while (($cnt  -ne 0 ) -and -not $done) {
  write-output ('Text: {0} ' -f $so.Result )
  if ($so.Result -eq 'The quick red fox jumped over the lazy brown dog.' ){ 
    $done = $true;
  } 
  else {
    start-sleep 10
  }   
  $cnt --
}
close_dialog

if ( -not $done ){
    write-output 'Time is up!'
} else { 
    write-output 'Well done!'
}

