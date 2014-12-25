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

# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/HandlesComboBoxItemSelectedevents.htm

#requires -version 2

$items = @(
  'Apple',
  'Banana',
  'Orange',
  'Pineapple',
  'Plum'
)
$selected = @{}
$context = @'
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Window1" Height="60" Width="200">
    <StackPanel>
    <ComboBox Name="comboBox" IsEditable="False" Margin="5">
'@
$cnt = 1
$items | ForEach-Object { $name = "Item_${cnt}"; $cnt++; $context += "<ComboBoxItem Name='${name}' Content='$_'/>" }
$context += @'
        </ComboBox>
    </StackPanel>
</Window>
'@


Add-Type -AssemblyName PresentationFramework
[xml]$xaml = $context

Clear-Host
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($reader)
$handler = {
  param([object]$sender,# System.Windows.Controls.ComboboxItem
    # http://msdn.microsoft.com/en-us/library/system.windows.controls.comboboxitem_properties%28v=vs.110%29.aspx
    [System.Windows.RoutedEventArgs]$eventargs)
  $sender.Background = [ System.Windows.Media.Brushes]::Red
  $target.Title = ('Added {0} ' -f $sender.Content)
  $selected[$sender.Content] = $true

}

foreach ($item in ("Item_1","Item_5","Item_2","Item_3","Item_4")) {
  $combobox_item_control = $target.FindName($item)
  $eventargsventMethod2 = $combobox_item_control.add_Selected
  $eventargsventMethod2.Invoke($handler)
  $combobox_item_control = $null
}

<#

# TODO - handle IsEditable='true' addl. event

$combobox_control = $target.FindName('comboBox')
$combobox_handler = $combobox_control.add_SelectionChanged
$combobox_handler.Invoke({
   param (
    [object] $sender, 
    [System.Windows.Controls.SelectionChangedEventArgs] $eventargs )

    write-host ("Additional event {0} routed from '{1}' to Powershell" -f $eventargs.GetType().ToString() , $sender.ToString())
})

#>

$target.ShowDialog() | Out-Null
Write-Output 'Selected items:'
$items | Where-Object { $selected.containskey($_) }
