using System.ServiceProcess;
using System.Windows.Forms;

namespace ServiceMonitor
{
    public class ServiceMenuItem : ToolStripMenuItem
    {
        public ServiceMenuItem(string text) : base(text)
        {
        }
        public ServiceMonitor Service;
        public ServiceControllerStatus Status = ServiceControllerStatus.Stopped;
    }
}