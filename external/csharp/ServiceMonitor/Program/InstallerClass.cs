using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using System.ComponentModel;
using System.Configuration.Install;

namespace ServiceMonitor
{
    // Taken from:http://msdn2.microsoft.com/en-us/library/
    // system.configuration.configurationmanager.aspx
    // Set 'RunInstaller' attribute to true.

    [RunInstaller(true)]
    public class InstallerClass : Installer
    {
        public InstallerClass()
        {
            // Attach the 'Committed' event.
            Committed += MyInstallerCommitted;           
        }        

        // Event handler for 'Committed' event.
        private static void MyInstallerCommitted(object sender, InstallEventArgs e)
        {
            Directory.SetCurrentDirectory(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)??string.Empty);
            Process.Start(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\ServiceMonitor.exe");
        }
    }
}