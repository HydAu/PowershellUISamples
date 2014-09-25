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
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Height="100" Width="200" Title="Window1">
  <Canvas Height="100" Width="200" Name="Canvas1">
    <!-- Draws a triangle with a blue interior. -->
    <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" Fill="Blue" Name="Polygon1" Canvas.Left="40" Canvas.Top="30" Canvas.ZIndex="40"/>
    <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" Fill="Green" Name="Polygon2" Canvas.Left="70" Canvas.Top="30" Canvas.ZIndex="30"/>
    <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" Fill="Red" Name="Polygon3" Canvas.Left="100" Canvas.Top="30" Canvas.ZIndex="20"/>
  </Canvas>
</Window>
"@
Clear-Host


$polygon_data = @{}
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$canvas = $target.FindName('Canvas1')
function save_orig_design {
  param([string]$name)
  $control = $target.FindName($name)
  return @{
    'fill' = ($control.Fill.Color);
    'ZIndex' = ([System.Windows.Controls.Canvas]::GetZIndex($control))
  }
}
$polygon_data['Polygon1'] = (save_orig_design ('Polygon1'))
$polygon_data['Polygon2'] = (save_orig_design ('Polygon2'))
$polygon_data['Polygon3'] = (save_orig_design ('Polygon3'))

# TODO :
# $canvas.Add_Initialized ...
function restore_orig {
  param([string]$name)
  $control = $target.FindName($name)
  $color = [System.Windows.Media.ColorConverter]::ConvertFromString([string]$polygon_data[$name]['fill'])
  $control.Fill = New-Object System.Windows.Media.SolidColorBrush ($color)
  [System.Windows.Controls.Canvas]::SetZIndex($control,[object]$polygon_data[$name]['ZIndex'])
}
$handler = {
  param(
    [object]$sender,
    [System.Windows.Input.MouseButtonEventArgs]$e)
  @( 'Polygon1','Polygon2','Polygon3') | % { restore_orig ($_) }
  # Highlight sender
  $sender.Fill = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Colors]::Orange)
  # uncomment to reveal a distortion
  # $sender.Stroke = new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Black)
  # Bring sender to front
  [System.Windows.Controls.Canvas]::SetZIndex($sender,[object]100)
  $target.Title = "Hello $($sender.Name)"
}
foreach ($item in ('Polygon1','Polygon2','Polygon3')) {
  $control = $target.FindName($item)
  $eventMethod = $control.add_MouseDown
  $eventMethod.Invoke($handler)
  $control = $null
}
$eventMethod.Invoke($handler)
$target.ShowDialog() | Out-Null

<#
NOTE:
on w2k3 
need to explicitly pass arguments when sourcing the script:
 powershell.exe -sta .\xaml_polygon_events.ps1
otherwise
Exception calling "Load" with "1" argument(s): "Cannot create instance of 'Window' 
defined in assembly 
'PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35'. 
The calling thread must be STA, because many UI components require this.  "
#>