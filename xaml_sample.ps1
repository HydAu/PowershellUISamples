# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
#requires -version 2
Add-Type -AssemblyName PresentationFramework
[xml]$xaml =
@"
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Window1" Height="300" Width="408">
    <Grid>
      <Button x:Name="button1"
                Width="75"
                Height="23"
                Canvas.Left="118"
                Canvas.Top="10"
                Content="Click Here" />
    </Grid>
    <!--   creating the Click="ButtonOnClick" attribute leads to the following:
           Exception calling "Load" with "1" argument(s): 
           
          "Failed to create a 'Click'from the text 'ButtonOnClick'."
http://social.msdn.microsoft.com/Forums/vstudio/en-US/753be353-a2f9-4b29-ba75-cd962a7260a4/dynamic-xaml-and-attaching-event-handlers-problem-wpf-4?forum=wpf

        <x:Code>
        void ButtonO1nClick(object sender, RoutedEventArgs args)
        {
            Button btn = sender as Button;
            MessageBox.Show("The button labeled '" + btn.Content + "' has been clicked.");
        }
        </x:Code>
   -->
</Window>
"@

Clear-Host
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$control = $target.FindName("button1")
$eventMethod = $control.add_click
$eventMethod.Invoke({ $target.Title = "Hello $((Get-Date).ToString('G'))" })
$target.ShowDialog() | Out-Null
