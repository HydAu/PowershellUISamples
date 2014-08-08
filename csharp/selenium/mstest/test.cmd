PATH=%PATH%;c:\Windows\Microsoft.NET\Framework\v4.0.30319
PATH=%PATH%;c:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
FOR /F "TOKENS=*" %%. in ('dir /b/ad "%USERNAME%_%COMPUTERNAME%*"') DO @echo %%. & start cmd /c rd /s/q "%%."
msbuild.exe mstest.sln /t:clean,build
del /q %CD%\results.trx

mstest.exe /testcontainer:Sample\bin\Debug\Sample.dll /resultsfile:%CD%\results.trx
GOTO :EOF

REM http://blogs.msdn.com/b/vstsqualitytools/archive/2009/12/22/running-tests-in-mstest-without-installing-the-vs-ide.aspx
REM (iso)
..\..\SharedAssemblies\Castle.Core.dll
..\..\SharedAssemblies\Castle.DynamicProxy2.dll
..\..\SharedAssemblies\Castle.Facilities.Logging.dll
..\..\SharedAssemblies\Castle.Services.Logging.Log4netIntegration.dll
..\..\SharedAssemblies\Castle.Windsor.dll
..\..\SharedAssemblies\Microsoft.Activities.UnitTesting.dll
..\..\SharedAssemblies\Microsoft.VisualStudio.QualityTools.UnitTestFramework.dll
..\..\SharedAssemblies\Moq.dll
..\..\SharedAssemblies\Moq.xml
..\..\SharedAssemblies\Newtonsoft.Json.dll
..\..\SharedAssemblies\nmock.dll
..\..\SharedAssemblies\nunit.core.dll
..\..\SharedAssemblies\nunit.framework.dll
..\..\SharedAssemblies\nunit.framework.xml
..\..\SharedAssemblies\nunit.mocks.dll
..\..\SharedAssemblies\pnunit.framework.dll
..\..\SharedAssemblies\Selenium.WebDriverBackedSelenium.dll
..\..\SharedAssemblies\Selenium.WebDriverBackedSelenium.xml
..\..\SharedAssemblies\ThoughtWorks.Selenium.Core.dll
..\..\SharedAssemblies\ThoughtWorks.Selenium.Core.xml
..\..\SharedAssemblies\ThoughtWorks.Selenium.IntegrationTests.dll
..\..\SharedAssemblies\ThoughtWorks.Selenium.UnitTests.dll
..\..\SharedAssemblies\WebDriver.dll
..\..\SharedAssemblies\WebDriver.Support.dll
..\..\SharedAssemblies\WebDriver.Support.xml
..\..\SharedAssemblies\WebDriver.xml
 