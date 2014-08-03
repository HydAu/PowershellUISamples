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

$syncHash = [hashtable]::Synchronized(@{ 
    'Result'='';
	'Window'=[System.Windows.Window] $null ;
	})
$syncHash.Result = 'none'
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)          
$run_script = [PowerShell]::Create().AddScript({   


Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window x:Name="Window"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Example with TextBox" Height="200" Width="300">
    <StackPanel Height="200" Width="300">

  <Canvas Height="100" Width="200" Name="Canvas1">
    <!-- Draws a triangle with a blue interior. -->
    <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" Fill="Blue" Name="Polygon1" Canvas.Left="40" Canvas.Top="30" Canvas.ZIndex="40"/>
    <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" Fill="Green" Name="Polygon2" Canvas.Left="70" Canvas.Top="30" Canvas.ZIndex="30"/>
    <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" Fill="Red" Name="Polygon3" Canvas.Left="100" Canvas.Top="30" Canvas.ZIndex="20"/>
  </Canvas>
          <TextBlock FontSize="14" FontWeight="Bold" 
                   Text="A spell-checking TextBox:"/>
        <TextBox AcceptsReturn="True" AcceptsTab="True" FontSize="14" 
                 Margin="5" SpellCheck.IsEnabled="True" TextWrapping="Wrap" x:Name="textbox">
            The qick red focks jumped over the lasy brown dog.
        </TextBox>

  </StackPanel>
</Window>
"@
Clear-Host


$polygon_data = @{}
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$syncHash.Window  = $target
$canvas = $target.FindName("Canvas1")
function save_orig_design{
  param ([String] $name)
  $control = $target.FindName($name)
  return @{
      'fill'   =  ( $control.Fill.Color ); 
      'ZIndex' =  ( [System.Windows.Controls.Canvas]::GetZIndex($control) )
	  }
  }
  $polygon_data['Polygon1'] = (save_orig_design('Polygon1'))  
  $polygon_data['Polygon2'] = (save_orig_design('Polygon2'))
  $polygon_data['Polygon3'] = (save_orig_design('Polygon3'))
  
# TODO :
# $canvas.Add_Initialized ...
function restore_orig {
  param ( [String] $name )
  $control = $target.FindName( $name )
  $color = [System.Windows.Media.ColorConverter]::ConvertFromString( [String] $polygon_data[$name]['fill'] )
  $control.Fill = new-Object System.Windows.Media.SolidColorBrush( $color )
  [System.Windows.Controls.Canvas]::SetZIndex($control, [Object] $polygon_data[$name]['ZIndex'])
}
$handler = {
param (
    [Object]  $sender, 
    [System.Windows.Input.MouseButtonEventArgs] $e  )
  @('Polygon1', 'Polygon2', 'Polygon3') | % { restore_orig( $_) }
  # Highlight sender
  $sender.Fill = new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Orange)
  # uncomment to reveal a distortion
  # $sender.Stroke = new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Black)
  # Bring sender to front
  [System.Windows.Controls.Canvas]::SetZIndex($sender,[Object]100)
  $target.Title="Hello $($sender.Name)"
}
foreach ($item in ('Polygon1', 'Polygon2', 'Polygon3') ){
  $control = $target.FindName($item)
  $eventMethod = $control.add_MouseDown
  $eventMethod.Invoke( $handler )
  $control = $null 
 }
 
$handler2 = {
	      param ( 
    [Object]  $sender, 
    [System.Windows.Controls.TextChangedEventArgs] $eventargs  
 )
	 $syncHash.Result  = $sender.Text
}
$control = $target.FindName("textbox")
$eventMethod2 = $control.Add_TextChanged
$eventMethod2.Invoke( $handler2 )

$eventMethod.Invoke($handler)
$target.ShowDialog() | out-null 
})
$run_script.Runspace = $newRunspace
$data = $run_script.BeginInvoke()

$cnt = 10 
while ($cnt  -ne 0 ) {

  write-output ('Text: {0} ' -f $syncHash.Result )
    start-sleep 1
  $cnt --
}
