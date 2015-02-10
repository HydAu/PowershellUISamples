# note:
# https://gist.github.com/qwertie/1150228
# http://www.codeproject.com/Articles/132992/A-WPF-DateTimePicker-That-Works-Like-the-One-in-Wi
# Get-EventLog time picker at http://showui.codeplex.com/ 
# among other things.
# http://www.c-sharpcorner.com/UploadFile/mahesh/wpf-datepicker/
# http://www.codeproject.com/Tips/399140/WPF-DatePicker-Background-Fix
# http://www.codeproject.com/Articles/237011/CREATING-A-CUSTOM-TIMEPICKER-CONTROL-IN-WPF
# http://www.codeproject.com/Articles/132992/A-WPF-DateTimePicker-That-Works-Like-the-One-in-Wi
# WPF 4.0 doesn't provide a DateTimePicker out of the box.
# http://jobijoy.blogspot.com/2007/10/time-picker-user-control.html

Add-Type -AssemblyName PresentationFramework
# WPF 4.0 doesn't provide a DateTimePicker out of the box. 
# Add-Type -AssemblyName System.Windows.Controls.Toolkit
# Add-Type -AssemblyName System.Windows.Controls
[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:toolkit="http://schemas.microsoft.com/winfx/2006/xaml/presentation/toolkit" Title="DatePicker Background Sample" Height="80" Width="150">
  <Grid VerticalAlignment="Center">
    <Grid.ColumnDefinitions>
      <ColumnDefinition/>
      <ColumnDefinition/>
    </Grid.ColumnDefinitions>
    <Grid.RowDefinitions>
      <RowDefinition/>
      <RowDefinition/>
    </Grid.RowDefinitions>
    <Label Content="Pick Date" Grid.Column="0" Grid.Row="0" Margin="1"/>
    <DatePicker x:Name="datePicker" Grid.Column="1" Grid.Row="0" Margin="2" Background="#FFC000"/>
    <!-- 
    <toolkit:TimePicker x:Name="TimePicker" Header="Arrival Time" Grid.Column="1" Grid.Row="1" Margin="2" Background="#FFC000"/>
     -->
  </Grid>
</Window>
"@
# http://msdn.microsoft.com/en-us/library/windows/apps/xaml/dn308514.aspx
# 
# Clear-Host
$result = $null
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$control = $target.FindName('datePicker')
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
