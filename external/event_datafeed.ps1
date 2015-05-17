# This cannot run as a standalone Powershell script, but can if there is a form
# https://github.com/lgarcia2/CraigslistScraper
$city = "denver"
$currentSearchTerm = "miata"
$URL = ("http://" + $city + ".craigslist.org/search/cta?query=" + $currentSearchTerm + "&format=rss")


[System.Net.WebClient]$client = New-Object System.Net.WebClient
$client.Add_DownloadStringCompleted({
    param(
      [object]$sender,[System.Net.DownloadStringCompletedEventArgs]$e
    )

    [string]$result = $null
    if ((-not $e.Cancelled) -and ($e.Error -eq $null))
    {
      $result = $e.Result
    }
    if ($result -eq $null) {
      [System.Windows.Forms.MessageBox]::Show('Failed to Connect to website.')
      return
    }

    [System.Xml.XmlDocument]$xml_document = New-Object System.Xml.XmlDocument
    $xml_document.LoadXml($result)

  })
$client.DownloadStringAsync((New-Object System.Uri ($URL)))

