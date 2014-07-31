# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
# www.dotnetheaven.com/article/wpf-polygon-and-mousedown-event-in-vb.net
#requires -version 2
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = 
@"
<Window Height="100" Width="200"   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Window1">
<Canvas Height="100" Width="200" Name="Canvas1">
  <!-- Draws a triangle with a blue interior. -->
  <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" 
    Fill="Blue" Name="Polygon1" Canvas.Left="40" Canvas.Top="30" Canvas.ZIndex="40" />
  <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" 
    Fill="Green" Name="Polygon2" Canvas.Left="70" Canvas.Top="30" Canvas.ZIndex="30"/>
  <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" 
    Fill="Red" Name="Polygon3" Canvas.Left="100" Canvas.Top="30" Canvas.ZIndex="20"/>

</Canvas>
</Window>
"@
Clear-Host
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$canvas = $target.FindName("Canvas1")
$alldata = @{}
function save_orig{
  param ([String] $name)
  $data = @{}
  $control = $target.FindName($name)
  $data['fill'] =  $control.Fill.Color
  $data['ZIndex'] =   [System.Windows.Controls.Canvas]::GetZIndex($control)
  
  return $data
}
function restore_orig {
  param (
          [String] $name )
write-host $alldata.GetType()
write-host "Name=${name}"
$alldata.Keys | % {write-host $_}
$data = $alldata[$name]
write-host $data.GetType()
$data.Keys | % {write-host $_}


[String] $fill = $alldata[$name]['fill']
[Int] $ZIndex = $alldata[$name]['ZIndex']

  $color = [System.Windows.Media.Color]::FromRgb([byte]($fill -band 0xff0000) , 0, 0)
  $control.Fill =  new-Object System.Windows.Media.SolidColorBrush($color)
  [System.Windows.Controls.Canvas]::SetZIndex($control,[Object] $ZIndex)

}

$handler = {
param (
    [Object]  $sender, 
    [System.Windows.Input.MouseButtonEventArgs] $e 

 )


$alldata['Polygon1'] = (save_orig('Polygon1'))
# write-host $data.GetType()
restore_orig( 'Polygon1' )

# Highlight $sender
$sender.Fill = new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Orange)
# uncomment to reveal a distortion
# $sender.Stroke = new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Black)

# Bring $sender to front
[System.Windows.Controls.Canvas]::SetZIndex($sender,[Object]100)
$target.Title="Hello $($sender.Name)"
}

foreach ($item in ("Polygon1", "Polygon2", "Polygon3") ){
  $control = $target.FindName($item)
  $eventMethod=$control.add_MouseDown
  $eventMethod.Invoke( $handler )
  $control = $null 
}

$eventMethod.Invoke($handler)
$target.ShowDialog() | out-null 