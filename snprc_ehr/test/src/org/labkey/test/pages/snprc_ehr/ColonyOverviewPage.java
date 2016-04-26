package org.labkey.test.pages.snprc_ehr;

import org.labkey.test.Locator;
import org.labkey.test.WebDriverWrapper;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.Component;
import org.labkey.test.components.html.Table;
import org.labkey.test.pages.ehr.BaseColonyOverviewPage;
import org.labkey.test.selenium.LazyWebElement;
import org.labkey.test.util.DataRegionTable;
import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class ColonyOverviewPage extends BaseColonyOverviewPage
{
    public ColonyOverviewPage(WebDriver driver)
    {
        super(driver);
        _elements = new Elements();
    }

    public static ColonyOverviewPage beginAt(WebDriverWrapper driver)
    {
        return beginAt(driver, driver.getCurrentContainerPath());
    }

    public static ColonyOverviewPage beginAt(WebDriverWrapper driver, String containerPath)
    {
        driver.beginAt(WebTestHelper.buildURL("ehr", containerPath, "colonyOverview"));
        return new ColonyOverviewPage(driver.getDriver());
    }

    public void clickPopulateionCompositionTab()
    {
        clickTab("Population Composition");
        //TODO: return new PopulationCompositionTab(getActiveTabPanel());
    }

    public BaboonColonyTab clickBaboonColonyTab()
    {
        clickTab("Baboon Colony");
        return new BaboonColonyTab(getActiveTabPanel());
    }

    private Elements elements()
    {
        if (_elements == null)
            _elements = new Elements();
        return (Elements) _elements;
    }

    public class BaboonColonyTab extends OverviewTab
    {
        protected BaboonColonyTab(WebElement el)
        {
            super(el);
        }

        protected final DataRegionTable assignedFundedDataRegion = DataRegionTable.findDataRegionWithin(ColonyOverviewPage.this, this);

        public DataRegionTable getAssignedFundedDataRegion()
        {
            return assignedFundedDataRegion;
        }
    }

    public class PopulationCompositionTab extends OverviewTab
    {
        protected PopulationCompositionTab(WebElement el)
        {
            super(el);
        }

        protected final Table populationTable = new Table(getDriver(), getComponentElement());
    }

    private class Elements extends BaseColonyOverviewPage.Elements
    {
        @Override
        protected SearchContext getContext()
        {
            return getDriver();
        }

        WebElement baboonColonyPanel = new LazyWebElement(Locator.css("button"), this);
    }
}