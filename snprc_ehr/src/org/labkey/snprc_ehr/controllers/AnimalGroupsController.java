/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
package org.labkey.snprc_ehr.controllers;


//import com.fasterxml.jackson.databind.ObjectMapper;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.ObjectFactory;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.util.GUID;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.SNPRC_EHRUserSchema;
import org.labkey.snprc_ehr.domain.AnimalGroup;
import org.labkey.snprc_ehr.domain.AnimalGroupCategory;
import org.labkey.snprc_ehr.domain.AnimalSpecies;
import org.labkey.snprc_ehr.domain.GroupMember;
import org.labkey.snprc_ehr.enums.AssignmentFailureReason;
import org.labkey.snprc_ehr.helpers.SortFilterHelper;
import org.labkey.snprc_ehr.security.ManageGroupMembersPermission;
import org.labkey.snprc_ehr.services.AnimalsGroupAssignor;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 3/17/2017.
 */

/**
 * Controller to manage categories, groups and group members
 * <p>
 * except for GroupCategoriesAction which return a view powered by ExtJs4, all other actions return JSON
 */
public class AnimalGroupsController extends SpringActionController
{
    public static final String NAME = "AnimalGroups";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(AnimalGroupsController.class);

    public AnimalGroupsController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class GroupCategoriesAction extends SimpleViewAction<AnimalGroupCategory>
    {

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            root.addChild("Animal Group Categories", new ActionURL(GroupCategoriesAction.class, getContainer()));
            return root;
        }


        @Override
        public ModelAndView getView(AnimalGroupCategory animalGroupCategory, BindException errors)
        {
            return new JspView<>("/org/labkey/snprc_ehr/views/AnimalGroups.jsp");
        }
    }

    /**
     * Get all defined categories
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetCategoriesAction extends ReadOnlyApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory o, BindException errors)
        {

            Map<String, Object> props = new HashMap<String, Object>();

            Sort sort = SortFilterHelper.getSort(o.getSort(), true);

            SimpleFilter filter = SortFilterHelper.getFilter(o.getFilter());

            // Category codes less than  11 are static categories reserved for cycles, pedigrees, and colonies.
            // These tables (cycles, pedigree, colonies) must be updated directly. Insert not permitted. tjh
            filter.addCondition(FieldKey.fromString("category_code"), 11, CompareType.GTE);

            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            ArrayList<AnimalGroupCategory> rows = new TableSelector(us.getTable("animal_group_categories"), filter, sort).getArrayList(AnimalGroupCategory.class);

            List<JSONObject> jsonRows = new ArrayList<>();
            for (AnimalGroupCategory form : rows)
            {
                jsonRows.add(form.toJSON());
            }

            props.put("rows", jsonRows);

            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Update/Add category
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class UpdateCategoriesAction extends MutatingApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory o, BindException errors)
        {

            Map<String, Object> props = new HashMap<>();
            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            ObjectFactory factory = ObjectFactory.Registry.getFactory(AnimalGroupCategory.class);

            TableInfo table = us.getTable("animal_group_categories");
            QueryUpdateService qus = table.getUpdateService();
            BatchValidationException batchErrors = new BatchValidationException();

            Map primaryKey = new HashMap();
            List pk = new ArrayList();
            List<Map<String, Object>> rowsList = new ArrayList<>();

            try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
            {
                if (o.getCategoryCode() != 0)
                {
                    Map categoryAsMap = factory.toMap(o, null);

                    categoryAsMap.put("container", this.getContainer().getId());
                    primaryKey.put("category_code", o.getCategoryCode());

                    pk.add(primaryKey);
                    rowsList.add(categoryAsMap);

                    qus.updateRows(this.getUser(), getContainer(), rowsList, pk, null, null);

                }
                else
                {
                    o.setCategoryCode(this.getNextCategoryId());
                    Map categoryAsMap = factory.toMap(o, null);

                    categoryAsMap.put("objectId", GUID.makeGUID());
                    categoryAsMap.put("container", this.getContainer().getId());

                    rowsList.add(categoryAsMap);

                    qus.insertRows(getUser(), getContainer(), rowsList, batchErrors, null, null);
                    if (batchErrors.hasErrors()) throw batchErrors;

                    props.put("categoryCode", o.getCategoryCode());
                }

                props.put("success", true);
                transaction.commit();
            }
            catch (Exception e)
            {
                props.put("success", false);
                //errors.reject(ERROR_MSG, e.getMessage());
                props.put("message", e.getMessage());
            }

            return new ApiSimpleResponse(props);
        }

        private Integer getNextCategoryId()
        {
            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            TableInfo table = us.getTable("animal_group_categories");

            SQLFragment sql = new SQLFragment("SELECT MAX(agc.category_code) AS MAX_CODE FROM ");
            sql.append(table, "agc");
            SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);

            return sqlSelector.getObject(Integer.class) + 1;
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class RemoveCategoryAction extends MutatingApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory animalGroupCategory, BindException errors)
        {
                Map<String, Object> props = new HashMap<String, Object>();
            try
            {
                UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
                TableInfo table = us.getTable("animal_groups");

                SimpleFilter filter = new SimpleFilter();
                filter.addCondition(FieldKey.fromString("category_code"), animalGroupCategory.getCategoryCode(), CompareType.EQUAL);

                List<AnimalGroup> groups = new TableSelector(table, filter, null).getArrayList(AnimalGroup.class);
                if (groups == null || groups.isEmpty())
                {
                    UserSchema cs = new SNPRC_EHRUserSchema(getUser(), getContainer());
                    TableInfo categoriesTable = cs.getTable("animal_group_categories");

                    SimpleFilter categoriesFilter = new SimpleFilter();
                    categoriesFilter.addCondition(FieldKey.fromString("category_code"), animalGroupCategory.getCategoryCode(), CompareType.EQUAL);
                    Map<String, Object> animalGroupsCategory = new TableSelector(categoriesTable, categoriesFilter, null).getObject(Map.class);

                    List<Map<String, Object>> keys = new ArrayList<Map<String, Object>>();

                    Map<String, Object> idMap = new HashMap<>();
                    idMap.put("category_code", animalGroupsCategory.get("category_code"));
                    keys.add(idMap);

                    QueryUpdateService qus = categoriesTable.getUpdateService();
                    try
                    {
                        qus.deleteRows(getUser(), getContainer(), keys, null, null);
                        props.put("success", true);
                        return new ApiSimpleResponse(props);
                    }
                    catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException | SQLException e)
                    {
                        props.put("success", false);
                        props.put("message", e.getMessage());
                        return new ApiSimpleResponse(props);
                    }
                }
                else
                {

                    props.put("success", false);
                    props.put("message", "Unable to delete this category, Please delete this category groups first");
                }
            }
            catch (Exception e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Get all defined species, needed when editing categories
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetSpeciesAction extends ReadOnlyApiAction<AnimalSpecies>
    {
        @Override
        public ApiResponse execute(AnimalSpecies o, BindException errors)
        {
            List<JSONObject> jsonRows = new ArrayList<>();
            Map<String, Object> props = new HashMap<String, Object>();

            try
            {
                SQLFragment sql = new SQLFragment("SELECT sc.code AS arcSpeciesCode,\n" +
                        "       sc.common_name AS common,\n" +
                        "       sc.scientific_name AS scientificName\n FROM ");
                sql.append(QueryService.get().getUserSchema(getUser(), getContainer(), "ehr_lookups").getTable("species_codes"), "sc");
                sql.append("\n   JOIN (SELECT DISTINCT arc_species_code, primate\n FROM ");
                sql.append(QueryService.get().getUserSchema(getUser(), getContainer(), "snprc_ehr").getTable("species"), "s");
                sql.append("\n         WHERE s.dateDisabled IS NULL AND s.primate = 'Y' ) AS s on s.arc_species_code = sc.code");

                SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);
                ArrayList<AnimalSpecies> rows = sqlSelector.getArrayList(AnimalSpecies.class);

                JSONObject noSpecies = new JSONObject();
                noSpecies.put("arcSpeciesCode", "");
                noSpecies.put("speciesName", "N/A");

                jsonRows.add(noSpecies);
                for (AnimalSpecies species : rows)
                {
                    jsonRows.add(species.toJSON());
                }
                props.put("species", jsonRows);
            }
            catch (Exception e)
            {
                String msg = e.getMessage();
            }

            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Given a category, get all its groups
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetGroupsByCategoryAction extends ReadOnlyApiAction<AnimalGroup>
    {
        @Override
        public ApiResponse execute(AnimalGroup animalGroup, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();
            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());

            ArrayList<AnimalGroup> rows = new TableSelector(us.getTable("animal_groups"),
                    new SimpleFilter().addCondition(FieldKey.fromString("category_code"), animalGroup.getCategoryCode(), CompareType.EQUAL), null).getArrayList(AnimalGroup.class);

            List<JSONObject> jsonRows = new ArrayList<>();
            for (AnimalGroup form : rows)
            {
                jsonRows.add(form.toJSON());
            }
            props.put("rows", jsonRows);
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Given a group, load all animals that are assigned to it
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetAnimalsByGroupAction extends ReadOnlyApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors)
        {
            UserSchema schema = QueryService.get().getUserSchema(getUser(), getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("groupid"), groupMember.getGroupid(), CompareType.EQUAL);
            if (groupMember.isActiveOnly())
            {
                Date today = new Date();
                filter.addClause(new SimpleFilter.OrClause(
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null),
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GT, today)
                ));
            }

            List<JSONObject> animals = new ArrayList<>();
            List<GroupMember> groupMembers = new TableSelector(table, filter, null).getArrayList(GroupMember.class);
            for (GroupMember member : groupMembers)
            {

                animals.add(member.toJSON());
            }

            Map<String, Object> props = new HashMap<String, Object>();
            props.put("animals", animals);
            props.put("success", true);
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Get Animals by name (animal id) - defined to present a list of valid animals to the user
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetAnimalsByNameAction extends ReadOnlyApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors)
        {
            UserSchema us = QueryService.get().getUserSchema(getUser(), getContainer(), "study");
            TableInfo table = us.getTable("Animal");

            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("Id"), groupMember.getId(), CompareType.STARTS_WITH);
            List<GroupMember> animals = new TableSelector(table, filter, null).getArrayList(GroupMember.class);
            Map props = new CaseInsensitiveHashMap();
            List<JSONObject> jsonRows = new ArrayList<>();
            for (GroupMember form : animals)
            {
                form.setParticipantid(form.getId());
                jsonRows.add(form.toJSON());
            }
            props.put("success", true);
            props.put("animals", jsonRows);
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Edit/Add a new group
     * validation of the data takes place in the animal_groups.js trigger script
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class UpdateGroupsAction extends MutatingApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();
            JSONObject json = simpleApiJsonForm.getJsonObject();

            JSONArray rows;

            try
            {
                rows = (JSONArray) json.get("rows");
            }
            catch (Exception exp)
            {
                rows = new JSONArray();
                rows.put(0, (JSONObject) json.get("rows"));
            }
            UserSchema schema = QueryService.get().getUserSchema(getUser(), getContainer(), "snprc_ehr");
            TableInfo table = schema.getTable("animal_groups");
            DbScope scope = schema.getDbSchema().getScope();
            QueryUpdateService qus = table.getUpdateService();
            BatchValidationException batchErrors = new BatchValidationException();

            try (DbScope.Transaction transaction = scope.ensureTransaction())
            {
                for (int i = 0; i < rows.length(); i++)
                {
                    JSONObject o = rows.getJSONObject(i);
                    Map<String, Object> mappedRows = new ObjectMapper().readValue(o.toString(), ArrayListMap.class);
                    List<Map<String, Object>> rowsList = new ArrayList<>();

                    Map primaryKey = new HashMap();
                    List pk = new ArrayList();

                    if (mappedRows.get("code") != null && (Integer) mappedRows.get("code") != 0)
                    {
                        mappedRows.put("category_code", o.get("categoryCode"));
                        mappedRows.put("sort_order", o.get("sortOrder"));

                        // update existing row
                        rowsList.add(mappedRows);

                        primaryKey.put("code", o.get("code"));
                        primaryKey.put("category_code", o.get("categoryCode"));

                        pk.add(primaryKey);

                        qus.updateRows(getUser(), getContainer(), rowsList, pk, null, null);

                    }
                    else // insert a new row
                    {
                        //mappedRows.put("code", -1);
                        mappedRows.put("objectId", GUID.makeGUID());
                        mappedRows.put("category_code", o.get("categoryCode"));
                        mappedRows.put("sort_order", o.get("sortOrder"));
                        rowsList.add(mappedRows);
                        qus.insertRows(getUser(), getContainer(), rowsList, batchErrors, null, null);
                        if (batchErrors.hasErrors()) throw batchErrors;
                    }

                }
                props.put("success", true);
                transaction.commit();
            }

            catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException |
                    DuplicateKeyException | NullPointerException | IOException | SQLException e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }

            return new ApiSimpleResponse(props);
        }

        /**
         * Get a group code to be assigned to a new group
         *
         * @param categoryCode
         * @param ignoreCategory - if true, this will return the next code regardless of the category the group belongs to
         * @return
         */
        private Integer getNextGroupCode(int categoryCode, boolean ignoreCategory)
        {
            if (!ignoreCategory)
            {
                return this.getNextGroupCode(categoryCode);
            }

            return this.getNextGroupCode();
        }


        /**
         * Get a group code to be assigned to a new group
         *
         * @param categoryCode
         * @return next code to be used for insert
         */
        private Integer getNextGroupCode(int categoryCode)
        {
            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            TableInfo table = us.getTable("animal_groups");

            SQLFragment sql = new SQLFragment("SELECT MAX(ag.category_code), MAX(ag.code) AS MAX_CODE FROM ");
            sql.append(table, "ag");
            sql.append(" WHERE category_code = ?").add(categoryCode);
            sql.append(" GROUP BY category_code");
            SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);
            Map result = sqlSelector.getValueMap();

            return result.get(categoryCode) == null ? 1 : ((Integer) result.get(categoryCode) + 1);

        }

        /**
         * Get a group code to be assigned to a new group
         *
         * @return int
         */

        private Integer getNextGroupCode()
        {
            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            TableInfo table = us.getTable("animal_groups");

            SQLFragment sql = new SQLFragment("SELECT MAX(ag.code) AS MAX_CODE FROM ");
            sql.append(table, "ag");

            SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);

            return sqlSelector.getObject(Integer.class) + 1;

        }


    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class DeleteGroupsAction extends MutatingApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {

            Map<String, Object> props = new HashMap<String, Object>();
            JSONObject json = simpleApiJsonForm.getJsonObject();
            JSONArray rows;
            try
            {
                rows = (JSONArray) json.get("rows");
            }
            catch (Exception exp)
            {
                rows = new JSONArray();
                rows.put(0, (JSONObject) json.get("rows"));
            }

            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            TableInfo groupsTable = us.getTable("animal_groups");

            UserSchema ss = QueryService.get().getUserSchema(this.getUser(), this.getContainer(), "study");
            TableInfo studyTable = ss.getTable("animal_group_members");

            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("groupid"), ((JSONObject) rows.get(0)).getInt("code"), CompareType.EQUAL);

            TableSelector tableSelector = new TableSelector(studyTable, filter, null);
            List<GroupMember> members = tableSelector.getArrayList(GroupMember.class);

            if (!members.isEmpty())
            {
                // can't delete group with animals assigned
                props.put("success", false);
                props.put("message", "Can't delete group with animals assigned.");
            }
            else
            {
                SimpleFilter codeFilter = new SimpleFilter();
                codeFilter.addCondition(FieldKey.fromString("code"), ((JSONObject) rows.get(0)).getInt("code"), CompareType.EQUAL);
                Map<String, String> animalGroup = new TableSelector(groupsTable, codeFilter, null).getObject(Map.class);

                List<Map<String, Object>> keys = new ArrayList<>();
                Map<String, Object> codeMap = new HashMap<>();
                codeMap.put("code", animalGroup.get("code"));
                codeMap.put("category_code", animalGroup.get("category_code"));
                keys.add(codeMap);

                QueryUpdateService qus = groupsTable.getUpdateService();
                try
                {
                    qus.deleteRows(getUser(), getContainer(), keys, null, null);
                    props.put("success", true);
                }
                catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException | SQLException e) {
                    props.put("success", false);
                    props.put("message", e.getMessage());
                }
            }

            return new ApiSimpleResponse(props);
        }
    }


    /**
     * Assigns animals to a group using an instance of  {@link AnimalsGroupAssignor}
     */
    @RequiresPermission(ManageGroupMembersPermission.class)
    public class UpdateGroupMembersAction extends MutatingApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors)
        {

            if (groupMember.getEnddate() != null && groupMember.getDate().after(groupMember.getEnddate()))
            {
                Map props = new HashMap();
                props.put("success", false);

                props.put("message", AssignmentFailureReason.INVALID_START_OR_END_DATE.toString());

                return new ApiSimpleResponse(props);
            }

            AnimalsGroupAssignor animalsGroupAssignor = new AnimalsGroupAssignor(this.getViewContext(), groupMember.getGroupid());

            List<GroupMember> groupMembers = new ArrayList<GroupMember>();
            for (String animal : groupMember.getId().split("\n"))
            {
                GroupMember animalForm = new GroupMember();
                animalForm.setParticipantid(animal);
                animalForm.setDate(groupMember.getDate());
                animalForm.setEnddate(groupMember.getEnddate());
                animalForm.setDescription(groupMember.getDescription());
                animalForm.setGroupid(groupMember.getGroupid());
                animalForm.setObjectid(groupMember.getObjectid());
                groupMembers.add(animalForm);

            }
            Map props = new HashMap();
            try
            {
                animalsGroupAssignor.assign(groupMembers);

                props.put("success", true);

            }
            catch (ValidationException e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }

            return new ApiSimpleResponse(props);
        }
    }

    @RequiresPermission(ManageGroupMembersPermission.class)
    public class DeleteGroupMembersAction extends MutatingApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors)
        {

            UserSchema schema = QueryService.get().getUserSchema(getUser(), getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");

            /**
             * SELECT GROUP MEMBER FIRST -- We need objectId to be able to use QueryUpdateService
             */

            Map props = new HashMap();
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("groupid"), groupMember.getGroupid(), CompareType.EQUAL);
            filter.addCondition(FieldKey.fromString("id"), groupMember.getId(), CompareType.EQUAL);
            filter.addCondition(FieldKey.fromString("date"), groupMember.getDate(), CompareType.EQUAL);
            TableSelector tableSelector = new TableSelector(table, filter, null);

            List<Map<String, Object>> keys = new ArrayList<Map<String, Object>>();
            List<GroupMember> members = tableSelector.getArrayList(GroupMember.class);
            for (GroupMember member : members)
            {
                Map<String, Object> objectIdMap = new HashMap<>();
                objectIdMap.put("objectid", member.getObjectid());
                keys.add(objectIdMap);
            }

            if (!keys.isEmpty())
            {
                QueryUpdateService qus = table.getUpdateService();
                try
                {
                    qus.deleteRows(getUser(), getContainer(), keys, null, null);
                    props.put("success", true);
                    return new ApiSimpleResponse(props);
                }
                catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException | SQLException e)
                {
                    props.put("success", false);
                    props.put("message", e.getMessage());
                    return new ApiSimpleResponse(props);
                }

            }
            //should not reach this point

            props.put("success", false);
            return new ApiSimpleResponse(props);
        }
    }
}
