#Copyright (c) 2014,2015 Serguei Kouzmine
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


# http://stackoverflow.com/questions/16789399/looking-for-time-picker-control-with-half-hourly-up-down

Add-Type -TypeDefinition @"
public class CustomTimePicker : System.Windows.Forms.DomainUpDown
{
    public CustomTimePicker()
    {         
        // build the list of times, in reverse order because the up/down buttons go the other way
        for (double time = 23.5; time >= 0; time -= 0.5)
        {
            int hour = (int)time; // cast to an int, we only get the whole number which is what we want
            int minutes = (int)((time - hour) * 60); // subtract the hour from the time variable to get the remainder of the hour, then multiply by 60 as .5 * 60 = 30 and 0 * 60 = 0

            this.Items.Add(hour.ToString("00") + ":" + minutes.ToString("00")); // format the hour and minutes to always have two digits and concatenate them together with the colon between them, then add to the Items collection
        }

        this.SelectedIndex = Items.IndexOf("09:00"); // select a default time

        this.Wrap = true; // this enables the picker to go to the first or last item if it is at the end of the list (i.e. if the user gets to 23:30 it wraps back around to 00:00 and vice versa)
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'

$form_onload = {
   $script:numeric_value = 0
   $script:time_value = ''
   $script:custom_value= ''
}

function UpDownsPrompt
{
  param(
    [object]$caller
  )
  @( 'System.Drawing',
    'System.Collections.Generic',
    'System.Collections',
    'System.ComponentModel',
    'System.Windows.Forms',
    'System.Text',
    'System.Data'
  ) | ForEach-Object { $assembly = $_; [void][System.Reflection.Assembly]::LoadWithPartialName($assembly) }

  $f = New-Object System.Windows.Forms.Form

  $f.Size = New-Object System.Drawing.Size (180,120)
  $n = New-Object System.Windows.Forms.NumericUpDown
  $n.SuspendLayout()

  $n.Parent = $this
  $n.Location = New-Object System.Drawing.Point (30,80)
  $n.Size = New-Object System.Drawing.Size (50,20)
  $n.Value = 1
  $n.Minimum = 0
  $n.Maximum = 1000
  $n.Increment = 1
  $n.DecimalPlaces = 0
  $n.ReadOnly = $false
  $n.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right

  ($n.add_ValueChanged).Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )

      $script:numeric_value = $n.Value
    }
  )

  $c = New-Object CustomTimePicker
  $c.Parent = $f
  $c.Location = New-Object System.Drawing.Point (30,50)
  $c.Size = New-Object System.Drawing.Size (70,20)
  $c.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Left
  $c.ReadOnly = $true

  ($c.add_TextChanged).Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
        $script:custom_value = $c.SelectedItem.ToString()
    }
  )

  $c.SuspendLayout()

  $c.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $c.ReadOnly = $true

  $c.TabIndex = 0
  $c.TabStop = $false

  $s = New-Object System.Windows.Forms.DateTimePicker
  $s.Parent = $f
  $s.Location = New-Object System.Drawing.Point (30,20)
  $s.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $s.Size = New-Object System.Drawing.Size (70,20)
  $s.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
  $s.CustomFormat = 'hh:mm'
  $s.ShowUpDown = $true
  $s.Checked = $false
  $s.Add_VisibleChanged({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs)
      $script:datetime_value = $s.Value

    })

  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $f.ClientSize = New-Object System.Drawing.Size (180,120)
  $components = New-Object System.ComponentModel.Container

  $f.Controls.AddRange(@( $c,$n,$s))

  $f.Name = 'Form1'
  $f.Text = 'UpDown Sample'
  $c.ResumeLayout($false)
  $n.ResumeLayout($false)
  $f.ResumeLayout($false)

  $f.StartPosition = 'CenterScreen'

  $f.KeyPreview = $True

  $f.Topmost = $True
  $f.Add_Shown({ $f.Activate() })

  [void]$f.ShowDialog()
  $f.add_Load($form_onload)

  $f.Dispose()
}

$DebugPreference = 'Continue'
UpDownsPrompt

Write-Debug ('Time Selection is : {0}' -f $script:datetime_value )
Write-Debug ('Numeric Value is : {0}' -f $script:numeric_value)
Write-Debug ('Custom contol Value is : {0}' -f $script:custom_value)
