# Get-EventLog time picker at http://showui.codeplex.com/ 
# among other things.
# http://www.c-sharpcorner.com/UploadFile/mahesh/wpf-datepicker/
# http://www.codeproject.com/Tips/399140/WPF-DatePicker-Background-Fix
Add-Type -AssemblyName PresentationFramework
[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="DatePicker Background Sample" Height="80" Width="150">
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
  </Grid>
</Window>
"@
# http://msdn.microsoft.com/en-us/library/windows/apps/xaml/dn308514.aspx
# 
Clear-Host
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$control = $target.FindName('datePicker')
$eventMethod = $control.Add_SelectedDateChanged 

$handler = {
  param(
    [object]$sender,
    [System.Windows.Controls.SelectionChangedEventArgs]$e)
    write-host $sender.SelectedDate.ToString()
}
$eventMethod.Invoke($handler )
$result = $target.ShowDialog() 
write-output $result

<#
NOTE: 
occasional
  Exception calling "ShowDialog" with "0" argument(s):
 "Not enough quota is available to process this command"
#>