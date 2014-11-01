<#
pushd  C:\developer\sergueik\powershell_ui_samples\unfinished
 . .\compressed_log.ps1 -infile b.gz
#>
# based on basic 
# http://www.codeproject.com/Articles/27203/GZipStream-Compress-Decompress-a-string
# http://social.technet.microsoft.com/Forums/windowsserver/en-US/5aa53fef-5229-4313-a035-8b3a38ab93f5/unzip-gz-files-using-powershell
# http://stackoverflow.com/questions/7343465/compression-decompression-string-with-c-sharp
param(

  $infile,
  $outfile = ($infile -replace '\.gz$','') # strip the extention in  the usual fashion
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}


function process {
  param(

    [System.Management.Automation.PSReference]$ref_output,
    [System.Management.Automation.PSReference]$ref_buffer,
    [System.Management.Automation.PSReference]$ref_read,
    [System.Management.Automation.PSReference]$ref_unfinished_line
  )
  [System.IO.Stream]$output = $ref_output.Value
  [string[]]$unfinished_line = $ref_unfinished_line.Value
  [System.Byte[]]$buffer = $ref_buffer.Value
  [string]$string_buffer = [System.Text.Encoding]::Default.GetString($buffer);
  [char[]]$newlines = @( 0xd,0xa)
  $lines = $string_buffer.split($newlines)

  Write-Debug ('<< ' + $unfinished_line + '|')
  Write-Debug ('<< ' + '|' + $lines[0])
  Write-Debug ('>> ' + $unfinished_line + $lines[0])

  $lines[0] = $unfinished_line + $lines[0]
  $unfinished_line = $lines[$lines.count - 1]
  $ref_unfinished_line.Value = $unfinished_line

  $lines[$lines.count - 1] = $null
  $lines | ForEach-Object { Write-Output $_ }


  <#
       [Int32]$read  =$ref_read.Value
  	$output.Write($buffer, 0, $read)	
   #>
}

$DebugPreference = 'Continue'
[string]$unfinished_line = ''
$input = New-Object System.IO.FileStream ('{0}\{1}' -f (Get-ScriptDirectory),$inFile),([IO.FileMode]::Open),([IO.FileAccess]::Read),([IO.FileShare]::Read)
$output = New-Object System.IO.FileStream ('{0}\{1}' -f (Get-ScriptDirectory),$outFile),([IO.FileMode]::Create),([IO.FileAccess]::Write),([IO.FileShare]::None)
$gzipStream = New-Object System.IO.Compression.GzipStream $input,([IO.Compression.CompressionMode]::Decompress)
[int]$BUF_SIZE = 8192
$buffer = New-Object byte[] ($BUF_SIZE)
while ($true) {
  $read = $gzipstream.Read($buffer,0,$BUF_SIZE)
  if ($read -le 0) { break }
  process ([ref]$output) ([ref]$buffer) ([ref]$read) ([ref]$unfinished_line)
}

$gzipStream.Close()
$output.Close()
$input.Close()
