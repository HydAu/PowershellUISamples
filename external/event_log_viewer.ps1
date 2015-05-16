#Copyright (c) 2015 Serguei Kouzmine
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


[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
$f = New-Object System.Windows.Forms.Form


# http://www.codeproject.com/Articles/14455/Eventlog-Viewer

$ts1 = New-Object System.Windows.Forms.ToolStrip
$button_error = New-Object System.Windows.Forms.ToolStripButton
$bsep1 = New-Object System.Windows.Forms.ToolStripSeparator
$button_warning = New-Object System.Windows.Forms.ToolStripButton
$bsep2 = New-Object System.Windows.Forms.ToolStripSeparator
$bm = New-Object System.Windows.Forms.ToolStripButton
$bsep4 = New-Object System.Windows.Forms.ToolStripSeparator
$sla = New-Object System.Windows.Forms.ToolStripLabel
$slo = New-Object System.Windows.Forms.ToolStripComboBox
$bsep5 = New-Object System.Windows.Forms.ToolStripSeparator
$fla = New-Object System.Windows.Forms.ToolStripLabel
$find_text = New-Object System.Windows.Forms.ToolStripTextBox
$nothing_found = New-Object System.Windows.Forms.ToolStripLabel
$data_gridview = New-Object System.Windows.Forms.DataGridView
$img_event = New-Object System.Windows.Forms.DataGridViewImageColumn
$ts1.SuspendLayout()
$f.SuspendLayout()
#
# ToolStrip1
#
$ts1.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$ts1.Items.AddRange(@( $button_error,$bsep1,$button_warning,$bsep2,$bm,$bsep4,$sla,$slo,$bsep5,$fla,$find_text,$nothing_found))
$ts1.Location = New-Object System.Drawing.Point (0,0)
$ts1.Name = "ToolStrip1"
$ts1.Padding = New-Object System.Windows.Forms.Padding (4,1,1,1)
$ts1.Size = New-Object System.Drawing.Size (728,25)
$ts1.TabIndex = 4
$ts1.Text = "ToolStrip1"
# 
# btnErrors
# 
$button_error.Checked = $true
$button_error.CheckOnClick = $true
$button_error.CheckState = [System.Windows.Forms.CheckState]::Checked
$button_error.Image = [System.Drawing.Image]::FromFile(('{0}\{1}' -f (Get-ScriptDirectory) , 'Error.gif'))

# Global.autoFocus.Components.My.Resources.Resources.ErrorGif
$button_error.ImageScaling = [System.Windows.Forms.ToolStripItemImageScaling]::None
$button_error.ImageTransparentColor = [System.Drawing.Color]::Magenta
$button_error.Name = "btnErrors"
$button_error.Size = New-Object System.Drawing.Size (63,20)
$button_error.Text = "0 Errors"
$button_error.ToolTipText = "0 Errors"
# 
# ButtonSeparator1
# 
$bsep1.Margin = New-Object System.Windows.Forms.Padding (-1,0,1,0)
$bsep1.Name = "ButtonSeparator1"
$bsep1.Size = New-Object System.Drawing.Size (6,23)
# 
# btnWarnings
# 
$button_warning.Checked = $true
$button_warning.CheckOnClick = $true
$button_warning.CheckState = [System.Windows.Forms.CheckState]::Checked
$button_warning.Image = [System.Drawing.Image]::FromFile(('{0}\{1}' -f (Get-ScriptDirectory) , 'Warning.gif'))
$button_warning.ImageScaling = [System.Windows.Forms.ToolStripItemImageScaling]::None
$button_warning.ImageTransparentColor = [System.Drawing.Color]::Magenta
$button_warning.Name = "btnWarnings"
$button_warning.Size = New-Object System.Drawing.Size (81,20)
$button_warning.Text = "0 Warnings"
$button_warning.ToolTipText = "0 Warnings"
#
# ButtonSeparator2
# 
$bsep2.Margin = New-Object System.Windows.Forms.Padding (-1,0,1,0)
$bsep2.Name = "ButtonSeparator2"
$bsep2.Size = New-Object System.Drawing.Size (6,23)
# 
# btnMessages
# 
$bm.Checked = $true
$bm.CheckOnClick = $true
$bm.CheckState = [System.Windows.Forms.CheckState]::Checked
$bm.Image = [System.Drawing.Image]::FromFile(('{0}\{1}' -f (Get-ScriptDirectory) , 'Message.gif'))
$bm.ImageScaling = [System.Windows.Forms.ToolStripItemImageScaling]::None
$bm.ImageTransparentColor = [System.Drawing.Color]::Magenta
$bm.Name = "btnMessages"
$bm.Size = New-Object System.Drawing.Size (82,20)
$bm.Text = "0 Messages"
$bm.ToolTipText = "0 Messages"
#
# SourceSeparator
# 
$bsep4.Margin = New-Object System.Windows.Forms.Padding (-1,0,1,0)
$bsep4.Name = "SourceSeparator"
$bsep4.Size = New-Object System.Drawing.Size (6,23)
#
# SourceLabel
# 
$sla.Name = "SourceLabel"
$sla.Size = New-Object System.Drawing.Size (44,20)
$sla.Text = "Source:"
#
# SourceCombo
# 
$slo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$slo.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
$slo.Font = New-Object System.Drawing.Font ("Tahoma",8.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([byte]0))
$slo.Items.AddRange(@( " "))
$slo.Margin = New-Object System.Windows.Forms.Padding (1,0,2,0)
$slo.Name = "SourceCombo"
$slo.Size = New-Object System.Drawing.Size (100,23)
$slo.Sorted = $true
#
# FindSeparator
#
$bsep5.Margin = New-Object System.Windows.Forms.Padding (0,0,1,0)
$bsep5.Name = "FindSeparator"
$bsep5.Size = New-Object System.Drawing.Size (6,23)
#
# FindLabel
#
$fla.Name = "FindLabel"
$fla.Size = New-Object System.Drawing.Size (31,20)
$fla.Text = "Find:"
#
# FindText
#
$find_text.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$find_text.ForeColor = [System.Drawing.SystemColors]::WindowText
$find_text.Name = "FindText"
$find_text.Padding = New-Object System.Windows.Forms.Padding (2,0,0,0)
$find_text.Size = New-Object System.Drawing.Size (86,23)
#
#NotFoundLabel
#
$nothing_found.Image = [System.Drawing.Image]::FromFile(('{0}\{1}' -f (Get-ScriptDirectory) , 'NotFound.gif'))
$nothing_found.Margin = New-Object System.Windows.Forms.Padding (5,1,0,2)
$nothing_found.Name = "NotFoundLabel"
$nothing_found.Size = New-Object System.Drawing.Size (103,20)
$nothing_found.Text = "No events found"
$nothing_found.ToolTipText = "There are no events that match the defined filter."
$nothing_found.Visible = $false
#
# DataGridView1
#
$data_gridview.AllowUserToAddRows = $false
$data_gridview.AllowUserToDeleteRows = $false
$data_gridview.AllowUserToResizeColumns = $false
$data_gridview.AllowUserToResizeRows = $false
$data_gridview.Anchor = [System.Windows.Forms.AnchorStyles]::Top `
   -bor [System.Windows.Forms.AnchorStyles]::Bottom `
   -bor [System.Windows.Forms.AnchorStyles]::Left `
   -bor [System.Windows.Forms.AnchorStyles]::Right
$data_gridview.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$data_gridview.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$data_gridview.CellBorderStyle = [System.Windows.Forms.DataGridViewCellBorderStyle]::None
$data_gridview.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize
$data_gridview.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$data_gridview.RowTemplate.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::Transparent
$data_gridview.AutoResizeRows([System.Windows.Forms.DataGridViewAutoSizeRowsMode]::AllCellsExceptHeaders)
$data_gridview.Columns.Add([System.Windows.Forms.DataGridViewColumn]$img_event)
$data_gridview.Location = New-Object System.Drawing.Point (0,26)
$data_gridview.MultiSelect = $false
$data_gridview.Name = "DataGridView1"
$data_gridview.ReadOnly = $true
$data_gridview.RowHeadersVisible = $false
$data_gridview.Size = New-Object System.Drawing.Size (728,320)
$data_gridview.TabIndex = 5
$data_gridview.Add_RowPrePaint({
    param(
      [object]$sender,
      [System.Windows.Forms.DataGridViewRowPrePaintEventArgs]$e
    )
    $e.PaintParts = $e.PaintParts -band (-bnot [System.Windows.Forms.DataGridViewPaintParts]::Focus)
    if (($e.State -band [System.Windows.Forms.DataGridViewElementStates]::Selected) -eq [System.Windows.Forms.DataGridViewElementStates]::Selected) {

      $row_bounds = New-Object System.Drawing.Rectangle (0,$e.RowBounds.Top,
        ($data_gridview.Columns.GetColumnsWidth([System.Windows.Forms.DataGridViewElementStates]::Visible) -
          $data_gridview.HorizontalScrollingOffset + 1),
        $e.RowBounds.Height)
      $back_brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush ($row_bounds,$data_gridview.DefaultCellStyle.SelectionBackColor,$e.InheritedRowStyle.ForeColor,[System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
      $back_brush_solid = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Blue)
      try {
        $e.Graphics.FillRectangle($back_brush,$row_bounds)
      } finally {
        $back_brush.Dispose()
      }
    }

  })
$logname = 'Application'
$event_set = New-Object System.Diagnostics.EventLog ($logname)
$event_set.EnableRaisingEvents = $true
$event_set.Add_EntryWritten({
    param(
      [object]$sender,
      [System.Diagnostics.EntryWrittenEventArgs]$e
    )
    #  does not work
  })
$data_source = New-Object System.Data.DataSet ('EventLog Entries')
[void]$data_source.Tables.Add('Events')
$t = $data_source.Tables['Events']
[void]$t.Columns.Add('EventType')
[void]$t.Columns.Add('Date/Time')

# $t.Columns["Date/Time"].DataType = [System.DateTime]
[void]$t.Columns.Add('Message')
[void]$t.Columns.Add('Source')
[void]$t.Columns.Add('Category')
[void]$t.Columns.Add('EventID')
$event_set_mock = @{ 'Entries' = @(
    @{
      'Index' = '32607';
      'EntryType' = 'Information';
      'InstanceId' = '0';
      'Message' = 'PowerEvent handled successfully by the service.';
      'Category' = '(0)';
      'CategoryNumber' = '0';
      'ReplacementStrings' = '{PowerEvent handled successfully by the service.}';
      'Source' = 'winws';
      'TimeGenerated' = '5/14/2015 7:27:48 PM';
      'TimeWritten' = '5/14/2015 7:27:48 PM';
      'UserName' = '';
    })
}
# $event_set = $event_set_mock
$MAX_EVENTLOG_ENTRIES = 10
$max_cnt = $event_set.Entries.Count - 1
if ($max_cnt -gt $MAX_EVENTLOG_ENTRIES) {
  $max_cnt = $MAX_EVENTLOG_ENTRIES
}

0..$max_cnt | ForEach-Object {
  $cnt = $_
  $event_item = $event_set.Entries[$cnt]

  # Two calls below are equivalent for mock, only 

  [void]$data_source.Tables['Events'].Rows.Add(
    @(
      $event_item.EntryType,
      $event_item.TimeGenerated,
      $event_item.Message,
      $event_item.Source,
      $event_item.Category,
      $event_item.Index
    )
  )
<#
  [void]$data_source.Tables['Events'].Rows.Add(
    @(
      $event_item['EntryType'],
      $event_item['TimeGenerated'],
      $event_item['Message'],
      $event_item['Source'],
      $event_item['Category'],
      $event_item['Index']
    )
  )
#>

<#
                    ' Increment the event type counts
                    If .EntryType = EventLogEntryType.Error Then
                        numErrors += 1
                        Continue For
                    End If

                    If .EntryType = EventLogEntryType.Warning Then
                        numWarnings += 1
                        Continue For
                    End If

                    If .EntryType = EventLogEntryType.Information Then
                        numMessages += 1
                        Continue For
                    End If

#>
}
[System.Windows.Forms.BindingSource]$bs = New-Object System.Windows.Forms.BindingSource ($data_source,'Events')
$data_gridview.DataSource = $bs
#
# EventImage
#
$img_event.HeaderText = ''
$img_event.Name = 'EventImage'
$img_event.ReadOnly = $true
$img_event.Resizable = [System.Windows.Forms.DataGridViewTriState]::True
$img_event.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::Automatic

#
#EventLogViewer
#
$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.Controls.Add($data_gridview)
$f.Controls.Add($ts1)
$f.Name = 'EventLogViewer'
$f.Size = New-Object System.Drawing.Size (728,346)
$ts1.ResumeLayout($false)
$ts1.PerformLayout()
$f.ResumeLayout($false)
$f.PerformLayout()
$f.Topmost = $True
$f.Add_Shown({ $f.Activate() })
[void]$f.ShowDialog()

$f.Dispose()
