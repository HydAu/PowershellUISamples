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


# FiddlerCode 

if (-not [environment]::Is64BitProcess) {
  # TODO: verify 
  $path = '/Software/Telerik/FiddlerCoreAPI/'
} else {
  $path = '/Software/Telerik/FiddlerCoreAPI/'
}

$hive = 'HKCU:'
[string]$name = $null
pushd $hive
cd $path
$fields = @( 'InstallPath')
$fields | ForEach-Object {
  $name = $_
  # write-output $name
  $result = Get-ItemProperty -Name $name -Path ('{0}/{1}' -f $hive,$path)
  [string]$DisplayName = $null
  [string]$Version = $null
  [string]$InstallPath = $null

  try {
    $Version = $result.Version
    $DisplayName = $result.DisplayName
    $UninstallString = $result.UninstallString
    $InstallPath = $result.InstallPath

  } catch [exception]{

  }
  if (($DisplayName -ne $null) -and ($DisplayName -ne '')) {
    Write-Output ('DisplayName :  {0}' -f $DisplayName)
  }
  if (($Version -ne $null) -and ($Version -ne '')) {
    Write-Output ('Version :  {0}' -f $Version)
  }
  if (($UninstallString -ne $null) -and ($UninstallString -ne '')) {
    Write-Output ('UninstallString :  {0}' -f $UninstallString)
  }
  if (($InstallPath -ne $null) -and ($InstallPath -ne '')) {
    Write-Output ('InstallPath :  {0}' -f $InstallPath)
  }

}
popd


