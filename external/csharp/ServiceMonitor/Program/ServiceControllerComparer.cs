using System.Collections.Generic;
using System.ServiceProcess;

namespace ServiceMonitor
{
    public class ServiceControllerComparer : IComparer<ServiceController>
    {
        public int Compare(ServiceController x, ServiceController y)
        {
            return string.Compare(x.DisplayName, y.DisplayName,false);
        }
    }
}
