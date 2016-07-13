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
import org.labkey.api.reader.TabLoader;
import org.labkey.api.util.GUID;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.TruncateTableCommand;
import org.labkey.test.Locator;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.SNPRC;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.pages.ehr.ParticipantViewPage;
import org.labkey.test.pages.snprc_ehr.ColonyOverviewPage;
import org.labkey.test.pages.snprc_ehr.SNPRCAnimalHistoryPage;
import org.labkey.test.tests.ehr.AbstractGenericEHRTest;
import org.labkey.test.util.Crawler;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.TextSearcher;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

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
    private static final File ANIMAL_GROUPS_TSV = TestFileUtils.getSampleData("snprc/animal_groups.tsv");
    private static final File ANIMAL_GROUP_MEMBERS_TSV = TestFileUtils.getSampleData("snprc/animal_group_members.tsv");
    private static final String PROJECT_NAME = "SNPRC";
    private static final String COREFACILITIES = "Core Facilities";
    private static final String GENETICSFOLDER = "Genetics";
    private static final String FOLDER_NAME = "SNPRC";
    private static Integer _pipelineJobCount = 0;

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
        initGenetics();
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
    protected boolean skipStudyImportQueryValidation()
    {
        return true;
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
        waitForPipelineJobsToComplete(++_pipelineJobCount, "Study import", false, MAX_WAIT_SECONDS * 2500);
    }

    protected void initGenetics() throws Exception
    {
        beginAt(WebTestHelper.buildURL("ehr", getProjectName(), "doGeneticCalculations"));
        clickButton("OK");
        waitForPipelineJobsToComplete(++_pipelineJobCount, "EHR Kinship Calculation", false, 10 * 60000);
    }

    @Override
    protected void populateHardTableRecords() throws Exception
    {
        super.populateHardTableRecords();
        Connection connection = createDefaultConnection(true);

        InsertRowsCommand command = new InsertRowsCommand("ehr", "animal_groups");
        command.setRows(loadTsv(ANIMAL_GROUPS_TSV));
        List<Map<String, Object>> savedRows = command.execute(connection, getProjectName()).getRows();
        Map<String, Number> groupIds = new HashMap<>();
        for (Map<String, Object> row : savedRows)
        {
            groupIds.put((String)row.get("name"), (Number)row.get("rowid"));
        }

        command = new InsertRowsCommand("study", "animal_group_members");
        List<Map<String, Object>> loadedTsv = loadTsv(ANIMAL_GROUP_MEMBERS_TSV);
        for (Map<String, Object> row : loadedTsv)
        {
            String group = (String)row.get("groupid");
            row.put("groupid", groupIds.get(group));
            row.put("objectid", new GUID());
        }
        command.setRows(loadedTsv);
        command.execute(connection, getProjectName());
    }

    @Override
    protected void deleteHardTableRecords() throws CommandException, IOException
    {
        super.deleteHardTableRecords();
        Connection connection = createDefaultConnection(true);

        TruncateTableCommand command = new TruncateTableCommand("ehr", "animal_groups");
        command.execute(connection, getProjectName());
    }

    private List<Map<String, Object>> loadTsv(File tsv)
    {
        try
        {
            TabLoader loader = new TabLoader(tsv, true);
            loader.setInferTypes(false);
            return loader.load();
        }
        catch (IOException fail)
        {
            throw new RuntimeException(fail);
        }
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
        waitForElement(Locator.linkWithText("TEST1020148"));
        recallLocation();
        waitForElement(Locator.inputByNameContaining("Id/curLocation/cage"));
        setFormElement(Locator.inputByNameContaining("Id/curLocation/cage"), "5426");
        click(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Locator.linkWithText("TEST499022"));
        waitForElement(Locator.linkWithText("TEST6390238"));

    }

    @Test
    public void testHousingSearch()
    {
        click(Locator.linkWithText("Housing Queries"));
        waitForElement(Locator.inputByNameContaining("Id"));
        pushLocation();
        setFormElement(Locator.inputByNameContaining("Id"), "1");
        click(Ext4Helper.Locators.ext4Button("Submit"));
        waitForElement(Locator.linkWithText("TEST1112911"));
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
        additionalReports.put("Mature Female Exposed To Fertile Male", Arrays.asList("TEST3844307", "TEST5598475"));

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
        assertElementPresent(Locator.linkWithText("TEST1020148"));
        assertElementPresent(Locator.linkWithText("Male"));
        assertElementPresent(Locator.linkWithText("Alive"));
    }

    @Test
    public void testCurrentBloodReportRhesus() throws Exception
    {
        // See snprc/species.tsv for blood values
        double maxDraw = 10.0; // mL/kg
        double weight = 5; //kg
        int refreshDays = 42;
        Connection connection = createDefaultConnection(true);
        String aliveRhesusId = "TEST9195996";
        List<Map<String, Object>> weightRows = Arrays.asList(
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(3 * refreshDays))),
                        "weight", weight));

        InsertRowsCommand command = new InsertRowsCommand("study", "weight");
        command.setRows(weightRows);
        command.execute(connection, getProjectName());

        List<Map<String, Object>> bloodRows = Arrays.asList(
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1))),
                        "quantity", weight),
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                        "quantity", (weight + 0.5) * maxDraw),
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                        "quantity", weight)
        );

        command = new InsertRowsCommand("study", "blood");
        command.setRows(bloodRows);
        command.execute(connection, getProjectName());

        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, aliveRhesusId);

        participantViewPage.clickCategoryTab("General");
        participantViewPage.clickReportTab("Current Blood");

        WebElement svg = Locator.css("div[id^=snprc-bloodsummarypanel-] svg").waitForElement(getDriver(), WAIT_FOR_JAVASCRIPT);
        assertEquals("Wrong number of data points", 5, svg.findElements(By.cssSelector("a.point")).size()); // Two blood draws, 3 refreshes
    }

    /**
     * Report based off of Animal Events dataset: referenceStudy/datasets/dataset1067.tsv
     */
    @Test
    public void testProceduresBeforeDispositionReport() throws Exception
    {
        final String deadAnimalId = "TEST1441142";
        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, deadAnimalId);

        participantViewPage.clickCategoryTab("Clinical");
        participantViewPage.clickReportTab("Animal Events");
        List<String> remarkColumn = participantViewPage.getActiveReportDataRegion().getColumnDataAsText("Remark");
        assertEquals("Should be 4 events for " + deadAnimalId + ". Check SNPRC reference study dataset1067.tsv", Arrays.asList("necropsy -4days", "necropsy -3days", "necropsy -0days", "necropsy +1days"), remarkColumn);

        participantViewPage.clickReportTab("Procedures Before Disposition");
        remarkColumn = participantViewPage.getActiveReportDataRegion().getColumnDataAsText("Remark");
        assertEquals("Report should show events less than 3 days before death", Arrays.asList("necropsy +1days", "necropsy -0days", "necropsy -3days"), remarkColumn);
    }

    @Test
    public void testAnimalHistoryReports()
    {
        clickAndWait(Locator.linkWithText("Animal History"));
        SNPRCAnimalHistoryPage animalHistoryPage = new SNPRCAnimalHistoryPage(getDriver());

        setFormElement(Locator.inputByNameContaining("textfield"), "TEST1441142");
        click(Locator.tagWithText("span", "Refresh"));
        _helper.verifyAllReportTabs(animalHistoryPage);
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

    @Test
    public void testProcedureLookups() throws Exception
    {
        final String animalId = "TEST3771679";
        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, animalId);

        participantViewPage.clickCategoryTab("Clinical");
        participantViewPage.clickReportTab("Procedures");
        DataRegionTable reportDataRegion = participantViewPage.getActiveReportDataRegion();
        List<String> columnData = reportDataRegion.getColumnDataAsText("usdaCategory");
        columnData.addAll(reportDataRegion.getColumnDataAsText("procType"));
        for (String value : columnData)
        {
            assertFalse("Broken lookup: " + value, value.startsWith("<"));
        }
    }

    @Test
    public void testBaboonCensus() throws Exception
    {
        clickAndWait(Locator.linkWithText("Colony Overview"));
        ColonyOverviewPage overviewPage = new ColonyOverviewPage(getDriver());
        ColonyOverviewPage.BaboonColonyTab baboonColonyTab = overviewPage.clickBaboonColonyTab();
        String[] censusColumns = {"Investigator", "Protocol", "M", "F", "baboon1", "baboon2", "baboon3", "Total"};
        List<List<String>> rows = baboonColonyTab.getAssignedFundedDataRegion().getRows(censusColumns);
        List<List<String>> expectedRows = Arrays.asList(
                Arrays.asList("dummyinvestigator", "dummyprotocol", "2", "2", "3", "1", " ", "4"),
                Arrays.asList("investigator101", "protocol101", "4", "8", "2", "8", "2", "12"));
        assertEquals(String.join(", ", Arrays.asList(censusColumns)), expectedRows, rows);
    }

    @Test
    public void testKinshipReport() throws Exception
    {
        final String animal1 = "TEST2312318";
        final String animal2 = "TEST3844307";

        SNPRCAnimalHistoryPage historyPage = SNPRCAnimalHistoryPage.beginAt(this);
        historyPage.appendMultipleAnimals(animal1, animal2);
        historyPage.clickCategoryTab("Genetics");
        historyPage.clickReportTab("Kinship");

        DataRegionTable tbl = historyPage.getActiveReportDataRegion();
        assertEquals(tbl.getDataRowCount(), 16);

        _ext4Helper.checkCheckbox(Locator.ehrCheckboxIdContaining("limitRawDataToSelection"));

        tbl = historyPage.getActiveReportDataRegion();
        assertEquals(tbl.getDataRowCount(), 1);

        String[] idCols = {"Id", "Id2", "Coefficient"};
        List<List<String>> rows = tbl.getRows(idCols);
        List<List<String>> expectedRows = Arrays.asList(
                Arrays.asList(animal1, animal2, "0.375"));
        assertEquals(String.join(", ", Arrays.asList(idCols)), expectedRows, rows);

        _ext4Helper.clickExt4Tab("Matrix");
        File csv = doAndWaitForDownload(() -> click(Ext4Helper.Locators.ext4Button("Export")));
        TextSearcher fileSearcher = new TextSearcher(()-> TestFileUtils.getFileContents(csv));

        assertTextPresent(fileSearcher, "," + animal1 + "," + animal2);
        assertTextPresent(fileSearcher, animal1 + ", ,0.375");
        assertTextPresent(fileSearcher, animal2 + ",0.375,");

    }
}
