using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Net;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class Form1 : Form
{
    private System.Windows.Forms.WebBrowser webBrowser1;

    public Form1()
    {
        InitializeComponent();
        webBrowser1.Navigate("http://localhost:8088/app#/users/sign-in");

    }
    private void InitializeComponent()
    {
        this.webBrowser1 = new System.Windows.Forms.WebBrowser();
        this.webBrowser1.Navigated += webBrowser1_Navigated;
        this.SuspendLayout();
        // 
        // webBrowser1
        // 
        this.webBrowser1.Dock = System.Windows.Forms.DockStyle.Fill;
        this.webBrowser1.Location = new System.Drawing.Point(0, 0);
        this.webBrowser1.Name = "webBrowser1";
        this.webBrowser1.Size = new System.Drawing.Size(600, 600);
        this.webBrowser1.TabIndex = 0;
        // 
        // Form1
        // 
        this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.ClientSize = new System.Drawing.Size(600, 600);
        this.Controls.Add(this.webBrowser1);
        this.Text = "Split Window";
        this.ResumeLayout(false);
    }
    // Updates the URL in TextBoxAddress upon navigation.
    private void webBrowser1_Navigated(object sender,
        WebBrowserNavigatedEventArgs e)
    {
        // wait for the user to navigate to Environment page
        // http://localhost:8088/app#/environments 
        //  then capture the OctopusIdentificationToken cookies
        // it will have the following format
        // OctopusIdentificationToken=6pivzR9B%2fEOyJwbBkA2XfYe1BW4BNuXUqCtpW7VX943Em%2fkBZataiWxOVRDnsiBz; path=/; domain=localhost; HttpOnly 
        // System.Windows.Forms.WebBrowser
        Console.WriteLine("->" + webBrowser1.Url.ToString());
        string globalcookies = GetGlobalCookies(webBrowser1.Url.ToString());
        Console.WriteLine(String.Format("globalcookies = \"{0}\"", globalcookies.ToString()));
    }
    /* unused */
    public CookieContainer GetCookieContainer()
    {

        CookieContainer container = new CookieContainer();

        foreach (string cookie in webBrowser1.Document.Cookie.Split(';'))
        {
            string name = cookie.Split('=')[0];

            Console.WriteLine("9");
            string value = cookie.Substring(name.Length + 1);
            string path = "/";

            string domain = ""; //change to your domain name
            container.Add(new Cookie(name.Trim(), value.Trim(), path, domain));
        }

        return container;
    }

    [DllImport("wininet.dll", SetLastError = true)]
    public static extern bool InternetGetCookieEx(
        string url,
        string cookieName,
        StringBuilder cookieData,
        ref int size,
        Int32 dwFlags,
        IntPtr lpReserved);

    private const int INTERNET_COOKIE_HTTPONLY = 0x00002000;
    private const int INTERNET_OPTION_END_BROWSER_SESSION = 42;

    public static string GetGlobalCookies(string uri)
    {
        int datasize = 1024;
        StringBuilder cookieData = new StringBuilder((int)datasize);
        if (InternetGetCookieEx(uri, null, cookieData, ref datasize, INTERNET_COOKIE_HTTPONLY, IntPtr.Zero)
            && cookieData.Length > 0)
        {
            return cookieData.ToString().Replace(';', ',');
        }
        else
        {
            return null;
        }
    }



    public static CookieContainer GetUriCookieContainer(Uri uri)
    {
        CookieContainer cookies = null;
        // Determine the size of the cookie
        int datasize = 8192 * 16;
        StringBuilder cookieData = new StringBuilder(datasize);
        if (!InternetGetCookieEx(uri.ToString(), null, cookieData, ref datasize, INTERNET_COOKIE_HTTPONLY, IntPtr.Zero))
        {
            if (datasize < 0)
                return null;
            // Allocate stringbuilder large enough to hold the cookie
            cookieData = new StringBuilder(datasize);
            if (!InternetGetCookieEx(
                uri.ToString(),
                null, cookieData,
                ref datasize,
                INTERNET_COOKIE_HTTPONLY,
                IntPtr.Zero))
                return null;
        }
        if (cookieData.Length > 0)
        {
            cookies = new CookieContainer();
            cookies.SetCookies(uri, cookieData.ToString().Replace(';', ','));
        }
        return cookies;
    }

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.Run(new Form1());
    }

}