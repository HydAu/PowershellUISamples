#Copyright (c) 2014 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# For installed producs 

function read_registry {
  param(
    [string]$registry_hive = 'HKLM',
    [string]$registry_path,
    [string]$package_name,
    [string]$subfolder = '',
    [bool]$debug = $false

  )

  $install_location_result = $null
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
  if ($debug) {
    Get-ChildItem
    popd
    return
  }

  cd $registry_path

  $apps = Get-ChildItem -Path .

  $apps | ForEach-Object {

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


      if ($displayname_result -ne $null -and $displayname_result -match "\b${package_name}\b") {
        $values2 = $registry_key.GetValueNames()
        $install_location_result = $null
        $values2 | Where-Object { $_ -match '\bInstallLocation\b' } | ForEach-Object {
          $install_location_result = $registry_key.GetValue($_).ToString()
          Write-Host -ForegroundColor 'yellow' (($displayname_result,$registry_key.Name,$install_location_result) -join "`r`n")
        }
      }
    }
    popd
  }
  popd
  if ($subfolder -ne '') {
    return ('{0}{1}' -f $install_location_result,$subfolder)
  } else {
    return $install_location_result
  }
}

# SQLite3 
$result = read_registry -subfolder 'bin' -registry_path '/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/' -package_name 'System.Data.SQLite' -Debug $false
$result
