#requires -version 2

#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


# http://msdn.microsoft.com/en-us/library/System.Windows.Media.Colors%28v=vs.110%29.aspx

$colors = @{
  'Steve Buscemi' = ([System.Windows.Media.Colors]::Pink);
  'Larry Dimmick' = ([System.Windows.Media.Colors]::White);
  'Quentin Tarantino' = ([System.Windows.Media.Colors]::Orange);
  'Tim Roth' = ([System.Windows.Media.Colors]::Brown);
}



# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
Add-Type -AssemblyName PresentationFramework
[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Row GridSplitter Example">
  <StackPanel Height="Auto">
    <Grid Height="200">
      <Grid.RowDefinitions>
        <RowDefinition Height="50*"/>
        <RowDefinition Height="50*"/>
      </Grid.RowDefinitions>
      <Grid.ColumnDefinitions>
        <ColumnDefinition/>
        <ColumnDefinition/>
      </Grid.ColumnDefinitions>
      <Button Background="gray" Grid.Column="0" Grid.Row="0" x:Name="button00" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Content="Quentin Tarantino"/>
      <Button Background="gray" Grid.Column="0" Grid.Row="1" x:Name="button01" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Content="Larry Dimmick"/>
      <Button Background="gray" Grid.Column="1" Grid.Row="0" x:Name="button10" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Content="Steve Buscemi"/>
      <Button Background="gray" Grid.Column="1" Grid.Row="1" x:Name="button11" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Content="Tim Roth"/>
    </Grid>
  </StackPanel>
</Window>
"@

# http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)

foreach ($button in @( "button01","button00","button10","button11")) {
  $control = $target.FindName($button)
  $eventMethod = $control.add_click
  $eventMethod.Invoke({
      param(
        [object]$sender,
        [System.Windows.RoutedEventArgs ]$eventargs
      )
      $who = $sender.Content.ToString()
      $color = $colors[$who]
      # $target.Title=("You will be  Mr. {0}" -f  $color)
      $sender.Background = New-Object System.Windows.Media.SolidColorBrush ($color)
      $result[$who] = $true
      Write-Debug $who
    })

}

$result = @{}

$DebugPreference = 'Continue'
Clear-Host
$target.ShowDialog() | Out-Null
# confirm the $result
# $result | format-table
