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


# origin: http://www.codeproject.com/Articles/14455/Eventlog-Viewer
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
$f = New-Object System.Windows.Forms.Form

$ts1 = New-Object System.Windows.Forms.ToolStrip
$be = New-Object System.Windows.Forms.ToolStripButton
$bsep1 = New-Object System.Windows.Forms.ToolStripSeparator
$bw = New-Object System.Windows.Forms.ToolStripButton
$bsep2 = New-Object System.Windows.Forms.ToolStripSeparator
$bm = New-Object System.Windows.Forms.ToolStripButton
$bsep4 = New-Object System.Windows.Forms.ToolStripSeparator
$sla = New-Object System.Windows.Forms.ToolStripLabel
$slo = New-Object System.Windows.Forms.ToolStripComboBox
$bsep5 = New-Object System.Windows.Forms.ToolStripSeparator
$fla = New-Object System.Windows.Forms.ToolStripLabel
$find_text = New-Object System.Windows.Forms.ToolStripTextBox
$nothing_found = New-Object System.Windows.Forms.ToolStripLabel
$dgv = New-Object System.Windows.Forms.DataGridView
$img_event = New-Object System.Windows.Forms.DataGridViewImageColumn
$ts1.SuspendLayout()
$f.SuspendLayout()
#
# ToolStrip1
#
$ts1.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$ts1.Items.AddRange(@( $be,$bsep1,$bw,$bsep2,$bm,$bsep4,$sla,$slo,$bsep5,$fla,$find_text,$nothing_found))
$ts1.Location = New-Object System.Drawing.Point (0,0)
$ts1.Name = "ToolStrip1"
$ts1.Padding = New-Object System.Windows.Forms.Padding (4,1,1,1)
$ts1.Size = New-Object System.Drawing.Size (728,25)
$ts1.TabIndex = 4
$ts1.Text = "ToolStrip1"
# 
# btnErrors
# 
$be.Checked = $true
$be.CheckOnClick = $true
$be.CheckState = [System.Windows.Forms.CheckState]::Checked
$be.Image = [System.Drawing.Image]::FromFile("C:\developer\sergueik\csharp\eventlogviewer\EventLogViewer\Images\Error.gif")

# Global.autoFocus.Components.My.Resources.Resources.ErrorGif
$be.ImageScaling = [System.Windows.Forms.ToolStripItemImageScaling]::None
$be.ImageTransparentColor = [System.Drawing.Color]::Magenta
$be.Name = "btnErrors"
$be.Size = New-Object System.Drawing.Size (63,20)
$be.Text = "0 Errors"
$be.ToolTipText = "0 Errors"
# 
# ButtonSeparator1
# 
$bsep1.Margin = New-Object System.Windows.Forms.Padding (-1,0,1,0)
$bsep1.Name = "ButtonSeparator1"
$bsep1.Size = New-Object System.Drawing.Size (6,23)
# 
# btnWarnings
# 
$bw.Checked = $true
$bw.CheckOnClick = $true
$bw.CheckState = [System.Windows.Forms.CheckState]::Checked
$bw.Image = [System.Drawing.Image]::FromFile("C:\developer\sergueik\csharp\eventlogviewer\EventLogViewer\Images\Warning.gif")
$bw.ImageScaling = [System.Windows.Forms.ToolStripItemImageScaling]::None
$bw.ImageTransparentColor = [System.Drawing.Color]::Magenta
$bw.Name = "btnWarnings"
$bw.Size = New-Object System.Drawing.Size (81,20)
$bw.Text = "0 Warnings"
$bw.ToolTipText = "0 Warnings"
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
$bm.Image = [System.Drawing.Image]::FromFile("C:\developer\sergueik\csharp\eventlogviewer\EventLogViewer\Images\Message.gif")
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
$nothing_found.Image = [System.Drawing.Image]::FromFile("C:\developer\sergueik\csharp\eventlogviewer\EventLogViewer\Images\NotFound.gif")
$nothing_found.Margin = New-Object System.Windows.Forms.Padding (5,1,0,2)
$nothing_found.Name = "NotFoundLabel"
$nothing_found.Size = New-Object System.Drawing.Size (103,20)
$nothing_found.Text = "No events found"
$nothing_found.ToolTipText = "There are no events that match the defined filter."
$nothing_found.Visible = $false
#
# DataGridView1
#
$dgv.AllowUserToAddRows = $false
$dgv.AllowUserToDeleteRows = $false
$dgv.AllowUserToResizeColumns = $false
$dgv.AllowUserToResizeRows = $false
$dgv.Anchor = [System.Windows.Forms.AnchorStyles]::Top `
   -bor [System.Windows.Forms.AnchorStyles]::Bottom `
   -bor [System.Windows.Forms.AnchorStyles]::Left `
   -bor [System.Windows.Forms.AnchorStyles]::Right
$dgv.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$dgv.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$dgv.CellBorderStyle = [System.Windows.Forms.DataGridViewCellBorderStyle]::None
$dgv.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize
$dgv.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$dgv.RowTemplate.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::Transparent
$dgv.AutoResizeRows([System.Windows.Forms.DataGridViewAutoSizeRowsMode]::AllCellsExceptHeaders)
$dgv.Columns.Add([System.Windows.Forms.DataGridViewColumn]$img_event)
$dgv.Location = New-Object System.Drawing.Point (0,26)
$dgv.MultiSelect = $false
$dgv.Name = "DataGridView1"
$dgv.ReadOnly = $true
$dgv.RowHeadersVisible = $false
$dgv.Size = New-Object System.Drawing.Size (728,320)
$dgv.TabIndex = 5
$logname = "System"
$e_set = New-Object System.Diagnostics.EventLog ($logname)
$e_set.EnableRaisingEvents = $true
$e_set.Add_EntryWritten({
    param(

      [object]$sender,
      [System.Diagnostics.EntryWrittenEventArgs]$e
    )

    #  does not work

  })

$ds = New-Object System.Data.DataSet ('EventLog Entries')
[void]$ds.Tables.Add('Events')
$t = $ds.Tables['Events']

[void]$t.Columns.Add('EventType')
[void]$t.Columns.Add('Date/Time')
# $t.Columns["Date/Time"].DataType = [System.DateTime]
[void]$t.Columns.Add('Message')
[void]$t.Columns.Add('Source')
[void]$t.Columns.Add('Category')
[void]$t.Columns.Add('EventID')
<#
$e_set_mock = @(

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

 0..($e_set_mock.Count - 1) | ForEach-Object {
#>
0..($e_set.Entries.Count - 1) | ForEach-Object {


  $cnt = $_
  $e_item = $e_set.Entries[$cnt]

  [void]$ds.Tables['Events'].Rows.Add(
    @(
      $e_item.EntryType,
      $e_item.TimeGenerated,
      $e_item.Message,
      $e_item.Source,
      $e_item.Category,
      $e_item.Index
    )
  )
  [void]$ds.Tables['Events'].Rows.Add(
    @(
      $e_item['EventType'],
      $e_item['TimeGenerated'],
      $e_item['Message'],
      $e_item['Source'],
      $e_item['Category'],
      $e_item['Index']
    )
  )

}
[System.Windows.Forms.BindingSource]$bs = New-Object System.Windows.Forms.BindingSource ($ds,'Events')

# Bind the datagridview
$dgv.DataSource = $bs
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
$f.Controls.Add($dgv)
$f.Controls.Add($ts1)
$f.Name = 'EventLogViewer'
$f.Size = New-Object System.Drawing.Size (728,346)
$ts1.ResumeLayout($false)
$ts1.PerformLayout()
# CType($dgv, System.ComponentModel.ISupportInitialize).EndInit()
$f.ResumeLayout($false)
$f.PerformLayout()

$f.Topmost = $True

$f.Add_Shown({ $f.Activate() })

[void]$f.ShowDialog()
$f.Dispose()
