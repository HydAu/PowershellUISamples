# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/HandlesComboBoxItemSelectedevents.htm
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/iftheuserhasenteredtextintotheComboBoxinstead.htm

# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots
# broken 
#requires -version 2

function ComboBoxItem_Selected 
{
param ([Object] $sender, [System.Windows.Controls.SelectionChangedEventArgs] $e) 
}
function ComboBox_SelectionChanged
{
param ([object] $sender, 
       [System.Windows.Controls.SelectionChangedEventArgs] $e )
$target.Title="Hello $((Get-Date).ToString('G'))"

}


#  SelectionChanged="ComboBox_SelectionChanged"
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = 
@"
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Window1" Height="300" Width="408">
    <StackPanel>
    <ComboBox Name="comboBox" IsEditable="True" Margin="5">
            <ComboBoxItem Name="Item_1" Content="ComboBox Item 1"/>
            <ComboBoxItem Name="Item_2" Content="ComboBox Item 2"/>
            <ComboBoxItem Name="Item_3" Content="ComboBox Item 3" IsSelected="True"/>
            <ComboBoxItem Name="Item_4" Content="ComboBox Item 4" />
            <ComboBoxItem Name="Item_5" Content="ComboBox Item 5"/>
        </ComboBox>
    </StackPanel>
</Window>
"@
#         <Button Content="Get Selected" Margin="5" Width="100" Click="Button_Click" />
Clear-Host
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)


foreach ($item in ("Item_1", "Item_5", "Item_2","Item_3","Item_4") ){

write-output ('Wiring {0} ?' -f $item )
$control2 = $target.FindName($item)
$eventMethod2 = $control2.add_Selected
$eventMethod2.Invoke( {
param ([object] $sender, 
[System.Windows.RoutedEventArgs] $e )
# $target.Title="Hello $((Get-Date).ToString('G'))"
$target.Title=( "Hello {0} " -f $sender.GetType().ToString() )
write-output ( "Hello {0} " -f $sender.ToString() )
})
$control2 = $null 
}

$control1=$target.FindName("comboBox")
$eventMethod1=$control1.add_SelectionChanged
$eventMethod1.Invoke({
param ([object] $sender, 
       [System.Windows.Controls.SelectionChangedEventArgs] $e )
write-host 'x'
 write-host ('Event routed from {0} to Powershell'  -f $sender.ToString())

})




$target.ShowDialog() | out-null 