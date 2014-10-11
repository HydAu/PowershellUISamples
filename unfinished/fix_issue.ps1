
$out_file = '40517_1972395_560868416_P_01_H.txt'
$data = Get-Content -Path $out_file
$data | ForEach-Object {
  $line = $_
  $found = $line -match 'ASP.NET_SessionId=([^; ]+);'
  if ($found) {
    $session_id = $matches[1]
  }

}
$session_id



[System.Text.Encoding]$in_encoding = [System.Text.Encoding]::UNICODE
$out_file = '40517_1972395_560868416_P_01_H.txt'

$data = Get-Content -Path $out_file
[byte[]]$bytes = $in_encoding.GetBytes($data)
$bytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UNICODE,[System.Text.Encoding]::ASCII,$bytes)
[byte[]]$bytes2 = @()

for ($cnt = 0; (($cnt -lt $bytes.Length) -and ($cnt -lt 10)); $cnt++) {
  if (($cnt % 2) -eq 1) {
    Write-Output ('x=>{0}' -f  $bytes[$cnt] )
  } else {
    Write-Output ('{0}=>{1}' -f $cnt,$bytes[$cnt])
    $bytes2 += $bytes[$cnt]
  }
}

$bytes2
