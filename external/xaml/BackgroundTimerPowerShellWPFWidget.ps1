# origin http://www.nivot.org/blog/post/2008/05/23/BackgroundTimerPowerShellWPFWidget
#requires -version 2
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<?xml version="1.0"?>
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:system="clr-namespace:System;assembly=mscorlib" WindowStyle="None" AllowsTransparency="True" Topmost="True" Background="Transparent" ShowInTaskbar="False" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterOwner">
  <Window.Resources>
    <system:String x:Key="Time">12:34.56</system:String>
  </Window.Resources>
  <Grid Height="2.2in">
    <Grid.ColumnDefinitions>
      <ColumnDefinition/>
    </Grid.ColumnDefinitions>
    <Label Name="ClockLabel" Grid.Column="2" Opacity="0.7" Content="{DynamicResource Time}" FontFamily="Impact, Arial" FontWeight="800" FontSize="2in">
      <Label.Foreground>
        <LinearGradientBrush>
          <GradientStop Color="#CC064A82" Offset="1"/>
          <GradientStop Color="#FF6797BF" Offset="0.8"/>
          <GradientStop Color="#FF6797BF" Offset="0.4"/>
          <GradientStop Color="#FFD4DBE1" Offset="0"/>
        </LinearGradientBrush>
      </Label.Foreground>
    </Label>
  </Grid>
</Window>
"@
    param([string]$scriptName)  
     
    # original script James Brundage (blogs.msdn.com/powershell)  
     
    $rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()  
    $rs.ApartmentState, $rs.ThreadOptions = “STA”, “ReuseThread”  
    $rs.Open()  
     
    # Reference the WPF assemblies  
    $psCmd = {Add-Type}.GetPowerShell()  
    $psCmd.SetRunspace($rs)  
    $psCmd.AddParameter("AssemblyName", "PresentationCore").Invoke()  
    $psCmd.Command.Clear()  
     
    $psCmd = $psCmd.AddCommand("Add-Type")  
    $psCmd.AddParameter("AssemblyName", "PresentationFramework").Invoke()  
    $psCmd.Command.Clear()  
     
    $psCmd = $psCmd.AddCommand("Add-Type")  
    $psCmd.AddParameter("AssemblyName", "WindowsBase").Invoke()  
     
    $sb = $executionContext.InvokeCommand.NewScriptBlock(  
        (Join-Path $pwd $scriptname)  
    )  
     
    $psCmd = $sb.GetPowerShell()  
    $psCmd.SetRunspace($rs)  
    $null = $psCmd.BeginInvoke()   


    param (  
        [timespan]$period = (New-Object system.TimeSpan(0,5,0)),  
        $clockxaml="<path to xaml file>\clock.xaml" 
    )  
     
    ### Import the WPF assemblies  
    Add-Type -Assembly PresentationFramework  
    Add-Type -Assembly PresentationCore  
     
    $clock = [Windows.Markup.XamlReader]::Load(   
             (New-Object System.Xml.XmlNodeReader (  
                [Xml](Get-Content $clockxaml) ) ) )  
     
    $then = [datetime]::Now  
     
    $red = [System.Windows.Media.Color]::FromRgb(255,0,0)  
    $redbrush = new-object system.windows.media.solidcolorbrush $red 
    $label = $clock.FindName("ClockLabel")  
    $done = $false 
     
    # Create a script block which will update the UI  
    $updateBlock = {     
       if (!$done) {  
            # update the clock  
            $elapsed = ([datetime]::Now - $then)  
            $remaining = $null;  
              
            if ($elapsed -lt $period) {  
                $remaining = ($period - $elapsed).ToString().substring(0,8)  
            } else {  
                $label.Foreground = $redbrush         
                $remaining = "00:00:00" 
                $done = $true 
            }         
            $clock.Resources["Time"] = $remaining 
       }  
    }  
     
    ## Hook up some event handlers   
    $clock.Add_SourceInitialized( {  
       ## Before the window's even displayed ...  
       ## We'll create a timer  
       $timer = new-object System.Windows.Threading.DispatcherTimer  
       ## Which will fire 2 times every second  
       $timer.Interval = [TimeSpan]"0:0:0.50" 
       ## And will invoke the $updateBlock  
       $timer.Add_Tick( $updateBlock )  
       ## Now start the timer running  
       $timer.Start()  
       if(! $timer.IsEnabled ) {  
          $clock.Close()  
       }  
    } )  
     
    $clock.Add_MouseLeftButtonDown( {   
       $_.Handled = $true 
       $clock.DragMove() # WPF Magic!  
    } )  
     
    $clock.Add_MouseRightButtonDown( {   
       $_.Handled = $true 
       $timer.Stop()  # we'd like to stop that timer now, thanks.  
       $clock.Close() # and close the windows  
    } )  
     
    ## Lets go ahead and invoke that update block   
    &$updateBlock 
    ## And then show the window  
    $clock.ShowDialog()   
