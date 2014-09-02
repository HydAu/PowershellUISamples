Add-Type -AssemblyName PresentationFramework
# WPF 4.0 doesn't provide a DateTimePicker out of the box. 
# Add-Type -AssemblyName System.Windows.Controls.Toolkit
# Add-Type -AssemblyName System.Windows.Controls
[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:toolkit="http://schemas.microsoft.com/winfx/2006/xaml/presentation/toolkit" Title="DatePicker Background Sample" Height="80" Width="150">
  <Grid VerticalAlignment="Center">
<!-- x:Class="DateTimeTest.TimeControl"  -->
<UserControl Height="Auto" Width="Auto" x:Name="UserControl">
  <Grid x:Name="LayoutRoot" Width="Auto" Height="Auto">
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="0.2*"/>
      <ColumnDefinition Width="0.05*"/>
      <ColumnDefinition Width="0.2*"/>
      <ColumnDefinition Width="0.05*"/>
      <ColumnDefinition Width="0.2*"/>
    </Grid.ColumnDefinitions>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'KeyDown' from the text 'Down'."
    <Grid x:Name="hour" Focusable="True" KeyDown="Down">
-->

   <Grid x:Name="hour" Focusable="True">
      <TextBlock x:Name="mmTxt" TextWrapping="Wrap" Text="{Binding Path=Hours, ElementName=UserControl, Mode=Default}" TextAlignment="Center" VerticalAlignment="Center" FontFamily="Goudy Stout" FontSize="14"/>
    </Grid>
    <Grid Grid.Column="1">
      <TextBlock x:Name="sep1" TextWrapping="Wrap" VerticalAlignment="Center" Background="{x:Null}" FontFamily="Goudy Stout" FontSize="14" Text=":" TextAlignment="Center"/>
    </Grid>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'KeyDown' from the text 'Down'."
       <Grid Grid.Column="2" x:Name="min" Focusable="True" KeyDown="Down">
-->
    <Grid Grid.Column="2" x:Name="min" Focusable="True">
      <TextBlock x:Name="ddTxt" TextWrapping="Wrap" Text="{Binding Path=Minutes, ElementName=UserControl, Mode=Default}" TextAlignment="Center" VerticalAlignment="Center" FontFamily="Goudy Stout" FontSize="14"/>
    </Grid>
    <Grid Grid.Column="3">
      <TextBlock x:Name="sep2" TextWrapping="Wrap" VerticalAlignment="Center" Background="{x:Null}" FontFamily="Goudy Stout" FontSize="14" Text=":" TextAlignment="Center"/>
    </Grid>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'KeyDown' from the text 'Down'."
    <Grid Grid.Column="4" Name="sec" Focusable="True" KeyDown="Down">
-->

    <Grid Grid.Column="4" Name="sec" Focusable="True">
      <TextBlock x:Name="yyTxt" TextWrapping="Wrap" Text="{Binding Path=Seconds, ElementName=UserControl, Mode=Default}" TextAlignment="Center" VerticalAlignment="Center" FontFamily="Goudy Stout" FontSize="14"/>
    </Grid>
  </Grid>
</UserControl>
 </Grid>
</Window>
"@
# http://msdn.microsoft.com/en-us/library/windows/apps/xaml/dn308514.aspx
# 
# Clear-Host
$result = $null
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$control = $target.FindName('yyTxt')
$eventMethod = $control.Add_SelectedDateChanged 

$handler = {
  param(
    [object]$sender,
    [System.Windows.Controls.SelectionChangedEventArgs]$e)
    $result =  $sender.SelectedDate.ToString()
}
$eventMethod.Invoke($handler )
$target.ShowDialog()  
# | Out-Null

write-output $result

<#
NOTE: 
occasional
  Exception calling "ShowDialog" with "0" argument(s):
 "Not enough quota is available to process this command"
#>
