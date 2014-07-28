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
            <ComboBoxItem Content="ComboBox Item 1" Selected="ComboBoxItem_Selected" />
            <ComboBoxItem Content="ComboBox Item 2" Selected="ComboBoxItem_Selected" />
            <ComboBoxItem Content="ComboBox Item 3" Selected="ComboBoxItem_Selected" IsSelected="True"/>
            <ComboBoxItem Content="ComboBox Item 4" Selected="ComboBoxItem_Selected" />
            <ComboBoxItem Content="ComboBox Item 5" Selected="ComboBoxItem_Selected" />
        </ComboBox>
    </StackPanel>
</Window>
"@
#         <Button Content="Get Selected" Margin="5" Width="100" Click="Button_Click" />
Clear-Host
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)
# $control1=$target.FindName("comboBox")

$control2=$target.FindName("comboBoxItem")
$eventMethod=$control1.add_Selected
$eventMethod.Invoke({
param ([object] $sender, 
       [System.Windows.SelectionChangedEventArgs] $e )
$target.Title="Hello $((Get-Date).ToString('G'))"})

$target.ShowDialog() | out-null 