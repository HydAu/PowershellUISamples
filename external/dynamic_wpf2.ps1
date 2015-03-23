# http://poshcode.org/5730
# Plik: 4_Demo_v3_Reflection.ps1
#requires -version 3

# this script uses type accelerators to shorten the progam
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/07/08/use-powershell-to-find-powershell-type-accelerators.aspx
# connect.microsoft.com/PowerShell/feedback/details/721443/system-management-automation-typeaccelerators-broken-in-v3-ctp2
$ta = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

Add-Type -AssemblyName 'PresentationCore','PresentationFramework' -Passthru |
Where-Object IsPublic |
ForEach-Object {
  $_class = $_
  try {
    $ta::Add($_class.Name,$_class)
  } catch {
    ( 'Failed to add {0} accelerator resolving to {1}' -f $_class.Name ,   $_class.FullName )
  }
}

[Window]@{
  Width = 310
  Height = 110
  WindowStyle = 'SingleBorderWindow'
  AllowsTransparency = $false
  TopMost = $true
  Content = & {
    $c1 = [StackPanel]@{
      Margin = '5'
      VerticalAlignment = 'Center'
      HorizontalAlignment = 'Center'
      Orientation='Horizontal' 
    }
    $t = [textblock]@{

    }

    $t.AddChild([label]@{
        Margin = '5'
        VerticalAlignment = 'Center'
        HorizontalAlignment = 'Center'
        FontSize = '11'
        FontFamily = 'Calibri'
        Foreground = 'Black'

        Content = 'Enter Password:'
      }
    )

    $c1.AddChild($t)
    $c1.AddChild(
      [passwordbox]@{
        Name = 'passwordBox'
        PasswordChar = '*'
        VerticalAlignment = 'Center'
        Width = '120'
      }
    )

    $c1.AddChild(
      [button]@{
        Content = 'OK'
        IsDefault = 'True'
        Margin = '5'
        Name = 'button1'
        Width='50'
        VerticalAlignment = 'Center'
      }
    )
    ,$c1
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
