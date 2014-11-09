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
import org.apache.http.message.BasicHttpEntityEnclosingRequest;
// ??
import  org.apache.http.impl.client.DefaultHttpClient;
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
  
    // System.setProperty("webdriver.chrome.driver", "C:\\java\\selenium\\chromedriver.exe"); 
    DesiredCapabilities capabilities = DesiredCapabilities.firefox();
	RemoteWebDriver driver = null;
	try {
   driver = new RemoteWebDriver(new URL("http://127.0.0.1:4444/wd/hub"), capabilities);
  } catch (MalformedURLException ex) { }

  try{
   
   driver.manage().timeouts().pageLoadTimeout(50, TimeUnit.SECONDS);
   driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);   
   driver.get("http://www.carnival.com/");
   WebDriverWait wait = new WebDriverWait(driver, 30);

  // http://assertselenium.com/2013/01/29/webdriver-wait-commands/

  wait.until(ExpectedConditions.elementToBeClickable(By.className("logo")));
  wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("logo")));
  String value1 = "dest";
  String css_selector1 = String.format("a[data-param='%s']", value1);
  driver.findElement(By.cssSelector(css_selector1)).click();
  
  // print the node information 
  String result = getIPOfNode(driver);
  System.out.println(result);
 
 //take a screenshot
 File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);

  //save the screenshot in png format on the disk.
  FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));   
  
  }
  
  catch(Exception ex){
   
   System.out.println(ex.toString());
   
  }
  finally{
   
   driver.close();
   driver.quit();
  }
 }
private static String getIPOfNode(RemoteWebDriver remoteDriver) 
{ 
  String hostFound = null; 
  try  { 
    HttpCommandExecutor ce = (HttpCommandExecutor) remoteDriver.getCommandExecutor(); 
    String hostName = ce.getAddressOfRemoteServer().getHost(); 
    int port = ce.getAddressOfRemoteServer().getPort(); 
    HttpHost host = new HttpHost(hostName, port); 
    DefaultHttpClient client = new DefaultHttpClient(); 
    URL sessionURL = new URL(String.format("http://%s:%d/grid/api/testsession?session=%s" , hostName, port, remoteDriver.getSessionId())); 
    BasicHttpEntityEnclosingRequest r = new BasicHttpEntityEnclosingRequest( "POST", sessionURL.toExternalForm()); 
    HttpResponse response = client.execute(host, r); 
    JSONObject object = extractObject(response); 
    URL myURL = new URL(object.getString("proxyId")); 
    if ((myURL.getHost() != null) && (myURL.getPort() != -1)) { 
       hostFound = myURL.getHost(); 
    } 
  } catch (Exception e) { 
    System.err.println(e);  
  } 
  return hostFound; 
} 

private static JSONObject extractObject(HttpResponse resp) throws IOException, JSONException { 
  InputStream contents = resp.getEntity().getContent(); 
  StringWriter writer = new StringWriter(); 
  IOUtils.copy(contents, writer, "UTF8"); 
  JSONObject objToReturn = new JSONObject(writer.toString()); 
  return objToReturn; 
}
}
