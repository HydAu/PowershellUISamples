#Copyright (c) 2014 Serguei Kouzmine
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

param(
  [switch]$browser
)

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
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

$shared_assemblies = @(
  "HtmlAgilityPack.dll",
  "nunit.framework.dll"
)

$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"
$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_; Write-Debug ("Loaded {0} " -f $_) }
popd


  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections.Generic') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Collections') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Text') 
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Data') 

# TODO : real html, with problems
$source = get-content -Path "C:\developer\sergueik\powershell_ui_samples\external\grid-console.html"
$source =  [System.Net.WebUtility]::HtmlDecode($source) 
$source
# http://stackoverflow.com/questions/691657/c-htmldocument-object-has-no-constructor
# [System.Windows.Forms.HtmlDocument] $resultat  = [System.Windows.Forms.HtmlDocument]::LoadHtml($source)
[HtmlAgilityPack.HtmlDocument]$resultat  = new-Object HtmlAgilityPack.HtmlDocument
$resultat.LoadHtml($source) 
# too messy to do in Powershell
# $resultat.DocumentNode.Descendants() |  foreach-object {write-output $_.Name; write-output $_.InnerText;  }
[HtmlAgilityPack.HtmlNodeCollection] $col = $resultat.DocumentNode.SelectNodes("//p/img")
 [HtmlAgilityPack.HtmlNode] $node = $null
foreach ( $node in $col)
{
     $actuald=$node.Attributes["title"].Value
     write-output $node
}
# http://www.codeproject.com/Tips/804660/How-to-Parse-Html-using-csharp
# http://htmlagilitypack.codeplex.com/downloads/get/437941
<#
try {
Add-Type -TypeDefinition @"

// "
using System;
using System.Net;
using HtmlAgilityPack;
using System.Data;
using System.Data.Linq;
using System.Xml.Linq;
using System.Xml;
using System.Text;
using System.Net.Http;
using System.Collections;
using System.Collections.Generic;
using System.Text;
public class Win32Window 
{

private async void Parsing(string website) 
        { 
            try 
            { 

                HttpClient http = new HttpClient(); 
                var response = await http.GetByteArrayAsync(website); 
                String source = Encoding.GetEncoding("utf-8").GetString(response, 0, response.Length - 1); 
                source = WebUtility.HtmlDecode(source); 
                HtmlDocument resultat = new HtmlDocument(); 
                resultat.LoadHtml(source); 
 
                List<HtmlNode> toftitle = resultat.DocumentNode.Descendants().Where 
                (x => (x.Name == "div" && x.Attributes["class"] != null && x.Attributes["class"].Value.Contains("block_content"))).ToList(); 
 
                var li = toftitle[6].Descendants("li").ToList(); 
                foreach (var item in li) 
                { 
                    var link = item.Descendants("a").ToList()[0].GetAttributeValue("href", null); 
                    var img = item.Descendants("img").ToList()[0].GetAttributeValue("src", null); 
                    var title = item.Descendants("h5").ToList()[0].InnerText; 
 
                    listproduct.Add(new Product() 
                    { 
                        Img = img, 
                        Title = title, 
                        Link = link 
                    }); 
                } 
 
            } 
            catch (Exception) 
            { 
 
                Console.WriteLine("Network Problem!"); 
            } 
 
        }

}
"@ -ReferencedAssemblies 'System.Data.Linq.dll','System.Net.dll','System.Xml.Linq.dll','System.Xml.dll','System.Text.Encoding.dll', 'System.Net.Http.dll','System.Collections.dll', 'C:\developer\sergueik\csharp\SharedAssemblies\HtmlAgilityPack.dll'
} catch  [Exception] { 
write-debug $_.Exception.Message
}

#>