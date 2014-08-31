# http://stackoverflow.com/questions/3327003/powershell-exit-does-not-work
# http://social.technet.microsoft.com/Forums/scriptcenter/en-US/f9de89d7-b2e5-4051-a241-f8f76f297fe6/stoping-powershell-script

function promptForContinueAuto ($title,$message)
{


  [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

  $objForm = New-Object System.Windows.Forms.Form

  $objForm.Text = $title

  $objForm.Size = New-Object System.Drawing.Size (640,430)

  $ad = ""

  $objForm.StartPosition = "CenterScreen"

  $ManualButton = New-Object System.Windows.Forms.Button
  $ManualButton.Location = New-Object System.Drawing.Size (75,350)
  $ManualButton.Size = New-Object System.Drawing.Size (75,23)
  $ManualButton.Text = "Manual"



  $ManualButton.add_click({

      if ($objADcheckbox.Checked -eq "True") {
        $ad = "Checked" } else { $ad = $objTextBox.Text }; $GetKB = $objKBBox.Text;
      $ps = $objOutBox.Text; $SCCM = $objSCCMBox.Text
      $objForm.Close()
    }

  )

  $objForm.Controls.Add($ManualButton)

  $ManualButton = New-Object System.Windows.Forms.Button
  $AutoButton = New-Object System.Windows.Forms.Button
  $AutoButton.Location = New-Object System.Drawing.Size (170,350)
  $AutoButton.Size = New-Object System.Drawing.Size (75,23)
  $AutoButton.Text = "Auto"



  $AutoButton.add_click({

      if ($objADcheckbox.Checked -eq "True") {
        $ad = "Checked" } else { $ad = $objTextBox.Text }; $GetKB = $objKBBox.Text;
      $ps = $objOutBox.Text; $SCCM = $objSCCMBox.Text
      $objForm.Close()
    }

  )

  $objForm.Controls.Add($AutoButton)


  $CancelButton = New-Object System.Windows.Forms.Button
  $CancelButton.Location = New-Object System.Drawing.Size (260,350)
  $CancelButton.Size = New-Object System.Drawing.Size (75,23)
  $CancelButton.Text = "Cancel"
  $CancelButton.add_click({ $objForm.Close(); Stop-Process -processname powershell })

  $objForm.Controls.Add($CancelButton)


  $objLblComplist = New-Object System.Windows.Forms.label

  $objLblComplist.Location = New-Object System.Drawing.Size (30,30)

  $objLblComplist.Size = New-Object System.Drawing.Size (400,20)

  $objLblComplist.Text = $message

  $objForm.Controls.Add($objLblComplist)

  $objTextBox = New-Object System.Windows.Forms.Textbox

  $objTextBox.Location = New-Object System.Drawing.Size (30,50)

  $objTextBox.Size = New-Object System.Drawing.Size (280,20)

  $objTextBox.Text = ""

  $objForm.Controls.Add($objTextBox)

  $objADcheckbox = New-Object System.Windows.Forms.checkbox

  $objADcheckbox.Location = New-Object System.Drawing.Size (75,90)

  $objADcheckbox.Size = New-Object System.Drawing.Size (20,20)

  $objForm.Controls.Add($objADcheckbox)

  $objADcheckbox.add_click({ if ($objADcheckbox.Checked -eq $true) { $objTextBox.Visible = $false } else { $objTextBox.Visible = $true } })

  $objBoxLbl = New-Object System.Windows.Forms.label

  $objBoxLbl.Location = New-Object System.Drawing.Size (93,92)

  $objBoxLbl.Size = New-Object System.Drawing.Size (300,20)

  $objBoxLbl.Text = "Check the box for AD"

  $objForm.Controls.Add($objBoxLbl)

  $objKBBox = New-Object System.Windows.Forms.Textbox

  $objKBBox.Location = New-Object System.Drawing.Size (30,150)

  $objKBBox.Size = New-Object System.Drawing.Size (280,20)

  $objKBBox.Text = ""

  $objForm.Controls.Add($objKBBox)

  $objKBlbl = New-Object System.Windows.Forms.label

  $objKBlbl.Location = New-Object System.Drawing.Size (93,130)

  $objKBlbl.Size = New-Object System.Drawing.Size (300,20)

  $objKBlbl.Text = "Enter KB Number (ex:KB12345)"

  $objForm.Controls.Add($objKBlbl)

  $objOutBox = New-Object System.Windows.Forms.Textbox

  $objOutBox.Location = New-Object System.Drawing.Size (30,220)

  $objOutBox.Size = New-Object System.Drawing.Size (280,20)

  $objOutBox.Text = ""

  $objForm.Controls.Add($objOutBox)

  $objOutlbl = New-Object System.Windows.Forms.label

  $objOutlbl.Location = New-Object System.Drawing.Size (62,200)

  $objOutlbl.Size = New-Object System.Drawing.Size (300,20)

  $objOutlbl.Text = "Enter OutPut Path (ex: C:\JoeIsAwesome)"

  $objForm.Controls.Add($objOutlbl)

  $objSCCMBox = New-Object System.Windows.Forms.Textbox

  $objSCCMBox.Location = New-Object System.Drawing.Size (30,290)

  $objSCCMBox.Size = New-Object System.Drawing.Size (280,20)

  $objSCCMBox.Text = ""

  $objForm.Controls.Add($objSCCMBox)

  $objSCCMlbl = New-Object System.Windows.Forms.label

  $objSCCMlbl.Location = New-Object System.Drawing.Size (35,270)

  $objSCCMlbl.Size = New-Object System.Drawing.Size (300,20)
  $objSCCMlbl.Text = "Enter SCCM Share (ex: \\JoeIsAwesome\smspkgs$)"
  $objForm.Controls.Add($objSCCMlbl)

  $objForm.Topmost = $True
  $objForm.Add_Shown({ $objForm.Activate() })
  [void]$objForm.ShowDialog()

  switch ($result)
  {
    0 { return $false }
    1 { return $true }
    2 { Write-Host `n"Process Halted At Step: " $title`n
      break }
  }

}

$sitecorehostnames = "ccluatecocms1"
promptForContinueAuto ("StepName - Rollback Authoring CMS ($sitecorehostnames)","Rename KeepaliveON to KeepAliveOFF")
