#Copyright (c) 2014 Serguei Kouzmine

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

#requires -version 2
# http://sourceforge.net/projects/watin/files/WatiN%202.x/2.1/
# http://www.codeproject.com/Articles/17064/WatiN-Web-Application-Testing-In-NET
Add-Type -AssemblyName PresentationFramework

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot;
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
  }
}

$so = [hashtable]::Synchronized(@{
    'Result' = [string]'';
    'ScriptDirectory' = [string]'';

    'Window' = [System.Windows.Window]$null;
    'Control' = [System.Windows.Controls.ToolTip]$null;
    'Contents' = [System.Windows.Controls.TextBox]$null;
    'Started' = [bool]$false;
    'Finished' = [bool]$false;

  })
$so.ScriptDirectory = Get-ScriptDirectory
$env:SHARED_ASSEMBLIES_PATH = "c:\developer\sergueik\csharp\SharedAssemblies"

$so.Result = ''
$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so',$so)

$run_script = [powershell]::Create().AddScript({

    $shared_assemblies = @(

      'Interop.SHDocVw.dll','Microsoft.mshtml.dll','WatiN.Core.dll',
      'nunit.framework.dll','nunit.core.dll'

    )


    $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
    pushd $shared_assemblies_path
    $shared_assemblies | ForEach-Object { Unblock-File -Path $_; Add-Type -Path $_ }
    popd
$so.Started = $true 
$browser = New-Object WatiN.Core.IE("http://www.google.com")


$browser.TextField([WatiN.Core.Find]::ByName("q")).TypeText("WatiN")
[WatiN.Core.Button]$button = $browser.Button([WatiN.Core.Find]::ByName("btnG"))
$so.Result +=  $button.Text
$so.Result += $button.OuterHtml
$button.Focus()
$button.Click()

[NUnit.Framework.Assert]::IsTrue($browser.ContainsText("WatiN"))

[WatiN.Core.Div] $div = ie.Div([WatiN.Core.Find]::ById("ssb"))
        [WatiN.Core.Para.Para] $p = $div.Paras[0]
        [string] $result = $p.Text
write-host $result
$so.Result += $result

start-sleep 10
$browser.Close()
<#
$browser = New-Object WatiN.Core.Firefox("http://www.google.com")

$browser.TextField([WatiN.Core.Find]::ByName("q")).TypeText("WatiN");
$browser.Button([WatiN.Core.Find]::ByName("btnG")).Click();
[NUnit.Framework.Assert]::IsTrue($browser.ContainsText("WatiN"));
start-sleep 10
$browser.Close()

#>
$so.Finished = $true 
  })

function send_text {
  param(
    $content,
    [switch]$append
  )
  # reserved for future use
  return
}


$run_script.Runspace = $rs
Clear-Host

$handle = $run_script.BeginInvoke()
while (-not $handle.IsCompleted) {
  Start-Sleep -Milliseconds 100
  if ($so.Started -and -not $so.Finished) {
    # Write-Output ('Waiting for test to complete')
    Start-Sleep -Milliseconds 1000
    send_text -Content ($null)
    # reserved for futute use
    # $so.HaveData = $true
  }
}

write-output $so.Result
$run_script.EndInvoke($handle)
$rs.Close()
