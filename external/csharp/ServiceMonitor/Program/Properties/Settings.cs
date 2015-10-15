using System;
using System.Collections.Generic;
using System.Configuration;

namespace ServiceMonitor.Properties
{
    internal sealed class Settings : ApplicationSettingsBase
    {
        [UserScopedSetting]
        [SettingsSerializeAs(SettingsSerializeAs.Xml)]
        [DefaultSettingValue("")]
        public List<Profile> Profiles
        {
            get
            {
                return (List<Profile>)(this["Profiles"] ?? (this["Profiles"] = new List<Profile>()));
            }
            set
            {
                this["Profiles"] = value;
            }
        }

        [UserScopedSetting]
        [SettingsSerializeAs(SettingsSerializeAs.Xml)]
        [DefaultSettingValue("")]
        public bool StartOnWindowsStartup
        {
            get
            {
                return (bool)(this["StartOnWindowsStartup"] ?? (this["StartOnWindowsStartup"] = false));
            }
            set
            {
                this["StartOnWindowsStartup"] = value;
            }
        }

        private static Settings _default;
        public static Settings Default 
        { 
            get
            {
                if (_default == null)
                {
                    _default = new Settings();
                    _default.Reload();
                }
                return _default;
            }            
        }
    }
}