using System;
using System.Collections.Generic;

namespace ServiceMonitor
{
    [Serializable]
    public class Profile
    {        
        public string Name { get; set; }

        private List<string> _services;
        public List<string> Services
        {
            get { return _services ?? (_services = new List<string>()); }
            set { _services = value; }
        }
    }
}
