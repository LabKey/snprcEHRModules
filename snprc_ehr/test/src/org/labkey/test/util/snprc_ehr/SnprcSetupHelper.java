package org.labkey.test.util.snprc_ehr;

import org.labkey.remoteapi.CommandException;
import org.labkey.remoteapi.query.InsertRowsCommand;
import org.labkey.remoteapi.query.SelectRowsCommand;
import org.labkey.remoteapi.query.SelectRowsResponse;
import org.labkey.test.BaseWebDriverTest;
import org.labkey.test.TestFileUtils;
import org.labkey.test.WebTestHelper;
import org.labkey.test.util.APIAssayHelper;
import org.labkey.test.util.Maps;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public final class SnprcSetupHelper
{
    public static final List<String> SND_CATEGORIES = Arrays.asList(
            "Alopecia",
            "BCS",
            "Cumulative Blood",
            "Vitals Temperature",
            "TB",
            "Vitals",
            "Weight");

    public static final int SND_PKG_ID_START = 901;
    public static final int SND_SUPER_PKG_ID_START = 1900;

    public static final String CORE_FACILITIES_FOLDER = "Core Facilities";
    public static final String GENETICS_SUBFOLDER = "Genetics";

    private SnprcSetupHelper() { }

    public static String geneticsContainerPath(String projectName)
    {
        return projectName + "/" + CORE_FACILITIES_FOLDER + "/" + GENETICS_SUBFOLDER;
    }

    // Creates Project/Core Facilities (Collaboration) and Project/Core Facilities/Genetics
    // (Laboratory Folder with SNPRC_Genetics enabled). Idempotent-ish: relies on containerHelper
    // to no-op on already-existing folders. The genetics folder is the target for the assay
    // designs uploaded by uploadGeneticsAssayDesigns.
    public static void createGeneticsSubfolder(BaseWebDriverTest test, String projectName)
    {
        test._containerHelper.createSubfolder(projectName, projectName, CORE_FACILITIES_FOLDER, "Collaboration", null);
        test._containerHelper.createSubfolder(projectName, CORE_FACILITIES_FOLDER, GENETICS_SUBFOLDER, "Laboratory Folder", new String[]{"SNPRC_Genetics"});
        // createSubfolder navigates into the new folder via the UI wizard; restore project-home
        // context so callers that use getContainerPath() (permission APIs, module properties, etc.)
        // target the project rather than the just-created subfolder.
        test.goToProjectHome();
    }

    // Uploads the four assay XAR files that back the study.GenHas* module-defined queries
    // (see snprc_ehr/resources/queries/study/GenHas{SNP,GeneExpression,Microsatellites,Phenotype}.sql).
    // Without these assay designs in <project>/Core Facilities/Genetics, those queries fail
    // validation with "Query or table not found: Project.Core Facilities/Genetics.assay.general.*.data".
    // Pipeline counts start at 1 because the genetics folder has no prior pipeline history.
    public static void uploadGeneticsAssayDesigns(BaseWebDriverTest test, String projectName)
    {
        APIAssayHelper assayHelper = new APIAssayHelper(test);
        test.clickFolder(GENETICS_SUBFOLDER);
        assayHelper.uploadXarFileAsAssayDesign(TestFileUtils.getSampleData("snprc/assays/Gene Expression.xar"), 1);
        assayHelper.uploadXarFileAsAssayDesign(TestFileUtils.getSampleData("snprc/assays/Microsatellites.xar"), 2);
        assayHelper.uploadXarFileAsAssayDesign(TestFileUtils.getSampleData("snprc/assays/Phenotypes.xar"), 3);
        assayHelper.uploadXarFileAsAssayDesign(TestFileUtils.getSampleData("snprc/assays/SNPs.xar"), 4);
        // Restore project-home navigation so callers (setPipelineRoot, folder import, etc.) run
        // in the project container rather than the genetics subfolder we just walked into.
        test.goToProjectHome();
    }

    public static void initSND(BaseWebDriverTest test, String projectName)
    {
        createDomain(test, projectName, "snd", "SND", "SND custom columns");
    }

    // Provisions ehr.* extensible columns declared in snprc_ehr's domain-templates/ehr.template.xml.
    // Equivalent to clicking "Generate EHR extensible columns" on the SNPRC ehrAdmin UI
    // (EhrColumnsPanel.js:40-49). Must run before any dataset import that expects those columns.
    public static void addEhrExtensibleColumns(BaseWebDriverTest test, String projectName)
    {
        createDomain(test, projectName, "ehr", "EHR", "EHR extensible columns");
    }

    // Seeds snprc_ehr.animal_group_categories + snprc_ehr.animal_groups from
    // snprc_ehr/test/sampledata/snprc/*.tsv. Required before importStudy() because
    // saved queries like study.baboonBreedingColonyUsageQuery pivot over
    // snprc_ehr.BaboonColonyGroups (SELECT ... FROM snprc_ehr.animal_groups JOIN
    // snprc_ehr.animal_group_categories WHERE description LIKE '%baboon colonies%').
    // With no rows, the pivot expands to zero dynamic columns and every reference to
    // col."pc_SPF::colonytotal" / col."pc_Conv::colonytotal" fails query validation.
    public static void populateAnimalGroupTables(BaseWebDriverTest test, String projectName) throws IOException, CommandException
    {
        insertFromTsv(test, projectName, "snprc_ehr", "animal_group_categories",
                TestFileUtils.getSampleData("snprc/animal_group_categories.tsv"));
        insertFromTsv(test, projectName, "snprc_ehr", "animal_groups",
                TestFileUtils.getSampleData("snprc/animal_groups.tsv"));
    }

    private static void insertFromTsv(BaseWebDriverTest test, String projectName, String schema, String query, File tsv) throws IOException, CommandException
    {
        InsertRowsCommand command = new InsertRowsCommand(schema, query);
        command.setRows(test.loadTsv(tsv));
        command.execute(test.createDefaultConnection(), projectName);
    }

    private static void createDomain(BaseWebDriverTest test, String projectName, String domainGroup, String domainKind, String description)
    {
        // Navigate into the container so LABKEY.Domain.create runs with the right container context.
        test.beginAt(WebTestHelper.buildURL("project", projectName, "begin"));
        String result = (String) test.executeAsyncScript(
                "LABKEY.Domain.create({\n" +
                "    domainGroup: '" + domainGroup + "',\n" +
                "    domainKind: '" + domainKind + "',\n" +
                "    module: 'snprc_ehr',\n" +
                "    importData: false,\n" +
                "    success: function () { callback('Success!'); },\n" +
                "    failure: function (e) { callback(e && (e.exception || e.responseText) || 'Failed'); }\n" +
                "});");
        assertEquals("LABKEY.Domain.create for " + description + " did not succeed", "Success!", result);
    }

    public static void createSNDCategories(BaseWebDriverTest test, String projectName) throws CommandException, IOException
    {
        SelectRowsCommand selectCommand = new SelectRowsCommand("snd", "PkgCategories");
        selectCommand.setColumns(List.of("Description"));
        SelectRowsResponse response = selectCommand.execute(test.createDefaultConnection(), projectName);

        List<String> existingCategories = new ArrayList<>();
        for (Map<String, Object> row : response.getRows())
        {
            Object description = row.get("Description");
            if (description != null)
                existingCategories.add(String.valueOf(description));
        }

        InsertRowsCommand insertCommand = new InsertRowsCommand("snd", "PkgCategories");
        boolean hasNewCategories = false;
        for (String category : SND_CATEGORIES)
        {
            if (existingCategories.contains(category))
                continue;

            insertCommand.addRow(new HashMap<>(Maps.of(
                    "Description", category,
                    "Active", true
            )));
            hasNewCategories = true;
        }

        if (hasNewCategories)
            insertCommand.execute(test.createDefaultConnection(), projectName);
    }

    public static void createSNDPackages(BaseWebDriverTest test, String projectName) throws IOException, CommandException
    {
        test.goToProjectHome();

        Map<String, Integer> categoryIds = getSndCategoryIds(test, projectName);
        saveSndPackage(test, SND_PKG_ID_START, SND_SUPER_PKG_ID_START, "Alopecia", categoryIds.get("Alopecia"),
                "Alopecia score: {alopeciaScore}",
                Arrays.asList(
                        sndAttribute("alopeciaScore", "Alopecia Score", "string", false),
                        sndAttribute("scorer", "Scorer", "string", false)));
        saveSndPackage(test, SND_PKG_ID_START + 1, SND_SUPER_PKG_ID_START + 10, "BCS", categoryIds.get("BCS"),
                "BCS: {bcs}",
                List.of(sndAttribute("bcs", "BCS", "int", false)));
        saveSndPackage(test, SND_PKG_ID_START + 2, SND_SUPER_PKG_ID_START + 20, "Cumulative Blood", categoryIds.get("Cumulative Blood"),
                "Blood volume: {BLOOD_Volume}",
                Arrays.asList(
                        sndAttribute("reason", "Reason", "string", false),
                        sndAttribute("BLOOD_Volume", "Blood Volume", "double", false)));
        saveSndPackage(test, SND_PKG_ID_START + 3, SND_SUPER_PKG_ID_START + 30, "Vitals Temperature", categoryIds.get("Vitals Temperature"),
                "Temperature: {temp}",
                List.of(sndAttribute("temp", "Temperature", "double", false)));
        saveSndPackage(test, SND_PKG_ID_START + 4, SND_SUPER_PKG_ID_START + 40, "TB", categoryIds.get("TB"),
                "TB result: {tb_result}",
                Arrays.asList(
                        sndAttribute("tb_site", "TB Site", "string", false),
                        sndAttribute("tb_result", "TB Result", "string", false)));
        saveSndPackage(test, SND_PKG_ID_START + 5, SND_SUPER_PKG_ID_START + 50, "Vitals", categoryIds.get("Vitals"),
                "Vitals: {HR}/{RR}/{temp}",
                Arrays.asList(
                        sndAttribute("HR", "Heart Rate", "double", false),
                        sndAttribute("RR", "Respiratory Rate", "double", false),
                        sndAttribute("temp", "Temperature", "double", false)));
        saveSndPackage(test, SND_PKG_ID_START + 6, SND_SUPER_PKG_ID_START + 60, "Weight", categoryIds.get("Weight"),
                "Weight: {weight} kg",
                List.of(sndAttribute("weight", "Weight", "double", false)));
    }

    private static Map<String, Integer> getSndCategoryIds(BaseWebDriverTest test, String projectName) throws IOException, CommandException
    {
        SelectRowsCommand command = new SelectRowsCommand("snd", "PkgCategories");
        command.setColumns(Arrays.asList("Description", "CategoryId"));
        SelectRowsResponse response = command.execute(test.createDefaultConnection(), projectName);

        Map<String, Integer> categoryIds = new HashMap<>();
        for (Map<String, Object> row : response.getRows())
        {
            Object description = row.get("Description");
            Object categoryId = row.get("CategoryId");
            if (description != null && categoryId != null)
            {
                categoryIds.put(String.valueOf(description), ((Number) categoryId).intValue());
            }
        }

        for (String category : SND_CATEGORIES)
        {
            assertTrue("Missing SND category ID for " + category, categoryIds.containsKey(category));
        }

        return categoryIds;
    }

    private static Map<String, Object> sndAttribute(String name, String label, String rangeUri, boolean required)
    {
        return new HashMap<>(Maps.of(
                "name", name,
                "label", label,
                "rangeURI", rangeUri,
                "required", required
        ));
    }

    private static void saveSndPackage(BaseWebDriverTest test, int pkgId, int superPkgIdStart, String description, int categoryId, String narrative, List<Map<String, Object>> attributes)
    {
        String result = (String) test.executeAsyncScript(buildSaveSndPackageScript(pkgId, superPkgIdStart, description, categoryId, narrative, attributes));
        assertEquals("JavaScript API failure while saving SND package " + description, "Success!", result);
    }

    private static String buildSaveSndPackageScript(int pkgId, int superPkgIdStart, String description, int categoryId, String narrative, List<Map<String, Object>> attributes)
    {
        return "LABKEY.Ajax.request({\n" +
                "    method: 'POST',\n" +
                "    url: LABKEY.ActionURL.buildURL('snd', 'savePackage.api'),\n" +
                "    success: function(){ callback('Success!'); },\n" +
                "    failure: function(e){ callback(e.exception || e.responseText || 'Failed'); },\n" +
                "    jsonData: {\n" +
                "        'id': " + pkgId + ",\n" +
                "        'testIdNumberStart': " + superPkgIdStart + ",\n" +
                "        'description': '" + jsEscape(description) + "',\n" +
                "        'active': true,\n" +
                "        'repeatable': true,\n" +
                "        'narrative': '" + jsEscape(narrative) + "',\n" +
                "        'categories': [" + categoryId + "],\n" +
                "        'subPackages': [],\n" +
                "        'extraFields': [],\n" +
                "        'attributes': " + attributesToJson(attributes) + "\n" +
                "    }\n" +
                "});";
    }

    private static String attributesToJson(List<Map<String, Object>> attributes)
    {
        List<String> values = new ArrayList<>();
        for (Map<String, Object> attribute : attributes)
        {
            values.add("{" +
                    "'name': '" + jsEscape(String.valueOf(attribute.get("name"))) + "', " +
                    "'label': '" + jsEscape(String.valueOf(attribute.get("label"))) + "', " +
                    "'rangeURI': '" + jsEscape(String.valueOf(attribute.get("rangeURI"))) + "', " +
                    "'required': " + attribute.get("required") +
                    "}");
        }

        return "[" + String.join(", ", values) + "]";
    }

    private static String jsEscape(String value)
    {
        return value.replace("\\", "\\\\").replace("'", "\\'");
    }
}
