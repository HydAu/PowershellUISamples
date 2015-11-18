using System;
using System.Collections.Generic;
using System.Text;

using System.Text.RegularExpressions;
using System.Management;
using System.ComponentModel;
using System.Diagnostics;
/// http://www.c-sharpcorner.com/UploadFile/scottlysle/FindListProcessesCS09102007024714AM/FindListProcessesCS.aspx


namespace SystemTrayApp
{

    public class ProcessTreeScanner
    {

        private bool _navigationStatus;
        private bool _discoveryStatus;
        private string _pattern;
        private string _parentProcessName = "puppet";

        public bool NavigationStatus { get { return _navigationStatus; } set { _navigationStatus = value; } }
        public bool DiscoveryStatus { get { return _discoveryStatus; } set { _discoveryStatus = value; } }
        public string Pattern { get { return _pattern; } set { _pattern = value; } }
        public string ParentProcessName { get { return _parentProcessName; } set { _parentProcessName = value; } }

        public void Perform()
        {

            this.NavigationStatus = true;
            this.DiscoveryStatus = false;

                string parentProcessId = FindProcessByName(this.ParentProcessName);

                string processes = FindProcessByParentProcessId(parentProcessId);
                Console.WriteLine(processes);
                if (DiscoveryStatus)
                {
                    Console.WriteLine("discovered");
                }

        }

        public string FindProcessByName(string processName)
        {
            ManagementClass MgmtClass = new ManagementClass("Win32_Process");
            NavigationStatus = false;
            String result = null;

            foreach (ManagementObject mo in MgmtClass.GetInstances())
            {
            	
            	string x = mo["Name"].ToString();
            	Console.WriteLine(x);
            	
                if (mo["Name"].ToString().ToLower() == processName.ToLower())
                {
                    NavigationStatus = true;
                    result = mo["ProcessID"].ToString();
                }
            }
            return result;
        }

        public string FindProcessByParentProcessId(string parentProcessId)
        {

            StringBuilder sb = new StringBuilder();
            ManagementClass MgmtClass = new ManagementClass("Win32_Process");
            this.NavigationStatus = false;
            foreach (ManagementObject mo in MgmtClass.GetInstances())
            {
                if (mo["ParentProcessId"].ToString() == parentProcessId)
                {
                    sb.Append(mo["Name"].ToString());
                    this.DiscoveryStatus = true;

                    string sCommand = @"command";
                    string aProcessChoiceRegExp = @"(?<known>msi|setup||" + sCommand + ")";
                    string s = mo["CommandLine"].ToString();
                    Console.WriteLine(s);

                    MatchCollection myMatchCollection =
                       Regex.Matches(s, aProcessChoiceRegExp);

                    foreach (Match myMatch in myMatchCollection)
                    {
                        Console.WriteLine("=> " + myMatch.Groups["known"]);
                        foreach (Group myGroup in myMatch.Groups)
                        {

                            foreach (Capture myCapture in myGroup.Captures)
                            {
                                Console.WriteLine("myCapture.Value = " + myCapture.Value);
                            }

                        }

                    }
                }
            }
            return sb.ToString();

        }

    }
}
