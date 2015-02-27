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


function Get-Runspace {
param(
[string]$ScriptPath
)

  if ($runspaceCreated -or [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.apartmentstate -eq "STA")  {
    Write-Debug "No new runspace was created"
    return
  }
  if ($PSBoundParameters.ContainsKey('ScriptPath'))  {
    $ScriptPath = Resolve-Path $ScriptPath
  }
  elseif ($host.version.major -ge 3)

  {
    $ScriptPath = $MyInvocation.PSCommandPath
  }

  else

  {

    $ScriptPath = Resolve-Path (Get-PSCallStack)[-2].InvocationInfo.InvocationName

  }



  Write-Debug "Script path: $ScriptPath"
  Write-Debug "Creating a new STA runspace ..."
  # Create a new runspace

  $rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($Host)
  $rs.apartmentstate = "STA"
  $rs.ThreadOptions = ?ReuseThread?
  $rs.Open()
  $rs.SessionStateProxy.SetVariable("runspaceCreated",$true)
  $rs.SessionStateProxy.SetVariable("debugPreference",$debugPreference)
  # Rerun the script in the new apartment
  $psCmd = [System.Management.Automation.PowerShell]::Create()
  $psCmd.Runspace = $rs
  Write-Debug "Rerunning $ScriptPath"
  [void]$psCmd.AddCommand("Set-Location")
  [void]$pscmd.AddParameter("Path",(Get-Location).Path)
  [void]$psCmd.AddScript($ScriptPath)
  [void]$psCmd.Invoke()
  $rs.Close()
  exit
}



$verificationErrors = New-Object System.Text.StringBuilder
Add-Type -AssemblyName 'PresentationFramework'
Add-Type -AssemblyName 'PresentationCore'
#Add-Type -AssemblyName 'WindowsBase'


# requires -version 2
# origin: http://www.codeproject.com/Articles/68748/TreeTabControl-A-Tree-of-Tab-Items

[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Window1" Margin="5,5,5,5" Height="310" Width="420">
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
  'nunit.framework.dll'
)
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
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
# http://learn-powershell.net/2015/02/15/dealing-with-variables-in-a-winform-event-handler-an-alternative-to-script-scope/
# http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/DisplayaPasswordEntryBoxandgettheinput.htm
# https://msdn.microsoft.com/en-us/library/system.windows.controls.passwordbox_events%28v=vs.110%29.aspx
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
[xml]$example = @"
<?xml version="1.0"?>
    <StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Height="400" Width="300">
        <Slider Minimum="0" Maximum="10" Name="sliderDrop" Value="14"/>
        <TextBox Text="{Binding ElementName=sliderDrop, Path=Value}"/>
    </StackPanel>
"@
# http://www.techques.com/question/1-408646/How-to-make-two-images-overlapping-with-WPF?
# https://msdn.microsoft.com/en-us/library/system.windows.controls.image%28v=vs.110%29.aspx
# http://stackoverflow.com/questions/1394297/generate-transparent-png-c-sharp
#// https://www.google.com/search?q=png+image+with+transparent+background&client=ubuntu&hs=yKp&channel=fs&tbm=isch&imgil=FbKw4dB_sLPEnM%253A%253BweoXd3QGdajWMM%253Bhttp%25253A%25252F%25252Fcommons.wikimedia.org%25252Fwiki%25252FFile%25253AGluecksklee_(transparent_background).png&source=iu&pf=m&fir=FbKw4dB_sLPEnM%253A%252CweoXd3QGdajWMM%252C_&usg=__VBVhCNnxSJcmBt1KaTKexgs36b0%3D
#// http://upload.wikimedia.org/wikipedia/commons/b/bc/Gluecksklee_%28transparent_background%29.png
#// http://farm1.static.flickr.com/2/1703693_687c42c89f_s.jpg
#// http://l.yimg.com/g/images/flickr_logo_gamma.gif.v59899.14
#// http://ataulswebdesigns.com/wp-content/uploads/2014/11/PNG-Transparency-in-IE6-with-GIMP.jpg

[xml]$example = @"
<?xml version="1.0"?>
<WrapPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <Grid>
        <Border BorderBrush="Gray" BorderThickness="1" Margin="3">
            <Border BorderBrush="White" BorderThickness="3">
                <Border BorderBrush="LightGray" BorderThickness="0.5">
                    <Image Source="http://upload.wikimedia.org/wikipedia/commons/b/bc/Gluecksklee_%28transparent_background%29.png" Stretch="Uniform" />
                </Border>
            </Border>
        </Border>
<Canvas Width="80" Height="80" VerticalAlignment="Bottom">
        <Image Margin="5" HorizontalAlignment="Right" VerticalAlignment="Center" Source="http://upload.wikimedia.org/wikipedia/commons/3/38/Brown_Trapdoor_Spider,_transparent_background.png" Height="80" />
</Canvas>
    </Grid>
</WrapPanel>

"@
Clear-Host

$check_for_apartment = $true
if ($check_for_apartment -and [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.apartmentstate -ne 'STA'){
  throw "This script must be run in a single threaded apartment.`r`nStart PowerShell with the -STA flag and rerun the script."

  exit
<#

W2K3:
Exception calling "Load" with "1" argument(s): 
"The invocation of the constructor on type 'System.Windows.Window' that matches the specified 
binding constraints threw an exception."

#>

}




$nsmgr = New-Object system.xml.xmlnamespacemanager ($xaml.nametable)
$nsmgr.AddNamespace("x",$xaml.DocumentElement.x)
$xaml.window.RemoveAttribute('x:Class')

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

<#

http://stackoverflow.com/questions/388677/can-you-make-an-alpha-transparent-png-with-c

Font f = GetSystemConfiguredFont();
//this sets the text to be rotated 90deg clockwise (i.e. down)
StringFormat stringFormat = new StringFormat { FormatFlags = StringFormatFlags.DirectionVertical };

SizeF size;
// creates 1Kx1K image buffer and uses it to find out how bit the image needs to be to fit the text
using ( Image imageg = (Image) new Bitmap( 1000, 1000 ) )
    size = Graphics.FromImage( imageg ).
    	MeasureString( text, f, 25, stringFormat );

using ( Bitmap image = new Bitmap( (int) size.Width, (int) size.Height ) )
{
    Graphics g = Graphics.FromImage( (Image) image );
    g.FillRectangle( Brushes.White, 0f, 0f, image.Width, image.Height );
    g.TranslateTransform( image.Width, image.Height );
    g.RotateTransform( 180.0F ); //note that we need the rotation as the default is down

    // draw text
    g.DrawString( text, f, Brushes.Black, 0f, 0f, stringFormat );

    //make be background transparent - this will be an index (rather than an alpha) transparency
    image.MakeTransparent( Color.White );

    //note that this image has to be a PNG, as GDI+'s gif handling renders any transparency as black.
    context.Response.AddHeader( "ContentType", "image/png" );
    using ( MemoryStream memStream = new MemoryStream() )
    {
    	image.Save( memStream, ImageFormat.Png );
    	memStream.WriteTo( context.Response.OutputStream );
    }
}
var timer = new DispatcherTimer();
timer.Interval = TimeSpan.FromSeconds(1);
timer.Start();
timer.Tick += (s,e) =>
{
  myImage.Source = // next image in sequence
}
http://stackoverflow.com/questions/14336597/adding-image-objects-to-wpf-with-code
http://www.java2s.com/Code/CSharp/Windows-Presentation-Foundation/CanvaswithoutViewbox.htm
#>