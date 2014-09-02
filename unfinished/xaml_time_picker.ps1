Add-Type -AssemblyName PresentationFramework
# WPF 4.0 doesn't provide a DateTimePicker out of the box. 
# Add-Type -AssemblyName System.Windows.Controls.Toolkit
# Add-Type -AssemblyName System.Windows.Controls
[xml]$xaml =
@"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:toolkit="http://schemas.microsoft.com/winfx/2006/xaml/presentation/toolkit" Title="DatePicker Background Sample" Height="80" Width="150">
  <Grid VerticalAlignment="Center">
<!-- x:Class="DateTimeTest.TimeControl"  -->
<UserControl Height="Auto" Width="Auto" x:Name="UserControl">
  <Grid x:Name="LayoutRoot" Width="Auto" Height="Auto">
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="0.2*"/>
      <ColumnDefinition Width="0.05*"/>
      <ColumnDefinition Width="0.2*"/>
      <ColumnDefinition Width="0.05*"/>
      <ColumnDefinition Width="0.2*"/>
    </Grid.ColumnDefinitions>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'KeyDown' from the text 'Down'."
    <Grid x:Name="hour" Focusable="True" KeyDown="Down">
-->

   <Grid x:Name="hour" Focusable="True">
      <TextBlock x:Name="mmTxt" TextWrapping="Wrap" Text="{Binding Path=Hours, ElementName=UserControl, Mode=Default}" TextAlignment="Center" VerticalAlignment="Center" FontFamily="Goudy Stout" FontSize="14"/>
    </Grid>
    <Grid Grid.Column="1">
      <TextBlock x:Name="sep1" TextWrapping="Wrap" VerticalAlignment="Center" Background="{x:Null}" FontFamily="Goudy Stout" FontSize="14" Text=":" TextAlignment="Center"/>
    </Grid>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'KeyDown' from the text 'Down'."
       <Grid Grid.Column="2" x:Name="min" Focusable="True" KeyDown="Down">
-->
    <Grid Grid.Column="2" x:Name="min" Focusable="True">
      <TextBlock x:Name="ddTxt" TextWrapping="Wrap" Text="{Binding Path=Minutes, ElementName=UserControl, Mode=Default}" TextAlignment="Center" VerticalAlignment="Center" FontFamily="Goudy Stout" FontSize="14"/>
    </Grid>
    <Grid Grid.Column="3">
      <TextBlock x:Name="sep2" TextWrapping="Wrap" VerticalAlignment="Center" Background="{x:Null}" FontFamily="Goudy Stout" FontSize="14" Text=":" TextAlignment="Center"/>
    </Grid>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'KeyDown' from the text 'Down'."
    <Grid Grid.Column="4" Name="sec" Focusable="True" KeyDown="Down">
-->

    <Grid Grid.Column="4" Name="sec" Focusable="True">
      <TextBlock x:Name="yyTxt" TextWrapping="Wrap" Text="{Binding Path=Seconds, ElementName=UserControl, Mode=Default}" TextAlignment="Center" VerticalAlignment="Center" FontFamily="Goudy Stout" FontSize="14"/>
    </Grid>
  </Grid>
</UserControl>
 </Grid>
</Window>
"@
# http://msdn.microsoft.com/en-us/library/windows/apps/xaml/dn308514.aspx
# 
[xml]$xaml =@"
<?xml version="1.0"?>
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:System="clr-namespace:System;assembly=mscorlib"

	x:Name="Window"
	Title="MainWindow"
>
<!-- Exception calling "Load" with "1" argument(s): "Failed to create a 'Loaded' from the text 'Window_Loaded'." 
dropping the attribute temporarily:
 Loaded="Window_Loaded"

Also removed offensive attributes 
	Width="640" Height="480" AllowsTransparency="True" WindowStyle="None" Background="{x:Null}"
-->
	<Window.Resources>
		<Storyboard x:Key="OnGotFocus1"/>
		<Style x:Key="ButtonFocusVisual">
			<Setter Property="Control.Template">
				<Setter.Value>
					<ControlTemplate>
						<Rectangle Margin="2" SnapsToDevicePixels="true" Stroke="{DynamicResource {x:Static SystemColors.ControlTextBrushKey}}" StrokeThickness="1" StrokeDashArray="1 2"/>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		<LinearGradientBrush x:Key="ButtonNormalBackground" EndPoint="0,1" StartPoint="0,0">
			<GradientStop Color="#F3F3F3" Offset="0"/>
			<GradientStop Color="#EBEBEB" Offset="0.5"/>
			<GradientStop Color="#DDDDDD" Offset="0.5"/>
			<GradientStop Color="#CDCDCD" Offset="1"/>
		</LinearGradientBrush>
		<SolidColorBrush x:Key="ButtonNormalBorder" Color="#FF707070"/>
		<Style x:Key="ButtonStyle1" TargetType="{x:Type Button}">
			<Setter Property="FocusVisualStyle" Value="{StaticResource ButtonFocusVisual}"/>
			<Setter Property="Background" Value="{StaticResource ButtonNormalBackground}"/>
			<Setter Property="BorderBrush" Value="{StaticResource ButtonNormalBorder}"/>
			<Setter Property="BorderThickness" Value="1"/>
			<Setter Property="Foreground" Value="{DynamicResource {x:Static SystemColors.ControlTextBrushKey}}"/>
			<Setter Property="HorizontalContentAlignment" Value="Center"/>
			<Setter Property="VerticalContentAlignment" Value="Center"/>
			<Setter Property="Padding" Value="1"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Grid x:Name="grid">
							<ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" Margin="{TemplateBinding Padding}" RecognizesAccessKey="True" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
						</Grid>
						<ControlTemplate.Triggers>
							<Trigger Property="IsFocused" Value="True">
								<Setter Property="Background" TargetName="grid" Value="#FF7C7A7A"/>
							</Trigger>
							<Trigger Property="IsKeyboardFocused" Value="true"/>
							<Trigger Property="ToggleButton.IsChecked" Value="true"/>
							<Trigger Property="IsEnabled" Value="false">
								<Setter Property="Foreground" Value="#ADADAD"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		<Style x:Key="ToggleButtonStyle1" TargetType="{x:Type ToggleButton}">
			<Setter Property="FocusVisualStyle" Value="{StaticResource ButtonFocusVisual}"/>
			<Setter Property="Background" Value="{StaticResource ButtonNormalBackground}"/>
			<Setter Property="BorderBrush" Value="{StaticResource ButtonNormalBorder}"/>
			<Setter Property="BorderThickness" Value="1"/>
			<Setter Property="Foreground" Value="{DynamicResource {x:Static SystemColors.ControlTextBrushKey}}"/>
			<Setter Property="HorizontalContentAlignment" Value="Center"/>
			<Setter Property="VerticalContentAlignment" Value="Center"/>
			<Setter Property="Padding" Value="1"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ToggleButton}">
						<Grid x:Name="grid">
							<ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" Margin="{TemplateBinding Padding}" RecognizesAccessKey="True" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
						</Grid>
						<ControlTemplate.Triggers>
							<Trigger Property="IsChecked" Value="true">
								<Setter Property="Background" TargetName="grid" Value="#FF919191"/>
							</Trigger>
							<Trigger Property="IsEnabled" Value="false">
								<Setter Property="Foreground" Value="#ADADAD"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		<Storyboard x:Key="OnClick1">
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="HrBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>True</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="MinBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="SecBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="AmPmBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
		</Storyboard>
		<Storyboard x:Key="OnClick2">
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="MinBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>True</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="HrBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="SecBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="AmPmBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
		</Storyboard>
		<Storyboard x:Key="OnClick3">
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="SecBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>True</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="MinBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="HrBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="AmPmBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
		</Storyboard>
		<Storyboard x:Key="OnClick4">
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="AmPmBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>True</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="HrBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="MinBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
			<ObjectAnimationUsingKeyFrames Storyboard.TargetProperty="(ToggleButton.IsChecked)" Storyboard.TargetName="SecBtn">
				<DiscreteObjectKeyFrame KeyTime="0">
					<DiscreteObjectKeyFrame.Value>
						<System:Boolean>False</System:Boolean>
					</DiscreteObjectKeyFrame.Value>
				</DiscreteObjectKeyFrame>
			</ObjectAnimationUsingKeyFrames>
		</Storyboard>
	</Window.Resources>
	<Window.Triggers>
		<EventTrigger RoutedEvent="ButtonBase.Click" SourceName="HrBtn">
			<BeginStoryboard x:Name="OnClick1_BeginStoryboard" Storyboard="{StaticResource OnClick1}"/>
		</EventTrigger>
		<EventTrigger RoutedEvent="ButtonBase.Click" SourceName="SecBtn">
			<BeginStoryboard x:Name="OnClick3_BeginStoryboard" Storyboard="{StaticResource OnClick3}"/>
		</EventTrigger>
		<EventTrigger RoutedEvent="ButtonBase.Click" SourceName="MinBtn">
			<BeginStoryboard x:Name="OnClick2_BeginStoryboard" Storyboard="{StaticResource OnClick2}"/>
		</EventTrigger>
		<EventTrigger RoutedEvent="ButtonBase.Click" SourceName="AmPmBtn">
			<BeginStoryboard x:Name="OnClick4_BeginStoryboard" Storyboard="{StaticResource OnClick4}"/>
		</EventTrigger>
	</Window.Triggers>

	<Grid x:Name="LayoutRoot" Background="Black">
		<Grid Margin="0" HorizontalAlignment="Center" Background="Black" VerticalAlignment="Center">
			<StackPanel Orientation="Horizontal">
				<ToggleButton x:Name="HrBtn" Width="50.5" Height="40" Style="{DynamicResource ToggleButtonStyle1}">
					<TextBlock x:Name="HrTxt" TextWrapping="Wrap" Text="12" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="29.333" Foreground="White"/>
				</ToggleButton>
				<TextBlock TextWrapping="Wrap" Text=":" Foreground="White" FontSize="29.333" HorizontalAlignment="Center" FontFamily="Segoe Condensed" Margin="0,5,0,0"/>
				<ToggleButton x:Name="MinBtn" Width="50.5" Height="40" Style="{DynamicResource ToggleButtonStyle1}" VerticalAlignment="Bottom">
					<TextBlock x:Name="MinTxt" TextWrapping="Wrap" Text="00" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="29.333" Foreground="White"/>
				</ToggleButton>
				<TextBlock TextWrapping="Wrap" Text=":" Foreground="White" FontSize="29.333" HorizontalAlignment="Center" FontFamily="Segoe Condensed" Margin="0,5,0,0"/>
				<ToggleButton x:Name="SecBtn" Width="50.5" Height="40" Style="{DynamicResource ToggleButtonStyle1}">
					<TextBlock x:Name="SecTxt" TextWrapping="Wrap" Text="00" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="29.333" Foreground="White"/>
				</ToggleButton>
				<ToggleButton x:Name="AmPmBtn" Width="50.5" Height="40" Style="{DynamicResource ToggleButtonStyle1}">
					<TextBlock x:Name="AmPmTxt" TextWrapping="Wrap" Text="AM" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="29.333" Foreground="White"/>
				</ToggleButton>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'Click' from the text 'Button_Click'.
removed attribute 
" Click="Button_Click"  -->
				<Button x:Name="upBtn" Content="up" Width="24.5" Margin="0,8,0,0"/>
<!-- 
Exception calling "Load" with "1" argument(s): "Failed to create a 'Click' from the text 'Button_Click'.
removed attribute 
Click="btn2_Click"  -->
				<Button x:Name="downBtn" Content="down" Width="36" Margin="0,8,0,0" />
			</StackPanel>
		</Grid>
		<TextBlock x:Name="time" TextWrapping="Wrap" Text="TextBlock" VerticalAlignment="Bottom" Margin="177,0,76.167,98.04" Height="55.96" FontSize="29.333" Foreground="White"/>
	</Grid>
</Window>
"@
# Clear-Host
$result = $null
$reader = (New-Object System.Xml.XmlNodeReader $xaml)

$target = [Windows.Markup.XamlReader]::Load($reader)

$control = $target.FindName('Window')
$Window_Loaded_Method = $control.Add_Loaded 

$Window_Loaded_Handler = {
  param(
    [object]$sender,
    [System.Windows.RoutedEventArgs]$e)

    # $result =  $sender.SelectedDate.ToString()
    # time.Text = DateTime.Now.ToLongTimeString();
}
$Window_Loaded_Method.Invoke($Window_Loaded_Handler )

$control = $target.FindName('upBtn')

$Button_Click_Method = $control.Add_Click 

$Button_Click_Handler = {
  param(
    [object]$sender,
    [System.Windows.RoutedEventArgs]$e 
   )
  #  $result =  $sender.SelectedDate.ToString()
}
$Button_Click_Method.Invoke($Button_Click_Handler )

control = $target.FindName('downBtn')

$btn2_ClicK_Method = $control.Add_Click 

$btn2_Click_Handler = {
  param(
    [object]$sender,
    [System.Windows.RoutedEventArgs]$e 
   )
  #  $result =  $sender.SelectedDate.ToString()
}
$btn2_ClicK_Method.Invoke($btn2_Click_Handler )
<# 
$eventMethod = $control.Add_SelectedDateChanged 

$handler = {
  param(
    [object]$sender,
    [System.Windows.Controls.SelectionChangedEventArgs]$e)
    $result =  $sender.SelectedDate.ToString()
}
$eventMethod.Invoke($handler )
#> 

$target.ShowDialog()  
# | Out-Null
# NOTE _MouseWheel_(object sender, MouseWheelEventArgs e)
write-output $result

<#
NOTE: 
occasional
  Exception calling "ShowDialog" with "0" argument(s):
 "Not enough quota is available to process this command"
#>
