using System;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.Support.UI;

namespace SeleniumTests
{
    [TestFixture]
    public class Example
    {
        private IWebDriver driver;
        private StringBuilder verificationErrors;
        private string baseURL;
        private bool acceptNextAlert = true;
        
        [SetUp]
        public void SetupTest()
        {
            driver = new FirefoxDriver();
            baseURL = "http://www.wikipedia.org/";
            verificationErrors = new StringBuilder();
        }
        
        [TearDown]
        public void TeardownTest()
        {
            try
            {
                driver.Quit();
            }
            catch (Exception)
            {
                // Ignore errors if unable to close the browser
            }
            Assert.AreEqual("", verificationErrors.ToString());
        }
        
        [Test]
        public void TheExampleTest()
        {
            // open | / | 
            driver.Navigate().GoToUrl(baseURL + "/");
            // click | css=strong | 
            driver.FindElement(By.CssSelector("strong")).Click();
            // type | id=searchInput | Selenium
            driver.FindElement(By.Id("searchInput")).Clear();
            driver.FindElement(By.Id("searchInput")).SendKeys("Selenium");
            // click | id=searchButton | 
            driver.FindElement(By.Id("searchButton")).Click();
            // click | link=Selenium (software) | 
            driver.FindElement(By.LinkText("Selenium (software)")).Click();
            // click | css=li.toclevel-2.tocsection-3 > a > span.toctext | 
            driver.FindElement(By.CssSelector("li.toclevel-2.tocsection-3 > a > span.toctext")).Click();
        }
        private bool IsElementPresent(By by)
        {
            try
            {
                driver.FindElement(by);
                return true;
            }
            catch (NoSuchElementException)
            {
                return false;
            }
        }
        
        private bool IsAlertPresent()
        {
            try
            {
                driver.SwitchTo().Alert();
                return true;
            }
            catch (NoAlertPresentException)
            {
                return false;
            }
        }
        
        private string CloseAlertAndGetItsText() {
            try {
                IAlert alert = driver.SwitchTo().Alert();
                string alertText = alert.Text;
                if (acceptNextAlert) {
                    alert.Accept();
                } else {
                    alert.Dismiss();
                }
                return alertText;
            } finally {
                acceptNextAlert = true;
            }
        }
    }
}

