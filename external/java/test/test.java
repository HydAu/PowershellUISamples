// package temp;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;

public class test {

  public static void main(String[] args) {
  
  
  System.setProperty("webdriver.chrome.driver", "C:\\SelenuimProject\\chromedriver.exe"); 
  WebDriver driver =  new ChromeDriver();
  
  try{
   
   driver.manage().timeouts().pageLoadTimeout(50, TimeUnit.SECONDS);
   driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);   
   driver.get("http://www.register.rediff.com/register/register.php");
   
   
 driver.findElement(By.xpath("//input[starts-with(@onblur,'field')]")).sendKeys("Sagar Salunke");
   
   
   
   Thread.sleep(2000);
   
  
  }
  
  catch(Exception ex){
   
   System.out.println(ex.toString());
   
  }
  finally{
   
   driver.close();
   driver.quit();
  }
 }

}
