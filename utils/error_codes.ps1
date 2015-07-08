# Perl-style HERE-DOCUMENT dictionary definition 

$errorcodes_data = @"
0 Success
1 Not Supported
2 Access Denied
3 Dependent Services Running
4 Invalid Service Control
5 Service Cannot Accept Control
6 Service Not Active
7 Service Request timeout
8 Unknown Failure
9 Path Not Found
10 Service Already Stopped
11 Service Database Locked
12 Service Dependency Deleted
13 Service Dependency Failure
14 Service Disabled
15 Service Logon Failed
16 Service Marked For Deletion
17 Service No Thread
18 Status Circular Dependency
19 Status Duplicate Name
20 Status - Invalid Name
21 Status - Invalid Parameter
22 Status - Invalid Service Account
23 Status - Service Exists
24 Service Already Paused
"@
$errorcodes_hash = @{}

$errorcodes_data.split("`n") | ForEach-Object {


  if ($_ -match [regex]'(\d+)\s(.+)') {

    $errorcodes_hash[$matches[1]] = $matches[2]

  }

}
Write-Output '$errorcodes = @{ '
$errorcodes_hash.Keys | ForEach-Object {
  $key = $_
  $value = $errorcodes_hash.$key
  Write-Output ("'{0}' = '{1}';" -f $key,$value)
}
Write-Output '}'
