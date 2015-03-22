# http://poshcode.org/5730
# Plik: 4_Demo_v3_Reflection.ps1
#requires -version 3

# this script uses type accelerators to shorten the progam
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/07/08/use-powershell-to-find-powershell-type-accelerators.aspx
# connect.microsoft.com/PowerShell/feedback/details/721443/system-management-automation-typeaccelerators-broken-in-v3-ctp2
$ta = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

Add-Type -AssemblyName 'PresentationCore','PresentationFramework' -PassThru |
Where-Object IsPublic |
ForEach-Object {
  $Class = $_
  try {
    $ta::Add($Class.Name,$Class)
  } catch {
    "Failed to add $($Class.Name) accelerator pointing to $($Class.FullName)"
  }
}

[window]@{
  Width = 400
  Height = 150
  WindowStyle = 'None'
  AllowsTransparency = $true
  Effect = [dropshadoweffect]@{
    BlurRadius = 10
  }
  TopMost = $true
  Content = & {
    $Stos = [stackpanel]@{
      VerticalAlignment = 'Center'
      HorizontalAlignment = 'Center'
    }

    $Stos.AddChild(
      [label]@{
        Content = 'Label'
        FontSize = 11
        FontFamily = 'Consolas'
        Foreground = 'Black'
      }
    )
    $Stos.AddChild(
      [checkbox]@{
        Content = 'Normal'
        Margin = "8"
        IsChecked = $null
      }
    )

    $Stos.AddChild(
      [checkbox]@{
        Content = 'Checked'
        IsChecked = 'ischecked'
        Margin = "8"
      }
    )

    $Stos.AddChild(
      [checkbox]@{
        Content = 'Three'
        Margin = "8"
      }
    )
    $x = new-object System.Windows.Controls.Checkbox
    $x.Content = 'Three'
    $x.Margin = "8"
    $Stos.AddChild($x)

$cb =  [ComboBox]@{
        Name="comboBox"
        IsEditable="True"
         Margin="5"
    } 
    $cb.AddChild(
      [ComboBoxItem]@{
        Content = 'Item 1'
        Margin = "8"
      }
    )
    $cb.AddChild(
      [ComboBoxItem]@{
        Content = 'Item 2'
        Margin = "8"
        IsSelected = 'True'
      }
    )
    $cb.AddChild(
      [ComboBoxItem]@{
        Content = 'Item 3'
        Margin = "8"
      }
    )

    $Stos.AddChild($cb)
    ,$Stos
  }
} | ForEach-Object {
  $_.Add_MouseLeftButtonDown({
      $this.DragMove()
    })
  $_.Add_MouseRightButtonDown({
      $this.Close()
    })
  $_.ShowDialog() | Out-Null
}
