using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.ServiceProcess;
using ServiceMonitor.Resources;
using Microsoft.Win32;

namespace ServiceMonitor
{
    public partial class ServiceSettings : Form
    {
        class ListServiceItem
        {
            public ListServiceItem(ServiceController service)
            {
                Service = service;
            }

            public readonly ServiceController Service;
            public override string ToString()
            {
                return Service.DisplayName;
            }
        }

        private Profile _selectedProfile;
        private bool _ignoreIndexChange;

        public ServiceSettings(Profile selectedProfile)
        {
            _selectedProfile = selectedProfile;
            InitializeComponent();
            UpdateDropDown();
            PopulateListBoxes();
            chkStartup.Checked = Properties.Settings.Default.StartOnWindowsStartup;
        }

        private void PopulateListBoxes()
        {            
            List<ServiceController> services = new List<ServiceController>(ServiceController.GetServices());
            services.Sort(new ServiceControllerComparer());
            lstServices.Items.Clear();
            lstSelectedServices.Items.Clear();
            foreach (var controller in services)
            {
                lstServices.Items.Add(new ListServiceItem(controller));
            }
            foreach (var serviceName in _selectedProfile.Services)
            {
                lstSelectedServices.Items.Add(new ListServiceItem(new ServiceController(serviceName)));
            }
        }

        private void BtnRightClick(object sender, EventArgs e)
        {            
            foreach (ListServiceItem selectedItem in lstServices.SelectedItems)
            {
                var isSelectedAlready = false;
                foreach (ListServiceItem serviceItem in lstSelectedServices.Items)
                {

                    if (serviceItem.Service.ServiceName == selectedItem.Service.ServiceName)
                    {
                        isSelectedAlready = true;
                    }                
                }
                if (!isSelectedAlready)
                {
                    lstSelectedServices.Items.Add(selectedItem);
                }
            }
        }        

        private void BtnLeftClick(object sender, EventArgs e)
        {            
            while (lstSelectedServices.SelectedItems.Count>0)
            {                
                lstSelectedServices.Items.Remove(lstSelectedServices.SelectedItems[0]);
            }
        }

        private void BtnOkClick(object sender, EventArgs e)
        {
            SaveSelectedServices();
            if (Properties.Settings.Default.StartOnWindowsStartup != chkStartup.Checked)
            {
                if (SetStartup(chkStartup.Checked))
                {
                    Properties.Settings.Default.StartOnWindowsStartup = chkStartup.Checked;
                }
                else
                {
                    chkStartup.Checked = Properties.Settings.Default.StartOnWindowsStartup;
                    return;
                }   
            }            
            Properties.Settings.Default.Save();
            Close();
        }

        private void SaveSelectedServices()
        {
            _selectedProfile.Services.Clear();
            foreach (ListServiceItem item in lstSelectedServices.Items)
            {
                _selectedProfile.Services.Add(item.Service.ServiceName);
            }
        }

        private static bool SetStartup(bool status)
        {
            RegistryKey rk = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true);
            if (rk!=null)
            {
                if (status)
                {
                    rk.SetValue("Windows Service Monitor", Application.ExecutablePath);
                }
                else
                {
                    rk.DeleteValue("Windows Service Monitor", false);
                }
            }    
            else
            {
                MessageBox.Show(English.NoAccessToRegistry, English.Error, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }


        private void BtnCancelClick(object sender, EventArgs e)
        {
            Properties.Settings.Default.Reload();
            Close();
        }

        private void ServiceSettingsResize(object sender, EventArgs e)
        {
            lstServices.Width = (Width - 80 - 24)/2;
            lstSelectedServices.Width = lstServices.Width;
            lstServices.Height = Height - 152;
            lstSelectedServices.Height = lstServices.Height;
            lbServicesSelected.Left = lstServices.Width + 80;
            lstSelectedServices.Left = lbServicesSelected.Left;
            btnRight.Left = Width/2 - 22;
            btnLeft.Left = btnRight.Left;
            btnRight.Top = lstServices.Top + lstServices.Height/2 - 31;
            btnLeft.Top = btnRight.Top + 37;            
        }

        private void CbxProfilesSelectedIndexChanged(object sender, EventArgs e)
        {
            if (cbxProfiles.SelectedIndex != -1 && !_ignoreIndexChange)
            {
                SaveSelectedServices();
                _selectedProfile = Properties.Settings.Default.Profiles[cbxProfiles.SelectedIndex];    
                PopulateListBoxes();
            }            
        }

        private void LstServicesDoubleClick(object sender, EventArgs e)
        {
            BtnRightClick(sender,e);
        }

        private void LstSelectedServicesDoubleClick(object sender, EventArgs e)
        {
            BtnLeftClick(sender,e);
        }

        private void BtnNewClick(object sender, EventArgs e)
        {
            var dlg = new InputText
                          {
                              Title = "Enter Profile Name",
                              TextLabel = "Profile Name"
                          };
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                if (!IsValidName(dlg.TextValue))
                {
                    MessageBox.Show(Properties.Resources.Profile_name_should_be_unique_Error_Text, Properties.Resources.Error_Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                SaveSelectedServices();
                _selectedProfile = new Profile {Name = dlg.TextValue};
                Properties.Settings.Default.Profiles.Add(_selectedProfile);                
                PopulateListBoxes();
                UpdateDropDown();              
            }
        }

        private bool IsValidName(string newName)
        {
            foreach (var p in Properties.Settings.Default.Profiles)
            {
                if (string.Compare(p.Name,newName,false) == 0)
                {
                    return false;
                }
            }
            return true;
        }

        private void BtnRenameClick(object sender, EventArgs e)
        {
            var dlg = new InputText
            {
                Title = "Enter New Profile Name",
                TextLabel = "Profile Name",
                TextValue =  _selectedProfile.Name
            };
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                _selectedProfile.Name = dlg.TextValue;                                
                UpdateDropDown();
            }
        }

        private void BtnDeleteClick(object sender, EventArgs e)
        {
            int selectedIndex = cbxProfiles.SelectedIndex;
            selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : 0;
            _selectedProfile = Properties.Settings.Default.Profiles[selectedIndex];
            Properties.Settings.Default.Profiles.Remove((Profile)cbxProfiles.SelectedItem);            
            PopulateListBoxes();
            UpdateDropDown();
        }

        private void UpdateDropDown()
        {            
            lock (_selectedProfile)
            {
                _ignoreIndexChange = true;
                int selectedIndex = 0;
                for (int i = 0; i < Properties.Settings.Default.Profiles.Count; i++)
                {
                    if (Properties.Settings.Default.Profiles[i] == _selectedProfile)
                    {
                        selectedIndex = i;
                        break;
                    }
                }
                cbxProfiles.DataSource = null;
                cbxProfiles.DataSource = Properties.Settings.Default.Profiles;
                cbxProfiles.DisplayMember = "Name";
                cbxProfiles.SelectedItem = _selectedProfile;
                cbxProfiles.SelectedText = _selectedProfile.Name;
                cbxProfiles.SelectedIndex = selectedIndex;
                cbxProfiles.Refresh();
                btnDelete.Visible = Properties.Settings.Default.Profiles.Count > 1;
                _ignoreIndexChange = false;
            }                        
        }
    }
}
