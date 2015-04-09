# Copyright (c) 2015 Serguei Kouzmine
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

param([string]$dirname,
  [string]$filename,
  # The algorithm to use for hash computation
  [ValidateSet('MD5','SHA1')]
  $hash_algorithm = 'MD5',

  [switch]$pause
)
function checksum_file {
  param(
    [string]$unc_path)
  # TODO: refactor 
  return [System.BitConverter]::ToString((New-Object -TypeName 'System.Security.Cryptography.MD5CryptoServiceProvider').ComputeHash([System.IO.File]::ReadAllBytes((Get-Item -Path $unc_path).FullName)))
}



function checksum_dir {
  param(
    $unc_path,
    [string]$hash_algorithm = 'MD5',
    [System.Management.Automation.PSReference]$result_ref
  )

  $hashproviderclasses = @{
    'MD5' = 'MD5CryptoServiceProvider';
    # https://msdn.microsoft.com/en-us/library/system.security.cryptography.md5cryptoserviceprovider%28v=vs.110%29.aspx
    'SHA1' = 'SHA1CryptoServiceProvider';
    # https://msdn.microsoft.com/en-us/library/system.security.cryptography.sha1cryptoserviceprovider%28v=vs.110%29.aspx
  }

  $local:result = @{}
  try {
    Push-Location "${unc_path}" -ErrorAction Stop
  } catch [exception]{
    throw ('Argument has to be a directory path: {0}' -f $unc_path)
  }
  Write-Host ('Generating chesksums for directory {0}' -f $unc_path)
  # http://poshcode.org/5815
  $md5 = New-Object -TypeName ('System.Security.Cryptography.{0}' -f $hashproviderclasses[$hash_algorithm])
  $files = Get-ChildItem -Recurse | Where-Object { -not ($_.Attributes -match 'Directory') }
  $files | Where-Object { -not ($_.Fulname -match 'Directory') } | ForEach-Object {
    $target_file = $_
    $file_hash = $md5.ComputeHash([System.IO.File]::ReadAllBytes($target_file.FullName))

    $format_builder = New-Object System.Text.StringBuilder
    $file_hash | ForEach-Object { [void]$format_builder.Append($_.ToString('X2')) }

    $local:result[$target_file.Name] = @{
      'bitconverter' = ([System.BitConverter]::ToString($file_hash));
      'shell' = ($format_builder.ToString());
    }
    #    $local:result[$target_file.Name] =  ( $format_builder.ToString() );
  }

  popd

  $result_ref.Value = $local:result

}

$source_md5 = @{}
if ($dirname) {
  [void](checksum_dir -unc_path $dirname -result_ref ([ref]$source_md5))
  #   $source_md5 | format-table -autosize
  $source_md5 | ConvertTo-Json
}
if ($filename) {
  Write-Output ($filename,(checksum_file -unc_path $filename -hash_algorithm $hash_algorithm))
}

#     if ($PSBoundParameters['pause'].IsPresent) 
