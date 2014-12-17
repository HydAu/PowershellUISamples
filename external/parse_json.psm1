# http://blog.tomasjansson.com/parsing-json-with-powershell-and-json-net/

$shared_assemblies = @(
  'Newtonsoft.Json.dll',
  'nunit.core.dll',
  'nunit.framework.dll'

)


$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd


function ParseItem($jsonItem) {
    if($jsonItem.Type -eq "Array") {
        return ParseJsonArray($jsonItem)
    }
    elseif($jsonItem.Type -eq "Object") {
        return ParseJsonObject($jsonItem)
    }
    else {
        return $jsonItem.ToString()
    }
}

function ParseJsonObject($jsonObj) {
    $result = @{}
    $jsonObj.Keys | ForEach-Object {
        $key = $_
        $item = $jsonObj[$key]
        $parsedItem = ParseItem $item
        $result.Add($key,$parsedItem)
    }
    return $result
}

function ParseJsonArray($jsonArray) {
    $result = @()
    $jsonArray | ForEach-Object {
        $parsedItem = ParseItem $_
        $result += $parsedItem
    }
    return $result
}

function ParseJsonString($json) {
# https://json.codeplex.com/releases/view/135702
    $config = [Newtonsoft.Json.Linq.JObject]::Parse($json)
    return ParseJsonObject($config)
}

function ParseJsonFile($fileName) {
    $json = (Get-Content $FileName ) -join ''
    return ParseJsonString $json
}

Export-ModuleMember ParseJsonFile, ParseJsonString
