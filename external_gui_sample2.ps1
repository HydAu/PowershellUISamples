function DecodeDigitalPID($digitalProductId)
{
	$decryptionLength = 14
	$cryptedStringLength = 24
	$base24 = 'BCDFGHJKMPQRTVWXY2346789'
	$decryptedKey = [System.String]::Empty

	$containsN = ($digitalProductId[$decryptionLength] -shr 3) -bAnd 1
	$digitalProductId[$decryptionLength] = [System.Byte]($digitalProductId[$decryptionLength] -bAnd 0xF7) ## 247
	for ($i = $cryptedStringLength; $i -ge 0; $i--)
	{
			$digitMapIndex = 0
			for ($j = $decryptionLength; $j -ge 0; $j--)
			{
					$digitMapIndex = [System.UInt16]($digitMapIndex -shl 8 -bXor $digitalProductId[$j])
					$digitalProductId[$j] = [System.Byte][System.Math]::Floor($digitMapIndex / $base24.Length)
					$digitMapIndex = [System.UInt16]($digitMapIndex % $base24.Length)
			}
			$decryptedKey = $decryptedKey.Insert(0, $base24[$digitMapIndex])
	}
	if ([System.Boolean]$containsN)
	{
			$firstCharIndex = 0
			for ($index = 0; $index -lt $cryptedStringLength; $index++)
			{
					if ($decryptedKey[0] -ne $base24[$index]) { continue }
					$firstCharIndex = $index
					break
			}
			$decryptedKey = $decryptedKey.Remove(0, 1)
			$decryptedKey = $decryptedKey.Insert($firstCharIndex,'N')
	}
	for ($t = 20; $t -ge 5; $t -= 5) { $decryptedKey = $decryptedKey.Insert($t, '-') }
	return $decryptedKey
} ## DecodeDigitalPID


Function Get-WindowsProduct
{
Add-Type -AssemblyName PresentationFramework        
[xml]$xaml_prototype = @"
<?xml version="1.0" encoding="UTF-8"?>
<!-- XAML Code - Imported from Visual Studio Express WPF Application -->
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" ResizeMode="NoResize" WindowStyle="None" Background="#FFF0F0F0" WindowStartupLocation="CenterScreen" SizeToContent="Width" Height="210" Title="OS Details" FontSize="14">
  <Grid Margin="0,0,0,0">
    <Label Width="380" Height="30" Margin="0,0,0,0" VerticalAlignment="Top" HorizontalAlignment="Center" HorizontalContentAlignment="Center" Content="Operating System Details" FontWeight="Bold" Name="mainLabel"/>
    <Button Width="30" Height="30" Margin="350,0,0,0" VerticalAlignment="Top" HorizontalAlignment="Left" Name="btnExit" BorderThickness="0" Foreground="White" Background="#FFC35A50" FontWeight="Bold" FontSize="20" Content="X" Cursor="Hand" ToolTip="Close Window"/>
    <Label Margin="0,35,0,0" Content="Version" Name="lblVersion"/>
    <Label Margin="0,70,0,0" Content="Edition" Name="lblEdition"/>
    <Label Margin="0,105,0,0" Content="Type" Name="lblType"/>
    <Label Margin="0,140,0,0" Content="Product ID" Name="lblProductID"/>
    <Label Margin="0,175,0,0" Content="Product Key" Name="lblProductKey"/>
    <TextBox Margin="115,35,0,0" Name="txtVersion"/>
    <TextBox Margin="115,70,0,0" Name="txtEdition"/>
    <TextBox Margin="115,105,0,0" Name="txtType"/>
    <TextBox Margin="115,140,0,0" Name="txtProductID"/>
    <TextBox Margin="115,175,0,0" Name="txtProductKey"/>
  </Grid>
</Window>
"@ 

$syncHash = [Hashtable]::Synchronized(@{})
$newRunspace = [RunspaceFactory]::CreateRunspace()
$newRunspace.ApartmentState,$newRunspace.ThreadOptions = "STA","ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
$syncHash.xaml = $xaml_prototype
$syncHash.Data = @()

## Getting values
$regPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion'
$binArray = $(Get-ItemProperty -Path $regPath).DigitalProductId[52..66]
$x64 = [System.Environment]::Is64BitOperatingSystem

$syncHash.Data += [System.Environment]::OSVersion.VersionString
$syncHash.Data += $(Get-ItemProperty -Path $regPath).EditionID
$syncHash.Data += switch ($x64) { $true {'x86-64'}; $false {'x86-32'}}
$syncHash.Data += $(Get-ItemProperty -Path $regPath).ProductId
$syncHash.Data += DecodeDigitalPID($binArray)

# create a script object 
$psCmd = [PowerShell]::Create().AddScript({ 
  
## Read XAML
$reader = New-Object -TypeName 'System.Xml.XmlNodeReader' -ArgumentList $syncHash.xaml

$Form = [Windows.Markup.XamlReader]::Load($reader)
## Store Form Objects In PowerShell
$labels = $txtblks = @()
$syncHash.xaml.SelectNodes("//*[@Name]") | ForEach-Object -Process {
	$element = $Form.FindName($_.Name)
	switch -Regex ($_.Name)		{
		'lbl*'      { $labels  += $element }
		'txt*'      { $txtblks += $element }
		'btnExit'   { $btnExit  = $element }
		'mainLabel' { $lblMain  = $element }
	}
}
## add an event handler to allow the window to be dragged using the left mouse button
$eventHandler_LeftButtonDown = [Windows.Input.MouseButtonEventHandler]{ $Form.DragMove() }
$lblMain.add_MouseLeftButtonDown($eventHandler_LeftButtonDown)
## Paint elements with color
$color_shading = {
	$txtblks | ForEach-Object -Process { $_.Background = '#FFFFECA8' }
	$labels  | ForEach-Object -Process { $_.Background = '#FF98D6EB' }
	$lblMain.Background = '#FF168DE2'
}
## Paint elements with monochrome
$monochrome_shading = {
	$txtblks | ForEach-Object -Process { $_.Background = '#FFECECEC' }
	$labels  | ForEach-Object -Process { $_.Background = '#FFC4C4C4' }
	$lblMain.Background = '#FF6F6F6F'
}

## Add events to Form Objects
$btnExit.add_Click({ $Form.Close() })
## Make the mouse act like something is happening
$btnExit.add_MouseEnter({ & $monochrome_shading })
## Switch back to regular mouse
$btnExit.add_MouseLeave({ & $color_shading })
## Initialize form
for ($i = 0; $i -lt $txtblks.Count; $i++){
	$tb = $txtblks[$i]
	$lb = $labels[$i]

	$tb.IsReadOnly = $true
	$tb.Text = $syncHash.Data[$i]
	$tb.Width,$lb.Width = 260,110
	$tb.Height = $lb.Height = 30
	$tb.TextWrapping = [System.Windows.TextWrapping]::Wrap
	@($tb,$lb) | ForEach-Object -Process {
		$_.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
		$_.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
	}
}
## Initially display Form in color
& $color_shading 
## Shows the form
[void]$Form.ShowDialog()
})

$psCmd.Runspace = $newRunspace
[void]$psCmd.BeginInvoke()

}

Get-WindowsProduct
