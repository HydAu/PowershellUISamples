function read_service_state_in_registry {
  param(
    [string]$service_name = 'WSearch',
    [string[]]$display_values = @(
      'DelayedAutoStart',# 1 for delayed start 
      'Start',# 4 -Disabled , 2 - Enabled, 2 - Enabled (delayed), 3 - Manual
      'ImagePath' # optional
    ),
    [bool]$debug = $false

  )
  $result = @{}
  if (-not $service_name) {
    throw "Need `$service_name"
  }
  [string]$registry_hive = 'HKLM'
  [string]$registry_path = '/SYSTEM/CurrentControlSet/services'
  $service_state_result = $null
  switch ($registry_hive) {
    'HKLM' {
      pushd HKLM:
    }

    'HKCU' {
      pushd HKCU:
    }

    default: {
      throw ('Unrecognized registry hive: {0}' -f $registry_hive)
    }
  }

  cd $registry_path

  $apps = Get-ChildItem -Path .

  $apps | Where-Object { $_.Name -match $service_name } | ForEach-Object {

    $registry_key = $_

    pushd $registry_key.Path

    $values = $registry_key.GetValueNames()
    if (-not ($values.GetType().BaseType.Name -match 'Array')) {
      throw 'Unexpected result type'
    }


    $values | Where-Object { $_ -match '^DisplayName$' } | ForEach-Object {

      try {
        $displayname_result = $registry_key.GetValue($_).ToString()

      } catch [exception]{
        Write-Debug $_
      }


      if ($displayname_result -ne $null -and $displayname_result -match "\b${service_display_name}\b") {



        $values2 = $registry_key.GetValueNames()
        $registry_key_value_data = $null

        $display_values | ForEach-Object {

          $registry_key_value_name = $_
          $result[$registry_key_value_name] = $null
          $values2 | Where-Object { $_ -match "\b${registry_key_value_name}\b" } | ForEach-Object {
            $result[$registry_key_value_name] = $registry_key_value_data = $registry_key.GetValue($_).ToString()
            if ($debug) {
              Write-Host -ForegroundColor 'yellow' ((
                  $displayname_result,
                  $registry_key.Name,
                  $registry_key_value_name,
                  $registry_key_value_data) -join "`r`n")
            }
          }
        }
      }
    }
    popd
  }
  popd
  return $result
}

# Windows Search
$service_name = 'WSearch'
Get-Service -Name $service_name
$result = read_service_state_in_registry -serviceName $service_name -Debug $false -service_display_name 'Windows search'
$result


#may need to start from 4 to 2 
# start-service -Name 'WSearch'
