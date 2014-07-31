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
$polygon_data = @{}

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
    [System.Windows.Input.MouseButtonEventArgs] $e 

 )

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

$eventMethod.Invoke($handler)
$target.ShowDialog() | out-null 