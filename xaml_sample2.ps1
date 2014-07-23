#requires -version 2

# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
# http://msdn.microsoft.com/en-us/library/System.Windows.Media.Colors%28v=vs.110%29.aspx
$pink = ([System.Windows.Media.Colors]::Pink)
$white = ([System.Windows.Media.Colors]::White)
$orange = ([System.Windows.Media.Colors]::Orange)
$brown = ([System.Windows.Media.Colors]::Brown)

$colors = @{
'Steve Buscemi' = ([System.Windows.Media.Colors]::Pink);
'Larry Dimmick' = $white;
'Quentin Tarantino' = $brown;
'Tim Roth' = $orange;
 }
$result = @{ }


Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string Message
    {
        get { return _message; }
        set { _message = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'



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

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)
  $caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

foreach ($button in @("button01" , "button00", "button10", "button11")) {
       $control=$target.FindName($button)
       $eventMethod=$control.add_click
       $eventMethod.Invoke({
           param(
              [Object] $sender, 
              [System.Windows.RoutedEventArgs ] $eventargs 
           )
           $who = $sender.Content.ToString()
           $color = $colors[$who ]
           # $target.Title=("You will be  Mr. {0}" -f  $color)
           $sender.Background = new-Object System.Windows.Media.SolidColorBrush($color)
           $result[ $who  ] = $true
           write-debug $who
           
        })

}
$DebugPreference = 'Continue'

$target.ShowDialog() | out-null 
# confirm the $result
# $result | format-table