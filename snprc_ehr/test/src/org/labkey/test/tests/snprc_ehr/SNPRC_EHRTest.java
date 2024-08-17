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

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.json.simple.JSONObject;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.CommandResponse;
import org.labkey.remoteapi.Connection;
import org.labkey.remoteapi.PostCommand;
import org.labkey.remoteapi.query.Filter;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SaveRowsResponse;
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
import org.labkey.test.util.LoggedParam;
import org.labkey.test.util.Maps;
import org.labkey.test.util.PortalHelper;
import org.labkey.test.util.RReportHelper;
import org.labkey.test.util.SqlserverOnlyTest;
import org.labkey.test.util.TextSearcher;
import org.labkey.test.util.ehr.EHRClientAPIHelper;
import org.labkey.test.util.ext4cmp.Ext4FieldRef;
import org.labkey.test.util.external.labModules.LabModuleHelper;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
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
    private static final String ANIMAL_HISTORY_URL = "/" + PROJECT_NAME + "/ehr-animalHistory.view";
    private static final String SNPRC_ROOM_ID = "S824778";
    private static final String SNPRC_ROOM_ID2 = "S043365";

    // SND data files
    private static final String SND_PKGS_IMPORT_FILE_NAME = "testPkgs.snd.xml";
    private static final File SND_PKGS_IMPORT_FILE = TestFileUtils.getSampleData("snd/pkgs/" + SND_PKGS_IMPORT_FILE_NAME);
    private static final String SND_DATA_DIR = "snd/data/";

    private static final int SND_VITALS_SPKG_ID = 1;
    private static final int SND_WEIGHT_SPKG_ID = 2;
    private static final int SND_BLOOD_SPKG_ID = 3;
    private static final int SND_ALOPECIA_SPKG_ID = 4;

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

        // SND data
        _containerHelper.enableModules(Arrays.asList("SND"));
        initSND();
        initSNDData();

        createTestSubjects();
        initGenetics();
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
    public String getModulePath()
    {
        return "/server/modules/" + getModuleDirectory();
    }

    @Override
    protected void importStudy()
    {
        importFolderFromPath(++_pipelineJobCount);
    }

    private void initSNDData() throws IOException, CommandException, ParseException
    {
        populateSNDLookups();
        importSNDPkgs();

        // Assume this creates project 1001, the first project id
        createSNDProject("Test project", true, 640991, new Date(), List.of(1, 2, 3, 4));

        createAndAssignCategory("Vitals", true, 1);
        createAndAssignCategory("Weight", true, 2);
        createAndAssignCategory("Cumulative blood", true, 3);
        createAndAssignCategory("alopecia", true, 4);

        setSNDPermissions();
        importSNDData();
    }

    private void importSNDPkgs()
    {
        clickProject(PROJECT_NAME);

        //go to Pipeline module
        goToModule("Pipeline");

        clickButton("Process and Import Data", defaultWaitForPage);

        boolean replace = false;
        if (_fileBrowserHelper.fileIsPresent(SND_PKGS_IMPORT_FILE.getName()))
            replace = true;

        // Note change the last param to true to run locally
        _fileBrowserHelper.uploadFile(SND_PKGS_IMPORT_FILE, null, null, replace);
        _fileBrowserHelper.checkFileBrowserFileCheckbox(SND_PKGS_IMPORT_FILE_NAME);
        _fileBrowserHelper.selectImportDataAction("SND document import");
        waitForPipelineJobsToComplete(++_pipelineJobCount, "SND Import (" + SND_PKGS_IMPORT_FILE_NAME + ")", false, 30000);
    }

    private void importSNDData() throws ParseException, CommandException, IOException
    {
        log("Import SND data");
        clickProject(PROJECT_NAME);

        importSNDTsv(SND_DATA_DIR + "vitals.tsv", SND_VITALS_SPKG_ID);
        importSNDTsv(SND_DATA_DIR + "blood.tsv", SND_BLOOD_SPKG_ID);
        importSNDTsv(SND_DATA_DIR + "weights.tsv", SND_WEIGHT_SPKG_ID);

    }

    private void importSNDTsv(String path, int superPkgId) throws ParseException, IOException, CommandException
    {
        List<Map<String, Object>> data = loadTsv(TestFileUtils.getSampleData(path));
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        for (Map<String, Object> row : data)
        {
            List<Map<String, Object>> attributes = new ArrayList<>();
            for (String s : row.keySet())
            {
                if (!s.equals("id") && !s.equals("date"))
                {
                    Object value = row.get(s);
                    if (value != null)
                    {
                        if (value instanceof String && NumberUtils.isParsable((String) value))
                        {
                            value = Double.parseDouble((String) value);
                        }
                        attributes.add(Map.of("propertyName", s, "value", value));
                    }
                }
            }

            insertSNDData((String)row.get("id"), sdf.parse((String)row.get("date")), superPkgId, attributes);
        }
    }

    private void createSNDProject(String description, boolean active, int refId, Date start, List<Integer> projItemList) throws IOException, CommandException
    {
        clickProject(PROJECT_NAME);

        Connection remoteApiConnection = WebTestHelper.getRemoteApiConnection();
        PostCommand<CommandResponse> command = new PostCommand<>("snd", "saveProject");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        JSONObject project = new JSONObject();
        project.put("description", description);
        project.put("active", active);
        project.put("referenceId", refId);
        project.put("startDate", sdf.format(start));

        JSONArray projectItems = new JSONArray();
        for (Integer item : projItemList)
        {
            JSONObject projItem = new JSONObject();
            projItem.put("active", true);
            projItem.put("superPkgId", item);

            projectItems.put(projItem);
        }

        project.put("projectItems", projectItems);

        command.setJsonObject(project);

        command.execute(remoteApiConnection, PROJECT_NAME);
    }

    private void createAndAssignCategory(String name, boolean active, int pkgId) throws IOException, CommandException
    {
        InsertRowsCommand command = new InsertRowsCommand("snd", "PkgCategories");

        Map<String,Object> rowMap = new HashMap<>();
        rowMap.put("Description", name);
        rowMap.put("Active", active);
        command.addRow(rowMap);

        Connection remoteApiConnection = WebTestHelper.getRemoteApiConnection();
        CommandResponse r = command.execute(remoteApiConnection, PROJECT_NAME);

        command = new InsertRowsCommand("snd", "PkgCategoryJunction");

        rowMap = new HashMap<>();
        rowMap.put("PkgId", pkgId);
        rowMap.put("CategoryId", ((SaveRowsResponse) r).getRows().get(0).get("categoryId"));
        command.addRow(rowMap);

        command.execute(remoteApiConnection, PROJECT_NAME);
    }

    private void clickRoleInOpenDropDown(String name)
    {
        List<WebElement> els = Locator.tagWithClassContaining("div", "btn-group open").child("ul").child("li").child("a").withText(name).findElements(getDriver());
        if (els.size() > 0)
        {
            els.get(0).click();
        }
    }

    private void setSNDPermissions()
    {
        log("Set SND permissions");
        beginAt(WebTestHelper.buildURL("snd",getProjectName(), "admin"));

        assertElementPresent(Locator.linkWithText("SND Security"));
        click(Locator.linkWithText("SND Security"));

        click(Locator.id("a_all_-2"));
        clickRoleInOpenDropDown("SND Data Admin");

        waitAndClickAndWait(Locator.linkContainingText("Save"));
    }

    private void insertSNDData(String id, Date date, int superPkgId, List<Map<String, Object>> attributes) throws IOException, CommandException
    {

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss");

        Connection remoteApiConnection = WebTestHelper.getRemoteApiConnection();
        PostCommand<CommandResponse> command = new PostCommand<>("snd", "saveEvent");

        JSONArray attributesArray = new JSONArray();
        for (Map<String, Object> attribute : attributes)
        {
            JSONObject attObj = new JSONObject();
            for (String prop : attribute.keySet())
            {
                attObj.put(prop, attribute.get(prop));
            }
            attributesArray.put(attObj);
        }

        JSONObject eventData = new JSONObject();
        eventData.put("superPkgId", superPkgId);
        eventData.put("attributes", attributesArray);

        JSONArray eventDataArray = new JSONArray();
        eventDataArray.put(eventData);

        JSONObject event = new JSONObject();
        event.put("subjectId", id);
        event.put("date", sdf.format(date));
        event.put("qcState", "Completed");
        event.put("projectIdRev", "1001|0");
        event.put("eventData", eventDataArray);

        command.setJsonObject(event);

        CommandResponse r = command.execute(remoteApiConnection, PROJECT_NAME);
        if (r != null && r.getText() != null && r.getText().contains("\"success\" : false"))
        {
            throw new RuntimeException(r.getText());
        }
    }

    private void populateSNDLookups()
    {
        log("Populate SND lookups");
        Connection connection = createDefaultConnection(true);
        CommandResponse resp;

        InsertRowsCommand command = new InsertRowsCommand("snd", "LookupSets");
        List<Map<String, Object>> lookupSetRows = Arrays.asList(
                new HashMap<String, Object>(Maps.of("SetName", "BCS",
                        "Label", "BCS",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7ae",
                        "Description", "Body Condition Scores")));

        command.setRows(lookupSetRows);

        try
        {
            resp = command.execute(connection, getProjectName());
        }
        catch (IOException | CommandException e)
        {
            throw new RuntimeException(e);
        }

        List<Map<String, Object>> data = (List<Map<String, Object>>)resp.getParsedData().get("rows");
        List<Map<String, Object>> lookupRows = Arrays.asList(
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "2.5 - Lean",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a1",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "1.5 - Very Thin",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a2",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "3.5 - Slightly Overweight",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a3",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "3 - Optimum",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a4",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "4 - Heavy",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a5",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "5 - Grossly Obese",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a6",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "1 - Emaciated",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a7",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "4.5 - Obese",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a8",
                        "Displayable", "true")),
                new HashMap<>(Maps.of("LookupSetId", data.get(0).get("lookupSetId"),
                        "Value", "2 - Thin",
                        "ObjectId", "dbe561b9-b7ba-102d-8c2a-9926f351b7a9",
                        "Displayable", "true"))
                );

        command = new InsertRowsCommand("snd", "Lookups");
        command.setRows(lookupRows);

        try
        {
            command.execute(connection, getProjectName());
        }
        catch (IOException | CommandException e)
        {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void createTestSubjects() throws Exception
    {
        String[] fields;
        Object[][] data;
        PostCommand insertCommand;

        //insert into demographics
        log("Creating test subjects");
        fields = new String[]{"Id", "Species", "Birth", "Gender", "date", "calculated_status", "objectid", FIELD_QCSTATELABEL};
        data = new Object[][]{
                {SUBJECTS[0], "Rhesus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {SUBJECTS[1], "Cynomolgus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {SUBJECTS[2], "Marmoset", (new Date()).toString(), getFemale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {SUBJECTS[3], "Cynomolgus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {SUBJECTS[4], "Cynomolgus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"}
        };
        insertCommand = getApiHelper().prepareInsertCommand("study", "demographics", "lsid", fields, data);
        getApiHelper().deleteAllRecords("study", "demographics", new Filter("Id", StringUtils.join(SUBJECTS, ";"), Filter.Operator.IN));
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), insertCommand, getExtraContext());

        //for simplicity, also create the animals from MORE_ANIMAL_IDS right now
        data = new Object[][]{
                {MORE_ANIMAL_IDS[0], "Rhesus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {MORE_ANIMAL_IDS[1], "Cynomolgus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {MORE_ANIMAL_IDS[2], "Marmoset", (new Date()).toString(), getFemale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {MORE_ANIMAL_IDS[3], "Cynomolgus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"},
                {MORE_ANIMAL_IDS[4], "Cynomolgus", (new Date()).toString(), getMale(), new Date(), "Alive", UUID.randomUUID().toString(), "Completed"}
        };
        insertCommand = getApiHelper().prepareInsertCommand("study", "demographics", "lsid", fields, data);
        getApiHelper().deleteAllRecords("study", "demographics", new Filter("Id", StringUtils.join(MORE_ANIMAL_IDS, ";"), Filter.Operator.IN));
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), insertCommand, getExtraContext());

        //used as initial dates
        Date pastDate1 = TIME_FORMAT.parse("2012-01-03 09:30");
        Date pastDate2 = TIME_FORMAT.parse("2012-05-03 19:20");

        //set housing
        log("Creating initial housing records");
        fields = new String[]{"Id", "date", "enddate", "room", "cage", FIELD_QCSTATELABEL};
        data = new Object[][]{
                {SUBJECTS[0], pastDate1, pastDate2, getRooms()[0], CAGES[0], "Completed"},
                {SUBJECTS[0], pastDate2, null, getRooms()[0], CAGES[0], "Completed"},
                {SUBJECTS[1], pastDate1, pastDate2, getRooms()[0], CAGES[0], "Completed"},
                {SUBJECTS[1], pastDate2, null, getRooms()[2], CAGES[2], "Completed"}
        };
        insertCommand = getApiHelper().prepareInsertCommand("study", "Housing", "lsid", fields, data);
        getApiHelper().deleteAllRecords("study", "Housing", new Filter("Id", StringUtils.join(SUBJECTS, ";"), Filter.Operator.IN));
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), insertCommand, getExtraContext());

        //set a base weight
        log("Setting initial weights");
        insertSNDData(SUBJECTS[0], pastDate2, SND_WEIGHT_SPKG_ID, List.of(Map.of("propertyName", "weight", "value", 10.5)));
        insertSNDData(SUBJECTS[0], pastDate2, SND_WEIGHT_SPKG_ID, List.of(Map.of("propertyName", "weight", "value", 12)));
        insertSNDData(SUBJECTS[1], pastDate2, SND_WEIGHT_SPKG_ID, List.of(Map.of("propertyName", "weight", "value", 12)));
        insertSNDData(SUBJECTS[2], pastDate2, SND_WEIGHT_SPKG_ID, List.of(Map.of("propertyName", "weight", "value", 12)));

        //set assignment
        log("Setting initial assignments");
        fields = new String[]{"Id", "date", "enddate", "project"};
        data = new Object[][]{
                {SUBJECTS[0], pastDate1, pastDate2, PROJECTS[0]},
                {SUBJECTS[1], pastDate1, pastDate2, PROJECTS[0]},
                {SUBJECTS[1], pastDate2, null, PROJECTS[2]}
        };
        insertCommand = getApiHelper().prepareInsertCommand("study", "Assignment", "lsid", fields, data);
        getApiHelper().deleteAllRecords("study", "Assignment", new Filter("Id", StringUtils.join(SUBJECTS, ";"), Filter.Operator.IN));
        getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), insertCommand, getExtraContext());
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

    private void setupBloodValues(String id, Double weight, List<Map<String, Object>> bloodRows) throws IOException, CommandException
    {
        insertSNDData(id, new Date(), SND_WEIGHT_SPKG_ID, List.of(Map.of("propertyName", "weight", "value", weight)));

        if (bloodRows != null)
        {
            for (Map<String, Object> bloodRow : bloodRows)
            {
                insertSNDData((String) bloodRow.get("Id"), (Date) bloodRow.get("date"), SND_BLOOD_SPKG_ID, List.of(
                        Map.of("propertyName", "blood_volume", "value", bloodRow.get("quantity")),
                        Map.of("propertyName", "reason", "value", bloodRow.get("reason"))
                ));
            }
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

    private void verifyRecentBloodDraws(ParticipantViewPage<?> page, Map<String, List<String>> values)
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

        String reason = "blood draw";

        List<Map<String, Object>> bloodRows = Arrays.asList(
                Maps.of("Id", aliveRhesusId,
                        "date", DateUtils.addDays(new Date(), -(2 * refreshDays - 1)),
                        "quantity", weight,
                        "reason", reason),
                Maps.of("Id", aliveRhesusId,
                        "date", DateUtils.addDays(new Date(), -(refreshDays -3)),
                        "quantity", (weight + 0.5) * maxDraw,
                        "reason", reason),
                Maps.of("Id", aliveRhesusId,
                        "date", DateUtils.addDays(new Date(), -3),
                        "quantity", weight,
                        "reason", reason),
                Maps.of("Id", aliveRhesusId,
                        "date", DateUtils.addDays(new Date(), -4),
                        "quantity", 2,
                        "reason", reason)
        );

        // Verify plot
        setupBloodValues(aliveRhesusId, 5.0, bloodRows);
        verifyBloodPlotValues(participantViewPage, 8, true); // 3 blood draws, 4 refreshes and today marker

        // Verify Recent blood draw values
        Map<String, List<String>> recentBloodDraws = new HashMap<>();

        List<String> quantities = Arrays.asList("5.0", "2.0", "55.0", "5.0");
        recentBloodDraws.put("quantity", quantities);

        List<String> dates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -4)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1)))

        );
        recentBloodDraws.put("date", dates);

        List<String> dropDates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3 + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -4 + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3) + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1) + refreshDays))
        );

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
                        "date", DateUtils.addDays(new Date(), -(2 * refreshDays - 1)),
                        "quantity", .8,
                        "reason", "blood draw"),
                Maps.of("Id", aliveMarmId,
                        "date", DateUtils.addDays(new Date(), -(refreshDays -3)),
                        "quantity", 1.0,
                        "reason", "blood draw"),
                Maps.of("Id", aliveMarmId,
                        "date", DateUtils.addDays(new Date(), -3),
                        "quantity", .5,
                        "reason", "blood draw"),
                Maps.of("Id", aliveMarmId,
                        "date", DateUtils.addDays(new Date(), -4),
                        "quantity", .2,
                        "reason", "blood draw")
        );

        // Test lower weight limit
        setupBloodValues(aliveMarmId, weightLimit - .01, bloodRows);
        verifyBloodPlotValues(participantViewPage, 8, true); // 4 refreshes, 3 draws and today

        // Test upper weight limit
        participantViewPage = ParticipantViewPage.beginAt(this, aliveMarmId);
        setupBloodValues(aliveMarmId, weightLimit, null);
        verifyBloodPlotValues(participantViewPage, 8, false);

        // Verify recent blood draw values
        Map<String, List<String>> recentBloodDraws = new HashMap<>();

        List<String> quantities = Arrays.asList("0.5", "0.2", "1.0", "0.8");
        recentBloodDraws.put("quantity", quantities);

        List<String> dates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -4)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3))),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1))));
        recentBloodDraws.put("date", dates);

        List<String> dropDates = Arrays.asList(
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -3 + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -4 + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(refreshDays -3) + refreshDays)),
                DATE_FORMAT.format(DateUtils.addDays(new Date(), -(2 * refreshDays - 1) + refreshDays)));
        recentBloodDraws.put("dropDate", dropDates);

        verifyRecentBloodDraws(participantViewPage, recentBloodDraws);

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
        animalHistoryPage.searchSingleAnimal("Test1441142", "No active housing");
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
        assertEquals("Wrong controller for 'Browse Data'", "snprc_ehr", actionId.getController());
        assertEquals("Wrong action for 'Browse Data'", "animalHistory", actionId.getAction());

        actionId = new Crawler.ControllerActionId(enterData.getAttribute("href"));
        assertEquals("Wrong controller for 'Enter Data'", "ehr", actionId.getController());
        assertEquals("Wrong action for 'Enter Data'", "enterData", actionId.getAction());

        actionId = new Crawler.ControllerActionId(colonyOverview.getAttribute("href"));
        assertEquals("Wrong controller for 'Colony Overview'", "ehr", actionId.getController());
        assertEquals("Wrong action for 'Colony Overview'", "colonyOverview", actionId.getAction());
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

        goToAnimalHistory();
        SNPRCAnimalHistoryPage historyPage = new SNPRCAnimalHistoryPage(getDriver());
        historyPage.appendMultipleAnimals(animal1, animal2);
        historyPage.clickCategoryTab("Genetics");
        historyPage.clickReportTab("Kinship");

        DataRegionTable tbl = historyPage.getActiveReportDataRegion();
        assertEquals(tbl.getDataRowCount(), 20);

        _ext4Helper.checkCheckbox(Locator.ehrCheckboxIdContaining("limitRawDataToSelection"));

        tbl = historyPage.getActiveReportDataRegion();
        assertEquals(tbl.getDataRowCount(), 2);

        String[] idCols = {"Id", "Id2", "Coefficient"};
        List<List<String>> rows = tbl.getRows(idCols);
        List<List<String>> expectedRows = Arrays.asList(
                Arrays.asList(animal1, animal2, "0.375"), Arrays.asList(animal2, animal1, "0.375"));
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
        clickButtonContainingText("Reload", "Labwork");

        List<String> expectedLabels = new ArrayList<>(
                Arrays.asList(
                        "Accounts",
                        "Assignments",
                        "Diet",
                        "Housing Transfers",
                        "Offspring",
                        "TB",
                        "Weights",
                        "Arrival/Departure",
                        "Blood Draws",
                        "Clinical",
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
                        "Charge Id: 640991",
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

        // Deselect weight, blood and housing - checkbox count starts at 0, count down the first column and then down the next
        waitAndClick(Locator.linkWithText("Show/Hide Types"));
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(3).click(); // Housing
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(7).click(); // weight
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(9).click(); // blood
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

        // ensure deselecting labwork from show/hide types removes labwork panels from clinical history
        // Deselect labwork
        waitAndClick(Locator.linkWithText("Show/Hide Types"));
        Locator.css("input[id^=checkboxfield]").findElements(getDriver()).get(11).click(); // labwork
        findButton("Submit").click();

        animalHistoryPage = new SNPRCAnimalHistoryPage(getDriver());
        activeReport = animalHistoryPage.getActiveReportPanel();

        assertTextNotPresent(new TextSearcher(activeReport::getText), "Service/Panel: X VIRUS", "Service/Panel: FULL PANEL CULTURE", "Service/Panel: URINE CHEM");

        entries = new ArrayList<>(
                Arrays.asList(
                        "TEST1020148 (2016-03-28)",
                        "TEST1020148 (2016-03-07)",
                        "Protocol: protocol101",
                        "Status: Holding"
                )
        );

        assertTextPresent(entries);
    }

    @Test
    public void testDateFormat(){

        String dateFormat = "yy-M-d";
        String dateTimeFormat = "yy-M-d H:mm";
        String expectedDate = "16-6-1";
        String expectedTime = "12:00";

        testDateFormat(dateFormat,dateTimeFormat, expectedDate, expectedTime);

        dateFormat = "yyyy-MM-dd";
        dateTimeFormat = dateFormat + " HH:mm";
        expectedDate = "2016-06-01";
        expectedTime = "12:00";

        testDateFormat(dateFormat,dateTimeFormat, expectedDate, expectedTime);

    }

    @Override
    @Test
    public void testWeightValidation()
    {
        // TODO: Add SND weight validation test
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
        selectQuery("study", "Blood");
        waitAndClick(Locator.linkWithText("view data"));
        DataRegionTable table = new DataRegionTable("query", this);
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

        setFormElement(Locator.name("defaultDateFormat"), dateFormat);
        setFormElement(Locator.name("defaultDateTimeFormat"), dateTimeFormat);
        clickAndWait(Locator.lkButton("Save"));
    }

    @Override
    protected String getAnimalHistoryPath()
    {
        return ANIMAL_HISTORY_URL;
    }

    @Test
    @Override
    public void testCustomButtons()
    {
        log("verifying custom buttons");

        //housing queries
        beginAt("/project/" + getContainerPath() + "/begin.view");
        goToSchemaBrowser();
        selectQuery("study", "Weight");
        waitForText("view data");
        clickAndWait(Locator.linkContainingText("view data"));

        DataRegionTable dr = new DataRegionTable("query", this);
        saveLocation();
        dr.checkCheckbox(0);
        dr.checkCheckbox(1);

        dr.clickHeaderMenu("More Actions", false, "Compare Weights");
        waitForText(5000, "Weight 1", "Weight 2", "Days Between", "% Change");
        waitAndClick(Ext4Helper.Locators.ext4Button("OK"));

        dr.clickHeaderMenu("More Actions", true, "Jump To History");
        assertTextPresent("Animal History");
        sleep(5000);
        recallLocation();
        List<String> submenuItems = dr.getHeaderMenuOptions("More Actions");
        List<String> expectedSubmenu = Arrays.asList("Jump To History", "Return Distinct Values","Show Record History", "Compare Weights");
        Assert.assertEquals("More actions menu did not contain expected options",expectedSubmenu, submenuItems);
    }

    @Override
    protected void testUserAgainstAllStates(@LoggedParam EHRUser user)
    {
        JSONObject extraContext = new JSONObject();
        extraContext.put("errorThreshold", "ERROR");
        extraContext.put("skipIdFormatCheck", true);
        extraContext.put("allowAnyId", true);
        CommandResponse response;

        //maintain list of insert/update times for interest
        _saveRowsTimes = new ArrayList<>();


        String[] fields = new String[]{"Id", "date", "enddate", "code", FIELD_QCSTATELABEL, FIELD_OBJECTID, FIELD_LSID, "_recordid"};
        Object[][] insertData = new Object[][]{
                {SUBJECTS[0], EHRClientAPIHelper.DATE_SUBSTITUTION, null, "S-00069", EHRQCState.IN_PROGRESS.label, null, null, "_recordID"}
        };

        //test insert
        insertData[0][Arrays.asList(fields).indexOf(FIELD_OBJECTID)] = null;
        insertData[0][Arrays.asList(fields).indexOf(FIELD_LSID)] = null;
        PostCommand insertCommand = getApiHelper().prepareInsertCommand("study", "diet", FIELD_LSID, fields, insertData);

        for (EHRQCState qc : EHRQCState.values())
        {
            extraContext.put("targetQC", qc.label);
            boolean successExpected = successExpected(user.getRole(), qc, "insert");
            log("Testing role: " + user.getRole().name() + " with insert of QCState: " + qc.label);
            if (successExpected)
                getApiHelper().doSaveRows(user.getEmail(), insertCommand, extraContext);
            else
                getApiHelper().doSaveRowsExpectingError(user.getEmail(), insertCommand, extraContext);
        }
        calculateAverage();

        //then update.  update is fun b/c we need to test many QCState combinations.  Updating a row from 1 QCstate to a new QCState technically
        //requires update Permission on the original QCState, plus insert Permission into the new QCState
        for (EHRQCState originalQc : EHRQCState.values())
        {
            // first create an initial row as a data admin
            UUID objectId = UUID.randomUUID();
            Object[][] originalData = insertData;
            originalData[0][Arrays.asList(fields).indexOf(FIELD_QCSTATELABEL)] = originalQc.label;
            extraContext.put("targetQC", originalQc.label);
            originalData[0][Arrays.asList(fields).indexOf(FIELD_OBJECTID)] = objectId.toString();
            PostCommand initialInsertCommand = getApiHelper().prepareInsertCommand("study", "diet", FIELD_LSID, fields, originalData);
            log("Inserting initial record for update test, with initial QCState of: " + originalQc.label);
            response = getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), initialInsertCommand, extraContext);

            String lsid = getLsidFromResponse(response);
            originalData[0][Arrays.asList(fields).indexOf(FIELD_LSID)] = lsid;

            //then try to update to all other QCStates
            for (EHRQCState qc : EHRQCState.values())
            {
                boolean successExpected = originalQc.equals(qc) ? successExpected(user.getRole(), originalQc, "update") : successExpected(user.getRole(), originalQc, "update") && successExpected(user.getRole(), qc, "insert");
                log("Testing role: " + user.getRole().name() + " with update from QCState " + originalQc.label + " to: " + qc.label);
                originalData[0][Arrays.asList(fields).indexOf(FIELD_QCSTATELABEL)] = qc.label;
                PostCommand updateCommand = getApiHelper().prepareUpdateCommand("study", "diet", FIELD_LSID, fields, originalData, null);
                extraContext.put("targetQC", qc.label);
                if (!successExpected)
                    getApiHelper().doSaveRowsExpectingError(user.getEmail(), updateCommand, extraContext);
                else
                {
                    getApiHelper().doSaveRows(user.getEmail(), updateCommand, extraContext);
                    log("Resetting QCState of record to: " + originalQc.label);
                    originalData[0][Arrays.asList(fields).indexOf(FIELD_QCSTATELABEL)] = originalQc.label;
                    extraContext.put("targetQC", originalQc.label);
                    updateCommand = getApiHelper().prepareUpdateCommand("study", "diet", FIELD_LSID, fields, originalData, null);
                    getApiHelper().doSaveRows(DATA_ADMIN.getEmail(), updateCommand, extraContext);
                }
            }
        }

        //log the average save time
        //TODO: eventually we should set a threshold and assert we dont exceed it
        calculateAverage();

        simpleSignIn(); //NOTE: this is designed to force the test to sign in, assuming our session was timed out from all the API tests
        resetErrors();  //note: inserting records without permission will log errors by design.  the UI should prevent this from happening, so we want to be aware if it does occur
    }
}
