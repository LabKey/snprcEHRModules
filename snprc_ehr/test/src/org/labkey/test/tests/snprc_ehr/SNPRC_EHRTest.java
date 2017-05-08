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
import org.labkey.test.components.ehr.panel.AnimalSearchPanel;
import org.labkey.test.components.ext4.widgets.SearchPanel;
import org.labkey.test.pages.ehr.AnimalHistoryPage;
import org.labkey.test.pages.ehr.ParticipantViewPage;
import org.labkey.test.pages.ehr.ColonyOverviewPage;
import org.labkey.test.pages.snprc_ehr.SNPRCAnimalHistoryPage;
import org.labkey.test.tests.ehr.AbstractGenericEHRTest;
import org.labkey.test.util.APIAssayHelper;
import org.labkey.test.util.Crawler;
import org.labkey.test.util.DataRegionTable;
import org.labkey.test.util.Ext4Helper;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.TextSearcher;
import org.labkey.test.util.UIAssayHelper;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.labkey.test.util.DataRegionTable.DataRegion;

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
    private static final File ANIMAL_GROUP_CATEGORIES_TSV = TestFileUtils.getSampleData("snprc/animal_group_categories.tsv");
    private static final File SPECIES_TSV = TestFileUtils.getSampleData("snprc/species.tsv");
    private static final String PROJECT_NAME = "SNPRC";
    private static final String COREFACILITIES = "Core Facilities";
    private static final String GENETICSFOLDER = "Genetics";
    private static final String FOLDER_NAME = "SNPRC";
    private static final String ANIMAL_HISTORY_URL = "/ehr/" + PROJECT_NAME + "/animalHistory.view?";
    private static Integer _pipelineJobCount = 0;

    private boolean _hasCreatedBirthRecords = false;

    public String getModuleDirectory()
    {
        return "snprc_ehr";
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
        _assayHelper = new UIAssayHelper(this); // API Helper is causing browser timeouts on experiment-showAddXarFile
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
        return new String[] {"2043365", "6824778", "2043365"};
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
            accountRow.put("objectid", new GUID());
        }

        command = new InsertRowsCommand("snprc_ehr", "validAccounts");
        command.setRows(accountRows);
        command.execute(connection, getProjectName());

        // Labwork types
        List<Map<String, Object>> labworkTypeRows = Arrays.asList(
                Maps.of("servicename", "BLOOD LAB SERVICES",
                        "dataset", "Hematology",
                        "serviceid", "11111",
                        "objectid", new GUID()),
                Maps.of("servicename", "X VIRUS",
                        "dataset", "Surveillance",
                        "serviceid", "22222",
                        "objectid", new GUID()),
                Maps.of("servicename", "FULL PANEL CULTURE",
                        "dataset", "Microbiology",
                        "serviceid", "33333",
                        "objectid", new GUID()),
                Maps.of("servicename", "URINE CHEM",
                        "dataset", "Urinalysis",
                        "serviceid", "44444",
                        "objectid", new GUID())
        );

        command = new InsertRowsCommand("snprc_ehr", "labwork_services");
        command.setRows(labworkTypeRows);
        command.execute(connection, getProjectName());
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
        waitForElement(Locator.linkWithText("Browse All"));
    }

    @Test
    public void testAnimalSearch() throws Exception
    {
        SearchPanel searchPanel;
        DataRegionTable searchResults;

        beginAt("/project/" + getContainerPath() + "/begin.view");
        waitAndClickAndWait(Locator.linkWithText("Animal Search"));
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.selectValues("Gender", " All");
        assertEquals("Selecting 'All' genders didn't set input correctly", "Female;Male;Unknown", getFormElement(Locator.input("gender")));
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows for searching all genders", 43, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.selectValues("Species code (3 char)", "PCC");
        assertEquals("Select 'PCC' species didn't set input correctly", "PCC", getFormElement(Locator.input("species")));
        searchPanel.selectValues("Species code (3 char)", "CTJ");
        assertEquals("Adding 'CTJ' to species filter didn't set input correctly", "PCC;CTJ", getFormElement(Locator.input("species")));
        searchResults = searchPanel.submit();
        assertEquals("Wrong number of rows: Species = PCC or CTJ", 14, searchResults.getDataRowCount());

        goBack();
        searchPanel = new AnimalSearchPanel(getDriver());
        searchPanel.setFilter("Id", null, "1");
        searchResults = searchPanel.submit();
        assertElementPresent(Locator.linkWithText("TEST1020148"));
        assertEquals("Wrong number of rows: 'Id' contains '1'", 22, searchResults.getDataRowCount());

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
    public void testAnimalHistorySingleAnimalFilter()
    {
        clickTab("Animal History");
        new SNPRCAnimalHistoryPage(getDriver())
                .searchSingleAnimal("12345");
        waitForText("Overview: 12345");
        waitForTextToDisappear("Loading...");
        //spot check a few of the data points
        assertTextPresent("2043365 / A1", "There are no active medications", "Rhesus");
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

        clickTab("Animal History");
        final SNPRCAnimalHistoryPage historyPage = new SNPRCAnimalHistoryPage(getDriver())
                .selectMultiAnimalSearch()
                .replaceSubjects(id + ";" + alias + ";" + conflictedAlias + ";" + notFound)
                .getPage();

        assertEquals("Wrong found ID(s)", Arrays.asList(id), historyPage.getFoundIds());
        assertEquals("Wrong aliased ID(s)", Arrays.asList(aliasedId), historyPage.getAliasIds());
        assertEquals("Wrong conflicted ID(s)", conflictedIds, historyPage.getConflictedIds());
        assertEquals("Wrong not-found ID(s)", Arrays.asList(notFound), historyPage.getNotFoundIds());

        List<String> expectedIds = new ArrayList<>();
        expectedIds.add(id);
        expectedIds.add(aliasedId);
        expectedIds.addAll(conflictedIds);
        Collections.sort(expectedIds);

        historyPage.clickReportTab("Demographics");
        DataRegionTable demographics = historyPage.getActiveReportDataRegion();
        assertEquals("Wrong animals in report", expectedIds, demographics.getColumnDataAsText("Id"));
    }

    @Test
    public void testAnimalHistoryMultiAnimalFilterSNPRCOverrides()
    {
        clickTab("Animal History");
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
        clickTab("Animal History");
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

    private void setupBloodValues(String id, Double weight, List<Map<String, Object>> bloodRows) throws IOException, CommandException
    {
        Connection connection = createDefaultConnection(true);
        List<Map<String, Object>> weightRows = Arrays.asList(
                Maps.of("Id", id,
                        "date", DATE_FORMAT.format(new Date()),
                        "weight", weight));

        InsertRowsCommand command = new InsertRowsCommand("study", "weight");
        command.setRows(weightRows);
        command.execute(connection, getProjectName());

        if(null!=bloodRows && !bloodRows.isEmpty())
        {
            command = new InsertRowsCommand("study", "blood");
            command.setRows(bloodRows);
            command.execute(connection, getProjectName());
        }
    }

    private void verifyBloodPlotValues(ParticipantViewPage page, int dataPoints, boolean limitShown)
    {
        page.clickCategoryTab("General");
        page.clickReportTab("Current Blood");

        WebElement svg = Locator.css("div[id^=snprc-bloodsummarypanel-] svg").waitForElement(getDriver(), WAIT_FOR_JAVASCRIPT);
        assertEquals("Wrong number of data points", dataPoints, svg.findElements(By.cssSelector("a.point")).size());

        if(limitShown)
        {
            assertElementPresent(Locator.css("rect[fill^=url]"));
        }
        else
        {
            assertElementNotPresent(Locator.css("rect[fill^=url]"));
        }
    }

    private void verifyRecentBloodDraws(ParticipantViewPage page, Map<String, List<String>> values)
    {
        sleep(1000);
        List<DataRegionTable> dataRegions = page.getActiveReportDataRegions();
        DataRegionTable recentBlood = dataRegions.get(dataRegions.size() - 1);

        for (String col : values.keySet())
        {
            assertEquals("Wrong values in Recent Blood Draws", values.get(col), recentBlood.getColumnDataAsText(col));
        }
    }

    @Test
    public void testCurrentBloodReportRhesus() throws Exception
    {
        // See snprc/species.tsv for blood values
        double maxDraw = 10.0; // mL/kg
        double weight = 5; //kg
        int refreshDays = 42;

        String aliveRhesusId = "TEST9195996";

        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, aliveRhesusId);

        List<Map<String, Object>> bloodRows = Arrays.asList(
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1))),
                        "quantity", weight,
                        "project", PROJECT_ID),
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                        "quantity", (weight + 0.5) * maxDraw,
                        "project", PROJECT_ID),
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                        "quantity", weight,
                        "project", PROJECT_ID),
                Maps.of("Id", aliveRhesusId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -4)),
                        "quantity", 2,
                        "project", PROTOCOL_PROJECT_ID)
        );

        // Verify plot
        setupBloodValues(aliveRhesusId, 5.0, bloodRows);
        verifyBloodPlotValues(participantViewPage, 6, true); // Two blood draws, 3 refreshes

        // Verify Recent blood draw values
        Map<String, List<String>> recentBloodDraws = new HashMap<>();

        List<String> quantities = Arrays.asList("5.0", "55.0", "5.0");
        recentBloodDraws.put("quantity", quantities);

        List<String> dates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1))));
        recentBloodDraws.put("date", dates);

        List<String> dropDates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3 + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3) + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1) + refreshDays)));
        recentBloodDraws.put("dropDate", dropDates);

        verifyRecentBloodDraws(participantViewPage, recentBloodDraws);
    }

    @Test
    public void testCurrentBloodReportMarmoset() throws Exception
    {
        double weightLimit = .340; //kg
        int refreshDays = 14;
        String aliveMarmId = "TEST3804589";

        ParticipantViewPage participantViewPage = ParticipantViewPage.beginAt(this, aliveMarmId);

        List<Map<String, Object>> bloodRows = Arrays.asList(
                Maps.of("Id", aliveMarmId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1))),
                        "quantity", .8,
                        "project", PROJECT_ID),
                Maps.of("Id", aliveMarmId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                        "quantity", 1.0,
                        "project", PROJECT_ID),
                Maps.of("Id", aliveMarmId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                        "quantity", .5,
                        "project", PROJECT_ID),
                Maps.of("Id", aliveMarmId,
                        "date", DATE_FORMAT.format(DateUtils.addDays(new Date(), -4)),
                        "quantity", 2,
                        "project", PROTOCOL_PROJECT_ID)
        );

        // Test lower weight limit
        setupBloodValues(aliveMarmId, weightLimit - .01, bloodRows);
        verifyBloodPlotValues(participantViewPage, 6, true);

        // Test upper weight limit
        participantViewPage = ParticipantViewPage.beginAt(this, aliveMarmId);
        setupBloodValues(aliveMarmId, weightLimit, null);
        verifyBloodPlotValues(participantViewPage, 6, false);

        // Verify recent blood draw values
        Map<String, List<String>> recentBloodDraws = new HashMap<>();

        List<String> quantities = Arrays.asList("0.5", "1.0", "0.8");
        recentBloodDraws.put("quantity", quantities);

        List<String> dates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1))));
        recentBloodDraws.put("date", dates);

        List<String> dropDates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3 + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3) + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1) + refreshDays)));
        recentBloodDraws.put("dropDate", dropDates);

        verifyRecentBloodDraws(participantViewPage, recentBloodDraws);

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
        List<String> remarkColumn = participantViewPage.getActiveReportDataRegion().getColumnDataAsText("Procedure Text");
        assertEquals("Should be 4 events for " + deadAnimalId + ". Check SNPRC reference study dataset1067.tsv", Arrays.asList("necropsy +1days", "necropsy -0days", "necropsy -3days", "necropsy -4days"), remarkColumn);

        participantViewPage.clickReportTab("Procedures Before Disposition");
        remarkColumn = participantViewPage.getActiveReportDataRegion().getColumnDataAsText("Procedure Text");
        assertEquals("Report should show events less than 3 days before death", Arrays.asList("necropsy +1days", "necropsy -0days", "necropsy -3days"), remarkColumn);
    }

    @Test
    public void testAnimalHistoryReports()
    {
        clickAndWait(Locator.linkWithText("Animal History"));
        SNPRCAnimalHistoryPage animalHistoryPage = new SNPRCAnimalHistoryPage(getDriver());

        animalHistoryPage.searchSingleAnimal("TEST1441142");
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
        ColonyOverviewPage overviewPage = ColonyOverviewPage.beginAt(this, getProjectName());
        ColonyOverviewPage.BaboonColonyTab baboonColonyTab = overviewPage.clickBaboonColonyTab();
        String[] censusColumns = {"Investigator", "Protocol", "M", "F", "baboon1", "baboon2", "baboon3", "Total"};
        List<List<String>> rows = baboonColonyTab.getAssignedFundedDataRegion().getRows(censusColumns);
        List<List<String>> expectedRows = Arrays.asList(
                Arrays.asList("dummyinvestigator", "dummyprotocol", "2", "2", "3", "1", " ", "4"),
                Arrays.asList("investigator101", "protocol101", "4", "8", "2", "8", "2", "12"));
        assertEquals(expectedRows, rows);
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

    @Test
    public void testClinicalHistoryPanelOptions(){
        beginAtAnimalHistoryTab();
        openClinicalHistoryForAnimal("TEST1020148");

        List<String> expectedLabels = new ArrayList<String>(
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
                        "Blood Draws",
                        "Clinical",
                        "Hematology",
                        "Labwork",
                        "Notes",
                        "Pregnancy",
                        "Therapy",
                        "Vitals"
                        ));
        checkClinicalHistoryType(expectedLabels);
        click(findButton("Submit"));

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
        click(Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(4));
        click(Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(9));
        click(Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(11));
        click(findButton("Submit"));

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

        confirmQueryDrivenDateFormat(expectedDate, expectedTime);
    }

    private void confirmQueryDrivenDateFormat(String expectedDate, String expectedTime)
    {
        goToSchemaBrowser();
        selectQuery("study", "blood");
        waitAndClick(Locator.linkWithText("view data"));
        DataRegionTable table = new DataRegionTable("Dataset", this);
        table.setFilter("Id", "Equals","TEST1020148");
        table.setFilter("quantity", "Equals","3.0");
        String date = table.getDataAsText(0,1);
        Assert.assertEquals("Expected Date", expectedDate + " " + expectedTime, date);
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

        setFormElement(new Locator.NameLocator("defaultDateFormat"), dateFormat);
        setFormElement(new Locator.NameLocator("defaultDateTimeFormat"), dateTimeFormat);
        clickAndWait(Locator.lkButton("Save"));
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }
}
