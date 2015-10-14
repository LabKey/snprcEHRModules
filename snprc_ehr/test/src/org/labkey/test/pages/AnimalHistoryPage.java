/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.test.pages;

import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.WebTestHelper;
import org.labkey.test.components.ComponentElements;
import org.openqa.selenium.SearchContext;
import org.openqa.selenium.WebElement;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class AnimalHistoryPage extends LabKeyPage
{
    private static final String REPORT_TAB_SIGNAL = "LDK_reportTabLoaded";
    private final Elements _elements;


    public AnimalHistoryPage(BaseWebDriverTest test)
    {
        super(test);
        _elements = new Elements();
    }

    public static AnimalHistoryPage beginAt(BaseWebDriverTest test)
    {
        return beginAt(test, test.getCurrentContainerPath());
    }

    public static AnimalHistoryPage beginAt(BaseWebDriverTest test, String containerPath)
    {
        test.beginAt(WebTestHelper.buildURL("ehr", containerPath, "animalHistory"));
        return new AnimalHistoryPage(test);
    }

    @Override
    protected void waitForPage()
    {
        waitForElement(Locators.pageSignal("LDK_reportPanelLoaded"));
    }

    public AnimalHistoryPage clickCategoryTab(String categoryTab)
    {
        return clickCategoryTab(elements().findCategoryTab(categoryTab));
    }

    public AnimalHistoryPage clickCategoryTab(WebElement categoryTab)
    {
        categoryTab.click();
        return this;
    }

    public AnimalHistoryPage clickReportTab(String reportLabel)
    {
        return clickReportTab(elements().findReportTab(reportLabel));
    }

    public AnimalHistoryPage clickReportTab(WebElement reportTab)
    {
        if (!reportTab.getAttribute("class").contains("active"))
            doAndWaitForPageSignal(reportTab::click, REPORT_TAB_SIGNAL);
        return this;
    }

    public Elements elements()
    {
        return _elements;
    }

    public class Elements extends ComponentElements
    {
        @Override
        protected SearchContext getContext()
        {
            return getDriver();
        }

        private Map<String, WebElement> categoryTabs = new HashMap<>();
        private Map<String, Map<String, WebElement>> reportTabsByCategory = new HashMap<>();

        WebElement findCategoryTab(String category)
        {
            return findCategoryTabs().get(category);
        }

        WebElement findReportTab(String reportLabel)
        {
            return findReportTabs().get(reportLabel);
        }

        public Map<String, WebElement> findCategoryTabs()
        {
            if (categoryTabs.isEmpty())
            {
                List<WebElement> tabs = Locators.categoryTab.findElements(this);
                List<String> tabLabels = getTexts(tabs);
                for (int i = 0; i < tabs.size(); i++)
                {
                    if (categoryTabs.containsKey(tabLabels.get(i)))
                        throw new IllegalStateException(String.format("Duplicate categories named '%s'", tabLabels.get(i)));
                    categoryTabs.put(tabLabels.get(i), tabs.get(i));
                }
            }

            return categoryTabs;
        }

        public Map<String, WebElement> findReportTabs()
        {
            String selectedCategory = findSelectedCategory().getText();
            if (!reportTabsByCategory.containsKey(selectedCategory))
            {
                List<WebElement> tabs = Locators.reportTab.findElements(this);
                List<String> tabLabels = getTexts(tabs);
                Map<String, WebElement> tabMap = new HashMap<>();
                for (int i = 0; i < tabs.size(); i++)
                {
                    String reportTab = tabLabels.get(i);
                    if (reportTab.isEmpty()) // Report tabs for inactive categories exist, but contain no text
                        continue;
                    if (tabMap.containsKey(reportTab))
                        throw new IllegalStateException(String.format("Duplicate reports named '%s' in category '%s'", reportTab, selectedCategory));
                    tabMap.put(reportTab, tabs.get(i));
                }
                reportTabsByCategory.put(selectedCategory, tabMap);
            }

            return reportTabsByCategory.get(selectedCategory);
        }

        WebElement findSelectedCategory()
        {
            return Locators.categoryTab.append(".x4-tab-active").findElement(this);
        }

        WebElement findSelectedReport()
        {
            List<WebElement> tabs = Locators.reportTab.append(".x4-tab-active").findElements(this);
            for (WebElement tab : tabs)
            {
                if (!tab.getText().isEmpty())
                    return tab;
            }

            return null;
        }
    }

    static class Locators extends LabKeyPage.Locators
    {
        static Locator.CssLocator categoryTab = Locator.css(".category-tab-bar .x4-tab");
        static Locator.CssLocator reportTab = Locator.css(".report-tab-bar .x4-tab");
    }
}