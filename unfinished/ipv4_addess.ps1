<#
		private void OnTextChange(object sender, System.EventArgs e)
		{
			int box_type = 0;

			CultureInfo MyCultureInfo = new CultureInfo("en-GB");

			double d;

			if( sender.Equals( ip1 ) )
				box_type = 1;
			if( sender.Equals( ip2 ) )
				box_type = 2;
			if( sender.Equals( ip3 ) )
				box_type = 3;
			if( sender.Equals( ip4 ) )
				box_type = 4;

			switch( box_type )
			{
				case 1:

					if( this.ip1.Text.Length > 0 && this.ip1.Text.ToCharArray()[this.ip1.Text.Length - 1] == '.' )
					{
						this.ip1.Text = this.ip1.Text.TrimEnd( '.' );
						ip1.Text = (this.ip1.Text.Length > 0 ) ? int.Parse( this.ip1.Text ).ToString() : "0" ;
						ip2.Focus();
						return;
					}

					// integer validation
					if( double.TryParse(
						this.ip1.Text,
						System.Globalization.NumberStyles.Integer,
						MyCultureInfo,
						out d ) == false
						)
					{
						this.ip1.Text = this.ip1.Text.Remove( 0, this.ip1.Text.Length );
						return;
					}

					// change focus to the next textbox if fully inserted
					if( this.ip1.Text.Length == 3 )
					{
						if( int.Parse( this.ip1.Text ) >= 255 )
							this.ip1.Text = "255";
						else
							ip1.Text = int.Parse( ip1.Text ).ToString();
						ip2.Focus();
					}
					break;
				case 2:
					if( this.ip2.Text.Length > 0 && this.ip2.Text.ToCharArray()[this.ip2.Text.Length - 1] == '.' )
					{
						this.ip2.Text = this.ip2.Text.TrimEnd( '.' );
						ip2.Text = (this.ip2.Text.Length > 0 ) ? int.Parse( this.ip2.Text ).ToString() : "0" ;
						ip3.Focus();
						return;
					}

					if( double.TryParse(
						this.ip2.Text,
						System.Globalization.NumberStyles.Integer,
						MyCultureInfo,
						out d ) == false
						)
					{
						this.ip2.Text = this.ip2.Text.Remove( 0, this.ip2.Text.Length );
						return;
					}

					if( this.ip2.Text.Length == 3 )
					{
						if( int.Parse( this.ip2.Text ) >= 255 )
							this.ip2.Text = "255";
						else
							ip2.Text = int.Parse( ip2.Text ).ToString();
						ip3.Focus();
					}
					break;
				case 3:
					if( this.ip3.Text.Length > 0 && this.ip3.Text.ToCharArray()[this.ip3.Text.Length - 1] == '.' )
					{
						this.ip3.Text = this.ip3.Text.TrimEnd( '.' );
						ip3.Text = (this.ip3.Text.Length > 0 ) ? int.Parse( this.ip3.Text ).ToString() : "0" ;
						ip4.Focus();
						return;
					}

					if( double.TryParse(
						this.ip3.Text,
						System.Globalization.NumberStyles.Integer,
						MyCultureInfo,
						out d ) == false
						)
					{
						this.ip3.Text = this.ip3.Text.Remove( 0, this.ip3.Text.Length );
						return;
					}

					if( this.ip3.Text.Length == 3 )
					{
						if( int.Parse( this.ip3.Text ) >= 255 )
							this.ip3.Text = "255";
						else
							ip3.Text = int.Parse( ip3.Text ).ToString();
						ip4.Focus();
					}
					break;
				case 4:

					if( double.TryParse(
						this.ip4.Text,
						System.Globalization.NumberStyles.Integer,
						MyCultureInfo,
						out d ) == false
						)
					{
						this.ip4.Text = this.ip4.Text.Remove( 0, this.ip4.Text.Length );
						return;
					}

					if( this.ip4.Text.Length == 3 )
					{
						if( int.Parse( this.ip4.Text ) >= 255 )
							this.ip4.Text = "255";
						else
							ip4.Text = int.Parse( ip4.Text ).ToString();
					}
					break;
			}
		}


#>
function dialogForContinueAuto($title, $message, $owner) {


[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


  function text_changed(){
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
     # NOOP
   }


  $f = New-Object System.Windows.Forms.Form
$f.Text = $title
$f.Size = New-Object System.Drawing.Size(400, 130)
$f.Owner =  $owner
$f.StartPosition = 'CenterScreen'
$f.Topmost = $True
  $p = new-object System.Windows.Forms.Panel  
  $ip1 = new-object System.Windows.Forms.TextBox  
  $ip2 = new-object System.Windows.Forms.TextBox  
  $ip3 = new-object System.Windows.Forms.TextBox  
  $ip4 = new-object System.Windows.Forms.TextBox  
  $dot_label_1 = new-object System.Windows.Forms.Label
  $dot_label_2 = new-object System.Windows.Forms.Label
  $dot_label_3 = new-object System.Windows.Forms.Label
  $p.SuspendLayout()  
  $p.SuspendLayout()  
  # 
  # ip1
  # 
  $ip1.BorderStyle = [System.Windows.Forms.BorderStyle]::None  
  $ip1.Location = new-object System.Drawing.Point(2, 3)  
  $ip1.MaxLength = 3  
  $ip1.Name = "ip1"  
  $ip1.Size = new-object System.Drawing.Size(20, 13)  
  $ip1.TabIndex = 0  
  $ip1.Text = "0"  
  $ip1.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center  
  $ip1_text_changed  = $ip1.add_TextChanged 
  $ip1_text_changed.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
        text_changed($sender, $eventargs)
      })

  # 
  # ip2
  # 
  $ip2.BorderStyle = [System.Windows.Forms.BorderStyle]::None  
  $ip2.Location = new-object System.Drawing.Point(28, 3)  
  $ip2.MaxLength = 3  
  $ip2.Name = "ip2"  
  $ip2.Size = new-object System.Drawing.Size(20, 13)  
  $ip2.TabIndex = 1  
  $ip2.Text = "0"  
  $ip2.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center  
  $ip2_text_changed  = $ip2.add_TextChanged 
  $ip2_text_changed.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
        text_changed($sender, $eventargs)
      })
  # 
  # ip3
  # 
  $ip3.BorderStyle = [System.Windows.Forms.BorderStyle]::None  
  $ip3.Location = new-object System.Drawing.Point(56, 3)  
  $ip3.MaxLength = 3  
  $ip3.Name = "ip3"  
  $ip3.Size = new-object System.Drawing.Size(20, 13)  
  $ip3.TabIndex = 2  
  $ip3.Text = "0"  
  $ip3.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center  
  $ip3_text_changed  = $ip3.add_TextChanged 
  $ip3_text_changed.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
        text_changed($sender, $eventargs)
      })

  # 
  # ip4
  # 
  $ip4.BorderStyle = [System.Windows.Forms.BorderStyle]::None  
  $ip4.Location = new-object System.Drawing.Point(84, 3)  
  $ip4.MaxLength = 3  
  $ip4.Name = "ip4"  
  $ip4.Size = new-object System.Drawing.Size(20, 13)  
  $ip4.TabIndex = 3  
  $ip4.Text = "0"  
  $ip4.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center   
  $ip4_text_changed  = $ip4.add_TextChanged 
  $ip4_text_changed.Invoke({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
        text_changed($sender, $eventargs)
      })

  # 
  # dotLabel1
  # 
  $dot_label_1.BackColor = [System.Drawing.Color]::White  
  $dot_label_1.Location = new-object System.Drawing.Point(25, -5)  
  $dot_label_1.Name = "dotLabel1"  
  $dot_label_1.Size = new-object System.Drawing.Size(1, 25)  
  $dot_label_1.Text = "."  
  $dot_label_1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter  
  # 
  # dotLabel2
  # 
  $dot_label_2.BackColor = [System.Drawing.Color]::White  
  $dot_label_2.Location = new-object System.Drawing.Point(53, -5)  
  $dot_label_2.Name = "dotLabel2"  
  $dot_label_2.Size = new-object System.Drawing.Size(1, 25)  
  $dot_label_2.Text = "."  
  $dot_label_2.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter  
  # 
  # dotLabel3
  # 
  $dot_label_3.BackColor = [System.Drawing.Color]::White  
  $dot_label_3.Location = new-object System.Drawing.Point(81, -5)  
  $dot_label_3.Name = "dotLabel3"  
  $dot_label_3.Size = new-object System.Drawing.Size(1, 25)  
  $dot_label_3.Text = "."  
  $dot_label_3.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter  

  # 
  # p
  # 
  $p.BackColor = [System.Drawing.Color]::White  
  $p.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D  
  $p.Controls.Add($ip1)  
  $p.Controls.Add($ip2)  
  $p.Controls.Add($ip3)  
  $p.Controls.Add($ip4)  
  $p.Controls.Add($dot_label_1)  
  $p.Controls.Add($dot_label_2)  
  $p.Controls.Add($dot_label_3)  
  $p.Location = new-object System.Drawing.Point(0, 0)  
  $p.Name = "IP Panel"  
  $p.Size = new-object System.Drawing.Size(112, 25)  

  $f.Controls.Add($p)
  $p.Name = "IpBox"  
  $p.Size = new-object System.Drawing.Size(112, 26)  
  $p.ResumeLayout($false)  
  $p.ResumeLayout($false)  
  $f.ResumeLayout($false)  



$f.Add_Shown({ $f.Activate() })
[void]$f.ShowDialog()

write-host $new_message

}

 dialogForContinueAuto 
