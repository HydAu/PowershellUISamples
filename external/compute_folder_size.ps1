#Copyright (c) 2015 Serguei Kouzmine
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# http://poshcode.org/5647
function Get-FolderSize
{

  begin {
    $fso = New-Object -ComObject Scripting.FileSystemObject
  }
  process {
    $path = $input.fullname
    $folder = $fso.GetFolder($path)
    $size = $folder.size
    [pscustomobject]@{ 'Name' = $path; 'Size' = ($size / 1Kb) }
  }

}


$skip_folders = @'
Program Files
Program Files (x86)
ProgramData
windows
sxs
Users
Bitnami
buildagent
Chef
cygwin
java
Perl
Ruby193
RubyDev
wix
'@
$skip_folders_pattern = ('\b({0})\b' -f ($skip_folders -replace "\(", '\(' -replace "\)", '\)' -replace "`r`n", '|'))

pushd 'C:'
cd '\'
$level1 = @()
Get-ChildItem -Directory -ErrorAction SilentlyContinue | ForEach-Object { $path = $_.fullname;

  if (-not ($path -match $skip_folders_pattern )) {
    $level1 += $path
    Write-Output ('added {0} to $level1 ' -f $path)
  }
  else {
    Write-Output ('Skipping directory from measuring: {0}' -f $path)
  } }
popd
Write-output 'Measuring:' 
$level1 | Format-Table
pushd 'C:'
cd '\'
$level1 | ForEach-Object {

  Get-ChildItem -LiteralPath $_ -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $path = $_; # TODO assert 
    if ($true) { Write-Output $path | Get-FolderSize } }
} | sort size -Descending | Out-GridView

popd
