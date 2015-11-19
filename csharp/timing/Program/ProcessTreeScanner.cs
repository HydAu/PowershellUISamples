using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Management;
using System.ComponentModel;
using System.Diagnostics;
/// http://www.c-sharpcorner.com/UploadFile/scottlysle/FindListProcessesCS09102007024714AM/FindListProcessesCS.aspx
//

using NUnit.Framework;

namespace SystemTrayApp
{

    public class ProcessTreeScanner
    {
        private const string s_dummy = @"command";
        private bool _navigationStatus;
        private bool _discoveryStatus;
        private string _pattern;
        private string _parentProcessName = "puppet";

        private ProcessTreeScanner() { }
        private static ProcessTreeScanner instance = new ProcessTreeScanner();
        public static ProcessTreeScanner Instance
        {
            get { return instance; }
        }

        public static void Perform()
        {
            Instance.DoWork();
        }

        public bool NavigationStatus { get { return _navigationStatus; } set { _navigationStatus = value; } }
        public bool DiscoveryStatus { get { return _discoveryStatus; } set { _discoveryStatus = value; } }
        public string Pattern { get { return _pattern; } set { _pattern = value; } }
        public string ParentProcessName { get { return _parentProcessName; } set { _parentProcessName = value; } }

        private void DoWork()
        {
            this.NavigationStatus = true; // for debugging  
            this.DiscoveryStatus = false;
            String logPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);

            string parentProcessId = FindProcessByName(this.ParentProcessName);
            if (this.NavigationStatus)
            {
                string processes = FindProcessByParentProcessId(parentProcessId);
                if (this.DiscoveryStatus)
                {
                    Console.WriteLine(String.Format("Discovered {0} {1}", processes, TimeStamp()));
                }
            }
        }

        private static string TimeStamp()
        {
            DateTime dt = DateTime.Now;
            long dt_file_time = dt.ToFileTime();
            return dt_file_time.ToString();
        }

        public string FindProcessByName(string processName)
        {
            ManagementClass MgmtClass = new ManagementClass("Win32_Process");
            String s_managed_object_processid = null;

            foreach (ManagementObject mo in MgmtClass.GetInstances())
            {
                string s_managed_object_name = mo["Name"].ToString();
                if (s_managed_object_name.ToLower() == processName.ToLower())
                {
                    this.NavigationStatus = true;
                    s_managed_object_processid = mo["ProcessID"].ToString();
                }
            }
            return s_managed_object_processid;
        }

        public string FindProcessByParentProcessId(string parentProcessId)
        {

            StringBuilder sb = new StringBuilder();
            ManagementClass MgmtClass = new ManagementClass("Win32_Process");
            foreach (ManagementObject mo in MgmtClass.GetInstances())
            {
                // recursion needs to be implemented if one wants to collect children of puppet.exe:
                // typical Puppet manifest sendom uses Package provider on windows
                // Exec provider is more likely 
                // therefore Puppet would not be direct parent of the msiexec process.

                // if (mo["ParentProcessId"].ToString() == parentProcessId)
                // {

                string s_process_selection_patterns = @"(?<known>msi|setup||" + s_dummy + ")";
                string s_managed_object_commandline = null;
                try
                {
                    s_managed_object_commandline = mo["CommandLine"].ToString();
                }
                catch (System.NullReferenceException e)
                {
                    // for debugging
                    Assert.IsNotEmpty(e.Message);
                }
                if (s_managed_object_commandline != null)
                {
                    sb.Append(s_managed_object_commandline);
                    this.DiscoveryStatus = true;

                    MatchCollection myMatchCollection =
                       Regex.Matches(s_managed_object_commandline, s_process_selection_patterns);

                    foreach (Match myMatch in myMatchCollection)
                    {
                        Console.WriteLine("=> " + myMatch.Groups["known"]);
                        foreach (Group match_group in myMatch.Groups)
                        {
                            foreach (Capture match_group_capture in match_group.Captures)
                            {
                                Console.WriteLine("match_group_capture.Value = " + match_group_capture.Value);
                            }
                        }
                    }
                }
            }
            return sb.ToString();
        }
    }
}
