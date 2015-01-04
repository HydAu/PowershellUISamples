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

$DebugPreference = 'Continue'

$shared_assemblies = @(
  # http://www.codeproject.com/Articles/11588/Progress-Task-List-Control
  'ProgressTaskList.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
)


$shared_assmblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'

if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {

  Write-Debug ('Using environment: {0}' -f $env:SHARED_ASSEMBLIES_PATH)
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assmblies_path

$shared_assemblies | ForEach-Object {
  $assembly = $_
  Write-Debug $assembly
  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $assembly
  }
  Add-Type -Path $assembly
}
popd


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
    'Title' = [string]'';
    'Visible' = [bool]$false;
    'ScriptDirectory' = [string]'';
    'Form' = [System.Windows.Forms.Form]$null;
    'Current' = 0;
    'Last' = 0;
    'Steps' = [System.Management.Automation.PSReference];
    'Progress' = [scriptblock]{};
  })

$so.ScriptDirectory = Get-ScriptDirectory
$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so',$so)

$run_script = [powershell]::Create().AddScript({

    function ProgressbarTasklist {
      param(
        [string]$title,
        [System.Management.Automation.PSReference]$data_ref,
        [object]$caller
      )

      @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

      $f = New-Object -TypeName 'System.Windows.Forms.Form'
      $so.Form = $f
      $f.Text = $title

      $f.Size = New-Object System.Drawing.Size (650,150)
      $f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
      $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,14)
      $f.ClientSize = New-Object System.Drawing.Size (292,144)


      $panel = New-Object System.Windows.Forms.Panel
      $panel.BackColor = [System.Drawing.Color]::Silver
      $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

      $b = New-Object System.Windows.Forms.Button
      $b.Location = New-Object System.Drawing.Point (210,114)
      $b.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
      $b.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',7,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)

      $b.Text = 'forward'
      $progress = { 
      } 
      $b.add_click({

          if ($so.Current -eq $so.Last)
          {
            $b.Enabled = $false
            start-sleep -millisecond 300
            $so.Current = $so.Current + 1
            $so.Visible = $false
          } else {

            if (-not $o.Visible) {
              # set the first task to 'in progress'
              $o.Visible = $true
              $caller.Current = 1
              $o.Start()


            } else {
              # set the following task to 'in progress'
              $o.NextTask()
              $so.Current = $so.Current + 1
            }
          }
        })

      $o = New-Object -TypeName 'Ibenza.UI.Winforms.ProgressTaskList' -ArgumentList @()
      $o.BackColor = [System.Drawing.Color]::Transparent
      $o.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
      $o.Dock = [System.Windows.Forms.DockStyle]::Fill
      $o.Location = New-Object System.Drawing.Point (0,0)
      $o.Name = "progressTaskList1"
      $o.Size = New-Object System.Drawing.Size (288,159)
      $o.TabIndex = 2

      $o.TaskItems.AddRange(@( [string[]]$data_ref.Value.Keys))

      $so.Last = $data_ref.Value.Keys.Count # will use 1-based index 
      $o.Visible = $false
      $panel.SuspendLayout()
      $panel.ForeColor = [System.Drawing.Color]::Black
      $panel.Location = New-Object System.Drawing.Point (0,0)
      $panel.Name = 'panel'
      $panel.Size = New-Object System.Drawing.Size (($f.Size.Width),($f.Size.Height))
      $panel.TabIndex = 1

      $panel.Controls.Add($o)
      $panel.ResumeLayout($false)
      $panel.PerformLayout()


      $f.Controls.AddRange(@( $b,$panel))
      $f.Topmost = $True

      $so.Visible = $true
      $f.Add_Shown({ $f.Activate() })

      [void]$f.ShowDialog()

      $f.Dispose()
    }
    $data_ref = $so.Steps
    ProgressbarTasklist -data_ref $data_ref -title $so.Title
    write-Output ("Processed:`n{0}" -f ($data_ref.value.Keys -join "`n"))

  })

$data = @{
  'Verifying cabinet integrity' = $null;
  'Checking necessary disk space' = $null;
  'Extracting files' = $null;
  'Modifying registry' = $null;
  'Installing files' = $null;
  'Removing temporary files' = $null; }

$so.Steps = ([ref]$data)
$so.Title = 'Task List'

$run_script.Runspace = $rs

$handle = $run_script.BeginInvoke()

Start-Sleep -millisecond 300 
while ($so.Current -lt $so.Last +  1) {
  Start-Sleep -Milliseconds 100
}

# Close the progress form
$so.Form.Close()


$run_script.EndInvoke($handle)
$rs.Close()
