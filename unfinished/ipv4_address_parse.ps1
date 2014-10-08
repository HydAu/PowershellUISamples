
function ipv4_address () {
  param(
    [object]$ip1,
    [object]$ip2,
    [object]$ip3,
    [object]$ip4
  )

  $r = @()

  @( $ip1,
    $ip2,
    $ip3,
    $ip4) | ForEach-Object {
    $q = $_
    if ($q.Length -gt 0) { $u = $q } else { $u = '0' }
    $d = [int]::Parse($u).ToString()
    $r += $d
  }

$result = [System.Net.IPAddress]::Parse( ($r -join '.') )

return $result
}
function ipv4_address1 () {
  param(
    [object]$ip1,
    [object]$ip2,
    [object]$ip3,
    [object]$ip4
  )

  $result = @()

  @( $ip1,
    $ip2,
    $ip3,
    $ip4) | ForEach-Object {
    $q = $_
    if ($q.Length -gt 0) { $u = $q } else { $u = '0' }
    $d = [int]::Parse($u).ToString()
    $result += $d
  }

  return ($result -join '.')


}
$ip1  = '192'
$ip2  = '168'
$ip3  = '56'
$ip4  = '101'

Write-Output (ipv4_address -ip1 $ip1  -ip2 $ip2  -ip3 $ip3  -ip4 $ip4 )
<#

[string]$address_str =	('{0}.{1}.{2}.{3}' -f
[int]::Parse(( if ( $ip1.Text.Length -gt 0 ) { $ip1.Text } else { "0" } )).ToString() ,
[int]::Parse(( if ( $ip2.Text.Length -gt 0 ) { $ip2.Text } else { "0" } )).ToString() ,

[int]::Parse(( if ( $ip3.Text.Length -gt 0 ) { $ip3.Text } else { "0" } )).ToString() ,

[int]::Parse(( if ( $ip4.Text.Length -gt 0 ) { $ip4.Text } else { "0" } )).ToString() 

)
[string]$address_str =	
[int]::Parse(( if ( $ip1.Text.Length -gt 0 ) { $ip1.Text } else { "0" } )).ToString()

+ "." +

[int]::Parse(( if ( $ip2.Text.Length -gt 0 ) { $ip2.Text } else { "0" } )).ToString()

+ "." +

[int]::Parse(( if ( $ip3.Text.Length -gt 0 ) { $ip3.Text } else { "0" } )).ToString()

+ "." +

[int]::Parse(( if ( $ip4.Text.Length -gt 0 ) { $ip4.Text } else { "0" } )).ToString()




#>


<#
System.Net.IPAddress GetIPAddress

		{

			get

			{

				address =	int.Parse( ( ip1.Text.Length > 0 ) ? ip1.Text : "0" ).ToString()

					+ "." +

					int.Parse( ( ip2.Text.Length > 0 ) ? ip2.Text : "0" ).ToString()

					+ "." +

					int.Parse( ( ip3.Text.Length > 0 ) ? ip3.Text : "0" ).ToString()

					+ "." +

					int.Parse( ( ip4.Text.Length > 0 ) ? ip4.Text : "0" ).ToString();



					return IPAddress.Parse( address );

			}
#>


