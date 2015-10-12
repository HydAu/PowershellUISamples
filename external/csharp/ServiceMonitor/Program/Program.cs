using System;
using System.Collections.Generic;
using System.Timers;
using System.Windows.Forms;
using System.Threading;
using System.ServiceProcess;
using ServiceMonitor.Resources;
using ServiceMonitor.Properties;
using Microsoft.Win32;

namespace ServiceMonitor
{
    static class Program
    {
               
        static NotifyIcon _appIcon;
        static System.Timers.Timer _timer;
        static readonly List<ServiceMonitor> Services = new List<ServiceMonitor>();        


        public static Profile SelectedProfile
        {
            get
            {
                if (Settings.Default.Profiles.Count == 0)
                {
                    Settings.Default.Profiles.Add(new Profile { Name = "Default" });
                }
                return _selectedProfile ?? (_selectedProfile = Settings.Default.Profiles[0]);
            }
        }

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {            
            Mutex appSingleTon = new Mutex(false, English.ServiceMonitor);
            if (appSingleTon.WaitOne(0, false))
            {
                Application.EnableVisualStyles();                
                SystemEvents.SessionEnded += SystemEventSessionEnded;
                _timer = new System.Timers.Timer(10000);
                _timer.Elapsed += ServiceChecker;
                _timer.Enabled = true;                
                BindServices();
                IntializeIcon();
                Application.Run();
            }
            appSingleTon.Close();
       
        }

        #region UI Handlers

        private static void ServiceChecker(object source, ElapsedEventArgs e)
        {
            int status = 0;            
            foreach (var controller in Services)
            {
                controller.Refresh();
                UpdateServiceStatus(_appIcon.ContextMenuStrip, controller);
                if (controller.Status == ServiceControllerStatus.Running)
                {
                    status++;
                }
            }
            SetIcon(status);
        }

        private static void UpdateServiceStatus(ContextMenuStrip mnu, ServiceMonitor controller)
        {
            foreach (var item in mnu.Items)
            {
                var menuItem = item as ServiceMenuItem;
                if (menuItem != null && menuItem.Service.DisplayName == controller.DisplayName && menuItem.Status != controller.Status)
                {
                    menuItem.Image = controller.Status == ServiceControllerStatus.Running ? Properties.Resources.GreenLight.ToBitmap() : Properties.Resources.RedLight.ToBitmap();
                    menuItem.Status = controller.Status;
                }
            }
        }

        private static void ChangeProfile(object sender, EventArgs e)
        {
            var profile = sender as ToolStripItem;
            if (profile == null)
            {
                MessageBox.Show(Properties.Resources.Internal_Error_Text, Properties.Resources.Error_Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            if (string.Compare(profile.Text, SelectedProfile.Name, true) == 0)
            {
                return;
            }
            profile.Image = Properties.Resources.Check;
            foreach (ToolStripItem item in _profilesItem.DropDownItems)
            {
                if (string.Compare(item.Text, SelectedProfile.Name, false) == 0)
                {
                    item.Image = null;
                    break;
                }
            }
            foreach (Profile p in Settings.Default.Profiles)
            {
                if (string.Compare(p.Name, profile.Text, false) == 0)
                {
                    _selectedProfile = p;
                    break;
                }
            }
            for (int i = 0; i < Services.Count; i++)
            {
                _trayContextMenu.Items.RemoveAt(0);
            }
            if (Services.Count > 0)
            {
                _trayContextMenu.Items.RemoveAt(0);
            }
            BindServices();
            AddServicesToTrayContextMenu();
        }

        private static void ServiceItemClick(object sender, EventArgs e)
        {
            var menuItem = sender as ServiceMenuItem;
            if (menuItem != null)
            {
                menuItem.Service.Refresh();
                if (menuItem.Service.Status == ServiceControllerStatus.Running)
                {
                    menuItem.Service.Stop();
                }
                else
                {
                    menuItem.Service.Start();
                }
                menuItem.Image = Properties.Resources.OrangeLight.ToBitmap();
            }
        }

        private static void ConfigItemClick(object sender, EventArgs e)
        {
            if (_configurationSettingsDialog != null)
            {
                return;
            }
            _configurationSettingsDialog = new ServiceSettings(SelectedProfile);
            _configurationSettingsDialog.ShowDialog();
            lock (Services)
            {
                Services.Clear();
                _selectedProfile = null;
                foreach (var serviceName in SelectedProfile.Services)
                {
                    Services.Add(new ServiceMonitor(serviceName));
                }
            }
            _appIcon.Dispose();
            IntializeIcon();               
            _configurationSettingsDialog.Dispose();
            _configurationSettingsDialog = null;
        }

        private static void CloseItemClick(object sender, EventArgs e)
        {
            _appIcon.Visible = false;
            Application.Exit();
        }

        private static void SystemEventSessionEnded(object sender, SessionEndedEventArgs e)
        {
            _appIcon.Visible = false;
            Application.Exit();
        }

        #endregion

        #region Helper Methods

        private static void BindServices()
        {
            Services.Clear();
            foreach (var serviceName in SelectedProfile.Services)
            {
                Services.Add(new ServiceMonitor(serviceName));
            }
        }

        private static void IntializeIcon()
        {
            _appIcon = new NotifyIcon { Visible = true };
            _trayContextMenu = new ContextMenuStrip();
            AddServicesToTrayContextMenu();
            AddProfiles();
            var configItem = new ToolStripMenuItem("Configuration");
            configItem.Click += ConfigItemClick;
            _trayContextMenu.Items.Add(configItem);
            _trayContextMenu.Items.Add("-");
            var closeItem = new ToolStripMenuItem("Exit");
            closeItem.Click += CloseItemClick;
            _trayContextMenu.Items.Add(closeItem);
            _appIcon.ContextMenuStrip = _trayContextMenu;
            _appIcon.Text = English.ServiceMonitor;
            _appIcon.DoubleClick += ConfigItemClick;

        }

        private static void AddServicesToTrayContextMenu()
        {
            int status = 0;
            for (int index = 0; index < Services.Count; index++)
            {
                var serviceController = Services[index];
                serviceController.Refresh();

                var menuItem = new ServiceMenuItem(serviceController.DisplayName) { Service = serviceController };
                if (serviceController.Status == ServiceControllerStatus.Running)
                {
                    status++;
                    menuItem.Image = Properties.Resources.GreenLight.ToBitmap();
                }
                else
                {
                    menuItem.Image = Properties.Resources.RedLight.ToBitmap();
                }
                menuItem.Status = serviceController.Status;
                menuItem.Click += ServiceItemClick;
                _trayContextMenu.Items.Insert(index, menuItem);
            }
            SetIcon(status);
            if (Services.Count > 0)
            {
                _trayContextMenu.Items.Insert(Services.Count, new ToolStripSeparator());
            }
        }

        private static void AddProfiles()
        {
            _profilesItem = new ToolStripMenuItem("Profiles");
            foreach (Profile profile in Settings.Default.Profiles)
            {
                _profilesItem.DropDownItems.Add(profile.Name, SelectedProfile == profile ? Properties.Resources.Check : null, ChangeProfile);
            }
            _trayContextMenu.Items.Add(_profilesItem);
        }
        

        private static void SetIcon(int status)
        {
            if (status == Services.Count)
            {
                _appIcon.Icon = Properties.Resources.On;
                _appIcon.Text = English.ServiceMonitor;
            }
            else if (status > 0)
            {
                _appIcon.Icon = Properties.Resources.Warning;
                _appIcon.Text = English.ServicesStopped;
            }
            else
            {
                _appIcon.Icon = Properties.Resources.Off;
                _appIcon.Text = English.AllServicesStopped;
            }
        }

        #endregion

        #region Private Variables

        private static Profile _selectedProfile;
        private static ToolStripMenuItem _profilesItem;
        private static ContextMenuStrip _trayContextMenu;
        private static ServiceSettings _configurationSettingsDialog;

        #endregion
    }
}