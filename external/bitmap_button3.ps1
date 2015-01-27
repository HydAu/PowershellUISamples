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
# $DebugPreference = 'Continue'

param(
  [switch]$pause
)

if ($host.Version.Major -le 2) {
  throw "This script will not work witn Powershell v2."
}

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot)
  {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path)
  {
    Split-Path $Invocation.MyCommand.Path
  }
  else
  {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"))
  }
}

@( 'System.Drawing','System.Windows.Forms','System.Windows.Forms.VisualStyles') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
$result = ''

$f = New-Object System.Windows.Forms.Form

$l1 = New-Object System.Windows.Forms.Label
$l2 = New-Object System.Windows.Forms.Label
$l3 = New-Object System.Windows.Forms.Label
$o1 = New-Object -TypeName System.Windows.Forms.Button
$o2 = New-Object -TypeName System.Windows.Forms.Button
$o3 = New-Object -TypeName System.Windows.Forms.Button

# label1
$l1.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$l1.Location = New-Object System.Drawing.Point (12,39)
$l1.Name = 'l1'
$l1.Text = ''
$l1.Size = New-Object System.Drawing.Size (172,23)
$l1.TabIndex = 4

# label2
$l2.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$l2.Location = New-Object System.Drawing.Point (12,70)
$l2.Name = "l2"
$l2.Text = ''
$l2.Size = New-Object System.Drawing.Size (172,23)
$l2.TabIndex = 4

# label2
$l3.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$l3.Location = New-Object System.Drawing.Point (12,110)
$l3.Name = "l3"
$l3.Text = ''
$l3.Size = New-Object System.Drawing.Size (172,23)
$l3.TabIndex = 4


# dDControls
$global:m = @{
  'b1' = 'l1';
  'b2' = 'l2';
  'b3' = 'l3';
}

$o1.Location = New-Object System.Drawing.Point (200,32)
$o1.Size = New-Object System.Drawing.Size (32,32)
$o1.Name = 'b1'
$o1.TabIndex = 1
$o1.Text = 'b1'
$o1 | get-member
# return
$o1.Focused = $false

# 
# $o1.SetStyle([System.Windows.Forms.ControlStyles]::UserPaint -bor [System.Windows.Forms.ControlStyles]::AllPaintingInWmPaint -bor [System.Windows.Forms.ControlStyles]::DoubleBuffer,$true)


# http://www.alkanesolutions.co.uk/2013/04/19/embedding-base64-image-strings-inside-a-powershell-application/
$do = 'iVBORw0KGgoAAAANSUhEUgAAAKAAAAAgBAMAAABnUW7GAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAwUExURQAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD//////08TJkkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAFHSURBVEjH7daxjsMgDAbgKAvZ8g5dbuTVrFvMlmxku1fNRre7EmwCbk0lel1Ox/bLzidboWqGfajO/Goe5u/q7NNWnV3WZTZYHZDgWoNfElhlvgdDmd06+TIvu6zL/A++BwS+ROYxWNVlvoGO74RnkB8PBOZrSuCFTiCw7I8gZwaRxl545ZEASyuPHGnlst8k6NgfNRDyRJ0g8AYKCBwJLPsN5p29CtJIFhvgRwtMOyyogSnb89oY/LxQv2EqsQoIPFEvCLSxBgJFBiGuHE7QZVUBj5HiRDqITTDuvKAOxmzxBIt+w+8jvRkNBJqoG4S0gQpCihk8+xPo+HZr4G2kY6JuEM2CLRBHiyV49tPP0NPlVkFIE/WDENpgrstMoPNPQJzxNZCOCub6X/iTulbfHuskv2VEXeZ7cBMPSFDWtyfg737ODfMP1mxvUDAf+WQAAAAASUVORK5CYII='

$i = [convert]::FromBase64String($do)
$s = New-Object IO.MemoryStream ($i,0,$i.Length)
$s.Write($i,0,$i.Length);

$o1.Image = [System.Drawing.Image]::FromStream($s,$true)

$o2.Location = New-Object System.Drawing.Point (200,70)
$o2.Size = New-Object System.Drawing.Size (32,32)
$o2.TabIndex = 2
$o1.Name = 'b2'
$o2.Text = 'b2'
$o2.Image = $o1.Image


$o3.Location = New-Object System.Drawing.Point (200,101)
$o3.Size = New-Object System.Drawing.Size (32,32)
$o3.Name = 'b3'
$o3.TabIndex = 3
$o3.Text = 'b3'
$o3.Image = $o1.Image

$f.SuspendLayout()

[System.Windows.Forms.Button[]]$buttons = @()
$buttons += $o1
$buttons += $o2
$buttons += $o3

# http://www.codeproject.com/Articles/4479/A-Simple-Bitmap-Button-Implementation
<#
BitmapButton.cs converted to Powershell syntax.
#>

# This example will fail on W2K3 after script fails to add properties to a System.Windows.Forms.Button object

# properties to maintain the state
$btnState = New-Object PSObject
$btnState | Add-Member -MemberType 'NoteProperty'  -Name 'BUTTON_UP' -Value 0
$btnState | Add-Member -MemberType 'NoteProperty'  -Name 'BUTTON_DOWN' -Value 1
$btnState | Add-Member -MemberType 'NoteProperty'  -Name 'BUTTON_FOCUSED' -Value 2
$btnState | Add-Member -MemberType 'NoteProperty'  -Name 'BUTTON_MOUSE_ENTER' -Value 3
$btnState | Add-Member -MemberType 'NoteProperty'  -Name 'BUTTON_DISABLED' -Value 4
$btnState | Add-Member -MemberType 'NoteProperty'  -Name 'BUTTON_FAILED' -Value 5 # currently unused

$buttons | ForEach-Object {
  Add-Member -InputObject $_ -MemberType 'NoteProperty'  -Name 'ImgState' -Value $btnState.BUTTON_UP -Force
  Add-Member -InputObject $_ -MemberType 'NoteProperty'  -Name 'mouseEnter' -Value $false -Force
  Add-Member -InputObject $_ -MemberType 'NoteProperty'  -Name 'Pressed' -Value $false -Force
}
$o1.ImgState = $btnState.BUTTON_UP 
Add-Member -InputObject $o1  -MemberType 'NoteProperty'  -Name 'ImgState' -Value $btnState.BUTTON_UP -Force

# callbacks
$button_OnPaint = {
  param([object]$sender,[System.Windows.Forms.PaintEventArgs]$e)
  [System.Drawing.Graphics]$gr = $e.Graphics
  # This math is used to determine which image go show
  # TODO: refactor
  [int]$indexWidth = $sender.Size.Width * ([int]$sender.ImgState)

    $size = $sender.Size
    $size = (New-Object System.Drawing.Size ($sender.Size.Width,$sender.Size.Height))

  # if ($sender.Image.Width -gt $indexWidth)
  if ($sender.ImgState -ne $btnState.BUTTON_UP)
  {
    $point = (New-Object System.Drawing.Point ($indexWidth,0))
    $rect = New-Object System.Drawing.Rectangle ($point,$size)
    $gr.DrawImage($sender.Image,0,0,$rect,[System.Drawing.GraphicsUnit]::Pixel)
  }
  else
  {
    $point = (New-Object System.Drawing.Point (0,0))
    $rect = New-Object System.Drawing.Rectangle ($point,$size)
    $gr.DrawImage($sender.Image,0,0,$rect,[System.Drawing.GraphicsUnit]::Pixel)
  }
}

$button_OnGotFocus = {
  param(
    [object]$sender,[System.EventArgs]$e
  )
  $o1.ImgState = $btnState.BUTTON_FOCUSED
  $sender.Invalidate()
}

$button_OnLostFocus = {
  param(
    [object]$sender,[System.EventArgs]$e
  )
  if ($sender.mouseEnter)
  {
    $sender.ImgState = $btnState.BUTTON_MOUSE_ENTER
  }
  else
  {
    $sender.ImgState = $btnState.BUTTON_UP
  }
  $sender.Invalidate()
}

$button_OnMouseEnter = {
  param(
    [object]$sender,[System.EventArgs]$e
  )
  #  only show mouse enter if doesn't have focus
  if ($sender.ImgState -eq $btnState.BUTTON_UP)
  {
    $sender.ImgState = $btnState.BUTTON_MOUSE_ENTER
  }
  $sender.mouseEnter = $true
  $sender.Invalidate()
}

$button_OnMouseLeave = {
  param(
    [object]$sender,[System.EventArgs]$e
  )
  # only restore state if doesn't have focus
  if ($sender.ImgState -ne $btnState.BUTTON_FOCUSED)
  {
    $sender.ImgState = $btnState.BUTTON_UP
  }
  $sender.mouseEnter = $false
  $sender.Invalidate()

}


function find_label {
  param([string]$button_name)
  $local:label_name = $global:m[$button_name]
  if (($local:label_name -eq $null) -or ($local:label_name -eq '')) {
    $local:label_name = 'notfound'
  }
  return $local:label_name
}

$button_OnMouseDown = {
  param(
    [object]$sender,[System.Windows.Forms.MouseEventArgs]$e
  )
  $sender.ImgState = $btnState.BUTTON_DOWN
  $sender.Pressed = $true
  $local:label_name = find_label -button_name $sender.Text
  try {
    $elems = $sender.Parent.Controls.Find($local:label_name,$false)
  } catch [exception]{
    Write-Host $_.Exception.Message
  }
  if ($elems -ne $null) {
    $elems[0].Text = ('Pressed {0} "{1}"' -f $sender.Text,$sender.ImgState )
  }
  $sender.Invalidate()
}

$button_OnMouseUp = {
  param(
    [object]$sender,[System.Windows.Forms.MouseEventArgs]$e
  )
  $sender.ImgState = $btnState.BUTTON_FOCUSED
  $local:label_name = find_label -button_name $sender.Text
  try {
    $elems = $sender.Parent.Controls.Find($local:label_name,$false)
  } catch [exception]{
    Write-Host $_.Exception.Message
  }
  if ($elems -ne $null) {
    $elems[0].Text = ''
  }
  $sender.Invalidate()

}

$button_OnEnabledChanged = {
  param(
    [object]$sender,[System.EventArgs]$e
  )

  if ($sender.Enabled)
  {
    $sender.ImgState = $btnState.BUTTON_UP
  }
  else
  {
    $sender.ImgState = $btnState.BUTTON_DISABLED
  }
  $sender.Invalidate()

}


$button_OnKeyDown = {
  param(
    [object]$sender,[System.Windows.Forms.KeyEventArgs]$e
  )
  if ($e.KeyData -eq [System.Windows.Forms.Keys]::Space)
  {
    $sender.Pressed = $true
    $sender.ImgState = $btnState.BUTTON_DOWN
    try {
      $elems = $f.Controls.Find('l1',$false)
    } catch [exception]{
    }
    if ($elems -ne $null) {
      $elems[0].Text = ('Pressed {0}' -f $sender.Text)
    }
  }
  $sender.Invalidate()
}

$button_OnKeyUp = {
  param(
    [object]$sender,[System.Windows.Forms.KeyEventArgs]$e
  )
  if ($e.KeyData -eq [System.Windows.Forms.Keys]::Space)
  {
    $sender.ImgState = $btnState.BUTTON_FOCUSED
    try {
      $elems = $f.Controls.Find('l1',$false)
    } catch [exception]{
    }
    if ($elems -ne $null) {
      $elems[0].Text = ''
    }
  }
  $sender.Invalidate()
}

# hook events
$buttons | ForEach-Object {
  $_.add_Paint($button_OnPaint)
  $_.add_GotFocus($button_OnGotFocus)
  $_.add_LostFocus($button_OnLostFocus)
  $_.add_MouseEnter($button_OnMouseEnter)
  $_.add_MouseLeave($button_OnMouseLeave)
  $_.add_MouseDown($button_OnMouseDown)
  $_.add_MouseUp($button_OnMouseUp)
  $_.add_EnabledChanged($button_OnEnabledChanged)
  $_.add_KeyDown($button_OnKeyDown)
  $_.add_KeyUp($button_OnKeyUp)
}

# Form
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (263,139)
$f.Controls.AddRange(@( $l1,$l2,$l3,$o1,$o2,$o3))
$f.Name = 'form'
$f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$f.Text = 'Bitmap Button Job Launcher'
$f.ResumeLayout($false)
$f.Add_Shown({ $f.Activate() })


# http://poshcode.org/5520
# Asynchronous GUI by Peter Kriegel
# Simon Mourier See: http://stackoverflow.com/questions/14401704/update-winforms-not-wpf-ui-from-another-thread

$so = [hashtable]::Synchronized(@{
    'Visible' = [bool]$false;
    'ScriptDirectory' = [string]'';
    'Form' = [System.Windows.Forms.Form]$f;
    'Buttons' = $buttons;
  })

$Runspace = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($host)

$so.ScriptDirectory = Get-ScriptDirectory
$rs = [runspacefactory]::CreateRunspace()
$rs.ApartmentState = 'STA'
$rs.ThreadOptions = 'ReuseThread'
$rs.Open()
$rs.SessionStateProxy.SetVariable('so',$so)
$po = [System.Management.Automation.PowerShell]::Create()
$po.Runspace = $rs

$run_script = $po.AddScript({
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::Run($so.Form)
  })

$res = $po.BeginInvoke()

if ($PSBoundParameters['pause']) {
  Write-Output 'Pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}
$total_steps = 20
1..($total_steps) | ForEach-Object {

  $current_step = $_
  $message = ('Processed {0} / {1}' -f $current_step,$total_steps)
  Write-Output $message

  $so.Buttons | ForEach-Object {

    if ($_.Pressed) {
      # start-job 
      $message = ('Processing "{0}"' -f $_.Text)
      Write-Output $message
      $_.Enabled = $false
      Start-Sleep -Millisecond 1000
      # receive-job 
      $_.Enabled = $true
      Start-Sleep -Millisecond 1000
      $_.Pressed = $false
    }
  }
  Start-Sleep -Millisecond 1000

}

if ($PSBoundParameters['pause']) {
  Write-Output 'Pause'
  try {
    [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
  } catch [exception]{}
} else {
  Start-Sleep -Millisecond 1000
}

$so.Form.Close()
[System.Windows.Forms.Application]::Exit()
$po.EndInvoke($res)
$rs.Close()
$po.Dispose()
