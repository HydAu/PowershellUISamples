# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/HandlesComboBoxItemSelectedevents.htm
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/iftheuserhasenteredtextintotheComboBoxinstead.htm
# origin: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/EmbeddedCodeinWindowxaml.htm
# origin: http://stackoverflow.com/questions/5863209/compile-wpf-xaml-using-add-type-of-powershell-without-using-powerboots

#requires -version 2


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
            <ComboBoxItem Name="Item_1" Content="ComboBox Item 1" IsSelected="True" />
            <ComboBoxItem Name="Item_2" Content="ComboBox Item 2"/>
            <ComboBoxItem Name="Item_3" Content="ComboBox Item 3"/>
            <ComboBoxItem Name="Item_4" Content="ComboBox Item 4"/>
            <ComboBoxItem Name="Item_5" Content="ComboBox Item 5"/>
        </ComboBox>
    </StackPanel>
</Window>
"@

Clear-Host
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$target=[Windows.Markup.XamlReader]::Load($reader)


foreach ($item in ("Item_1", "Item_5", "Item_2","Item_3","Item_4") ){
  
  write-output ('Wiring {0} ?' -f $item )
  $combobox_item_control = $target.FindName($item)
  $eventMethod2 = $combobox_item_control.add_Selected
  $eventMethod2.Invoke( {
      param ([object] $sender,  # System.Windows.Controls.ComboboxItem
             [System.Windows.RoutedEventArgs] $e )

      $target.Title = ( "Hello {0} " -f $sender.Name.ToString() ) 

  })
  $combobox_item_control = $null 
}

$combobox_control = $target.FindName('comboBox')
$eventMethod0 = $combobox_control.add_SelectionChanged
$eventMethod0.Invoke({
   param (
    [object] $sender, 
    [System.Windows.Controls.SelectionChangedEventArgs] $e )

    write-host ("Additional event {0} routed from '{1}' to Powershell" -f $e.GetType().ToString() , $sender.ToString())
})




$target.ShowDialog() | out-null 