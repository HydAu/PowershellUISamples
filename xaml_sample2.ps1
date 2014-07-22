# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
#requires -version 2
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = 
@"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Row GridSplitter Example">

        <StackPanel Width="Auto" Height="Auto" Grid.Row="0" Grid.Column="0">

            <Grid >
                <Grid.RowDefinitions>
                    <RowDefinition Height="50" />
                    <RowDefinition Height="50"/>
                </Grid.RowDefinitions>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition/>
                    <ColumnDefinition/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Row="0" Grid.Column="0" 
                      Background="Red">
                </StackPanel>
                <StackPanel Grid.Row="0" Grid.Column="1" 
                      Background="Green"/>

                <StackPanel Grid.Row="1" Grid.Column="0" 
                      Background="Tan"/>
                <StackPanel Grid.Row="1" Grid.Column="1" 
                      Background="Blue"/>


                <GridSplitter Grid.Row="1" 
                        Grid.ColumnSpan="2" 
                        HorizontalAlignment="Stretch" 
                        VerticalAlignment="Top"
                        Background="Black" 
                        ShowsPreview="true"
                        ResizeDirection="Columns"
                        Height="5"/>
                <GridSplitter Grid.Column="1" 
                        Grid.RowSpan="2" 
                        HorizontalAlignment="Left" 
                        VerticalAlignment="Stretch"
                        Background="White" 
                        ShowsPreview="true"
                        Width="5"/>

      <Button Background="Transparent" Grid.Column="0" Grid.Row="0" x:Name="button00" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Click Here" />
      <Button Background="Transparent" Grid.Column="0" Grid.Row="1" x:Name="button01" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Click Here" />
      <Button Background="Transparent" Grid.Column="1" Grid.Row="0" x:Name="button10" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Click Here" />
      <Button Background="Transparent" Grid.Column="1" Grid.Row="1" x:Name="button11" HorizontalAlignment="Stretch" VerticalAlignment="Stretch"
                Content="Click Here" />

            </Grid>

        </StackPanel>

</Window>
"@

Clear-Host
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)
$control=$target.FindName("button01")
$eventMethod=$control.add_click
$eventMethod.Invoke({$target.Title="Hello $((Get-Date).ToString('G'))"})
$target.ShowDialog() | out-null 