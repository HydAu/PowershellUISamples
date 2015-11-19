using System;
using System.Drawing;
using System.Diagnostics;
using System.ComponentModel;
using System.Windows.Forms;
using NUnit.Framework;

#region Bootstrap Application

namespace SystemTrayApp
{
    public class App
    {
        private NotifyIcon appIcon = new NotifyIcon();
        private bool is_busy = false;
        private Icon idle_icon;
        private Icon busy_icon;
        private ContextMenu system_tray_menu = new ContextMenu();
        private MenuItem run_now = new MenuItem("Run Now");
        private MenuItem exit_app = new MenuItem("Exit");
        static System.Windows.Forms.Timer action_timer = new System.Windows.Forms.Timer();
        static int nScanCounter = 1;
        const bool exitFlag = false;

        private void TimerEventProcessor(Object myObject,
                         EventArgs myEventArgs)
        {
            action_timer.Stop();
            nScanCounter++;
            is_busy = !is_busy;
            appIcon.Visible = false;
            appIcon.Icon = (is_busy) ? busy_icon : idle_icon;
            appIcon.Visible = true;

            ProcessTreeScanner.Instance.ParentProcessName = "SharpDevelop.exe";
            ProcessTreeScanner.Perform();
            is_busy = !is_busy;
            appIcon.Visible = false;
            appIcon.Icon = (is_busy) ? busy_icon : idle_icon;
            appIcon.Visible = true;
            action_timer.Start();
        }

        public void Start()
        {
            idle_icon = new Icon(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("timing.IdleIcon.ico"));
            busy_icon = new Icon(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("timing.BusyIcon.ico"));

            appIcon.Icon = idle_icon;
            appIcon.Text = "Process Tree Scanner Tool";
            system_tray_menu.MenuItems.Add(run_now);
            system_tray_menu.MenuItems.Add(exit_app);
            appIcon.ContextMenu = system_tray_menu;

            action_timer.Tick += new EventHandler(TimerEventProcessor);

            action_timer.Interval = 3000;
            action_timer.Start();

            appIcon.Visible = true;

            run_now.Click += new EventHandler(RunNow);
            exit_app.Click += new EventHandler(ExitApp);
        }

        private void RunNow(object sender, System.EventArgs e)
        {
            TimerEventProcessor(sender, e);
        }
        private void ExitApp(object sender, System.EventArgs e)
        {
            Assert.IsFalse(exitFlag);
            appIcon.Dispose();
            idle_icon.Dispose();
            busy_icon.Dispose();

            Application.Exit();
        }

        public static void Main()
        {
#if DEBUG
            Console.WriteLine("Debug version.");
#endif
            App app = new App();
            app.Start();
            Application.Run();
        }
    }
}
#endregion