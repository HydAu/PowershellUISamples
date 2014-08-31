# http://learn-powershell.net/2012/10/14/powershell-and-wpf-writing-data-to-a-ui-from-a-different-runspace/
# http://stackoverflow.com/questions/23142137/write-powershell-output-as-it-happens-to-wpf-ui-control?rq=1
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase


$uiHash = [hashtable]::Synchronized(@{})
$newRunspace = [runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable('uiHash',$uiHash)

$psCmd = [powershell]::Create().AddScript({
    [xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" Title="Patcher" Height="350" Width="525" Topmost="True">
    <Grid>
        <Label Content="A Builds" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="88" RenderTransformOrigin="0.191,0.566"/>
        <ListBox HorizontalAlignment="Left" Height="269" Margin="10,41,0,0" VerticalAlignment="Top" Width="88"/>
        <Label Content="New Build" HorizontalAlignment="Left" Margin="387,10,0,0" VerticalAlignment="Top"/>
        <TextBox HorizontalAlignment="Left" Height="23" Margin="387,41,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label Content="B Builds" HorizontalAlignment="Left" Margin="117,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.528,-0.672"/>
        <ListBox HorizontalAlignment="Left" Height="269" Margin="103,41,0,0" VerticalAlignment="Top" Width="88"/>
        <Label Content="C Builds" HorizontalAlignment="Left" Margin="185,10,0,0" VerticalAlignment="Top"/>
        <ListBox HorizontalAlignment="Left" Height="269" Margin="196,41,0,0" VerticalAlignment="Top" Width="88"/>
        <Button x:Name="PatchButton" Content="Patch!" HorizontalAlignment="Left" Margin="426,268,0,0" VerticalAlignment="Top" Width="75"/>
        <RichTextBox x:Name="OutputTextBox" HorizontalAlignment="Left" Height="194" Margin="289,69,0,0" VerticalAlignment="Top" Width="218">
            <FlowDocument>
                <Paragraph>
                    <Run Text=""/>
                </Paragraph>
            </FlowDocument>
        </RichTextBox>

    </Grid>
</Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $uiHash.Window = [Windows.Markup.XamlReader]::Load($reader)

    $uiHash.Button = $uiHash.Window.FindName("PatchButton")
    $uiHash.OutputTextBox = $uiHash.Window.FindName("OutputTextBox")

    $uiHash.OutputTextBox.Dispatcher.Invoke("Render",[Windows.Input.InputEventHandler]{ $uiHash.OutputTextBox.UpdateLayout() },$null,$null)

    $uiHash.Window.ShowDialog() | Out-Null
  })
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()

# The next line fails (null-valued expression)
<#
$uiHash.OutputTextBox.Dispatcher.Invoke("Normal", [action]{
    for ($i = 0; $i -lt 10000; $++) {
        $uiHash.OutputTextBox.AppendText("hi")
    }
})#>
