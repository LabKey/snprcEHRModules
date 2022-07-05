/*
 * Copyright (c) 2015-2019 LabKey Corporation
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
package org.labkey.snprc_ehr.table;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.collections.CaseInsensitiveHashSet;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.ForeignKey;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.MutableColumnInfo;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WhitespacePreservingDisplayColumnFactory;
import org.labkey.api.data.WrappedColumn;

import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.exp.api.StorageProvisioner;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.ldk.LDKService;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.FilteredTable;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.UserSchema;
import org.labkey.api.study.DatasetTable;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import static org.labkey.snprc_ehr.query.QueryConstants.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

/**
 * Created by bimber on 1/23/2015.
 */
public class SNPRC_EHRCustomizer extends AbstractTableCustomizer
{
    private static final Logger _log = LogManager.getLogger(SNPRC_EHRCustomizer.class);

    private static CustomizerQueryProvider provider;

    public SNPRC_EHRCustomizer()
    {
        provider = new CustomizerQueryProvider();

    }

    @Override
    public void customize(TableInfo table)
    {
        if (table instanceof AbstractTableInfo)
        {
            doSharedCustomization((AbstractTableInfo) table);
            doTableSpecificCustomizations((AbstractTableInfo) table);
            doCalculatedCustomizations((AbstractTableInfo) table);
            //TODO: customizeColumns((AbstractTableInfo) table);
        }
    }

/*  //TODO: need to add investigator foreign key to multiple tables once the arc_valid_pi table has been ETL'd. tjh
    // Are we using investigatorId or investigatorName???

    private void customizeColumns(AbstractTableInfo ti)
    {

        // add foreign key for investigator id
        boolean found = false;
        for (String field : new String[]{"investigator", "investigatorId"})

        {
            if (found)

                continue; //a table should never contain both of these anyway

            ColumnInfo investigator = ti.getColumn(field);
            if (investigator != null)
            {
                found = true;
                investigator.setLabel("Investigator");

                if (!ti.getName().equalsIgnoreCase("investigators") && investigator.getJdbcType().getJavaClass().equals(Integer.class))
                {
                    UserSchema us = getEHRUserSchema(ti, "snprc_ehr");
                    if (us != null){
                        //here:   investigator.setFk(new QueryForeignKey(us, us.getContainer(), "package", "id", "name"));
                        //investigator.setFk(new QueryForeignKey(us, us.getContainer(), "investigators", "rowid", "lastname"));
                    }
                }
                investigator.setLabel("Investigator");
            }
        }



    }
*/

    /**
     * This should contain java code that will act upon any table in the EHR, which includes
     * core ehr and ehr_lookups schema, study datasets, etc.
     * <p>
     * This gives you the opportunity to apply standardized configuration across all tables that
     * use this customizer, which can be more efficient than editing each XML file.
     * <p>
     * It also gives the opportunity to make conditional changes, such as only adding a URL if the user has
     * specific permissions.
     * <p>
     * Finally, you can add calculated columns, such as SQL expressions.  This can be very useful, as the LK API typically
     * only lets you act on single columns.  An example could be a column created by concatenating 2 columns (ie. drug amount + units in a single col),
     * or coalescing a series of columns (preferentially displaying col 1, but showing col 2 if null)
     */
    public void doSharedCustomization(AbstractTableInfo ti)
    {
        if (ti.getColumn("code") != null)
        {
            var snomedCol = ti.getMutableColumn("code");
            ForeignKey fk = snomedCol.getFk();
            if (fk != null && fk.getLookupTableName().equalsIgnoreCase("snomed"))
            {
                snomedCol.setFk(fk);
            }
        }

        if (ti.getColumn("species") != null)
        {
            var species = ti.getMutableColumn("species");
            ForeignKey fk = species.getFk();
            if (fk != null && fk.getLookupTableName().equalsIgnoreCase("species") && fk.getLookupSchemaName().equalsIgnoreCase("ehr_lookups"))
            {
                UserSchema us = getEHRUserSchema(ti, SNPRC_EHRSchema.NAME);
                species.setFk(new QueryForeignKey(QueryForeignKey.from(us, ti.getContainerFilter())
                        .table("species")));
            }
        }

        if (ti.getColumn("project") != null)
        {
            ti.getMutableColumn("project").setLabel("Charge Id");
        }
    }


    public UserSchema getEHRUserSchema(AbstractTableInfo ds, String name)
    {
        Container ehrContainer = EHRService.get().getEHRStudyContainer(ds.getUserSchema().getContainer());
        if (ehrContainer == null)
            return null;

        return getUserSchema(ds, name, ehrContainer);
    }

    protected boolean hasTable(AbstractTableInfo tableInfo, String schemaName, String queryName, @Nullable Container targetContainer) {

        if (targetContainer == null)
            targetContainer = tableInfo.getUserSchema().getContainer();

        UserSchema userSchema = getUserSchema(tableInfo, schemaName, targetContainer);
        if (userSchema == null)
            return false;

        CaseInsensitiveHashSet schemaTableNames = new CaseInsensitiveHashSet(userSchema.getTableNames());

        return schemaTableNames.contains(queryName);
    }

    /**
     * Allows changes to be applied table-by-table
     */
    public void doTableSpecificCustomizations(AbstractTableInfo ti)
    {
        /*
            if (matches(ti, "study", "Lab Results"))
            {
                customizeLabResults(ti);
            }
         */
        if (matches(ti, "study", "Animal"))
        {
            customizeAnimalTable(ti);
        }
        if (matches(ti, "study", "Animal Events") || matches(ti, "study", "encounters"))
        {
            customizeEncounterTable(ti);
        }
        if (matches(ti, "study", "housing"))
        {
            customizeHousingTable((AbstractTableInfo) ti);
        }
//        if (matches(ti, "ehr", "project")) {
//            customizeProjectTable((AbstractTableInfo) ti);
//        }

        if (matches(ti, "ehr_lookups", "areas"))
        {
            LDKService.get().applyNaturalSort(ti, "area");
        }

        if (matches(ti, "ehr_lookups", "rooms"))
        {
            LDKService.get().applyNaturalSort(ti, "room");
        }
        if (matches(ti, "ehr_lookups", "DispositionType"))
        {
            LDKService.get().applyNaturalSort(ti, "value");
        }
        if (matches(ti, "ehr_lookups", "id_type"))
        {
            LDKService.get().applyNaturalSort(ti, "value");
        }
        if (matches(ti, "ehr", "tasks") || matches(ti, "ehr", "my_tasks"))
        {
            customizeTasks(ti);
        }
    }

    public void doCalculatedCustomizations(AbstractTableInfo tableInfo) {
        if (tableInfo.getColumn(DATE_COLUMN) != null) {
            addCalculatedColumns((AbstractTableInfo) tableInfo);
        }
    }

    private boolean isDemographicsTable(TableInfo tableInfo) {
        return tableInfo.getName().equalsIgnoreCase(DEMOGRAPHICS_TABLE) && tableInfo.getPublicSchemaName().equalsIgnoreCase(STUDY_SCHEMA);
    }

    private void addCalculatedColumns(AbstractTableInfo table)
    {
        UserSchema ehrSchema = getEHRUserSchema(table, STUDY_SCHEMA);
        if (ehrSchema != null && !isDemographicsTable(table))
        {
            appendAssignmentAtTimeColumn(ehrSchema, table, DATE_COLUMN);
            appendAgeAtTimeColumn(ehrSchema, table, DATE_COLUMN);
        }
    }

    private void appendAssignmentAtTimeColumn(UserSchema ehrSchema, AbstractTableInfo tableInfo, final String dateColumnName) {

        if(!hasTable(tableInfo, STUDY_SCHEMA, ASSIGNMENT_TABLE, ehrSchema.getContainer()))
            return;
        List<String> calculatedColumnNames = new ArrayList<>(Arrays.asList(ASSIGNMENT_AT_TIME_COLUMN,
                PROTOCOLS_AT_TIME_CALCULATED,
                PROJECTS_AT_TIME_CALCULATED,
                PROJECT_NUMBERS_AT_TIME_CALCULATED));

        if(!provider.buildTableFromQuery(tableInfo, ASSIGNMENT_AT_TIME_COLUMN, dateColumnName, ASSIGNMENT_AT_TIME_SQL,
                ehrSchema, calculatedColumnNames,false))
            return;
    }

    private void appendAgeAtTimeColumn(UserSchema ehrSchema, AbstractTableInfo tableInfo, String dateColumnName) {

        if (!hasTable(tableInfo, STUDY_SCHEMA, DEMOGRAPHICS_TABLE, ehrSchema.getContainer()))
            return;
        if (!hasAnimalLookup(tableInfo))
            return;
        List<String> calculatedColumnNames = new ArrayList<>(Arrays.asList(AGE_AT_TIME_COLUMN,
                AGE_AT_TIME_DAYS_COLUMN,
                AGE_AT_TIME_MONTHS_COLUMN,
                AGE_AT_TIME_YEARS_COLUMN,
                AGE_AT_TIME_YEARS_ROUNDED_COLUMN,
                AGE_CLASS_AT_TIME_COLUMN));

        if(!provider.buildTableFromQuery(tableInfo, AGE_AT_TIME_COLUMN, dateColumnName, AGE_AT_TIME_SQL,
                ehrSchema, calculatedColumnNames,true))
            return;

    }


    private boolean hasAnimalLookup(AbstractTableInfo tableInfo) {
        var idCol = tableInfo.getMutableColumn(ID_COLUMN);
        return idCol != null && idCol.getFk() != null && idCol.getFk().getLookupTableName().equalsIgnoreCase(ANIMAL_TABLE);
    }

    /**
     * A helper that will do a case-insensitive, name-vs-label-aware match to determine if the
     * TableInfo corresponds to schemaName/queryName provided.
     */
    @Override
    protected boolean matches(TableInfo ti, String schema, String query)
    {
        if (ti instanceof DatasetTable)
            return ti.getSchema().getName().equalsIgnoreCase(schema) && (ti.getName().equalsIgnoreCase(query) || ti.getTitle().equalsIgnoreCase(query));
        else
            return ti.getSchema().getName().equalsIgnoreCase(schema) && ti.getName().equalsIgnoreCase(query);
    }

    private void customizeTasks(AbstractTableInfo ti)
    {
        DetailsURL detailsURL = DetailsURL.fromString("/ehr/dataEntryFormDetails.view?formType=${formtype}&taskid=${taskid}");

        var updateCol = ti.getMutableColumn("updateTitle");
        if (updateCol == null)
        {
            updateCol = new WrappedColumn(ti.getColumn("title"), "updateTitle");
            ti.addColumn(updateCol);
        }

        var updateTaskId = ti.getMutableColumn("updateTaskId");
        if (updateTaskId == null)
        {
            updateTaskId = new WrappedColumn(ti.getColumn("rowid"), "updateTaskId");
            ti.addColumn(updateTaskId);
        }

        if (ti.getUserSchema().getContainer().hasPermission(ti.getUserSchema().getUser(), EHRDataEntryPermission.class))
        {
            updateCol.setURL(DetailsURL.fromString("/ehr/dataEntryForm.view?formType=${formtype}&taskid=${taskid}"));
            updateTaskId.setURL(DetailsURL.fromString("/ehr/dataEntryForm.view?formType=${formtype}&taskid=${taskid}"));
        }
        else
        {
            updateCol.setURL(detailsURL);
            updateTaskId.setURL(detailsURL);
        }
    }

    private void customizeEncounterTable(AbstractTableInfo ti)
    {
        var remark = ti.getMutableColumn("remark");
        if (null != remark)
            remark.setDisplayColumnFactory(new WhitespacePreservingDisplayColumnFactory());
    }

//    species column moved to extensible column (in ehr.template.xml) - keep this code example. tjh
//    private void customizeProjectTable(AbstractTableInfo ti)
//    {
//
//        if (ti.getColumn("species") == null)
//        {
//            UserSchema us = getUserSchema(ti, "ehr");
//
//            if (us != null)
//            {
//                ColumnInfo project = ti.getColumn("project");
//                BaseColumnInfo col = ti.addColumn(new WrappedColumn(project, "species"));
//                col.setLabel("Species");
//                col.setUserEditable(false);
//                col.setIsUnselectable(false);
//                col.setFk(new QueryForeignKey(QueryForeignKey.from(us, ti.getContainerFilter())
//                        .table("projectSpecies")
//                        .key("project")
//                        .display("species")));
//            }
//        }
//
//    }
    private void customizeHousingTable(AbstractTableInfo ti)
    {
// ToDo: uncomment for paired caging. tjh

//        if (ti.getColumn("effectiveCage") == null)
//        {
//            UserSchema us = getUserSchema(ti, "study");
//
//            if (us != null)
//            {
//                ColumnInfo lsidCol = ti.getColumn("lsid");
//                ColumnInfo col = ti.addColumn(new WrappedColumn(lsidCol, "effectiveCage"));
//                col.setLabel("Lowest Joined Cage");
//                col.setUserEditable(false);
//                col.setIsUnselectable(true);
//                col.setFk(new QueryForeignKey(us, null, "housingEffectiveCage", "lsid", "effectiveCage"));
//            }
//        }

        if (ti.getColumn("daysInRoom") == null)
        {
            TableInfo realTable = getRealTable(ti);
            if (realTable != null && realTable.getColumn("participantid") != null && realTable.getColumn("date") != null && realTable.getColumn("enddate") != null)
            {
                SQLFragment roomSql = new SQLFragment(realTable.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "(SELECT max(h2.enddate) as d FROM " + realTable.getSelectName() + " h2 WHERE h2.enddate IS NOT NULL AND h2.enddate <= " + ExprColumn.STR_TABLE_ALIAS + ".date AND h2.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid and h2.room != " + ExprColumn.STR_TABLE_ALIAS + ".room)"));
                ExprColumn roomCol = new ExprColumn(ti, "daysInRoom", roomSql, JdbcType.INTEGER, realTable.getColumn("participantid"), realTable.getColumn("date"), realTable.getColumn("enddate"));
                roomCol.setLabel("Days In Room");
                ti.addColumn(roomCol);

                SQLFragment sql = new SQLFragment(realTable.getSqlDialect().getDateDiff(Calendar.DATE, "{fn curdate()}", "(SELECT max(h2.enddate) as d FROM " + realTable.getSelectName() + " h2 LEFT JOIN ehr_lookups.rooms r1 ON (r1.room = h2.room) WHERE h2.enddate IS NOT NULL AND h2.enddate <= " + ExprColumn.STR_TABLE_ALIAS + ".date AND h2.participantid = " + ExprColumn.STR_TABLE_ALIAS + ".participantid and r1.area != (select area FROM ehr_lookups.rooms r WHERE r.room = " + ExprColumn.STR_TABLE_ALIAS + ".room))"));
                ExprColumn areaCol = new ExprColumn(ti, "daysInArea", sql, JdbcType.INTEGER, realTable.getColumn("participantid"), realTable.getColumn("date"), realTable.getColumn("enddate"));
                areaCol.setLabel("Days In Area");
                ti.addColumn(areaCol);

            }
        }

        String cagePosition = "cagePosition";
        if (ti.getColumn(cagePosition) == null && ti.getColumn("cage") != null)
        {
            UserSchema us = getUserSchema(ti, "ehr_lookups");
            if (us != null)
            {
                WrappedColumn wrapped = new WrappedColumn(ti.getColumn("cage"), cagePosition);
                wrapped.setLabel("Cage Position");
                wrapped.setIsUnselectable(true);
                wrapped.setUserEditable(false);
                wrapped.setFk(new QueryForeignKey(QueryForeignKey.from(us, ti.getContainerFilter())
                        .table("cage_positions")
                        .key("cage")
                        .display("cage")));
                ti.addColumn(wrapped);
            }
        }

        if (ti.getColumn("cond") != null)
        {
            ti.getMutableColumn("cond").setHidden(true);
        }

        if (ti.getColumn("previousLocation") == null)
        {
            UserSchema us = getUserSchema(ti, "study");
            if (us != null)
            {
                ColumnInfo lsidCol = ti.getColumn("lsid");
                var col = ti.addColumn(new WrappedColumn(lsidCol, "previousLocation"));
                col.setLabel("Previous Location");
                col.setUserEditable(false);
                col.setIsUnselectable(true);
                col.setFk(new QueryForeignKey(QueryForeignKey.from(us, ti.getContainerFilter())
                        .table("housingPreviousLocation")
                        .key("lsid")
                        .display("location")));
            }
        }
    }

    private void customizeAnimalTable(AbstractTableInfo ds)
    {
        String geneticsSchema = "genetic_assays";
        UserSchema us = getUserSchema(ds, "study");
        UserSchema genetics = getUserSchema(ds, geneticsSchema);

        if (us == null)
        {
            return;
        }
        if (ds.getColumn("flags") == null)
        {
            var col = getWrappedCol(us, ds, "Flags", "demographicsActiveFlags", "Id", "Id");
            col.setLabel("ActiveFlags");
            col.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr_lookups&queryName=flag_values&query.Id~eq=${Id}", ds.getContainerContext()));
            ds.addColumn(col);
        }
        if (ds.getColumn("parents") == null)
        {
            var col = getWrappedCol(us, ds, "parents", "demographicsParents", "Id", "Id");
            col.setLabel("Parents");
            ds.addColumn(col);
        }

        if (ds.getColumn("mhcSummary") == null)
        {
            var col = getWrappedCol(us, ds, "mhcSummary", "mhcSummary", "Id", "Id");
            col.setLabel("mhcSummary");
            ds.addColumn(col);
        }
        if (ds.getColumn("totalOffspring") == null)
        {
            var col15 = getWrappedCol(us, ds, "totalOffspring", "demographicsTotalOffspring", "Id", "Id");
            col15.setLabel("Number of Offspring");
            col15.setDescription("Shows the total offspring of each animal");
            ds.addColumn(col15);
        }

        if (ds.getColumn("labworkHistory") == null)
        {
            var col = getWrappedCol(us, ds, "labworkHistory", "demographicsLabwork", "Id", "Id");
            col.setLabel("Labwork History");
            col.setDescription("Shows the date of last labwork for a subsets of tests");
            ds.addColumn(col);
        }

        //do we have freezer samples?
        if (ds.getColumn("freezerSamples") == null)
        {
            var col = getWrappedCol(us, ds, "freezerSamples", "demographicsFreezers", "Id", "Id");
            col.setLabel("Freezer Samples");
            col.setDescription("Shows the number of archived freezer samples");
            col.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study&queryName=freezerWorks&query.Id~eq=${Id}", ds.getContainerContext()));
            ds.addColumn(col);
        }
        if (ds.getColumn("idHistoryList") == null)
        {
            var col = getWrappedCol(us, ds, "idHistoryList", "demographicsIdHistory", "Id", "Id");
            col.setLabel("Id Hx List");
            col.setDescription("List of Ids assigned to animal");
            col.setURL(DetailsURL.fromString("/query/executeQuery.view?schemaName=study&queryName=idHistory&query.Id~eq=${Id}", ds.getContainerContext()));
            ds.addColumn(col);
        }

        if (ds.getColumn("activeAccounts") == null)
        {
            var col = getWrappedCol(us, ds, "activeAccounts", "demographicsActiveAccount", "Id", "Id");
            col.setLabel("Accounts - Active");
            col.setDescription("Shows all accounts to which the animal is actively assigned on the current date");
            ds.addColumn(col);
        }

        if (ds.getColumn("packageCategory") == null)
        {
            var col = getWrappedCol(us, ds, "packageCategory", "demographicsPackageCategories", "Id", "Id");
            col.setLabel("Package Category");
            col.setDescription("Shows the package category for procedures");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeAssignments") == null)
        {
            var col = getWrappedCol(us, ds, "activeAssignments", "demographicsActiveAssignment", "Id", "Id");
            col.setLabel("IACUC Assignments - Active");
            col.setDescription("Shows all protocols to which the animal is actively assigned on the current date");
            ds.addColumn(col);
        }

        if (ds.getColumn("activeGroups") == null)
        {
            var col = getWrappedCol(us, ds, "activeGroups", "demographicsAnimalGroups", "Id", "Id");
            col.setLabel("Animal Groups - Active");
            col.setDescription("Shows all groups to which the animal is actively assigned on the current date");
            ds.addColumn(col);
        }

        if (ds.getColumn("MostRecentTBDate") == null)
        {
            var col = getWrappedCol(us, ds, "MostRecentTBDate", "demographicsMostRecentTBDate", "Id", "Id");
            col.setLabel("Most Recent TB");
            col.setDescription("Queries the most recent TB date for the animal.");
            ds.addColumn(col);
        }
        if (ds.getColumn("LastBCS") == null)
        {
            var col = getWrappedCol(us, ds, "LastBCS", "demographicsLastBCS", "Id", "Id");
            col.setLabel("Most Recent BCS");
            col.setDescription("Queries the most recent BCS value for the animal.");
            ds.addColumn(col);
        }

        // Change label and description 8/31/2017 tjh
        if (ds.getColumn("MostRecentArrival") != null)
        {
            var col = getWrappedCol(us, ds, "MostRecentArrival", "demographicsArrival", "Id", "Id");
            ds.removeColumn(col);
            col.setLabel("Acquisition");
            col.setDescription("Calculates the earliest and most recent acquisition per animal.");
            ds.addColumn(col);

        }
        // Change label and description 8/31/2017 tjh
        if (ds.getColumn("MostRecentDeparture") != null)
        {
            var col = getWrappedCol(us, ds, "MostRecentDeparture", "demographicsMostRecentDeparture", "Id", "Id");
            ds.removeColumn(col);
            col.setLabel("Disposition");
            col.setDescription("Calculates the earliest and most recent departure per animal, if applicable, and most recent acquisition.");
            ds.addColumn(col);
        }

        // Because of performance, changed to study based dataset ETLed from genetics folder 10/14/19 srr
        if (genetics != null)
        {
            if (ds.getColumn("GenDemoCustomizer") == null)
            {
                var col = getWrappedCol(us, ds, "GenDemoCustomizer", "GenDemoCustomizer", "Id", "Id");
                col.setLabel("Genetic Assays");
                col.setDescription("Show if genetic assays exist for ID");
                ds.addColumn(col);
            }
        }
        else
        {
            _log.info("Linked Schema: " + geneticsSchema + " - Not found");
        }
    }

    private MutableColumnInfo getWrappedCol(UserSchema us, AbstractTableInfo ds, String name, String queryName, String colName, String targetCol)
    {

        WrappedColumn col = new WrappedColumn(ds.getColumn(colName), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new QueryForeignKey(QueryForeignKey.from(us, ds.getContainerFilter())
                .table(queryName)
                .key(targetCol)
                .display(targetCol)));

        return col;
    }


    private TableInfo getRealTable(TableInfo targetTable)
    {
        TableInfo realTable = null;
        if (targetTable instanceof FilteredTable)
        {
            if (targetTable instanceof DatasetTable)
            {
                Domain domain = targetTable.getDomain();
                if (domain != null)
                {
                    realTable = StorageProvisioner.createTableInfo(domain);
                }
            }
            else if (targetTable.getSchema() != null)
            {
                realTable = targetTable.getSchema().getTable(targetTable.getName());
            }
        }
        return realTable;
    }
}
