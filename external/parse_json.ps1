# http://blog.tomasjansson.com/parsing-json-with-powershell-and-json-net/
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
    $config = [Newtonsoft.Json.Linq.JObject]::Parse($json)
    return ParseJsonObject($config)
}

function ParseJsonFile($fileName) {
    $json = (Get-Content $FileName | Out-String)
    return ParseJsonString $json
}

Export-ModuleMember ParseJsonFile, ParseJsonString
