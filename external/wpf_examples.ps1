#Copyright (c) 2015 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#requires -version 2

param(
  [switch]$debug
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}

$verificationErrors = New-Object System.Text.StringBuilder

Add-Type -AssemblyName PresentationFramework


# requires -version 2
# origin: http://www.codeproject.com/Articles/68748/TreeTabControl-A-Tree-of-Tab-Items

[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Window1" Margin="0,0,0,0">
<ScrollViewer>
    <WrapPanel>
  <Grid x:Name="LayoutRoot">
  </Grid>

     </WrapPanel>
  </ScrollViewer>

</Window>
"@


Clear-Host


$shared_assemblies = @(
  'TreeTab.dll',
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
popd
# TODO: http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/GetsthecurrentlyselectedComboBoxItemwhentheuserclickstheButton.htm
# does not work 

# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/ThreeStateCheckBox.htm
[xml]$example = @"
<?xml version="1.0"?>
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
  <UserControl xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Height="244" Width="533">
    <HeaderedItemsControl Header="GroupBox">
      <StackPanel>
        <GroupBox Margin="8" Header="This is the Header" Width="200">
          <Border Height="100">
            <HeaderedItemsControl Header="CheckBox">
              <CheckBox Margin="8">Normal</CheckBox>
              <CheckBox Margin="8" IsChecked="true">Checked</CheckBox>
              <CheckBox Margin="8" IsThreeState="true" IsChecked="{x:Null}">Indeterminate</CheckBox>
            </HeaderedItemsControl>
          </Border>
        </GroupBox>
      </StackPanel>
    </HeaderedItemsControl>
  </UserControl>
</StackPanel>
"@
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/DisplayaPasswordEntryBoxandgettheinput.htm
[xml]$example = @"
<?xml version="1.0"?>
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Orientation="Horizontal">
  <TextBlock Margin="5" VerticalAlignment="Center">
            Enter Password:
        </TextBlock>
  <PasswordBox Name="passwordBox" PasswordChar="!" VerticalAlignment="Center" Width="150"/>
  <Button Content="OK" IsDefault="True" Margin="5" Name="button1" VerticalAlignment="Center"/>
</StackPanel>
"@
# TODO: origin link
<#
[xml]$example = @"
<?xml version="1.0"?>
<!-- need to strip away all event handling element attributes like SelectionChanged="ComboBox_SelectionChanged" -->
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
  <ComboBox Name="comboBox" IsEditable="True" Margin="5">
    <ComboBoxItem Content="ComboBox Item 1"/>
    <ComboBoxItem Content="ComboBox Item 2"/>
    <ComboBoxItem Content="ComboBox Item 3" IsSelected="True"/>
    <ComboBoxItem Content="ComboBox Item 4"/>
    <ComboBoxItem Content="ComboBox Item 5"/>
  </ComboBox>
  <Button Content="Get Selected" Margin="5" Width="100"/>
</StackPanel>
"@
#>
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/RadioButtonGroups.htm

[xml]$example = @"
<?xml version="1.0"?>
<!-- need to strip away all event handling element attributes like SelectionChanged="ComboBox_SelectionChanged" -->
<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
  <GroupBox Margin="5">
    <StackPanel>
      <RadioButton>Group 1</RadioButton>
      <RadioButton>Group 1</RadioButton>
      <RadioButton>Group 1</RadioButton>
      <RadioButton Margin="0,10,0,0" GroupName="Group2">Group 2</RadioButton>
    </StackPanel>
  </GroupBox>
  <GroupBox Margin="5">
    <StackPanel>
      <RadioButton>Group 3</RadioButton>
      <RadioButton>Group 3</RadioButton>
      <RadioButton>Group 3</RadioButton>
      <RadioButton Margin="0,10,0,0" GroupName="Group2">Group 2</RadioButton>
    </StackPanel>
  </GroupBox>
</StackPanel>
"@

# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/UseStackPaneltoHoldRadioButtons.htm
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/RadioButtonclickevent.htm
[xml]$example = @"
<?xml version="1.0"?>
<!-- need to strip away all event handling element attributes like SelectionChanged="ComboBox_SelectionChanged" -->
<Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
  <Grid.ColumnDefinitions>
    <ColumnDefinition Width="50*"/>
    <ColumnDefinition Width="50*"/>
  </Grid.ColumnDefinitions>
  <StackPanel Grid.Column="0" Margin="2">
    <RadioButton Content="b1" Margin="5">RadioButton</RadioButton>
    <RadioButton Content="Two" Margin="5">RadioButton</RadioButton>
    <RadioButton Content="Two" Margin="5">RadioButton</RadioButton>
    <RadioButton Margin="5">RadioButton</RadioButton>
  </StackPanel>
  <StackPanel Grid.Column="1" Margin="2">
    <RadioButton Margin="5">RadioButton</RadioButton>
    <RadioButton Margin="5">RadioButton</RadioButton>
    <RadioButton Margin="5">RadioButton</RadioButton>
    <RadioButton Margin="5">RadioButton</RadioButton>
  </StackPanel>
</Grid>
"@

# Clear-Host

$layout_reader = (New-Object System.Xml.XmlNodeReader $xaml)
$target = [Windows.Markup.XamlReader]::Load($layout_reader)
$LayoutRoot = $target.FindName("LayoutRoot")
$LayoutRoot.add_Loaded.Invoke({

    $example_reader = (New-Object System.Xml.XmlNodeReader $example)
    $example_target = [Windows.Markup.XamlReader]::Load($example_reader)
    $LayoutRoot.Children.Add($example_target)
  })
$target.ShowDialog() | Out-Null

<# 
Exception calling "ShowDialog" with "0" argument(s): "Not enough quota is
available to process this command"
#>
