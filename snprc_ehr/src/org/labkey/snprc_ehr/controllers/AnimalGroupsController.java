package org.labkey.snprc_ehr.controllers;


import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.util.GUID;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.domain.AnimalGroup;
import org.labkey.snprc_ehr.domain.AnimalGroupCategory;
import org.labkey.snprc_ehr.domain.AnimalSpecies;
import org.labkey.snprc_ehr.domain.GroupMember;
import org.labkey.snprc_ehr.enums.AssignmentFailureReason;
import org.labkey.snprc_ehr.security.ManageGroupMembersPermission;
import org.labkey.snprc_ehr.services.AnimalsGroupAssignor;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

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
    public static final String NAME = "animalgroups";
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

            return root.addChild("Animal Group Categories", new ActionURL(GroupCategoriesAction.class, getContainer()));

        }


        @Override
        public ModelAndView getView(AnimalGroupCategory animalGroupCategory, BindException errors) throws Exception
        {

            return new JspView<>("/org/labkey/snprc_ehr/views/animal_groups.jsp");
        }


    }

    /**
     * Get all defined categories
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetCategoriesAction extends ApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory o, BindException errors) throws Exception
        {

            Map<String, Object> props = new HashMap<String, Object>();
            Sort sort = new Sort();

            if (o.getSort() != null)
            {
                ObjectMapper m = new ObjectMapper();
                JSONObject sortObject = m.readValue(o.getSort().replace('[', ' ').replace(']', ' '), JSONObject.class);
                switch (((String) sortObject.get("direction")).toUpperCase())
                {
                    case "ASC":
                        sort.appendSortColumn(FieldKey.fromString((String) sortObject.get("property")), Sort.SortDirection.ASC, false);
                        break;
                    case "DESC":
                        sort.appendSortColumn(FieldKey.fromString((String) sortObject.get("property")), Sort.SortDirection.DESC, false);
                        break;
                }
            }
            SimpleFilter filter = new SimpleFilter();
            if (o.getFilter() != null && !o.getFilter().equals(""))
            {
                ObjectMapper m = new ObjectMapper();
                JSONObject filterObject = m.readValue(o.getFilter().replace('[', ' ').replace(']', ' '), JSONObject.class);

                filter.addCondition(FieldKey.fromString("description"), filterObject.get("value"), CompareType.CONTAINS);
                /*
                filter.addCondition(new SimpleFilter.OrClause(
                        new CompareType.CompareClause(FieldKey.fromString("description"), CompareType.CONTAINS, o.getFilter()),
                        new CompareType.CompareClause(FieldKey.fromString("comment"), o.getFilter(), CompareType.CONTAINS)
                ));
                */


            }
            ArrayList<AnimalGroupCategory> rows = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories(), filter, sort).getArrayList(AnimalGroupCategory.class);

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
    public class UpdateCategoriesAction extends ApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory o, BindException errors) throws Exception
        {
            o.setContainerId(getContainer().getId());
            Map<String, Object> props = new HashMap<String, Object>();
            try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
            {
                if (o.getCategory_code() != 0)
                {
                    Table.update(getUser(), SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories(), o, o.getCategory_code());

                }
                else
                {
                    o.setCategory_code(this.getNextCategoryId());
                    o.setObjectId((new GUID()).toString());

                    Table.insert(getUser(), SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories(), o);
                    props.put("category_code", o.getCategory_code());
                }

                props.put("success", true);
                transaction.commit();
            }
            catch (Exception e)
            {
                props.put("success", false);
                errors.reject(ERROR_MSG, e.getMessage());
            }

            return new ApiSimpleResponse(props);
        }

        private Integer getNextCategoryId()
        {
            SQLFragment sql = new SQLFragment("SELECT MAX(category_code) AS MAX_CODE FROM ");
            sql.append(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories());
            SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);

            return sqlSelector.getObject(Integer.class) + 1;

        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class RemoveCategoryAction extends ApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory animalGroupCategory, BindException errors) throws Exception
        {

            TableInfo table = SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups();
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("category_code"), animalGroupCategory.getCategory_code(), CompareType.EQUAL);

            List<AnimalGroup> groups = new TableSelector(table, filter, null).getArrayList(AnimalGroup.class);

            Map<String, Object> props = new HashMap<String, Object>();

            if (groups == null || groups.isEmpty())
            {
                TableInfo categoriesTable = SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories();
                SimpleFilter categoriesFilter = new SimpleFilter();
                categoriesFilter.addCondition(FieldKey.fromString("category_code"), animalGroupCategory.getCategory_code(), CompareType.EQUAL);
                Table.delete(categoriesTable, categoriesFilter);
                props.put("success", true);

            }
            else
            {

                props.put("success", false);
                props.put("message", "Unable to delete this category, Please delete this category groups first");
            }

            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Get all defined species, needed when editing categories
     *
     * @TODO: move this to a species controller?
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetSpeciesAction extends ApiAction<AnimalSpecies>
    {
        @Override
        public ApiResponse execute(AnimalSpecies o, BindException errors) throws Exception
        {
            ArrayList<AnimalSpecies> rows = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoSpecies(), null, null).getArrayList(AnimalSpecies.class);
            List<JSONObject> jsonRows = new ArrayList<>();

            Map<String, Object> props = new HashMap<String, Object>();
            for (AnimalSpecies form : rows)
            {
                jsonRows.add(form.toJSON());
            }
            props.put("rows", jsonRows);
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Given a category, get all its groups
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class GetGroupsByCategoryAction extends ApiAction<AnimalGroup>
    {
        @Override
        public ApiResponse execute(AnimalGroup animalGroup, BindException errors) throws Exception
        {
            Map<String, Object> props = new HashMap<String, Object>();
            ArrayList<AnimalGroup> rows = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups(), new SimpleFilter().addCondition("category_code", animalGroup.getCategory_code(), CompareType.EQUAL), null).getArrayList(AnimalGroup.class);

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
    public class GetAnimalsByGroupAction extends ApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors) throws Exception
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
    public class GetAnimalsByNameAction extends ApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors) throws Exception
        {
            TableInfo table = SNPRC_EHRSchema.getInstance().getStudySchema().getTable("Participant");
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("participantId"), groupMember.getParticipantid(), CompareType.STARTS_WITH);
            List<GroupMember> animals = new TableSelector(table, filter, null).getArrayList(GroupMember.class);
            Map props = new CaseInsensitiveHashMap();
            List<JSONObject> jsonRows = new ArrayList<>();
            for (GroupMember form : animals)
            {
                jsonRows.add(form.toJSON());
            }
            props.put("success", true);
            props.put("animals", jsonRows);
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Edit/Add a new group
     */
    @RequiresPermission(EHRDataEntryPermission.class)
    public class UpdateGroupsAction extends ApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors) throws Exception
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
            TableInfo table = SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups();
            try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
            {
                for (int i = 0; i < rows.length(); i++)
                {
                    JSONObject o = rows.getJSONObject(i);
                    if (o.get("date") != null)
                    {
                        o.put("date", ((String) o.get("date")).substring(0, 10));
                    }
                    if (o.get("enddate") != null)
                    {
                        o.put("enddate", ((String) o.get("enddate")).substring(0, 10));
                    }

                    Map primaryKey = new HashMap();

                    if (o.get("code") != null && (Integer) o.get("code") != 0)
                    {
                        primaryKey.put("code", o.get("code"));
                        primaryKey.put("category_code", o.get("category_code"));

                        Table.update(getUser(), table, o, primaryKey);

                    }
                    else
                    {
                        o.put("code", this.getNextGroupCode());
                        o.put("container", this.getContainer().getEntityId());
                        o.put("objectid", new GUID());

                        Table.insert(getUser(), table, o);

                    }
                }

                props.put("success", true);
                transaction.commit();
            }
            catch (Exception e)
            {
                props.put("success", false);
                errors.reject("ERROR", e.getMessage());
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

            SQLFragment sql = new SQLFragment("SELECT MAX(category_code), MAX(code) AS MAX_CODE FROM ");
            sql.append(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups());
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

            SQLFragment sql = new SQLFragment("SELECT MAX(code) AS MAX_CODE FROM ");
            sql.append(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups());
            SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);

            return sqlSelector.getObject(Integer.class) + 1;

        }


    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class DeleteGroupsAction extends ApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors) throws Exception
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
            TableInfo groupTable = SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups();

            UserSchema schema = QueryService.get().getUserSchema(this.getUser(), this.getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("groupid"), ((JSONObject) rows.get(0)).getInt("code"), CompareType.EQUAL);


            TableSelector tableSelector = new TableSelector(table, filter, null);
            List<GroupMember> members = tableSelector.getArrayList(GroupMember.class);

            if (!members.isEmpty())
            {
                props.put("success", false);
            }
            else
            {
                SimpleFilter deleteFilter = new SimpleFilter();
                deleteFilter.addCondition(FieldKey.fromString("code"), ((JSONObject) rows.get(0)).getInt("code"), CompareType.EQUAL);
                Table.delete(groupTable, deleteFilter);
                props.put("success", true);
            }
            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Assigns animals to a group using an instance of  {@link AnimalsGroupAssignor}
     */
    @RequiresPermission(ManageGroupMembersPermission.class)
    public class UpdateGroupMembersAction extends ApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors) throws Exception
        {

            if (groupMember.getEnddate() != null && groupMember.getDate().after(groupMember.getEnddate()))
            {
                Map props = new HashMap();
                props.put("success", true);

                Map dateFailure = new HashMap<>();
                dateFailure.put("Invalid End Date", "End Date must be greater than Start Date");
                props.put("failure", dateFailure);

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
                groupMembers.add(animalForm);

            }
            List<Map<String, AssignmentFailureReason>> notAssignedAnimals = animalsGroupAssignor.assign(groupMembers);

            Map<AssignmentFailureReason, String> failedAssignments = new HashMap<>();
            for (Map failedAssignment : notAssignedAnimals)
            {
                if (failedAssignments.containsKey((AssignmentFailureReason) (failedAssignment.values().toArray()[0])))
                {
                    failedAssignments.put((AssignmentFailureReason) (failedAssignment.values().toArray()[0]), failedAssignments.get((AssignmentFailureReason) (failedAssignment.values().toArray()[0])) + ", " + (failedAssignment.keySet().toArray()[0]).toString());
                }
                else
                {
                    failedAssignments.put((AssignmentFailureReason) (failedAssignment.values().toArray()[0]), (failedAssignment.keySet().toArray()[0]).toString());

                }

            }


            Map props = new HashMap();
            props.put("success", true);
            if (!failedAssignments.isEmpty())
            {
                props.put("failure", failedAssignments);

            }

            return new ApiSimpleResponse(props);
        }


    }

    @RequiresPermission(ManageGroupMembersPermission.class)
    public class DeleteGroupMembersAction extends ApiAction<GroupMember>
    {
        @Override
        public ApiResponse execute(GroupMember groupMember, BindException errors)
        {
            UserSchema schema = QueryService.get().getUserSchema(this.getUser(), this.getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");


            /**
             * SELECT GROUP MEMBER FIRST -- We need objectId to be able to use QueryUpdateService
             */

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
                    qus.deleteRows(this.getUser(), this.getContainer(), keys, null, null);
                }
                catch (InvalidKeyException e)
                {
                    e.printStackTrace();
                }
                catch (BatchValidationException e)
                {
                    e.printStackTrace();
                }
                catch (QueryUpdateServiceException e)
                {
                    e.printStackTrace();
                }
                catch (SQLException e)
                {
                    e.printStackTrace();
                }

            }
            return null;
        }
    }
}
