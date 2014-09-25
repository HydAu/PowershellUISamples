param(
  [switch]$all
)
Write-Host -ForegroundColor 'green' @"
This call clears "Enable Protected Mode" - checkboxes - for specific internet "Zones" 
- "Restricted sites" and "Internet"
- or all 4 Zones when wun with '-all'switch 
"@

$zones = @( '4','3')

if ($PSBoundParameters["all"]) {
  # Proceed to two remaining zones

  $zones += @( '2','1')

}


$zones | ForEach-Object {

  $zone = $_
  $hive = 'HKCU:'
  $path = ('/Software/Microsoft/Windows/CurrentVersion/Internet Settings/Zones/{0}' -f $zone)

  $data = @{ '2500' = '3';
    '2707' = '0'
  }


  pushd $hive
  cd $path

  $description = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name 'DisplayName' -ErrorAction 'SilentlyContinue'
  if ($description -eq $null) {
    $description = '???'

  } else {
    $description = $description.DisplayName }

  Write-Output ('Configuring Zone {0} - "{1}"' -f $zone,$description)


  $data.Keys | ForEach-Object {
    $name = $_
    $value = $data.Item($name)
    Write-Output ('Writing Settings {0}' -f $name)
    $setting = Get-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -ErrorAction 'SilentlyContinue'
    if ($setting -ne $null) {
      Set-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value
    } else {
      if ($setting -ne $value) {
        New-ItemProperty -Path ('{0}/{1}' -f $hive,$path) -Name $name -Value $value -PropertyType DWORD

      }
    }
  }
  popd

}
