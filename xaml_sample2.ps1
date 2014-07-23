
# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
#requires -version 2
$pink = ([System.Windows.Media.Colors]::Pink)
$white = ([System.Windows.Media.Colors]::White)
$orange = ([System.Windows.Media.Colors]::Orange)
$brown = ([System.Windows.Media.Colors]::Brown)
$colors = @{
'Steve Buscemi' = $pink;
'Larry Dimmick' = $white;
'Quentin Tarantino' = $brown;
'Tim Roth' = $orange;
 }


Add-Type -AssemblyName PresentationFramework
[xml]$xaml = 
@"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Row GridSplitter Example">

        <StackPanel Height="Auto">

            <Grid Height="400">
                <Grid.RowDefinitions>
                    <RowDefinition Height="50*" />
                    <RowDefinition Height="50*"/>
                </Grid.RowDefinitions>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition/>
                    <ColumnDefinition/>
                </Grid.ColumnDefinitions>

      <Button Background="gray" Grid.Column="0" Grid.Row="0" x:Name="button00" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Quentin Tarantino" />
      <Button Background="gray" Grid.Column="0" Grid.Row="1" x:Name="button01" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Larry Dimmick" />
      <Button Background="gray" Grid.Column="1" Grid.Row="0" x:Name="button10" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Steve Buscemi" />
      <Button Background="gray" Grid.Column="1" Grid.Row="1" x:Name="button11" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Tim Roth" />

            </Grid>

        </StackPanel>

</Window>
"@

Clear-Host
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)

foreach ($button in @("button01" , "button00", "button10", "button11")) {
       $control=$target.FindName($button)
       $eventMethod=$control.add_click
$eventMethod.Invoke({
       param(
            [Object] $sender, 
            [System.Windows.RoutedEventArgs ] $eventargs 
         )

$target.Title=("You will be  Mr. {0} {1} {2}" -f 

$sender.Content.ToString(),
$sender.Background.ToString(),
'x'
# ($colors[$sender.Content.ToString()]).ToString()
)
# $colors[[System.Windows.Media.Colors]::Pink).ToString()])
# $colors[$sender.Background.ToString()]) 
# ([System.Windows.Media.Colors]::Pink).ToString() )
$sender.Background = new-Object System.Windows.Media.SolidColorBrush($colors[$sender.Content.ToString()])

# [System.Windows.Media.Colors]::Pink);

})
}

$target.ShowDialog() | out-null 
# $colors   |format-table -autosize