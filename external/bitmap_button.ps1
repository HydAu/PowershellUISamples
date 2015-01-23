
# http://www.codeproject.com/Articles/4479/A-Simple-Bitmap-Button-Implementation

<#
BitmapButton.cs
#>
# $DebugPreference = 'Continue'

param(
  [switch]$pause
)
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Windows.Forms;

namespace BitmapButton
{
    public class BitmapButton : Button
    {
        enum btnState
        {
            BUTTON_UP=0,
            BUTTON_DOWN=1,
            BUTTON_FOCUSED=2,
            BUTTON_MOUSE_ENTER=3,
            BUTTON_DISABLED=4,
        }

        btnState imgState=btnState.BUTTON_UP;
        bool mouseEnter=false;

        public BitmapButton()
        {
            // enable double buffering.  Must be done by a derived class
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.DoubleBuffer, true);

            // initialize event handlers
            Paint+=new PaintEventHandler(BitmapButton_Paint);
            MouseDown+=new MouseEventHandler(BitmapButton_MouseDown);
            MouseUp+=new MouseEventHandler(BitmapButton_MouseUp);
            GotFocus+=new EventHandler(BitmapButton_GotFocus);
            LostFocus+=new EventHandler(BitmapButton_LostFocus);
            MouseEnter+=new EventHandler(BitmapButton_MouseEnter);
            MouseLeave+=new EventHandler(BitmapButton_MouseLeave);
            KeyDown+=new KeyEventHandler(BitmapButton_KeyDown);
            KeyUp+=new KeyEventHandler(BitmapButton_KeyUp);
            EnabledChanged+=new EventHandler(BitmapButton_EnabledChanged);
        }

        private void BitmapButton_Paint(object sender, PaintEventArgs e)
        {
            Graphics gr=e.Graphics;
            int indexWidth=Size.Width*(int)imgState;

            if (Image.Width > indexWidth)
            {
                gr.DrawImage(Image, 0, 0, new Rectangle(new Point(indexWidth, 0), Size), GraphicsUnit.Pixel);
            }
            else
            {
                gr.DrawImage(Image, 0, 0, new Rectangle(new Point(0, 0), new Size(Size.Width, Size.Height)), GraphicsUnit.Pixel);
            }
        }

        private void BitmapButton_MouseDown(object sender, MouseEventArgs e)
        {
            imgState=btnState.BUTTON_DOWN;
            Invalidate();
        }

        private void BitmapButton_MouseUp(object sender, MouseEventArgs e)
        {
            imgState=btnState.BUTTON_FOCUSED;
            Invalidate();
        }

        private void BitmapButton_GotFocus(object sender, EventArgs e)
        {
            imgState=btnState.BUTTON_FOCUSED;
            Invalidate();
        }

        private void BitmapButton_LostFocus(object sender, EventArgs e)
        {
            if (mouseEnter)
            {
                imgState=btnState.BUTTON_MOUSE_ENTER;
            }
            else
            {
                imgState=btnState.BUTTON_UP;
            }
            Invalidate();
        }

        private void BitmapButton_MouseEnter(object sender, EventArgs e)
        {
            // only show mouse enter if doesn't have focus
            if (imgState==btnState.BUTTON_UP)
            {
                imgState=btnState.BUTTON_MOUSE_ENTER;
            }
            mouseEnter=true;
            Invalidate();
        }

        private void BitmapButton_MouseLeave(object sender, EventArgs e)
        {
            // only restore state if doesn't have focus
            if (imgState != btnState.BUTTON_FOCUSED)
            {
                imgState=btnState.BUTTON_UP;
            }
            mouseEnter=false;
            Invalidate();
        }

        private void BitmapButton_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyData==Keys.Space)
            {
                imgState=btnState.BUTTON_DOWN;
                Invalidate();
            }
        }

        private void BitmapButton_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyData==Keys.Space)
            {
                // still has focus
                imgState=btnState.BUTTON_FOCUSED;
                Invalidate();
            }
        }

        private void BitmapButton_EnabledChanged(object sender, EventArgs e)
        {
            if (Enabled)
            {
                imgState=btnState.BUTTON_UP;
            }
            else
            {
                imgState=btnState.BUTTON_DISABLED;
            }
            Invalidate();
        }
    }
}
"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll','System.Data.dll'


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
$o1 = New-Object -TypeName 'BitmapButton.BitmapButton'

$o1.Location = New-Object System.Drawing.Point (200,32)
$o1.Size = New-Object System.Drawing.Size (32,32)
$o1.Name = 'b1'
$o1.TabIndex = 1
$o1.Text = "b1"
$o1.Image = New-Object System.Drawing.Bitmap ([System.IO.Path]::Combine((Get-ScriptDirectory),"downArrow.bmp"))


$o2 = New-Object -TypeName 'BitmapButton.BitmapButton'

$o2.Location = New-Object System.Drawing.Point (200,70)
$o2.Size = New-Object System.Drawing.Size (32,32)
$o2.TabIndex = 2
$o1.Name = 'b2'
$o2.Text = "b2"
$o2.Image = New-Object System.Drawing.Bitmap ([System.IO.Path]::Combine((Get-ScriptDirectory),"downArrow.bmp"))


$do = 'iVBORw0KGgoAAAANSUhEUgAAAKAAAAAgBAMAAABnUW7GAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAwUExURQAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD//////08TJkkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAFHSURBVEjH7daxjsMgDAbgKAvZ8g5dbuTVrFvMlmxku1fNRre7EmwCbk0lel1Ox/bLzidboWqGfajO/Goe5u/q7NNWnV3WZTZYHZDgWoNfElhlvgdDmd06+TIvu6zL/A++BwS+ROYxWNVlvoGO74RnkB8PBOZrSuCFTiCw7I8gZwaRxl545ZEASyuPHGnlst8k6NgfNRDyRJ0g8AYKCBwJLPsN5p29CtJIFhvgRwtMOyyogSnb89oY/LxQv2EqsQoIPFEvCLSxBgJFBiGuHE7QZVUBj5HiRDqITTDuvKAOxmzxBIt+w+8jvRkNBJqoG4S0gQpCihk8+xPo+HZr4G2kY6JuEM2CLRBHiyV49tPP0NPlVkFIE/WDENpgrstMoPNPQJzxNZCOCub6X/iTulbfHuskv2VEXeZ7cBMPSFDWtyfg737ODfMP1mxvUDAf+WQAAAAASUVORK5CYII='

$i = [Convert]::FromBase64String($do)
$s = New-Object IO.MemoryStream($i, 0, $i.Length)
$s.Write($i, 0, $i.Length);
$o2.Image = [System.Drawing.Image]::FromStream($s, $true)


$f.SuspendLayout()

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

# dDControls
$o1.Name = "b1"
$o1.TabIndex = 1
$global:m = @{
  'b1' = 'l1';
  'b2' = 'l2';
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
  $local:label_name = find_label -button_name $sender.Text
  try {
    $elems = $sender.Parent.Controls.Find($local:label_name,$false)
  } catch [exception]{
    Write-Host $_.Exception.Message
  }
  if ($elems -ne $null) {
    $elems[0].Text = ('Pressed {0}' -f $sender.Text)
  }
}

$o1.add_MouseDown($button_OnMouseDown)
$o2.add_MouseDown($button_OnMouseDown)
$button_OnMouseUp = {
  param(
    [object]$sender,[System.Windows.Forms.MouseEventArgs]$e
  )
  $local:label_name = find_label -button_name $sender.Text
  try {
    $elems = $sender.Parent.Controls.Find($local:label_name,$false)
  } catch [exception]{
    Write-Host $_.Exception.Message
  }
  if ($elems -ne $null) {
    $elems[0].Text = ''
  }
}

$o1.add_MouseUp($button_OnMouseUp)
$o2.add_MouseUp($button_OnMouseUp)
$button_OnEnabledChanged = {
  param(
    [object]$sender,[System.EventArgs]$e
  )
}

$o1.add_EnabledChanged($button_OnEnabledChanged)
$o2.add_EnabledChanged($button_OnEnabledChanged)

$button_OnKeyDown = {
  param(
    [object]$sender,[System.Windows.Forms.KeyEventArgs]$e
  )
  if ($e.KeyData -eq [System.Windows.Forms.Keys]::Space)
  {
    try {
      $elems = $f.Controls.Find('l1',$false)
    } catch [exception]{
    }
    if ($elems -ne $null) {
      $elems[0].Text = ('Pressed {0}' -f $sender.Text)
    }
  }
}

$o1.add_KeyDown($button_OnKeyDown)
$o2.add_KeyDown($button_OnKeyDown)
$button_OnKeyUp = {
  param(
    [object]$sender,[System.Windows.Forms.KeyEventArgs]$e
  )
  if ($e.KeyData -eq [System.Windows.Forms.Keys]::Space)
  {
    try {
      $elems = $f.Controls.Find('l1',$false)
    } catch [exception]{
    }
    if ($elems -ne $null) {
      $elems[0].Text = ''
    }
  }
}

$o1.add_KeyUp($button_OnKeyUp)

# Form
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (263,109)
$f.Controls.AddRange(@( $l1,$l2,$o1,$o2))
$f.Name = 'form'
$f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$f.Text = 'Bitmap Button Demo'
$f.ResumeLayout($false)
# http://www.alkanesolutions.co.uk/2013/04/19/embedding-base64-image-strings-inside-a-powershell-application/
$f.Add_Shown({ $f.Activate() })
[void]$f.ShowDialog()

<#
$base64ImageString = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAT6SURBVFhHvZcPbBNVHMe/1+tdu26l3R+3zmHt2ABF2TTqcNFgNhN0glXUKIbEaCBqjMZoTJyRIDGOhAiJiqKJI5iJGMmUsIyoaEDHIpapiWRjEGBL9rfAtnZr17W93p3v2lfWXu/2Bxc+6Uvf33u/936/+/1+xzy/0yljARAEkdb0MfEcDAYGMXF6roH+/284jp21iJIIIRajKxIsmABzgWGYeEnlugqgxZxtQJYERIUQBCkGSSZLEr+rJE5mAMvy4HkLONVJ9ZhVAFkWEY34EEEuiopWwJFth4k1ko1YJLeQJZnMI4JJYUxODWBwqBs+KQvZWRawGk9niCEmmVEAWSanDoeQ51qPypL7UHXnM6i0W+moNtHQP/D82YRTg7+j43wPjDk2sHQsiYGdqwAREc6KV/FUbT0qLLRzroRPovWXbfju9BkYzfqmpjsiywHwy+qxae01bK5grsa6R3fjMedkQkUpJRXdG2Cjy+F+6SjcebQjlZEWHO5sgy9K6mw+nKXPonaJKzGmItazCRubj8JM24r+U19F9o41tm20ngZ39wG8taKAtqaJXK5Hw6GP0Xb2V3T1d+Dc4Cmc6zuBrqwHUF2Ul6lvI4/Ov1sxTn1AqgEq6KqA6f8Ae4/vwonersRJ40yh4/DX6BwdB8vfgEUWUswWxCbPoLvtRwxJdFoq5nwsV/ZMFhX6RhgLkVePI/47B2bODCPLkdNFERz3QSRuVUEirlWMTSAYChD//hDefecnVGe8JF048mEdDtKWEgtS0TdC1gxOCRxRP8YDQ7ji68XQSC9GI154R/vQd6kPXv8gpOwarH2yBZ++fRD35NDFahiZXH+iqJnVEUnEA04GhjEWIgZjd6C68hXUVTyOpUW3osBspLNmgtzArkfQTFtqdAWQZQmx8AB8Uyyq3L/h9VX3w07H5kcXWndOC6D20LoqkIQRMM4vcaAhhveuefMEBrJLsqjRFEBxwbxjHxqf2wwb7dNDDPehq/t9fLZ3IzwTtHMeaArAyCzq1m+AibbTkEbg7dmDTxrtcG9h4N5+M7Z8vwMn/TxMmk8jECXHA6iGsjWXWKzbsVrrzoULOPZtIV785k10TNhwo6MMzsIyOOzFsLJWGHVsUiZ6V3Sv1r+CtgpcrquuM43RH7Bn2IXFeYthNZH8LvlgOYSw5V4Uai5S5ui/htoCpKUaKWQtwUrOh3AskVQyJAcQImMIiCW47cEaFMZ7M2HIFSSLGk0BDL7LEGg9DdvD2HyXGy5TMO6cxsIRWB3rsHrVbrxRVkwnqSHeUkxeVaYAmn6Awy3Y8PLPqM2mHSouXfwCHq8fMb4Q5eUvoCI388HTnMfxxhrsDxrjoUAU07fTFECSAii+vRFb657AfFMBJelOt8UwLrQvQ8NfBjDx1I12U7RVYLBi+PRWfH6sBT7aNysjX6HpSCOG09N+ghlO19MkjisHy7Qt3XxAxjj6B9rRe+UsgsaluCk/n6hGjYjA0H40t+/AIU8T/ujxoKTqNZSrJrKL1qB0/CN4RmlHCjMGI5lkuVEhCi67FAXWXGQpIZkakpIti1IIU5MD8E6MQWCyYeFkWGwrUWhKVwJv4iEH/8VFf+ZWs0ZDJSiJ4lT8k0oi9enJSoZjIBmuGSaj4hMSggkRPyLqvI/MYzkbzOp0iTCrAAuBTC1P/VmmoGmEC008F9TYXOG6CKAP8B8y8tsX2eJriwAAAABJRU5ErkJggg=="
$imageBytes = [Convert]::FromBase64String($base64ImageString)
$ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
$ms.Write($imageBytes, 0, $imageBytes.Length);
$alkanelogo = [System.Drawing.Image]::FromStream($ms, $true)
$oms = New-Object IO.MemoryStream
$o2.Image.Save($oms, [System.Drawing.Imaging.ImageFormat]::Png)
$result = [System.Convert]::ToBase64String($oms.ToArray())
write-output $result  | Out-File ([System.IO.Path]::Combine((Get-ScriptDirectory),"downArrow.converted.txt"))
#>