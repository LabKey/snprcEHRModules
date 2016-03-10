/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
package org.labkey.test.tests.snprc_ehr;

import org.apache.commons.lang3.time.DateUtils;
import org.jetbrains.annotations.Nullable;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.TestFileUtils;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.SNPRC;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.pages.snprc_ehr.SNPRCAnimalHistoryPage;
import org.labkey.test.pages.ehr.ParticipantViewPage;
import org.labkey.test.tests.AbstractGenericEHRTest;
import org.labkey.test.util.Crawler;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.TestLogger;
import org.openqa.selenium.WebDriverException;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

@Category ({CustomModules.class, EHR.class, SNPRC.class})
public class SNPRC_EHRTest extends AbstractGenericEHRTest implements SqlserverOnlyTest
{
    private static final String ASSAY_GENE_EXPRESSION = "Gene Expression";
    private static final File ASSAY_GENE_EXPRESSION_XAR = TestFileUtils.getSampleData("snprc/assays/Gene Expression.xar");
    private static final File ASSAY_GENE_EXPRESSION_TSV = TestFileUtils.getSampleData("snprc/assays/gene_expression.tsv");
    private static final String ASSAY_MICROSATELLITES = "Microsatellites";
    private static final File ASSAY_MICROSATELLITES_XAR = TestFileUtils.getSampleData("snprc/assays/Microsatellites.xar");
    private static final File ASSAY_MICROSATELLITES_TSV = TestFileUtils.getSampleData("snprc/assays/microsatellites.tsv");
    private static final String ASSAY_PHENOTYPES = "Phenotypes";
    private static final File ASSAY_PHENOTYPES_XAR = TestFileUtils.getSampleData("snprc/assays/Phenotypes.xar");
    private static final File ASSAY_PHENOTYPES_TSV = TestFileUtils.getSampleData("snprc/assays/phenotypes.tsv");
    private static final String ASSAY_SNPS = "SNPs";
    private static final File ASSAY_SNPS_XAR = TestFileUtils.getSampleData("snprc/assays/SNPs.xar");
    private static final File ASSAY_SNPS_TSV = TestFileUtils.getSampleData("snprc/assays/snps.tsv");
    private static final File LOOKUP_LIST_ARCHIVE = TestFileUtils.getSampleData("snprc/SNPRC_Test.lists.zip");
    private static final String PROJECT_NAME = "SNPRC";
    private static final String COREFACILITIES = "Core Facilities";
    private static final String GENETICSFOLDER = "Genetics";
    private static final String FOLDER_NAME = "SNPRC";

    private boolean _hasCreatedBirthRecords = false;

    public String getModuleDirectory()
    {
        return "snprc_ehr";
    }

    @Override
    protected void goToEHRFolder()
    {
        clickProject(getProjectName());
    }

    @Nullable
    @Override
    protected String getProjectName()
    {
        return PROJECT_NAME;
    }

    @Override
    public String getFolderName() { return FOLDER_NAME; }

    @Override
    public String getContainerPath()
    {
        return PROJECT_NAME;
    }

    public String getGeneticsPath() { return PROJECT_NAME + "/" + COREFACILITIES + "/" + GENETICSFOLDER; }

    @Override
    protected void createProjectAndFolders(String type)
    {
        _containerHelper.createProject(getProjectName(), type);
        _containerHelper.createSubfolder(getProjectName(), getProjectName(), COREFACILITIES, "Collaboration", null);
        _containerHelper.createSubfolder(getProjectName(), COREFACILITIES, GENETICSFOLDER, "Laboratory Folder", new String[]{"SequenceAnalysis", "SNPRC_Genetics"});
        clickFolder(getProjectName());
    }

    @Override
    public BrowserType bestBrowser()
    {
        return BrowserType.CHROME;
    }

    @Override
    public List<String> getAssociatedModules()
    {
        return Arrays.asList("ehr", "snprc_ehr", "snprc_genetics");
    }

    @BeforeClass
    public static void setupProject() throws Exception
    {
        SNPRC_EHRTest initTest = (SNPRC_EHRTest) getCurrentTest();

        initTest.doSetup();
    }

    private void doSetup() throws Exception
    {
        new RReportHelper(this).ensureRConfig();
        initProject("SNPRC EHR");
        createTestSubjects();
        goToProjectHome();
        clickFolder(GENETICSFOLDER);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_GENE_EXPRESSION_XAR, 1);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_MICROSATELLITES_XAR, 2);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_PHENOTYPES_XAR, 3);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_SNPS_XAR, 4);
        clickFolder(GENETICSFOLDER);
        String containerPath = getContainerPath();
        _listHelper.importListArchive(LOOKUP_LIST_ARCHIVE);
        clickFolder(PROJECT_NAME);
        PortalHelper portalHelper = new PortalHelper(this);
        portalHelper.addWebPart("EHR Datasets");
        clickFolder(GENETICSFOLDER);
        portalHelper.addWebPart("Assay List");
        _assayHelper.importAssay(ASSAY_GENE_EXPRESSION, ASSAY_GENE_EXPRESSION_TSV, getGeneticsPath());
        _assayHelper.importAssay(ASSAY_MICROSATELLITES, ASSAY_MICROSATELLITES_TSV, getGeneticsPath());
        _assayHelper.importAssay(ASSAY_PHENOTYPES, ASSAY_PHENOTYPES_TSV, getGeneticsPath());
        _assayHelper.importAssay(ASSAY_SNPS, ASSAY_SNPS_TSV, getGeneticsPath());
    }

    @Override
    protected String getMale() {
        return "M";
    }

    @Override
    protected String getFemale() {
        return "F";
    }

    @Override
    protected String[] getRooms()
    {
        return new String[] {"2043365", "6824778", "2043365"};
    }

    @Override
    protected boolean doSetUserPasswords()
    {
        return true;
    }

    @Override
    protected String getExpectedAnimalIDCasing(String id)
    {
        return id.toUpperCase();
    }

    @Override
    protected void importStudy()
    {
        File path = new File(TestFileUtils.getLabKeyRoot(), getModulePath() + "/resources/referenceStudy");
        setPipelineRoot(path.getPath());

        beginAt(getBaseURL() + "/pipeline-status/" + getContainerPath() + "/begin.view");
        clickButton("Process and Import Data", defaultWaitForPage);

        _fileBrowserHelper.expandFileBrowserRootNode();
        _fileBrowserHelper.checkFileBrowserFileCheckbox("study.xml");

        if (isTextPresent("Reload Study"))
            _fileBrowserHelper.selectImportDataAction("Reload Study");
        else
            _fileBrowserHelper.selectImportDataAction("Import Study");

        if (skipStudyImportQueryValidation())
        {
            Locator cb = Locator.checkboxByName("validateQueries");
            waitForElement(cb);
            uncheckCheckbox(cb);
        }

        clickButton("Start Import"); // Validate queries page
        waitForPipelineJobsToComplete(1, "Study import", false, MAX_WAIT_SECONDS * 2500);
    }

    @Override
    protected void populateInitialData()
    {
        beginAt(getBaseURL() + "/" + getModuleDirectory() + "/" + getContainerPath() + "/populateData.view");

        repopulate("Lookup Sets");
        repopulate("Procedures");
        repopulate("All");
        repopulate("SNOMED Codes");
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
        clickFolder(FOLDER_NAME);
        waitForElement(Locator.linkWithText("Animal Search"));
        waitForElement(Locator.linkWithText("Browse All Datasets"));
    }

    @Test
    public void testAnimalSearch()
    {
        click(Locator.linkWithText("Animal Search"));
        waitForElement(Locator.inputByNameContaining("Id"));
        //pushLocation();
        saveLocation();
        setFormElement(Locator.inputByNameContaining("Id"), "1");
        click(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Locator.linkWithText("test1020148"));
        recallLocation();
        waitForElement(Locator.inputByNameContaining("Id/curLocation/cage"));
        setFormElement(Locator.inputByNameContaining("Id/curLocation/cage"), "5426");
        click(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Locator.linkWithText("test499022"));
        waitForElement(Locator.linkWithText("test6390238"));

    }

    @Test
    public void testHousingSearch()
    {
        click(Locator.linkWithText("Housing Queries"));
        waitForElement(Locator.inputByNameContaining("Id"));
        pushLocation();
        setFormElement(Locator.inputByNameContaining("Id"), "1");
        click(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Locator.linkWithText("test1112911"));
        popLocation();
        waitForElement(Locator.inputByNameContaining("cage"));
        setFormElement(Locator.inputByNameContaining("cage"), "100172");
        click(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Locator.linkWithText("100172"));
    }

    @Test @Ignore("TODO: add protocol search")
    public void testProtocolSearch()
    {
    }

    @Test
    public void testCustomQueries()
    {
        BodyWebPart dashboard = new BodyWebPart(this, "Electronic Health Record", 1);
        clickAndWait(Locator.linkWithText("Room Utilization").findElement(dashboard));

        DataRegionTable table = new DataRegionTable("query", this);
        assertTrue("No data in room utilization query", table.getDataRowCount() > 0);
    }


    @Test @Ignore("Reports not finalized for SNPRC")
    public void testMoreReports()
    {
        Map<String, List<String>> additionalReports = new HashMap<>();
        additionalReports.put("Listing of Cages", Arrays.asList());
        additionalReports.put("Mature Female Exposed To Fertile Male", Arrays.asList("test3844307", "test5598475"));

        BodyWebPart dashboard = new BodyWebPart(this, "Electronic Health Record", 1);
        clickAndWait(Locator.linkWithText("More Reports").findElement(dashboard));
        saveLocation();

        for (Map.Entry<String, List<String>> entry : additionalReports.entrySet())
        {
            clickAndWait(Locator.linkWithText(entry.getKey()));
            assertTextPresent(entry.getValue());
            recallLocation();
        }
    }

    @Test
    public void testLookups()
    {
        navigateToQuery("ehr", "animalExposure", 180000);

        DataRegionTable query = new DataRegionTable("query", this);
        List<String> row = query.getRowDataAsText(0);

        for (int i = 0; i < row.size(); i++)
        {
            String cell = row.get(i);
            if (cell != null && cell.startsWith("<"))
            {
                List<String> header = query.getColumnHeaders();
                Assert.fail("Broken lookup '" + cell + "' for column '" + header.get(i) + "'");
            }
        }
    }

    @Test
    public void testAnimalHistory()
    {
        click(Locator.linkWithText("Animal History"));
        saveLocation();
        waitForElement(Locator.inputByNameContaining("textfield"));
        setFormElement(Locator.inputByNameContaining("textfield"), "12345");
        click(Locator.tagWithText("span", "Refresh"));
        waitForText("Overview: 12345");
        waitForTextToDisappear("Loading...");
        //spot check a few of the data points
        assertTextPresent("2043365 / A1", "There are no active medications", "Rhesus");
        recallLocation();
        click(Locator.xpath("//label[.='Entire Database']/../input"));
        click(Locator.tagWithText("span", "Refresh"));
        //check count and links for one subject
        DataRegionTable tbl = DataRegionTable.findDataRegionWithin(this, PortalHelper.Locators.webPart("Overview").waitForElement(getDriver(), WAIT_FOR_JAVASCRIPT));
        assertEquals(tbl.getDataRowCount(), 49);
        assertElementPresent(Locator.linkWithText("test1020148"));
        assertElementPresent(Locator.linkWithText("Male"));
        assertElementPresent(Locator.linkWithText("Alive"));
    }

    @Test
    public void testCurrentBloodReportRhesus() throws Exception
    {
        Connection connection = createDefaultConnection(true);
        String aliveRhesusId = "TEST9195996";
        Map<String, Object> weightRow = new HashMap<>();
        weightRow.put("Id", aliveRhesusId);
        weightRow.put("date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)));
        weightRow.put("weight", 5);

        InsertRowsCommand command = new InsertRowsCommand("study", "weight");
        command.setRows(Arrays.asList(weightRow));
        command.execute(connection, getProjectName());

        Map<String, Object> bloodRow = new HashMap<>();
        bloodRow.put("Id", aliveRhesusId);
        bloodRow.put("date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -2)));
        bloodRow.put("quantity", 5);

        command = new InsertRowsCommand("study", "blood");
        command.setRows(Arrays.asList(bloodRow));
        command.execute(connection, getProjectName());

        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, aliveRhesusId);

        participantViewPage.clickCategoryTab("General");
        participantViewPage.clickReportTab("Current Blood");

        //TODO: Verify report. Blocked -- SNPRC reports don't understand some test data (demographics)
    }

    /**
     * Report based off of Animal Events dataset: referenceStudy/datasets/dataset1067.tsv
     */
    @Test
    public void testProceduresBeforeDispositionReport() throws Exception
    {
        String deadAnimalId = "TEST1441142";
        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, deadAnimalId);

        participantViewPage.clickCategoryTab("Clinical");
        participantViewPage.clickReportTab("Animal Events");
        List<String> remarkColumn = participantViewPage.getActiveReportDataRegion(this).getColumnDataAsText("Remark");
        assertEquals("Should be 4 events for " + deadAnimalId + ". Check SNPRC reference study dataset1067.tsv", Arrays.asList("necropsy -4days", "necropsy -3days", "necropsy -0days", "necropsy +1days"), remarkColumn);

        participantViewPage.clickReportTab("Procedures Before Disposition");
        remarkColumn = participantViewPage.getActiveReportDataRegion(this).getColumnDataAsText("Remark");
        assertEquals("Report should show events less than 3 days before death", Arrays.asList("necropsy +1days", "necropsy -0days", "necropsy -3days"), remarkColumn);
    }

    @Test
    public void testAnimalHistoryReports()
    {
        clickAndWait(Locator.linkWithText("Animal History"));
        SNPRCAnimalHistoryPage animalHistoryPage = new SNPRCAnimalHistoryPage(this);

        waitForElement(Locator.inputByNameContaining("textfield"));
        setFormElement(Locator.inputByNameContaining("textfield"), "TEST1441142");
        click(Locator.tagWithText("span", "Refresh"));

        List<String> errors = new ArrayList<>();
        Map<String, WebElement> categoryTabs = animalHistoryPage.elements().findCategoryTabs();
        for (String category : categoryTabs.keySet())
        {
            log("Category: " + category);
            TestLogger.increaseIndent();
            animalHistoryPage.clickCategoryTab(category);

            Map<String, WebElement> reportTabs = animalHistoryPage.elements().findReportTabs();
            for (String report : reportTabs.keySet())
            {
                log("Report: " + report);
                try
                {
                    animalHistoryPage.clickReportTab(report);
                }
                catch(WebDriverException fail)
                {
                    throw new AssertionError("There appears to be an error in the report: " + report, fail);
                }

                List<WebElement> errorEls = Locator.CssLocator.union(Locators.labkeyError, Locator.css(".error")).findElements(getDriver());
                if (!errorEls.isEmpty())
                {
                    List<String> errorTexts = getTexts(errorEls);
                    if (!String.join("", errorTexts).trim().isEmpty())
                    {
                        errors.add("Error in: " + category + " - " + report);
                        for (String errorText : errorTexts)
                            if (!errorText.trim().isEmpty())
                                errors.add("\t" + errorText.trim());
                    }
                }
            }

            TestLogger.decreaseIndent();
        }
        if (!errors.isEmpty())
        {
            errors.add(0, "Error(s) in animal history report(s)");
            fail(String.join("\n", errors).replaceAll("\n+", "\n"));
        }
    }

    @Test
    public void testSnprcFrontPageView()
    {
        BodyWebPart frontPage = new BodyWebPart(this, "Electronic Health Record");
        WebElement browseData = Locator.tagWithText("a", "Browse Data").findElement(frontPage);
        WebElement enterData = Locator.tagWithText("a", "Enter Data").findElement(frontPage);
        WebElement colonyOverview = Locator.tagWithText("a", "Colony Overview").findElement(frontPage);

        Crawler.ControllerActionId actionId = new Crawler.ControllerActionId(browseData.getAttribute("href"));
        assertEquals("Wrong controller for 'Browse Data", "snprc_ehr", actionId.getController());
        assertEquals("Wrong action for 'Browse Data", "animalHistory", actionId.getAction());

        actionId = new Crawler.ControllerActionId(enterData.getAttribute("href"));
        assertEquals("Wrong controller for 'Enter Data", "ehr", actionId.getController());
        assertEquals("Wrong action for 'Enter Data", "enterData", actionId.getAction());

        actionId = new Crawler.ControllerActionId(colonyOverview.getAttribute("href"));
        assertEquals("Wrong controller for 'Colony Overview", "ehr", actionId.getController());
        assertEquals("Wrong action for 'Colony Overview", "colonyOverview", actionId.getAction());
    }

    @Test
    public void testEhrDatasets()
    {
        /* Non-exhaustive lists */
        List<String> expectedDatasets = new ArrayList<>(Arrays.asList(
                "SNPRC Labwork Results",
                "SNPRC ID History",
                "Freezerworks"
        ));
        List<String> expectedHiddenDatasets = new ArrayList<>(Arrays.asList(
                "miscTests",
                "Misc Tests",
                "notes",
                "Notes"
        ));

        BodyWebPart datasets = new BodyWebPart(this, "EHR Datasets");
        List<WebElement> datasetLabelElements = Locator.css(".ldk-navpanel-section-row div.x4-box-item.x4-panel").findElements(datasets);
        List<String> datasetLabels = new ArrayList<>();
        for (WebElement el : datasetLabelElements)
        {
            datasetLabels.add(el.getText().replace(":", ""));
        }

        expectedDatasets.removeAll(datasetLabels);
        assertTrue("Missing dataset(s): [" + String.join(", ", expectedDatasets) + "]", expectedDatasets.isEmpty());
        List<String> hiddenDatasets = new ArrayList<>(expectedHiddenDatasets);
        hiddenDatasets.removeAll(datasetLabels);
        assertEquals("Dataset(s) not hidden", expectedHiddenDatasets, hiddenDatasets);
    }
}
