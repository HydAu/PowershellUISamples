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
    'NeedData' = [bool]$false;
    'HaveData' = [bool]$false;

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

$browser = New-Object WatiN.Core.IE("http://www.google.com")

$browser.TextField([WatiN.Core.Find]::ByName("q")).TypeText("WatiN");
$browser.Button([WatiN.Core.Find]::ByName("btnG")).Click();
[NUnit.Framework.Assert]::IsTrue($browser.ContainsText("WatiN"));


    <#
var browser = new IE("http://www.google.com"))
{
browser.TextField(Find.ByName("q")).TypeText("WatiN");
browser.Button(Find.ByName("btnG")).Click();
Assert.IsTrue(browser.ContainsText("WatiN"));
#>
  })

function send_text {
  param(
    $content,
    [switch]$append
  )

  return
  # NOTE - host-specific method signature:
  $so.Indicator.Dispatcher.Invoke([System.Action]{
      $so.Indicator.Visibility = 'Collapsed'
    },'Normal')
  $so.Contents.Dispatcher.Invoke([System.Action]{

      if ($PSBoundParameters['append_content']) {
        $so.Contents.AppendText($content)
      } else {
        $so.Contents.Text = $content
      }
      $so.Result = $so.Contents.Text
    },'Normal')

}


$run_script.Runspace = $rs
Clear-Host

$handle = $run_script.BeginInvoke()
while (-not $handle.IsCompleted) {
  Start-Sleep -Milliseconds 100
  if ($so.NeedData -and -not $so.HaveData) {
    Write-Output ('Need to provide data')
    Start-Sleep -Milliseconds 10
    send_text -Content (Date)
    Write-Output ('Sent {0}' -f $so.Result)
    $so.HaveData = $true
  }
}
$run_script.EndInvoke($handle)
$rs.Close()
