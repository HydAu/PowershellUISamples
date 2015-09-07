$ErrorActionPreference = 'Stop'
# NUnit msi installer creates 'InstallDir' registry key direcory
$version = '2.6.4'
$nunit_key = "HKCU:\Software\nunit.org\NUnit\${version}"

if (-not (Get-ChildItem $nunit_key -ErrorAction 'SilentlyContinue'))
{
  throw "Nunit is not installed."
}
else
{
  $item = Get-ItemProperty -Path $nunit_key -Name 'InstallDir'
  $nunit_path = [System.IO.Path]::GetDirectoryName($item.'InstallDir')
}

$assembly_list = @{
  'nunit.core.dll' = 'bin\lib';
  'nunit.framework.dll' = 'bin\framework';
}



foreach ($assembly in $assembly_list.Keys)
{
  $assembly_path = $assembly_list[$assembly]
  pushd "${nunit_path}\${assembly_path}"
  Write-Host ('Loading {0} from {1}' -f $assembly,"${nunit_path}\${assembly_path}")
  if (-not (Test-Path -Path $assembly)) {
    throw ('no assembly "{0}" in {1} ' -f $assembly,"${nunit_path}\${assembly_path}")
  }
  Add-Type -Path $assembly
  popd
}



[NUnit.Framework.Assert]::IsTrue($true)
