using System;
using System.Configuration;
using System.Reflection;
using System.Xml;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Imaging;
using System.IO;

namespace TreeTab
{
    public class TreeTabConfig
    {
        #region Constants

        const string SHOW_DEFAULT_ICONS_KEY = "showDefaultIcons";
        const string ICONS_DIRECTORY_PATH = "iconsDirectoryPath";
        const string CONTEXT_MENU_ICONS_SECTION = "ContextMenuIcons";
        const string CONFIG_FILENAME = "TreeTab.config";

        #endregion

        #region Attributes

        Configuration config;
        XmlElement xmlContextMenuIcons;
        private string iconsDirectoryPath;
        private readonly bool isCorrectlyLoaded;

        #endregion

        #region Constructors

        /// <summary>
        /// Loads the config file
        /// </summary>
        public TreeTabConfig()
        {
            try
            {
                ExeConfigurationFileMap fileMap = new ExeConfigurationFileMap();
                System.Uri uri = new Uri(Path.GetDirectoryName(Assembly.GetCallingAssembly().Location));
                fileMap.ExeConfigFilename = Path.Combine(uri.LocalPath, CONFIG_FILENAME);
                config = ConfigurationManager.OpenMappedExeConfiguration(fileMap, ConfigurationUserLevel.None);
                if (config.HasFile)
                {
                    ConfigurationSection cs = config.GetSection(CONTEXT_MENU_ICONS_SECTION);
                    if (cs != null)
                    {
                        XmlDocument xmlConf = new XmlDocument();
                        xmlConf.LoadXml(cs.SectionInformation.GetRawXml());
                        xmlContextMenuIcons = (XmlElement)xmlConf.FirstChild;
                        this.isCorrectlyLoaded = true;
                    }
                }
            }
            catch
            {
                this.isCorrectlyLoaded = false;
            }
        }

        #endregion

        #region Properties

        /// <summary>
        /// Gets a boolean indicating whether the icons can be shown.
        /// </summary>
        public bool ShowDefaultIcons
        {
            get
            {
                string show = null;
                if (this.isCorrectlyLoaded)
                    show = config.AppSettings.Settings[SHOW_DEFAULT_ICONS_KEY].Value;
                return (!string.IsNullOrEmpty(show) && bool.Parse(show));
            }
        }

        /// <summary>
        /// Gets the path where the icon files are located.
        /// </summary>
        public string IconsDirectoryPath
        {
            get
            {
                if (string.IsNullOrEmpty(this.iconsDirectoryPath))
                {
                    if (System.IO.Directory.Exists(config.AppSettings.Settings[ICONS_DIRECTORY_PATH].Value))
                        this.iconsDirectoryPath = Path.GetFullPath(config.AppSettings.Settings[ICONS_DIRECTORY_PATH].Value);
                }
                return this.iconsDirectoryPath;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Gets the Image by its name.
        /// </summary>
        /// <param name="_id">string</param>
        /// <returns>Image</returns>
        public Image GetIconById(string _id)
        {
            Image img = null;
            if (!string.IsNullOrEmpty(this.IconsDirectoryPath))
            {
                XmlNode xmlIcon = xmlContextMenuIcons.SelectSingleNode("icon[@id='" + _id + "']");
                if (xmlIcon != null)
                {
                    string file = this.IconsDirectoryPath + @"\" + xmlIcon.Attributes["fileName"].Value;
                    if (File.Exists(file))
                    {
                        BitmapSource ico = new BitmapImage(new Uri(file));
                        img = new Image();
                        img.Source = ico;
                    }
                }
            }
            return img;
        }

        /// <summary>
        /// Gets the Image by its Id and sets the width and height.
        /// </summary>
        /// <param name="_id">string</param>
        /// <param name="_height">uint</param>
        /// <param name="_width">uint</param>
        /// <returns>Image</returns>
        public Image GetIconById(string _id, uint _height, uint _width)
        {
            Image img = this.GetIconById(_id);
            if (img != null)
            {
                img.Height = _height;
                img.Width = _width;
            }
            return img;
        }

        #endregion
    }
}
