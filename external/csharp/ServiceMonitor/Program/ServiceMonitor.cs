using System;
using System.ServiceProcess;

namespace ServiceMonitor
{
    public class ServiceMonitor
    {
        private ServiceController _serviceController;
        private string _name;

        public ServiceMonitor(string name)
        {
            _name = name;
            try
            {
                _serviceController = new ServiceController(name);
            }
            catch
            {                
            }
        }

        public ServiceControllerStatus Status
        {
            get
            {
                try
                {
                    if (_serviceController !=null)
                    {
                        return _serviceController.Status;
                    }
                    _serviceController = new ServiceController(_name);
                    return _serviceController.Status;
                }
                catch (InvalidOperationException)
                {                    
                    return ServiceControllerStatus.Stopped;
                }                
            }
        }

        public string DisplayName
        {
            get
            {
                try
                {
                    if (_serviceController != null)
                    {
                        return _serviceController.DisplayName;
                    }
                    _serviceController = new ServiceController(_name);
                    return _serviceController.DisplayName;
                }
                catch (InvalidOperationException)
                {                    
                    return _name;
                }                
            }
        }

        public void Refresh()
        {
            try
            {
                if (_serviceController != null)
                {
                    _serviceController.Refresh();
                }
                else
                {
                    _serviceController = new ServiceController(_name);
                }
            }
            catch (InvalidOperationException)
            {                                
            }            
        }

        public void Stop()
        {
            try
            {
                if (_serviceController != null)
                {
                    _serviceController.Stop();
                }
                else
                {
                    _serviceController = new ServiceController(_name);
                    _serviceController.Stop();
                }
            }
            catch (InvalidOperationException)
            {                
            }            
        }

        public void Start()
        {
            try
            {
                if (_serviceController != null)
                {
                    _serviceController.Start();
                }
                else
                {
                    _serviceController = new ServiceController(_name);
                    _serviceController.Start();
                }
            }
            catch (InvalidOperationException)
            {
            }            
        }
    }
}
