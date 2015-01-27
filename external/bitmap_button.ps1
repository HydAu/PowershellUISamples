
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
$o1.Size = New-Object System.Drawing.Size (16,15)
$l1.TabIndex = 1
$o1.Name = 'b1'
# tabindex 1 is a tabu
# http://www.iconspedia.com/icon/arrow-mini-left-icon-23724.html
$o1.TabIndex = 2
$o1.Text = "b1"
# http://www.alkanesolutions.co.uk/2013/04/19/embedding-base64-image-strings-inside-a-powershell-application/

$do = 'iVBORw0KGgoAAAANSUhEUgAAAKAAAAAgBAMAAABnUW7GAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAwUExURQAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD//////08TJkkAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAFHSURBVEjH7daxjsMgDAbgKAvZ8g5dbuTVrFvMlmxku1fNRre7EmwCbk0lel1Ox/bLzidboWqGfajO/Goe5u/q7NNWnV3WZTZYHZDgWoNfElhlvgdDmd06+TIvu6zL/A++BwS+ROYxWNVlvoGO74RnkB8PBOZrSuCFTiCw7I8gZwaRxl545ZEASyuPHGnlst8k6NgfNRDyRJ0g8AYKCBwJLPsN5p29CtJIFhvgRwtMOyyogSnb89oY/LxQv2EqsQoIPFEvCLSxBgJFBiGuHE7QZVUBj5HiRDqITTDuvKAOxmzxBIt+w+8jvRkNBJqoG4S0gQpCihk8+xPo+HZr4G2kY6JuEM2CLRBHiyV49tPP0NPlVkFIE/WDENpgrstMoPNPQJzxNZCOCub6X/iTulbfHuskv2VEXeZ7cBMPSFDWtyfg737ODfMP1mxvUDAf+WQAAAAASUVORK5CYII='

$i = [convert]::FromBase64String($do)
$s = New-Object IO.MemoryStream ($i,0,$i.Length)
$s.Write($i,0,$i.Length);
$o1.Image = [System.Drawing.Image]::FromStream($s,$true)

$o1.Image = New-Object System.Drawing.Bitmap ([System.IO.Path]::Combine((Get-ScriptDirectory),"downArrow16.bmp"))


$o2 = New-Object -TypeName 'BitmapButton.BitmapButton'

$o2.Location = New-Object System.Drawing.Point (200,70)
$o2.Size = New-Object System.Drawing.Size (16,15)
$o2.TabIndex = 3
$o1.Name = 'b2'
$o2.Text = "b2"
$o2.Image = $o1.Image



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
$o2.add_KeyUp($button_OnKeyUp)

# Form
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (263,109)
$f.Controls.AddRange(@( $l1,$l2,$o1,$o2))
$f.Name = 'form'
$f.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$f.Text = 'Bitmap Button Demo'
$f.ResumeLayout($false)
$f.Add_Shown({ $f.Activate() })
[void]$f.ShowDialog()
