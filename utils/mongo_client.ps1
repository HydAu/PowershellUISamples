#Copyright (c) 2015 Serguei Kouzmine
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

# https://github.com/nightroman/Mdbc
# https://danielweberonline.wordpress.com/2012/01/30/query-and-update-data-on-mongodb-using-powershell/
# http://stackoverflow.com/questions/29327856/how-to-insert-data-into-a-mongodb-collection-using-c
# http://stackoverflow.com/questions/25530172/powershell-querying-mongodb
param(
  [switch]$pause
)

function custom_pause {
  param([bool]$fullstop)

  if ($fullstop) {
    try {
      Write-Output 'pause'
      [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    } catch [exception]{}
  } else {
    Start-Sleep -Millisecond 1000
  }
}

function netstat_check
{
  param(
    [string]$mongod_http_port = 27017
  )
  $results = Invoke-Expression -Command "netsh interface ipv4 show tcpconnections"
  $port_check = $results -split "`r`n" | Where-Object { ($_ -match "\s${mongod_http_port}\s") }
  (($port_check -ne '') -and $port_check -ne $null)

}

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}

function cleanup
{
  param(
    [System.Management.Automation.PSReference]$selenium_ref
  )
  try {
    $selenium_ref.Value.Quit()
  } catch [exception]{
    Write-Output (($_.Exception.Message) -split "`n")[0]
    # Ignore errors if unable to close the browser
  }
}

$shared_assemblies = @(
  'MongoDB.Bson.dll',
  'MongoDB.Driver.dll',
  'nunit.framework.dll'
)

$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  # Unblock-File -Path $_; 
  Add-Type -Path $_
}
popd


if (-not (netstat_check)) {
  Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -ArgumentList "start /min cmd.exe /c c:\tools\mongo\mongod.cmd"
  Start-Sleep -Seconds 10
}

# https://www.mongodb.org/dl/win32/i386
# http://downloads.mongodb.org/win32/mongodb-win32-i386-3.0.2.zip?_ga=1.51627113.1983772218.1431297369
# https://s3.amazonaws.com/drivers.mongodb.org/dotnet/CSharpDriver-1.8.1.zip

$database_name = 'local'
$collection_name = 'startup_log'
$client = New-Object -TypeName MongoDB.Driver.MongoClient -ArgumentList "mongodb://localhost:27017"
$server = $client.GetServer()
$database = $server.GetDatabase($database_name)
$collection = $database.GetCollection($collection_name)
$query = New-Object MongoDB.Driver.QueryDocument ('hostname',$env:COMPUTERNAME.ToLower())
$result = $collection.FindOne($query)
$result

$database_name = "MyDatabase"
$collection_name = "MyCollection"
$database = [MongoDB.Driver.MongoDatabase]::Create("mongodb://localhost:27017/$($database_name)")
$collection = $database[$collection_name]

$document = New-Object MongoDB.Bson.BsonDocument
$document.Add("FirstName",[MongoDB.Bson.BsonValue]::Create("James"))
$document.Add("LastName",[MongoDB.Bson.BsonValue]::Create("Bond"))
# may not work with 3.0.2 / 1.0.x ? 
$collection.save($document)

$document.Add("UserId",[MongoDB.Bson.BsonObjectId]::Create("4f2193e0df6e251d040a6df6"))
$results = $collection.findall()
foreach ($result in $results) {
  Write-Host $result
}

$query = [MongoDB.Driver.Builders.Query]::AND(
  [MongoDB.Driver.Builders.Query]::EQ("FirstName","James"),
  [MongoDB.Driver.Builders.Query]::EQ("LastName","Bond"))

$results = $collection.Find($query)
foreach ($result in $results) {
  Write-Host $result
}

return


# cleanup ([ref]$selenium)
