function Execute-SOAPRequest
(
  [xml]$SOAPRequest,
  [string]$URL
)
{
  Write-Host "Sending SOAP Request To Server: $URL"
  $soapWebRequest = [System.Net.WebRequest]::Create($URL)
  $soapWebRequest.Headers.Add("SOAPAction",'""')

  $soapWebRequest.ContentType = 'text/xml;charset="utf-8"'
  $soapWebRequest.Accept = "text/xml"
  $soapWebRequest.Method = "POST"

  Write-Host "Initiating Send."
  $requestStream = $soapWebRequest.GetRequestStream()
  $SOAPRequest.Save($requestStream)
  $requestStream.Close()

  Write-Host "Send Complete, Waiting For Response."
  $resp = $soapWebRequest.GetResponse()
  $responseStream = $resp.GetResponseStream()
  $soapReader = [System.IO.StreamReader]($responseStream)
  $ReturnXml = [xml]$soapReader.ReadToEnd()
  $responseStream.Close()

  Write-Host "Response Received."

  return $ReturnXml
}

function Execute-SOAPRequestFromFile
(
  [string]$SOAPRequestFile,
  [string]$URL
)
{
  Write-Host "Reading and converting file to XmlDocument: $SOAPRequestFile"
  $SOAPRequest = [xml](Get-Content $SOAPRequestFile)

  return $(Execute-SOAPRequest $SOAPRequest $URL)
}




# https://developer.salesforce.com/forums?id=906F00000008rL3IAI
# http://www.symantec.com/connect/forums/powershell-30-invoke-webrequest-wf-service
# http://rambletech.wordpress.com/2011/09/21/posting-soap-request-from-windows-powershell/