# http://stackoverflow.com/questions/3327003/powershell-exit-does-not-work
# http://social.technet.microsoft.com/Forums/scriptcenter/en-US/f9de89d7-b2e5-4051-a241-f8f76f297fe6/stoping-powershell-script

function promptForContinueAuto($title, $message)
{
write-output '-----'
write-output $message
write-output '-----'
$message = "Rename KeepaliveON to KeepAliveOFF"
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = $title
$objForm.Size = New-Object System.Drawing.Size(640, 430)

$objForm.StartPosition = 'CenterScreen'
$objForm.Topmost = $True

$ManualButton = New-Object System.Windows.Forms.Button
$ManualButton.Location = New-Object System.Drawing.Size(75, 350)
$ManualButton.Size = New-Object System.Drawing.Size(75, 23)
$ManualButton.Text = "Manual"

$ManualButton.Add_Click({

if ($objADcheckbox.checked -eq "True") { 
$ad = "Checked" } else { $ad = $objTextBox.text } ;$GetKB = $objKBBox.text;
$ps = $objOutBox.text ; $SCCM = $objSCCMBox.text
$objForm.Close()
}

)

$objForm.Controls.Add($ManualButton)

$ManualButton = New-Object System.Windows.Forms.Button
$AutoButton = New-Object System.Windows.Forms.Button
$AutoButton.Location = New-Object System.Drawing.Size(170, 350)
$AutoButton.Size = New-Object System.Drawing.Size(75, 23)
$AutoButton.Text = "Auto"



$AutoButton.Add_Click({

if ($objADcheckbox.checked -eq "True") { 
$ad = "Checked" } else { $ad = $objTextBox.text } ;$GetKB = $objKBBox.text;
$ps = $objOutBox.text ; $SCCM = $objSCCMBox.text
$objForm.Close()
}

)

$objForm.Controls.Add($AutoButton)


$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(260, 350)
$CancelButton.Size = New-Object System.Drawing.Size(75, 23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({ $objForm.Close(); Stop-Process -processname powershell })

$objForm.Controls.Add($CancelButton)


$objLblComplist = New-Object System.Windows.Forms.label
$objLblComplist.Location = New-Object System.Drawing.Size(30, 30)
$objLblComplist.Size = New-Object System.Drawing.Size(400, 20)
$objLblComplist.Text = $message
$objForm.Controls.Add($objLblComplist)


$objForm.Add_Shown({ $objForm.Activate() })
[void]$objForm.ShowDialog()

switch ($result)
	{
		0 {return $false}
		1 {return  $true}
		2 {Write-Host `n"Process Halted At Step: " $title`n ; break}
	}	

}

$sitecorehostnames = "ccluatecocms1"
promptForContinueAuto "StepName - Rollback Authoring CMS ($sitecorehostnames)" ,"Rename KeepaliveON to KeepAlivsssOFF"