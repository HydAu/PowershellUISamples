package com.mycompany.app;

import java.io.File;
import java.io.InputStream;
import java.io.StringWriter;
import java.lang.StringBuilder;
import java.util.concurrent.TimeUnit;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.FileUtils;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openqa.selenium.android.AndroidDriver;

// http://stackoverflow.com/questions/10715378/java-lang-noclassdeffounderror-org-openqa-selenium-android-androidwebdriver-err
import org.apache.http.message.BasicHttpEntityEnclosingRequest;
// ??
import  org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.openqa.selenium.By;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.remote.HttpCommandExecutor;
import org.openqa.selenium.remote.RemoteWebDriver;

import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;


import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.BindException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;

public class App
{  public static void main(String[] args) {

           WebDriver driver = new AndroidDriver();
    
//		   driver.manage().timeouts().pageLoadTimeout(900, TimeUnit.SECONDS);
//		   driver.manage().timeouts().implicitlyWait(300, TimeUnit.SECONDS);
           try{
		   driver.get("http://www.carnival.com/");


           }	
           catch(Exception ex) {

		   System.out.println(ex.toString());

	   }
		   WebDriverWait wait = new WebDriverWait(driver, 300);

	   try{
/*		   wait.until(ExpectedConditions.elementToBeClickable(By.className("logo")));
		   wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("logo")));
		   String value1 = "dest";
		   String css_selector1 = String.format("a[data-param='%s']", value1);
		   driver.findElement(By.cssSelector(css_selector1)).click();
*/
	   }

	   catch(Exception ex) {

		   System.out.println(ex.toString());

	   }
	   try{
		   //take a screenshot
		   File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);

		   //save the screenshot in png format on the disk.
		   FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));

	   }

	   catch(Exception ex) {

		   System.out.println(ex.toString());

	   }
	   finally {

		   driver.close();
		   driver.quit();
	   }
   }
}
