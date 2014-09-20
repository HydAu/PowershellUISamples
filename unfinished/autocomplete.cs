// http://www.java2s.com/Code/CSharp/Components/UseanAutocompleteComboBox.htm
// shows first match instantly, need to rub to get to the next
using System;
using System.Windows.Forms;
using System.Drawing;

public class AutoCompleteComboBoxTest : System.Windows.Forms.Form {

   public AutoCompleteComboBoxTest(){
        AutoCompleteComboBox combo = new AutoCompleteComboBox();
        combo.Location = new Point(10,10);
        this.Controls.Add(combo);

         // 'Lorem ipsum dolor sit amet, consectetur adipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
        combo.Items.Add("Lorem");
        combo.Items.Add("ipsum");
        combo.Items.Add("dolor");
        combo.Items.Add("sit");
        combo.Items.Add("amet");
        combo.Items.Add("consectetur");
        combo.Items.Add("adipisicing");
        combo.Items.Add("elit");
        combo.Items.Add("sed"); 
        combo.Items.Add("do"); 
        combo.Items.Add("eiusmod"); 
        combo.Items.Add("tempor"); 
        combo.Items.Add("incididunt"); 
        combo.Items.Add("ut"); 
        combo.Items.Add("labore"); 
        combo.Items.Add("et"); 
        combo.Items.Add("dolore"); 
        combo.Items.Add("magna"); 
        combo.Items.Add("aliqua");
   }
   public static void Main(){
       Application.Run(new AutoCompleteComboBoxTest());
   } 
}


public class AutoCompleteComboBox : ComboBox {
    private bool controlKey = false;

    protected override void OnKeyPress( System.Windows.Forms.KeyPressEventArgs e) {
        base.OnKeyPress(e);
        if (e.KeyChar == (int)Keys.Escape) {
            this.SelectedIndex = -1;
            this.Text = "";
            controlKey = true;
        } else if (Char.IsControl(e.KeyChar)) {
            controlKey = true;
        } else {
            controlKey = false;
        }
    }

    protected override void OnTextChanged(System.EventArgs e) {
        base.OnTextChanged(e);
        if (this.Text != "" && !controlKey) {
            string matchText = this.Text;
            int match = this.FindString(matchText);
            if (match != -1) {
                this.SelectedIndex = match;
                this.SelectionStart = matchText.Length;
                this.SelectionLength = this.Text.Length - this.SelectionStart;
            }
        }
    }
}