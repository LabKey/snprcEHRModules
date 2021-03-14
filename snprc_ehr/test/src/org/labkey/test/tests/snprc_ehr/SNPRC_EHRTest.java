/*
 * Copyright (c) 2016-2019 LabKey Corporation
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
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.TruncateTableCommand;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.Locator;
import org.labkey.test.Locators;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.categories.CustomModules;
import org.labkey.test.categories.EHR;
import org.labkey.test.categories.SNPRC;
import org.labkey.test.components.BodyWebPart;
import org.labkey.test.components.ehr.panel.AnimalSearchPanel;
import org.labkey.test.components.ext4.widgets.SearchPanel;
import org.labkey.test.pages.ehr.AnimalHistoryPage;
import org.labkey.test.pages.ehr.ColonyOverviewPage;
import org.labkey.test.pages.ehr.ParticipantViewPage;
import org.labkey.test.pages.snprc_ehr.SNPRCAnimalHistoryPage;
import org.labkey.test.tests.ehr.AbstractGenericEHRTest;
import org.labkey.test.util.APIAssayHelper;
import org.labkey.test.util.Crawler;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.LogMethod;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.TextSearcher;
import org.labkey.test.util.UIAssayHelper;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;
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
import java.util.UUID;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.labkey.test.util.DataRegionTable.DataRegion;

@Category ({CustomModules.class, EHR.class, SNPRC.class})
@BaseWebDriverTest.ClassTimeout(minutes = 45)
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
    private static final File ANIMAL_GROUP_CATEGORIES_TSV = TestFileUtils.getSampleData("snprc/animal_group_categories.tsv");
    private static final File SPECIES_TSV = TestFileUtils.getSampleData("snprc/species.tsv");
    private static final String PROJECT_NAME = "SNPRC";
    private static final String COREFACILITIES = "Core Facilities";
    private static final String GENETICSFOLDER = "Genetics";
    private static final String FOLDER_NAME = "SNPRC";
    private static final String ANIMAL_HISTORY_URL = "/ehr/" + PROJECT_NAME + "/animalHistory.view?";
    private static final String SNPRC_ROOM_ID = "S824778";
    private static final String SNPRC_ROOM_ID2 = "S043365";

    private static int _pipelineJobCount = 0;

    @Override
    public String getModuleDirectory()
    {
        return "snprcEHRModules/snprc_ehr";
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
        _containerHelper.createSubfolder(getProjectName(), COREFACILITIES, GENETICSFOLDER, "Laboratory Folder", new String[]{"SNPRC_Genetics"});
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

    private void goToAnimalHistory()
    {
        clickTab("Animal History");
        waitForText("General");
        waitForText("Enter Subject Id");
    }

    private void doSetup() throws Exception
    {
        new RReportHelper(this).ensureRConfig();
        initProject("SNPRC EHR");
        goToProjectHome();
        _containerHelper.enableModules(Arrays.asList("SND"));
        createTestSubjects();
        initGenetics();
        initSND();
        goToProjectHome();
        clickFolder(GENETICSFOLDER);
        _assayHelper = new APIAssayHelper(this);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_GENE_EXPRESSION_XAR, 1);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_MICROSATELLITES_XAR, 2);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_PHENOTYPES_XAR, 3);
        _assayHelper.uploadXarFileAsAssayDesign(ASSAY_SNPS_XAR, 4);
        clickFolder(GENETICSFOLDER);
        _listHelper.importListArchive(LOOKUP_LIST_ARCHIVE);
        clickProject(PROJECT_NAME);
        PortalHelper portalHelper = new PortalHelper(this);
        portalHelper.addWebPart("EHR Datasets");
        clickFolder(GENETICSFOLDER);
        portalHelper.addWebPart("Assay List");
        _assayHelper = new APIAssayHelper(this);
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
        return new String[] {SNPRC_ROOM_ID2, SNPRC_ROOM_ID, SNPRC_ROOM_ID2};
    }

    @Override
    protected boolean doSetUserPasswords()
    {
        return true;
    }

    @Override
    protected File getStudyPolicyXML()
    {
        return TestFileUtils.getSampleData("snprcEHRStudyPolicy.xml");
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
    public String getModulePath() {
        return "/server/modules/" + getModuleDirectory();
    }

    @Override
    protected void importStudy()
    {
        importStudyFromPath(++_pipelineJobCount);
    }

    protected void initSND()
    {
        goToProjectHome();
        waitAndClickAndWait(Locators.bodyPanel().append(Locator.tagContainingText("a", "EHR Admin Page")));
        clickAndWait(Locator.linkWithText("SND SETTINGS"));
        waitAndClick(Locator.linkWithSpan("Generate SNPRC custom columns"));
        waitForText("Success");
        goToProjectHome();
    }

    protected void initGenetics()
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

        InsertRowsCommand command = new InsertRowsCommand("snprc_ehr", "animal_groups");
        command.setRows(loadTsv(ANIMAL_GROUPS_TSV));
        command.execute(connection, getProjectName()).getRows();

        command = new InsertRowsCommand("snprc_ehr", "animal_group_categories");
        command.setRows(loadTsv(ANIMAL_GROUP_CATEGORIES_TSV));
        command.execute(connection, getProjectName()).getRows();

        command = new InsertRowsCommand("snprc_ehr", "species");
        command.setRows(loadTsv(SPECIES_TSV));
        command.execute(connection, getProjectName()).getRows();

        // Valid accounts
        List<Map<String, Object>> accountRows = Arrays.asList(
                new HashMap<String, Object>(Maps.of("account", "1000-100-10",
                        "description", "Doe, 1111MM",
                        "accountStatus", "A",
                        "accountGroup", "Doe",
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -20)))),
                new HashMap<String, Object>(Maps.of("account", "2000-200-20",
                        "description", "Smith, 2222PC",
                        "accountStatus", "A",
                        "accountGroup", "Smith 2222",
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -15)))),
                new HashMap<String, Object>(Maps.of("account", "3000-300-30",
                        "description", "Yu, Reseach 1212",
                        "accountStatus", "A",
                        "accountGroup", "Undefined",
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -2)))),
                new HashMap<String, Object>(Maps.of("account", "4000-400-40",
                        "description", "General clinical",
                        "accountStatus", "I",
                        "accountGroup", "Clinical",
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -112)))));

        for (Map<String, Object> accountRow : accountRows)
        {
            accountRow.put("objectid", UUID.randomUUID());
        }

        command = new InsertRowsCommand("snprc_ehr", "validAccounts");
        command.setRows(accountRows);
        command.execute(connection, getProjectName());

        // Labwork types
        List<Map<String, Object>> labworkTypeRows = Arrays.asList(
                Maps.of("serviceType", "Hematology"),
                Maps.of("serviceType", "Surveillance"),
                Maps.of("serviceType", "Microbiology"),
                Maps.of("serviceType", "Urinalysis")
        );

        command = new InsertRowsCommand("snprc_ehr", "labwork_types");
        command.setRows(labworkTypeRows);
        command.execute(connection, getProjectName());

        // Labwork services
        List<Map<String, Object>> labworkServiceRows = Arrays.asList(
                Maps.of("servicename", "BLOOD LAB SERVICES",
                        "dataset", "Hematology",
                        "serviceid", "11111",
                        "objectid", UUID.randomUUID()),
                Maps.of("servicename", "X VIRUS",
                        "dataset", "Surveillance",
                        "serviceid", "22222",
                        "objectid", UUID.randomUUID()),
                Maps.of("servicename", "FULL PANEL CULTURE",
                        "dataset", "Microbiology",
                        "serviceid", "33333",
                        "objectid", UUID.randomUUID()),
                Maps.of("servicename", "URINE CHEM",
                        "dataset", "Urinalysis",
                        "serviceid", "44444",
                        "objectid", UUID.randomUUID())
        );

        command = new InsertRowsCommand("snprc_ehr", "labwork_services");
        command.setRows(labworkServiceRows);
        command.execute(connection, getProjectName());
    }

    @Override
    @LogMethod
    protected void populateRoomRecords() throws Exception
    {
        InsertRowsCommand insertCmd = new InsertRowsCommand("ehr_lookups", "rooms");
        insertCmd.addRow(Maps.of("room", SNPRC_ROOM_ID));
        insertCmd.addRow(Maps.of("room", SNPRC_ROOM_ID2));
        insertCmd.execute(createDefaultConnection(false), getContainerPath());
    }

    @Override
    protected void deleteHardTableRecords() throws CommandException, IOException
    {
        super.deleteHardTableRecords();
        Connection connection = createDefaultConnection(true);

        TruncateTableCommand command = new TruncateTableCommand("snprc_ehr", "animal_groups");
        command.execute(connection, getProjectName());

        command = new TruncateTableCommand("snprc_ehr", "animal_group_categories");
        command.execute(connection, getProjectName());

        command = new TruncateTableCommand("snprc_ehr", "species");
        command.execute(connection, getProjectName());
    }

    @Override
    @LogMethod
    protected  void deleteRoomRecords() throws CommandException, IOException
    {
        deleteIfNeeded("ehr_lookups", "rooms", Maps.of("room", SNPRC_ROOM_ID), "room");
        deleteIfNeeded("ehr_lookups", "rooms", Maps.of("room", SNPRC_ROOM_ID2), "room");
    }

    @Override
    protected void populateInitialData()
    {
        beginAt(WebTestHelper.getBaseURL() + "/SNPRC_EHR/" + getContainerPath() + "/populateData.view");

        repopulate("Lookup Sets");
        repopulate("All");
        repopulate("Weight Ranges");
    }

    @Before
    public void preTest()
    {
        goToProjectHome();
        waitForElement(Locator.linkWithText("Animal Search"));
        waitForElement(Locator.linkWithText("Browse All"));
    }

    @Test
    public void testAnimalSearch()
    {
        SearchPanel searchPanel;
        DataRegionTable searchResults;

        beginAt("/project/" + getContainerPath() + "/begin.view");
        waitAndClickAndWait(Locator.linkWithText("Animal Search"));
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.selectValues("Gender", false, " All");
        assertEquals("Selecting 'All' genders didn't set input correctly", "Female;Male;Unknown", getFormElement(Locator.input("gender")));
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows for searching all genders", 41, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.selectValues("Species code (3 char)", false, "PCC");
        assertEquals("Select 'PCC' species didn't set input correctly", "PCC", getFormElement(Locator.input("species")));
        searchPanel.selectValues("Species code (3 char)", true, "CTJ");
        assertEquals("Adding 'CTJ' to species filter didn't set input correctly", "PCC;CTJ", getFormElement(Locator.input("species")));
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows: Species = PCC or CTJ", 14, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.setFilter("Id", null, "1");
        searchResults = searchPanel.submit();
        assertElementPresent(Locator.linkWithText("TEST1020148"));
        assertEquals("Wrong number of rows: 'Id' contains '1'", 20, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.setFilter("Cage", null, "5426");
        searchResults = searchPanel.submit();
        assertEquals("Wrong animals for search: 'cage' contains '5426'", Arrays.asList("TEST499022", "TEST6390238"), searchResults.getColumnDataAsText("Id"));
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
        BodyWebPart dashboard = new BodyWebPart(getDriver(), "Electronic Health Record", 1);
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

        BodyWebPart dashboard = new BodyWebPart(getDriver(), "Electronic Health Record", 1);
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
    public void testLookupsAndSND()
    {
        navigateToQuery("ehr", "animalExposure", 180000);

        DataRegionTable query = new DataRegionTable("query", this);
        List<String> row = query.getRowDataAsText(0);

        for (int i = 0; i < row.size(); i++)
        {
            String cell = row.get(i);
            if (cell != null && cell.startsWith("<"))
            {
                List<String> header = query.getColumnLabels();
                Assert.fail("Broken lookup '" + cell + "' for column '" + header.get(i) + "'");
            }
        }

        // Just verify these extensible columns were successfully added
        navigateToQuery("snd", "Pkgs", 180000);
        assertTextPresent("UsdaCode");

        navigateToQuery("snd", "Projects", 180000);
        assertTextPresent("VsNumber");
        assertTextPresent("ProjectType");
    }

    @Test
    public void testAnimalHistorySingleAnimalFilter()
    {
        goToAnimalHistory();
        new SNPRCAnimalHistoryPage(getDriver())
                .searchSingleAnimal("12345");
        waitForText("Overview: 12345");
        waitForTextToDisappear("Loading...");
        //spot check a few of the data points
        assertTextPresent("S043365 / A1", "There are no active medications", "Rhesus");
    }

    @Test
    public void testAnimalHistoryMultiAnimalFilter()
    {
        final String id = "12345";
        final String alias = "ALIAS1";
        final String aliasedId = "TEST3804589";
        final String conflictedAlias = "ALIAS2";
        final List<String> conflictedIds = Arrays.asList("TEST4551032", "TEST5904521");
        final String notFound = "1234";

        goToAnimalHistory();
        final SNPRCAnimalHistoryPage historyPage = new SNPRCAnimalHistoryPage(getDriver())
                .selectMultiAnimalSearch()
                .replaceSubjects(id + ";" + alias + ";" + conflictedAlias + ";" + notFound)
                .getPage();

        assertEquals("Wrong found ID(s)", Arrays.asList(id), historyPage.getFoundIds());
        assertEquals("Wrong aliased ID(s)", Arrays.asList(aliasedId), historyPage.getAliasIds());
        assertEquals("Wrong conflicted ID(s)", conflictedIds, historyPage.getConflictedIds());
        assertEquals("Wrong not-found ID(s)", Arrays.asList(notFound), historyPage.getNotFoundIds());

        List<String> expectedIds = new ArrayList<>();
        expectedIds.add(aliasedId);
        expectedIds.addAll(conflictedIds);
        expectedIds.add(id);

        historyPage.clickReportTab("Demographics");
        DataRegionTable demographics = historyPage.getActiveReportDataRegion();
        assertEquals("Wrong animals in report", expectedIds, demographics.getColumnDataAsText("Id"));
    }

    @Test
    public void testAnimalHistoryMultiAnimalFilterSNPRCOverrides()
    {
        goToAnimalHistory();
        final SNPRCAnimalHistoryPage historyPage = new SNPRCAnimalHistoryPage(getDriver());
        List<String> ids = historyPage.selectMultiAnimalSearch()
                .replaceSubjects("1..5")
                .getPage()
                .getNotFoundIds();
        assertEquals("Search for 1..5 did not work correctly", Arrays.asList("1", "2", "3", "4", "5"), ids);

        ids = historyPage.selectMultiAnimalSearch()
                .replaceSubjects("1 12345")
                .getPage()
                .getNotFoundIds();
        assertEquals("Search for \"1 12345\" did not work correctly", Arrays.asList("1_12345"), ids);
    }

    @Test
    public void testAnimalHistoryNoFilter()
    {
        goToAnimalHistory();
        new SNPRCAnimalHistoryPage(getDriver())
                .selectEntireDatabaseSearch()
                .refreshReport();
        //check count and links for one subject
        final WebElement overview = PortalHelper.Locators.webPart("Overview").waitForElement(getDriver(), WAIT_FOR_JAVASCRIPT);
        DataRegionTable tbl = DataRegion(getDriver()).find(overview);
        assertEquals(tbl.getDataRowCount(), 49);
        assertElementPresent(Locator.linkWithText("TEST1020148"));
        assertElementPresent(Locator.linkWithText("Male"));
        assertElementPresent(Locator.linkWithText("Alive"));
    }

    /**
     * Report based off of Animal Events dataset: referenceStudy/datasets/dataset1067.tsv
     */
    @Test
    public void testProceduresBeforeDispositionReport()
    {
        final String deadAnimalId = "TEST1441142";
        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, deadAnimalId);

        participantViewPage.clickCategoryTab("Clinical");
        participantViewPage.clickReportTab("Animal Events");
        List<String> remarkColumn = participantViewPage.getActiveReportDataRegion().getColumnDataAsText("Procedure Text");
        assertEquals("Should be 4 events for " + deadAnimalId + ". Check SNPRC reference study dataset1067.tsv", Arrays.asList("necropsy +1days", "necropsy -0days", "necropsy -3days", "necropsy -4days"), remarkColumn);

        participantViewPage.clickReportTab("Procedures Before Disposition");
        remarkColumn = participantViewPage.getActiveReportDataRegion().getColumnDataAsText("Procedure Text");
        assertEquals("Report should show events less than or equal to 3 days before death", Arrays.asList("necropsy +1days", "necropsy -0days", "necropsy -3days", "necropsy -4days"), remarkColumn);
    }

    @Test
    public void testAnimalHistoryReports()
    {
        goToAnimalHistory();
        SNPRCAnimalHistoryPage animalHistoryPage = new SNPRCAnimalHistoryPage(getDriver());
        animalHistoryPage.searchSingleAnimal("TEST1441142", "No active housing");
        _helper.verifyAllReportTabs(animalHistoryPage);
    }

    @Test
    public void testSnprcFrontPageView()
    {
        BodyWebPart frontPage = new BodyWebPart(getDriver(), "Electronic Health Record");
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
                "SNPRC ID History",
                "Freezerworks"
        ));
        List<String> expectedHiddenDatasets = new ArrayList<>(Arrays.asList(
                "miscTests",
                "Misc Tests",
                "notes",
                "Notes"
        ));

        BodyWebPart datasets = new BodyWebPart(getDriver(), "EHR Datasets");
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
    public void testProcedureLookups()
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
    public void testBaboonCensus()
    {
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        ColonyOverviewPage.BaboonColonyTab baboonColonyTab = overviewPage.clickBaboonColonyTab();
        String[] censusColumns = {"Investigator", "Protocol", "M", "F", "SPF", "Conventional", "Total"};
        waitForElement(Locator.tagContainingText("span","Active IACUC Assignments"),WAIT_FOR_PAGE);
        List<String> row = baboonColonyTab.getActiveIacucDataRegion().getRows(censusColumns).get(0);
        List<String> expectedRows =
                Arrays.asList("dummyinvestigator", "dummyprotocol", "2", "2", " ", "1", "4");
        assertEquals(expectedRows, row);
    }

    @Test
    public void testKinshipReport()
    {
        final String animal1 = "TEST2312318";
        final String animal2 = "TEST3844307";

        SNPRCAnimalHistoryPage historyPage = SNPRCAnimalHistoryPage.beginAt(this);
        historyPage.appendMultipleAnimals(animal1, animal2);
        historyPage.clickCategoryTab("Genetics");
        historyPage.clickReportTab("Kinship");

        DataRegionTable tbl = historyPage.getActiveReportDataRegion();
        assertEquals(tbl.getDataRowCount(), 14);

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
        TextSearcher fileSearcher = new TextSearcher(csv);

        assertTextPresent(fileSearcher, "," + animal1 + "," + animal2);
        assertTextPresent(fileSearcher, animal1 + ", ,0.375");
        assertTextPresent(fileSearcher, animal2 + ",0.375,");

    }

    @Test
    public void testClinicalHistoryPanelOptions(){
        beginAtAnimalHistoryTab();
        openClinicalHistoryForAnimal("TEST1020148");

        Ext4FieldRef.getForLabel(this, "Min Date").setValue("09/01/2015");
        clickButtonContainingText("Reload", "Hematology");

        List<String> expectedLabels = new ArrayList<>(
                Arrays.asList(
                        "Accounts",
                        "Assignments",
                        "Chemistry",
                        "Diet",
                        "Housing Transfers",
                        "Labwork Results",
                        "Offspring",
                        "TB",
                        "Virology",
                        "Weights",

                        "Arrival/Departure",
                        "Clinical",
                        "Hematology",
                        "Labwork",
                        "Notes",
                        "Pregnancy",
                        "Therapy",
                        "Vitals"
                        ));
        checkClinicalHistoryType(expectedLabels);
        findButton("Submit").click();

        List<String> entries = new ArrayList<>(
                Arrays.asList(
                        "TEST1020148 (2016-06-14)",
                        "TEST1020148 (2016-06-10)",
                        "TEST1020148 (2016-06-01)",
                        "TEST1020148 (2016-04-21)",
                        "TEST1020148 (2016-01-18)",
                        "Weight: 3.73 kg",
                        "Charge Id: 7133145",
                        "Service/Panel: X VIRUS",
                        "Protocol: protocol101",
                        "Service/Panel: FULL PANEL CULTURE",
                        "Moved to: 950756 / 4420023",
                        "Service/Panel: URINE CHEM"
                )
        );
        SNPRCAnimalHistoryPage animalHistoryPage = new SNPRCAnimalHistoryPage(getDriver());
        WebElement activeReport = animalHistoryPage.getActiveReportPanel();

        assertTextPresent(new TextSearcher(activeReport::getText), entries.toArray(new String[]{}));

        // Deselect weight, blood and housing
        waitAndClick(Locator.linkWithText("Show/Hide Types"));
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(4).click();
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(9).click();
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(11).click();
        findButton("Submit").click();

        animalHistoryPage = new SNPRCAnimalHistoryPage(getDriver());
        activeReport = animalHistoryPage.getActiveReportPanel();

        assertTextNotPresent(new TextSearcher(activeReport::getText), "Weight: 3.73 kg", "Charge Id: 7133145", "Moved to: 950756 / 4420023");

        entries = new ArrayList<>(
                Arrays.asList(
                        "TEST1020148 (2016-06-14)",
                        "TEST1020148 (2016-01-18)",
                        "Service/Panel: X VIRUS",
                        "Protocol: protocol101",
                        "Service/Panel: FULL PANEL CULTURE",
                        "Service/Panel: URINE CHEM"
                )
        );

        assertTextPresent(entries);

    }

    @Test
    public void testDateFormat(){

        String dateFormat = "yy-M-d";
        String dateTimeFormat = "yy-M-d H:mm";
        String expectedDate = "16-6-1";
        String expectedTime = "8:58";

        testDateFormat(dateFormat,dateTimeFormat, expectedDate, expectedTime);

        dateFormat = "yyyy-MM-dd";
        dateTimeFormat = dateFormat + " HH:mm";
        expectedDate = "2016-06-01";
        expectedTime = "08:58";

        testDateFormat(dateFormat,dateTimeFormat, expectedDate, expectedTime);

    }

    private void testDateFormat(String dateFormat, String dateTimeFormat, String expectedDate, String expectedTime)
    {
        setProjectDateFormat(dateFormat,dateTimeFormat);

        confirmJavascriptDrivenDateFormat(expectedDate);
    }

    private void confirmJavascriptDrivenDateFormat(String expectedDate)
    {
        beginAtAnimalHistoryTab();

        //chronological history
        AnimalHistoryPage animalHistoryPage = new AnimalHistoryPage(getDriver());
        animalHistoryPage.searchSingleAnimal("TEST1020148");
        animalHistoryPage.clickCategoryTab("Clinical");
        animalHistoryPage.clickReportTab("Clinical History");
        assertTextPresentCaseInsensitive(expectedDate);
    }

    private void setProjectDateFormat(String dateFormat, String dateTimeFormat)
    {
        goToProjectSettings(PROJECT_NAME);

        setFormElement(Locator.name("defaultDateFormat"), dateFormat);
        setFormElement(Locator.name("defaultDateTimeFormat"), dateTimeFormat);
        clickAndWait(Locator.lkButton("Save"));
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }
}
