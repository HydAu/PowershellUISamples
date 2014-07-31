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
    Fill="Violet" Name="Polygon2" Canvas.Left="70" Canvas.Top="30" Canvas.ZIndex="30"/>
  <Polygon Points="0,0 0,30 0,10 30,10 30,-10 45,10 30,30 30,20 0,20 0,0 30,0 30,10 0,10" 
    Fill="Brown" Name="Polygon3" Canvas.Left="100" Canvas.Top="30" Canvas.ZIndex="20"/>

</Canvas>
</Window>
"@
Clear-Host
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)
$canvas=$target.FindName("Canvas1")

function restore_orig{

$control = $target.FindName('Polygon1')
$control.Fill =  new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Blue)
[System.Windows.Controls.Canvas]::SetZIndex($control,[Object] 40)

$control = $target.FindName('Polygon2')
$control.Fill =  new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Violet)
[System.Windows.Controls.Canvas]::SetZIndex($control,[Object] 30)

$control = $target.FindName('Polygon3')
$control.Fill =  new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Brown)
[System.Windows.Controls.Canvas]::SetZIndex(($target.FindName('Polygon3')),[Object] 20)

}
$handler = {
param (
    [Object]  $sender, 
    [System.Windows.Input.MouseButtonEventArgs] $e 
 )

restore_orig

# highlight $sender
$sender.Fill = new-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Green)

# bring $sender to front

[System.Windows.Controls.Canvas]::SetZIndex($sender,[Object]100)
$name = $sender.Name
$target.Title="Hello $($sender.Name)"
}

foreach ($item in ("Polygon1", "Polygon2", "Polygon3") ){
   $control = $target.FindName($item)
   $control | get-member | out-null
   $eventMethod=$control.add_MouseDown
  $eventMethod.Invoke( $handler )
  $combobox_item_control = $null 
}

$eventMethod.Invoke($handler)
$target.ShowDialog() | out-null 