#  based on basic 
# http://www.codeproject.com/Articles/27203/GZipStream-Compress-Decompress-a-string
# http://social.technet.microsoft.com/Forums/windowsserver/en-US/5aa53fef-5229-4313-a035-8b3a38ab93f5/unzip-gz-files-using-powershell
# http://stackoverflow.com/questions/7343465/compression-decompression-string-with-c-sharp
Param(
	$infile,
	$outfile = ($infile -replace '\.gz$','') # strip the extention in  the usual fashion
	)

	
function process {
Param(

    [System.Management.Automation.PSReference] $ref_output,
	[System.Management.Automation.PSReference] $ref_buffer, 
	[System.Management.Automation.PSReference] $ref_read
	 )
     [System.IO.Stream]$output  = $ref_output.Value

     [System.Byte[]]$buffer = $ref_buffer.Value
     [string] $string_buffer  = [System.Text.Encoding]::Default.GetString($buffer );
     [char[]] $newlines = @( 0xd, 0xa )
     $lines =  $string_buffer.split($newlines)
# http://msdn.microsoft.com/en-us/library/ms228388.aspx
# The following will not work :"
#      $lines =  $string_buffer -split '`l'
#     write-output "`n---`n${string_buffer}`n---`n" 
     $lines.count
     start-sleep 1;
 
     [Int32]$read  =$ref_read.Value
	$output.Write($buffer, 0, $read)	
}


$input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
$output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
$gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)

$buffer = New-Object byte[](4096)
while($true){
	$read = $gzipstream.Read($buffer, 0, 4096)
	if ($read -le 0){break}
write-debug ('{0}={1}' -f 'output', $output.GetType() )
write-debug ('{0}={1}' -f 'buffer', $buffer.GetType())
write-debug ('{0}={1}' -f 'read', $read.GetType())
	
	process  ([ref]$output ) ([ref]$buffer )  ([ref]$read ) 

	}

$gzipStream.Close()
$output.Close()
$input.Close()
