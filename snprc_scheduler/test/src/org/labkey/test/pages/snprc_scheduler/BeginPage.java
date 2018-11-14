package org.labkey.test.pages.snprc_scheduler;

import org.labkey.test.Locator;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.pages.LabKeyPage;
import org.openqa.selenium.WebElement;

public class BeginPage extends LabKeyPage<BeginPage.ElementCache>
{
    public BeginPage(WebDriverWrapper driver)
    {
        super(driver);
    }

    public static BeginPage beginAt(WebDriverWrapper driver)
    {
        return beginAt(driver, driver.getCurrentContainerPath());
    }

    public static BeginPage beginAt(WebDriverWrapper driver, String containerPath)
    {
        driver.beginAt(WebTestHelper.buildURL("snprc_scheduler", containerPath, "begin"));
        return new BeginPage(driver);
    }

    public String getHelloMessage()
    {
        return elementCache().helloMessage.getText();
    }

    @Override
    protected ElementCache newElementCache()
    {
        return new ElementCache();
    }

    protected class ElementCache extends LabKeyPage.ElementCache
    {
        protected final WebElement helloMessage = Locator.tagWithName("div", "helloMessage").findWhenNeeded(this);
    }
}
