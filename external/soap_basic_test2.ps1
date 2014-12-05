# http://www.leeholmes.com/blog/2007/02/28/calling-a-webservice-from-powershell/
# http://stackoverflow.com/questions/27271744/using-new-webserviceproxy-under-powershell
param(
  [string]$wsdlLocation = $(throw 'Please specify a WSDL location'),
  [string]$namespace,
  [switch]$requiresAuthentication,
  [switch]$use_proxy,
  [string]$offline = '',
  [switch]$no_cache # does not work
)

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


function page_content {
  param(
    [string]$username = $env:USERNAME,
    [string]$url = '',
    [string]$password = '',
    [string]$use_proxy
  )

  if ($url -eq $null -or $url -eq '') {
    #  $url =  ('https://github.com/{0}' -f $username)
    $url = 'https://api.github.com/user'
  }


  $sleep_interval = 10
  $max_retries = 5

  if ($PSBoundParameters['use_proxy']) {

    # Use current user NTLM credentials do deal with corporate firewall
    $proxy_address = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer

    if ($proxy_address -eq $null) {
      $proxy_address = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').AutoConfigURL
    }

    if ($proxy_address -eq $null) {
      # write a hard coded proxy address here 
      $proxy_address = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
    }

    $proxy = New-Object System.Net.WebProxy
    $proxy.Address = $proxy_address
    Write-Debug ("Probing {0}" -f $proxy.Address)
    $proxy.useDefaultCredentials = $true

  }

  <#
request.Credentials = new NetworkCredential(xxx,xxx);
CookieContainer myContainer = new CookieContainer();
request.CookieContainer = myContainer;
request.PreAuthenticate = true;

#>

  [system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($url)
  try {
    [string]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding('ASCII').GetBytes(($username + ':' + $password)))
    Write-Debug $encoded
    $request.Headers.Add('Authorization','Basic ' + $encoded)
  } catch [argumentexception]{
    # NOP 
  }

  if ($PSBoundParameters['use_proxy']) {
    Write-Host ('Use Proxy: "{0}"' -f $proxy.Address)
    $request.proxy = $proxy
    $request.useDefaultCredentials = $true
  }
  # Note github returns a json result saying that it requires authentication 
  # standard server response is a "classic" 401 html page

  Write-Host ('Open {0}' -f $url)
  $expected_status = 200
  for ($i = 0; $i -ne $max_retries; $i++) {

    Write-Host ('Try {0}' -f $i)


    try {
      $response = $request.GetResponse()
    } catch [System.Net.WebException]{
      $response = $_.Exception.Response
    }

    $int_status = [int]$response.StatusCode
    $time_stamp = (Get-Date -Format 'yyyy/MM/dd hh:mm')
    $status = $response.StatusCode # not casting

    Write-Host "$time_stamp`t$url`t$int_status`t$status"
    if ($int_status -ne $expected_status) {
      Write-Host ('Unexpected http status detected [{0}]. Sleep and retry.' -f $int_status)

      Start-Sleep -Seconds $sleep_interval

      # sleep and retry
    } else {
      break
    }
  }

  $time_stamp = $null
  if ($int_status -ne $expected_status) {
    # write error status to a log file and exit
    # 
    Write-Host ('Unexpected http status detected. Error reported. {0}, {1} ' -f $int_status)
    log_message 'STEP_STATUS=ERROR' $build_status
  }

  $respstream = $response.GetResponseStream()
  $stream_reader = New-Object System.IO.StreamReader $respstream
  $result_page = $stream_reader.ReadToEnd()
  <#
       if ($result_page -match $confirm_page_text) {
         $found_expected_status =  $true
         if ($result_page.size -lt 100 )
         {
           $result_page_fragment= $result_page
         }
           write-host "Page Contents:`n${result_page_fragment}"
       } else {
         $found_expected_status =  $false
         $result_page = ''
       }
       #>


  Write-Debug $result_page

  return $result_page

}



function page_content_offline  {
param ([string] $page_content = '' )

if ( $page_content -ne '' ){
return ((get-content -path $page_content) -join '' )

} else {
  $wsdlStream_contents = @"
<?xml version="1.0" encoding="utf-8"?>
<wsdl:definitions xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:tns="http://tempuri.org/" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy" xmlns:wsap="http://schemas.xmlsoap.org/ws/2004/08/addressing/policy" xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl" xmlns:msc="http://schemas.microsoft.com/ws/2005/12/wsdl/contract" xmlns:wsa10="http://www.w3.org/2005/08/addressing" xmlns:wsx="http://schemas.xmlsoap.org/ws/2004/09/mex" xmlns:wsam="http://www.w3.org/2007/05/addressing/metadata" name="ManageItems" targetNamespace="http://tempuri.org/">
  <wsdl:types>
    <xsd:schema targetNamespace="http://tempuri.org/Imports">
      <xsd:import schemaLocation="http://localhost:8081/ConsoleHost/ItemService/?xsd=xsd0" namespace="http://tempuri.org/"/>
      <xsd:import schemaLocation="http://localhost:8081/ConsoleHost/ItemService/?xsd=xsd1" namespace="http://schemas.microsoft.com/2003/10/Serialization/"/>
      <xsd:import schemaLocation="http://localhost:8081/ConsoleHost/ItemService/?xsd=xsd2" namespace="http://schemas.datacontract.org/2004/07/ItemService"/>
    </xsd:schema>
  </wsdl:types>
  <wsdl:message name="IManageItems_GetItem_InputMessage">
    <wsdl:part name="parameters" element="tns:GetItem"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_GetItem_OutputMessage">
    <wsdl:part name="parameters" element="tns:GetItemResponse"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_SaveItem_InputMessage">
    <wsdl:part name="parameters" element="tns:SaveItem"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_SaveItem_OutputMessage">
    <wsdl:part name="parameters" element="tns:SaveItemResponse"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_RemoveItem_InputMessage">
    <wsdl:part name="parameters" element="tns:RemoveItem"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_RemoveItem_OutputMessage">
    <wsdl:part name="parameters" element="tns:RemoveItemResponse"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_GetAllItems_InputMessage">
    <wsdl:part name="parameters" element="tns:GetAllItems"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_GetAllItems_OutputMessage">
    <wsdl:part name="parameters" element="tns:GetAllItemsResponse"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_DumpItems_InputMessage">
    <wsdl:part name="parameters" element="tns:DumpItems"/>
  </wsdl:message>
  <wsdl:message name="IManageItems_DumpItems_OutputMessage">
    <wsdl:part name="parameters" element="tns:DumpItemsResponse"/>
  </wsdl:message>
  <wsdl:portType name="IManageItems">
    <wsdl:operation name="GetItem">
      <wsdl:input wsaw:Action="http://tempuri.org/IManageItems/GetItem" message="tns:IManageItems_GetItem_InputMessage"/>
      <wsdl:output wsaw:Action="http://tempuri.org/IManageItems/GetItemResponse" message="tns:IManageItems_GetItem_OutputMessage"/>
    </wsdl:operation>
    <wsdl:operation name="SaveItem">
      <wsdl:input wsaw:Action="http://tempuri.org/IManageItems/SaveItem" message="tns:IManageItems_SaveItem_InputMessage"/>
      <wsdl:output wsaw:Action="http://tempuri.org/IManageItems/SaveItemResponse" message="tns:IManageItems_SaveItem_OutputMessage"/>
    </wsdl:operation>
    <wsdl:operation name="RemoveItem">
      <wsdl:input wsaw:Action="http://tempuri.org/IManageItems/RemoveItem" message="tns:IManageItems_RemoveItem_InputMessage"/>
      <wsdl:output wsaw:Action="http://tempuri.org/IManageItems/RemoveItemResponse" message="tns:IManageItems_RemoveItem_OutputMessage"/>
    </wsdl:operation>
    <wsdl:operation name="GetAllItems">
      <wsdl:input wsaw:Action="http://tempuri.org/IManageItems/GetAllItems" message="tns:IManageItems_GetAllItems_InputMessage"/>
      <wsdl:output wsaw:Action="http://tempuri.org/IManageItems/GetAllItemsResponse" message="tns:IManageItems_GetAllItems_OutputMessage"/>
    </wsdl:operation>
    <wsdl:operation name="DumpItems">
      <wsdl:input wsaw:Action="http://tempuri.org/IManageItems/DumpItems" message="tns:IManageItems_DumpItems_InputMessage"/>
      <wsdl:output wsaw:Action="http://tempuri.org/IManageItems/DumpItemsResponse" message="tns:IManageItems_DumpItems_OutputMessage"/>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:service name="ManageItems"/>
</wsdl:definitions>


"@ ##  end of inline data


  return $wsdlStream_contents

}

} ## 


if (-not (Test-Path Variable:\Lee.Holmes.WebServiceCache)) {
  ${GLOBAL:Lee.Holmes.WebServiceCache} = @{}

}

if (-not ($PSBoundParameters['no_cache'])) {

  ## Create the web service cache, if it doesn’t already exist


  Write-Debug 'Check if there was an instance from a previous connection to this web service'

  $oldInstance = ${GLOBAL:Lee.Holmes.WebServiceCache}[$wsdlLocation]
  if ($oldInstance) {
    Write-Debug 'Return cached instance'
    $oldInstance
    return
  }
}

$wsdlStream_content = ''
if (($offline -ne '' -and $offline  -ne $null )) {
  # TODO use 
  $wsdlStream_content = page_content_offline -page_content $offline
} else {

  [string]$use_proxy_arg = $null
  # TODO pass switches correctly
  if ($PSBoundParameters['use_proxy']) {
    $use_proxy_arg = @( '-use_proxy',$true) -join ' '
  }
  Write-Debug "page_content -username $username -password $password -url $wsdlLocation $use_proxy_arg"
  $wsdlStream_content = page_content -UserName $username -password $password -url $wsdlLocation $use_proxy_arg

}
$filename = 'a'
$wsdlStream = [System.IO.Path]::Combine((Get-ScriptDirectory),('{0}.{1}' -f $filename,'wsdl'))
Set-Content -Path $wsdlStream -Value $wsdlStream_content
Write-Debug 'Loading the required Web Services DLL'

[void][Reflection.Assembly]::LoadWithPartialName("System.Web.Services")
## Download the WSDL for the service, and create a service description from
## it.
## Ensure that we were able to fetch the WSDL
if (-not (Test-Path Variable:\wsdlStream)) {
  throw ('Unable to fetch the WSDL from the {0}' - $wsdlLocation)
  # return
}
Write-Debug 'Reading Service Description'
$serviceDescription = [Web.Services.Description.ServiceDescription]::Read($wsdlStream)
try {
  Write-Debug 'Closing Service provider stream'
  $wsdlStream.Close()
} catch {
  # due to refactoring and introduction of 'offline'
  # Method invocation failed because [System.String] does not contain a method
  # named 'Close'.
  # slurp it
}
## Ensure that we were able to read the WSDL into a service description
if (-not (Test-Path Variable:\serviceDescription)) {
  Write-Debug 'No service Description'
  return
}

Write-Debug 'Import the web service into a CodeDom namespace'
$serviceNamespace = New-Object System.CodeDom.CodeNamespace
if ($namespace) {
  $serviceNamespace.Name = $namespace
}


$codeCompileUnit = New-Object System.CodeDom.CodeCompileUnit
$serviceDescriptionImporter = New-Object Web.Services.Description.ServiceDescriptionImporter
$serviceDescriptionImporter.AddServiceDescription($serviceDescription,$null,$null)
[void]$codeCompileUnit.Namespaces.Add($serviceNamespace)
[void]$serviceDescriptionImporter.Import($serviceNamespace,$codeCompileUnit)

Write-Debug 'Generate the code from that CodeDom into a string'

$generatedCode = New-Object Text.StringBuilder
$stringWriter = New-Object IO.StringWriter $generatedCode
$provider = New-Object Microsoft.CSharp.CSharpCodeProvider
$provider.GenerateCodeFromCompileUnit($codeCompileUnit,$stringWriter,$null)

Write-Debug 'Compile the source code'

$references = @( 'System.dll','System.Web.Services.dll','System.Xml.dll')
$compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
$compilerParameters.ReferencedAssemblies.AddRange($references)
$compilerParameters.GenerateInMemory = $true
$compilerResults = $provider.CompileAssemblyFromSource($compilerParameters,$generatedCode)

if ($compilerResults.Errors.Count -gt 0) {
  Write-Debug 'There were errors, stay tuned'
  $errorLines = ''
  foreach ($error in $compilerResults.Errors) {
    $errorLines += "`n`t" + $error.Line + ":`t" + $error.ErrorText
  }
  Write-Debug $errorLines
  return
}
else
{
  Write-Debug 'Create the webservice object and return it'

  ## Get the assembly that we just compiled
  $assembly = $compilerResults.CompiledAssembly
  ## Find the type that had the WebServiceBindingAttribute.
  ## There may be other "helper types" in this file, but they will
  ## not have this attribute
  $type = $assembly.GetTypes() |
  Where-Object { $_.GetCustomAttributes(
      [System.Web.Services.WebServiceBindingAttribute],$false) }

  if (-not $type) {
    Write-Debug 'Could not generate web service proxy.'
    return
  }
  ## Create an instance of the type, store it in the cache,
  ## and return it to the user.
  ## cannot create instance if the assembly type already present 
  ## TODO: http://www.codeproject.com/Tips/836907/Loading-Assembly-in-Separate-AppDomain-to-Have-Fil
  $instance = $assembly.CreateInstance($type)
  if   ($instance -ne $null) {  
    Write-Debug ('Created {0}' -f $instance.GetType())
    ${GLOBAL:Lee.Holmes.WebServiceCache}[$wsdlLocation] = $instance
  }

<#
# Until the class is created the code is expected to be  entirely the same
# each class methods are unique. 
# TODO : constrcute few example functions 
# specific to TerraService2
  $place = New-Object Place
  $place.City = "Miami"
  $place.State = "FL"
  $place.Country = "USA"
  $facts = $instance.GetPlaceFacts($place)
  $facts.Center | Format-List
#>
<#
Cannot invoke web method from behind the firewall : 

Exception calling "GetPlaceFacts" with "1" argument(s): 
"The request failed with HTTP status 407: Proxy Authentication Required ( Forefront TMG requires authorization to fulfill the request. Access to the Web Proxy filter isdenied.  )."
#>
$instance.AccountList()

<#
$instance | get-member

  $cmwClient = new-object $instance.CoreWebServiceClient.CoreWebServiceClient("WSHttpBinding_ICoreWebService")
#   $cmwClient = $instance
$cmwClient.ClientCredentials |  get-member
  $cmwClient.ClientCredentials.UserName = "Administrator";
$cmwClient.ClientCredentials |  get-member
  $cmwClient.ClientCredentials.Password = "e15HlFmH";

$taskData = @{"title" = "Hello, world";
            "description" = "Ws task";}
            $cmwClient.TaskCreate($null, $taskData)


  return $instance
#>
}
