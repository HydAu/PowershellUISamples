Add-Type -AssemblyName 'PresentationFramework'
Add-Type -AssemblyName 'PresentationCore'

[xml]$parent_markup =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Window1" Margin="15,15,15,15" Height="310" Width="420">
  <ScrollViewer>
    <Border Padding="10">
      <WrapPanel>
        <Grid x:Name="LayoutRoot">
  </Grid>
      </WrapPanel>
    </Border>
  </ScrollViewer>
</Window>
"@


[xml]$child_markup =
@"
<?xml version="1.0"?>
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
  <StackPanel.Resources>
    <Style TargetType="{x:Type TextBox}">
      <Setter Property="Margin" Value="0,10,0,0"/>
    </Style>
  </StackPanel.Resources>
  <Label x:Name="lblNumberOfTargetHits" HorizontalAlignment="Center">Input:</Label>
  <TextBox Width="120" x:Name="txtTargetKeyFocus" FontSize="12"/>
  <TextBox x:Name="txtTargetFocus" TextWrapping="Wrap" FontSize="12"/>
</StackPanel>
"@

$parent_reader = (New-Object System.Xml.XmlNodeReader $parent_markup)
$parent_target = [Windows.Markup.XamlReader]::Load($parent_reader)
$LayoutRoot = $parent_target.FindName("LayoutRoot")
$child_reader = (New-Object System.Xml.XmlNodeReader $child_markup)
$child_target = [Windows.Markup.XamlReader]::Load($child_reader)
$LayoutRoot.add_Loaded.Invoke({
    $LayoutRoot.Children.Add($child_target)
  })
$target = $child_target
$control = $target.FindName("txtTargetKeyFocus")

$handler_got_keyboard_focus = {
  param(
    [object]$sender,
    [System.Windows.Input.KeyboardFocusChangedEventArgs]$e
  )
  $source = $e.Source
  $source.Background = [System.Windows.Media.Brushes]::LightBlue
  $source.Clear()

}
$handler_lost_keyboard_focus = {
  param(
    [object]$sender,
    [System.Windows.Input.KeyboardFocusChangedEventArgs]$e
  )
  $source = $e.Source
  $source.Background = [System.Windows.Media.Brushes]::White
}

[System.Management.Automation.PSMethod]$event_got_keyboard_focus = $control.Add_GotKeyboardFocus
[System.Management.Automation.PSMethod]$event_lost_keyboard_focus = $control.Add_LostKeyboardFocus

$event_got_keyboard_focus.Invoke($handler_got_keyboard_focus)
$event_lost_keyboard_focus.Invoke($handler_lost_keyboard_focus)
$control = $null

$control = $target.FindName("txtTargetFocus")

$handler_got_focus = {
  param(
    [object]$sender,
    [System.Windows.RoutedEventArgs]$e
  )
  $source = $e.Source
  $source.Background = [System.Windows.Media.Brushes]::LightGreen
  $source.Clear()

}
$handler_lost_focus = {
  param(
    [object]$sender,
    [System.Windows.RoutedEventArgs]$e
  )
  $source = $e.Source
  $source.Background = [System.Windows.Media.Brushes]::White
}

[System.Management.Automation.PSMethod]$event_got_focus = $control.Add_GotFocus
[System.Management.Automation.PSMethod]$event_lost_focus = $control.Add_LostFocus

$event_got_focus.Invoke($handler_got_focus)
$event_lost_focus.Invoke($handler_lost_focus)
$control = $null

$parent_target.ShowDialog() | Out-Null

