#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the 'Software'), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# http://www.codeproject.com/Articles/16186/DialogBoxes
@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }

function TextInputBox {
  param(
    $prompt_message = 'Enter the Value',
    $caption = 'Inputbox Test'
  )
  $script:result = @{ 'text' = ''; 'status' = $null; }
  $form = New-Object System.Windows.Forms.Form
  $label_prompt = New-Object System.Windows.Forms.Label
  $button_ok = New-Object System.Windows.Forms.Button
  $button_cancel = New-Object System.Windows.Forms.Button
  $text_input = New-Object System.Windows.Forms.TextBox
  $form.SuspendLayout()
  $label_prompt.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $label_prompt.BackColor = [System.Drawing.SystemColors]::Control
  $label_prompt.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $label_prompt.Location = New-Object System.Drawing.Point (12,9)
  $label_prompt.Name = 'lblPrompt'
  $label_prompt.Size = New-Object System.Drawing.Size (302,82)
  $label_prompt.TabIndex = 3
  $label_prompt.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $button_ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $button_ok.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
  $button_ok.Location = New-Object System.Drawing.Point (326,8)
  $button_ok.Name = 'button_ok'
  $button_ok.Size = New-Object System.Drawing.Size (64,24)
  $button_ok.TabIndex = 1
  $button_ok.Text = '&OK'
  $button_ok.Add_Click({
      param([object]$sender,[System.EventArgs]$e)
      $script:result.status = [System.Windows.Forms.DialogResult]::OK
      $script:result.Text = $text_input.Text
      $form.Dispose()
    })
  $button_ok.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $button_cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $button_cancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
  $button_cancel.Location = New-Object System.Drawing.Point (326,40)
  $button_cancel.Name = 'button_cancel'
  $button_cancel.Size = New-Object System.Drawing.Size (64,24)
  $button_cancel.TabIndex = 2
  $button_cancel.Text = '&Cancel'
  $button_cancel.Add_Click({
      param([object]$sender,[System.EventArgs]$e)
      $script:result.status = [System.Windows.Forms.DialogResult]::Cancel
      $text_input.Text = ''
      $script:result.Text = ''
      $form.Dispose()
    })

  $button_cancel.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $text_input.Location = New-Object System.Drawing.Point (8,100)
  $text_input.Name = 'text_input'
  $text_input.Size = New-Object System.Drawing.Size (379,20)
  $text_input.TabIndex = 0
  $text_input.Text = ''
  $text_input.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $form.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $form.ClientSize = New-Object System.Drawing.Size (398,128)
  $form.Controls.AddRange(@($text_input,$button_cancel,$button_ok,$label_prompt))
  $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
  $form.MaximizeBox = $false
  $form.MinimizeBox = $false
  $form.Name = 'InputBoxDialog'
  $form.ResumeLayout($false)
  $form.AcceptButton = $button_ok
  $form.ShowInTaskbar = $false

  $response = [System.Windows.Forms.DialogResult]::Ignore
  $result = ''
  $text_input.Text = ''
  $label_prompt.Text = $prompt_message
  $form.Text = $caption
  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

  $text_input.SelectionStart = 0;
  $text_input.SelectionLength = $text_input.Text.Length
  $text_input.Focus()

  $form.Name = 'Form1'
  $form.ResumeLayout($false)

  $form.Topmost = $Trues

  $form.Add_Shown({ $form.Activate() })

  [void]$form.ShowDialog()

  $form.Dispose()
  $form = $null
  return $script:result
}

function ComboInputBox {

  param(
    [string]$prompt_message = 'Select or Enter the Country',
    [string[]]$items = @(),
    [string]$caption = 'combo test'
  )

function PopulateCombo ()
{
  param([string[]]$comboBoxItems)
  for ($i = 0; $i -lt $comboBoxItems.Length; $i++)
  {
    $str = $comboBoxItems[$i]
    if ($str -ne $null)
    {
      [void]$combobox.Items.Add($str)
    }
  }
}

  $script:result = @{ 'text' = ''; 'status' = $null; }
  $script:result.status = [System.Windows.Forms.DialogResult]::None;

  $form = New-Object System.Windows.Forms.Form
  $label_prompt = New-Object System.Windows.Forms.Label
  $button_ok = New-Object System.Windows.Forms.Button
  $button_cancel = New-Object System.Windows.Forms.Button
  $combobox = New-Object System.Windows.Forms.ComboBox
  $form.SuspendLayout()
  $label_prompt.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $label_prompt.BackColor = [System.Drawing.SystemColors]::Control
  $label_prompt.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',8.25,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $label_prompt.Location = New-Object System.Drawing.Point (12,9)
  $label_prompt.Name = 'lblPrompt'
  $label_prompt.Size = New-Object System.Drawing.Size (302,82)
  $label_prompt.TabIndex = 3
  $label_prompt.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $button_ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $button_ok.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
  $button_ok.Location = New-Object System.Drawing.Point (326,8)
  $button_ok.Name = 'btnOK'
  $button_ok.Size = New-Object System.Drawing.Size (64,24)
  $button_ok.TabIndex = 1
  $button_ok.Text = '&OK'
  $button_ok.Add_Click({
      param([object]$sender,[System.EventArgs]$e)
      $script:result.status = [System.Windows.Forms.DialogResult]::OK
      $script:result.Text = $combobox.Text
      $form.Dispose()

    })
  $button_ok.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $button_cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $button_cancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
  $button_cancel.Location = New-Object System.Drawing.Point (326,40)
  $button_cancel.Name = 'btnCancel'
  $button_cancel.Size = New-Object System.Drawing.Size (64,24)
  $button_cancel.TabIndex = 2
  $button_cancel.Text = '&Cancel'
  $button_cancel.Add_Click({
      param([object]$sender,[System.EventArgs]$e)
      $script:result.status = [System.Windows.Forms.DialogResult]::Cancel
      $script:result.Text = ''
      $form.Dispose()

    })
  $button_cancel.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $combobox.Location = New-Object System.Drawing.Point (8,100)
  $combobox.Name = 'CmBxComboBox'
  $combobox.Size = New-Object System.Drawing.Size (379,20)
  $combobox.TabIndex = 0
  $combobox.Text = ''
  $combobox.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $combobox.Add_TextChanged({
      param([object]$sender,[System.EventArgs]$e)

    })

  $combobox.Add_KeyPress({
      param(
        [object]$sender,[System.Windows.Forms.KeyPressEventArgs]$e
      )

    })
  $combobox.Add_TextChanged({
      param(
        [object]$sender,[System.EventArgs]$e
      )

    })


  $form.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $form.ClientSize = New-Object System.Drawing.Size (398,128)
  $form.Controls.AddRange(@($combobox,$button_cancel,$button_ok,$label_prompt))
  $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
  $form.MaximizeBox = $false
  $form.MinimizeBox = $false
  $form.Name = 'ComboBoxDialog'
  $form.ResumeLayout($false)
  $form.AcceptButton = $button_ok
  $script:result.status = [System.Windows.Forms.DialogResult]::Ignore
  $script:result.status = ''
  PopulateCombo -comboBoxItems $items
  $label_prompt.Text = $prompt_message
  $form.Text = $caption
  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
  $combobox.SelectionStart = 0
  $combobox.SelectionLength = $combobox.Text.Length
  $combobox.Focus()
  $form.Name = 'Form1'
  $form.ResumeLayout($false)

  $form.Topmost = $True

  $form.Add_Shown({ $form.Activate() })

  [void]$form.ShowDialog($caller)

  $form.Dispose()
  $form = $null
  return $script:result

}


function ChangePasswordDialogBox {

  param(
    [string]$prompt_message = 'Change the password',
    [string]$caption = 'Default Caption',
    [string]$old_password = 'password'

  )
  $script:result = @{ 'text' = ''; 'status' = $null; }

  $form = New-Object System.Windows.Forms.Form
  $label_old_password = New-Object System.Windows.Forms.Label
  $label_new_password = New-Object System.Windows.Forms.Label
  $label_prompt = New-Object System.Windows.Forms.Label
  $label_confirm_password = New-Object System.Windows.Forms.Label
  $button_ok = New-Object System.Windows.Forms.Button
  $button_cancel = New-Object System.Windows.Forms.Button
  $text_old_password = New-Object System.Windows.Forms.TextBox
  $text_new_password = New-Object System.Windows.Forms.TextBox
  $text_confirm_password = New-Object System.Windows.Forms.TextBox
  $form.SuspendLayout()
  $label_old_password.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $label_old_password.Location = New-Object System.Drawing.Point (16,88)
  $label_old_password.Name = 'lblOldPassword'
  $label_old_password.Size = New-Object System.Drawing.Size (168,24)
  $label_old_password.TabIndex = 1
  $label_old_password.Text = 'Old Password'
  $label_old_password.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  $label_new_password.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $label_new_password.Location = New-Object System.Drawing.Point (16,112)
  $label_new_password.Name = 'lblNewPassword'
  $label_new_password.Size = New-Object System.Drawing.Size (168,24)
  $label_new_password.TabIndex = 2
  $label_new_password.Text = 'New Password'
  $label_new_password.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  $label_confirm_password.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $label_confirm_password.Location = New-Object System.Drawing.Point (16,136)
  $label_confirm_password.Name = 'lblConfirmPassword'
  $label_confirm_password.Size = New-Object System.Drawing.Size (168,24)
  $label_confirm_password.TabIndex = 3
  $label_confirm_password.Text = 'Confirm New Password';
  $label_confirm_password.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  $label_prompt.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $label_prompt.Location = New-Object System.Drawing.Point (16,8)
  $label_prompt.Name = 'lblPrompt'
  $label_prompt.Size = New-Object System.Drawing.Size (280,72)
  $label_prompt.TabIndex = 9
  $label_prompt.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
  $label_prompt.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $text_old_password.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $text_old_password.Location = New-Object System.Drawing.Point (192,88)
  $text_old_password.Name = 'txtbxOldPassword'
  $text_old_password.Size = New-Object System.Drawing.Size (184,21);
  $text_old_password.TabIndex = 4
  $text_old_password.Text = ''
  $text_old_password.PasswordChar = '*'
  $text_new_password.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0);
  $text_new_password.Location = New-Object System.Drawing.Point (192,112)
  $text_new_password.Name = 'txtbxNewPassword'
  $text_new_password.Size = New-Object System.Drawing.Size (184,21)
  $text_new_password.TabIndex = 5
  $text_new_password.Text = ''
  $text_new_password.PasswordChar = '*'
  $text_confirm_password.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0)
  $text_confirm_password.Location = New-Object System.Drawing.Point (192,136)
  $text_confirm_password.Name = 'txtbxConfirmPassword'
  $text_confirm_password.Size = New-Object System.Drawing.Size (184,21)
  $text_confirm_password.TabIndex = 6
  $text_confirm_password.Text = ''
  $text_confirm_password.PasswordChar = '*'
  $button_ok.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $button_ok.Location = New-Object System.Drawing.Point (312,16)
  $button_ok.Name = 'button_ok'
  $button_ok.Size = New-Object System.Drawing.Size (64,24)
  $button_ok.TabIndex = 7
  $button_ok.Text = 'OK'
  $button_ok.Add_Click({
      param([object]$sender,[System.EventArgs]$e)
      if ($text_old_password.Text.Trim() -ne $old_password) {
        # MessageBox.Show(ChangePasswordDialogBox.frmInputDialog, 'Incorrect Old Password', 'LinkSys', MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
        $text_old_password.SelectionStart = 0
        $text_old_password.SelectionLength = $text_old_password.Text.Length
        $text_old_password.Focus()
      } else {

        if ($text_new_password.Text.Trim() -ne $text_confirm_password.Text.Trim()) {

          $text_confirm_password.SelectionStart = 0
          $text_confirm_passwordSelectionLength = $text_confirm_password.Text.Length
          $text_confirm_password.Focus()

        } else {

          $script:result.status = [System.Windows.Forms.DialogResult]::OK
          $script:result.Text = $text_new_password.Text
          $form.Dispose()
        } }


    })
  $button_cancel.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
  $button_cancel.Location = New-Object System.Drawing.Point (312,48)
  $button_cancel.Name = 'btnCancel'
  $button_cancel.Size = New-Object System.Drawing.Size (64,24)
  $button_cancel.TabIndex = 8
  $button_cancel.Text = 'Cancel'
  $button_cancel.Add_Click({
      param([object]$sender,[System.EventArgs]$e)
      $script:result.status = [System.Windows.Forms.DialogResult]::Cancel
      $text_input.Text = ''
      $script:result.Text = ''
      $form.Dispose()

    }
  )
  $form.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $form.ClientSize = New-Object System.Drawing.Size (400,182)
  $form.Controls.AddRange(@($text_old_password,
$text_new_password,
$text_confirm_password,
$button_cancel,
$button_ok,
$label_prompt,
$label_old_password,
$label_new_password,
$label_confirm_password))
  $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
  $form.MaximizeBox = $false
  $form.MinimizeBox = $false
  $form.Name = 'InputBoxDialog'
  $form.ResumeLayout($false)
  $form.AcceptButton = $button_ok
  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
  $form.ShowInTaskbar = $false

  $script:result.status = [System.Windows.Forms.DialogResult]::Ignore

  $label_prompt.Text = $prompt_message
  $label_old_password.Text = 'Old Password'
  $label_new_password.Text = 'New Password'
  $label_confirm_password.Text = 'Confirm New Password'
  $text_old_password.Text = $old_password # ''
  $text_new_password.Text = ''
  $text_confirm_password.Text = ''
  $form.Text = $caption
  # Rectangle workingArea = Screen.PrimaryScreen.WorkingArea;

  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
  $text_old_password.Focus()

  $form.Name = 'Form1'
  $form.ResumeLayout($false)

  $form.Topmost = $Trues

  $form.Add_Shown({ $form.Activate() })

  [void]$form.ShowDialog()

  $form.Dispose()
  $form = $null
  return $script:result
}

Add-Type -TypeDefinition @" 
// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public string Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'
@( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
$shared_assemblies = @(
  'nunit.framework.dll'
)
$shared_assemblies_path = 'c:\developer\sergueik\csharp\SharedAssemblies'
if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}
pushd $shared_assemblies_path
$shared_assemblies | ForEach-Object {
  if ($host.Version.Major -gt 2) {
    Unblock-File -Path $_;
  }
  Write-Debug $_
  Add-Type -Path $_
}
popd
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
$f = New-Object -TypeName 'System.Windows.Forms.Form'
$f.Text = $title
$f.SuspendLayout()

$f.AutoScaleDimensions = New-Object System.Drawing.SizeF (6.0,13.0)
$f.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$f.ClientSize = New-Object System.Drawing.Size (210,105)
$button_combobox_test = New-Object System.Windows.Forms.Button
$button_combobox_test.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
$button_combobox_test.Location = New-Object System.Drawing.Point (10,10)
$button_combobox_test.Size = New-Object System.Drawing.Size (135,23)
$button_combobox_test.Text = 'Combobox Test'
$button_combobox_test.Add_Click({
    $countries = @(
      "India",
      "USA",
      "UK",
      "Russia",
      "Bulgaria",
      "Singapore",
      "Malayasia",
      "Japan",
      "Thailand"
    )
    $prompt_message = 'Select or Enter the Country'
    $caption = 'Combobox Test' 
    $o = ComboInputBox -items $countries -caption  $caption -prompt_message  $prompt_message 
    if ($o.status -match 'OK') {
      $caller.Data = $o.Text
    $f.Close()
    }
  })
$f.Controls.Add($button_combobox_test)
$button_change_password_test = New-Object System.Windows.Forms.Button
$button_change_password_test.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
$button_change_password_test.Location = New-Object System.Drawing.Point (10,40)
$button_change_password_test.Size = New-Object System.Drawing.Size (135,23)
$button_change_password_test.Text = 'Change Password Test'
$button_change_password_test.Add_Click({
    $prompt_message = 'Change the Password'
    $caption = 'Change Password Test'
    $old_password = '123'
    $o = ChangePasswordDialogBox -prompt_message $prompt_message -caption $caption -old_password $old_password
    if ($o.status -match 'OK') {
      $caller.Data = $o.Text
    $f.Close()
    }

  })
$f.Controls.Add($button_change_password_test)
$button_inputbox_test = New-Object System.Windows.Forms.Button
$button_inputbox_test.Font = New-Object System.Drawing.Font ('Arial',10,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Point,0)
$button_inputbox_test.Location = New-Object System.Drawing.Point (10,70)
$button_inputbox_test.Size = New-Object System.Drawing.Size (135,23)
$button_inputbox_test.Text = 'Inputbox test'
$button_inputbox_test.Add_Click({
    $prompt_message = 'Enter the Value'
    $caption = 'Inputbox test'
    $o = TextInputBox -caption $caption -prompt_message $prompt_message
    if ($o.status -match 'OK') {
      $caller.Data = $o.Text
    $f.Close()
    }
  })
$f.Controls.Add($button_inputbox_test)
$f.Name = "Form1"
$f.Text = 'Standard Input Dialogs'
$f.ResumeLayout($false)
$f.Topmost = $Trues
$f.Add_Shown({ $f.Activate() })
[void]$f.ShowDialog($caller)
$f.Dispose()
Write-Output $caller.Data