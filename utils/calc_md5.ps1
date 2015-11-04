$md5 = new-object -TypeName 'System.Security.Cryptography.MD5CryptoServiceProvider'
foreach ($file in $files ) {
$filename = '' 
$filepath = '' 

write-output ('{0} *{1}' -f $filename, [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($filepath)))


