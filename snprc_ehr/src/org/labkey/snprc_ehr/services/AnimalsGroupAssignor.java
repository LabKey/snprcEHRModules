package org.labkey.snprc_ehr.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.view.ViewContext;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.domain.AnimalGroup;
import org.labkey.snprc_ehr.domain.AnimalGroupCategory;
import org.labkey.snprc_ehr.domain.AnimalSpecies;
import org.labkey.snprc_ehr.domain.GroupMember;
import org.labkey.snprc_ehr.enums.AssignmentFailureReason;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 3/27/2017.
 */

public class AnimalsGroupAssignor
{
    ViewContext viewContext;
    private AnimalGroup group = null;
    private AnimalGroupCategory category = null;
    private List<GroupMember> groupMembers = new ArrayList<GroupMember>();
    private List<GroupMember> categoryMembers = new ArrayList<GroupMember>();


    public AnimalsGroupAssignor(ViewContext viewContext, int group)
    {
        this.viewContext = viewContext;

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("code"), group, CompareType.EQUAL);

        this.group = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups(), filter, null).getObject(AnimalGroup.class);
        this.category = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories(), new SimpleFilter(FieldKey.fromString("category_code"), this.group.getCategory_code(), CompareType.EQUAL), null).getObject(AnimalGroupCategory.class);

        this.groupMembers = this.getGroupAssignees();
        if (this.category.getEnforce_exclusivity().equalsIgnoreCase("Y"))
        {
            this.categoryMembers = this.getCategoryAssignees();
        }

    }

    /**
     * @return all animals that are already assigned and which assignment is still active
     */
    private List<GroupMember> getGroupAssignees()
    {

        Date today = new Date();

        UserSchema schema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo table = schema.getTable("animal_group_members");
        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("groupid"), this.group.getCode(), CompareType.EQUAL);

        filter.addClause(new SimpleFilter.OrClause(
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GTE, today)
        ));

        TableSelector tableSelector = new TableSelector(table, filter, null);
        List<GroupMember> members = tableSelector.getArrayList(GroupMember.class);

        return members;
    }


    /**
     * @return all animals that are already assigned to the category, needed to enforce assignment exclusivity at the category level
     */
    private List<GroupMember> getCategoryAssignees()
    {
        Date today = new Date();

        UserSchema schema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo table = schema.getTable("animal_group_members");
        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("groupid"), this.getCategoryGroups(), CompareType.IN);

        filter.addClause(new SimpleFilter.OrClause(
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GT, today)
        ));

        TableSelector tableSelector = new TableSelector(table, filter, null);
        List<GroupMember> members = tableSelector.getArrayList(GroupMember.class);

        return members;
    }

    private List<Integer> getCategoryGroups()
    {
        TableInfo table = SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups();
        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("category_code"), this.category.getCategory_code(), CompareType.EQUAL);

        List<AnimalGroup> groups = new TableSelector(table, filter, null).getArrayList(AnimalGroup.class);

        List<Integer> groupIds = new ArrayList<>();
        for (AnimalGroup group : groups)
        {
            groupIds.add(group.getCode());
        }

        return groupIds;

    }

    /**
     * @param groupMembers: Animals to be assigned (animalId, start date, and end date)
     * @return list of animals that couldn't be assigned,
     */
    public List<Map<String, AssignmentFailureReason>> assign(List<GroupMember> groupMembers)
    {
        List<Map<String, AssignmentFailureReason>> notAssigned = new ArrayList<>();
        List<Map<String, Object>> rows = new ArrayList<>();
        ObjectMapper oMapper = new ObjectMapper();

        //Load Demographics Records
        List<String> animalIds = new ArrayList<String>();
        for (GroupMember m : groupMembers)
        {
            animalIds.add(m.getParticipantid());
        }

        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");

        TableInfo demographicsTable = userSchema.getTable("demographics");
        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("id"), animalIds, CompareType.IN);
        Map<String, Map<String, String>> demographicsMap = new HashMap<>();
        for (Map a : new TableSelector(demographicsTable, filter, null).getMapCollection())
        {
            Map oneAnimalDemographicsMap = new HashMap();
            oneAnimalDemographicsMap.put("gender", a.get("gender"));
            oneAnimalDemographicsMap.put("species", a.get("species"));
            oneAnimalDemographicsMap.put("death", a.get("death"));
            demographicsMap.put((String) a.get("id"), oneAnimalDemographicsMap);
        }


        for (GroupMember groupMember : groupMembers)
        {
            if (!demographicsMap.containsKey(groupMember.getParticipantid()))
            {
                Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.INVALID_ANIMAL_ID);
                notAssigned.add(failureReasonMap);
                continue;
            }
            if (demographicsMap.get(groupMember.getParticipantid()).get("death") != null)
            {
                Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.DEAD_ANIMAL);
                notAssigned.add(failureReasonMap);
                continue;

            }
            if (this.groupMembers.contains(groupMember))
            {
                Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.ALREADY_IN_GROUP);
                notAssigned.add(failureReasonMap);
                continue;
            }
            if (this.category.getEnforce_exclusivity().equalsIgnoreCase("Y") && this.categoryMembers.contains(groupMember))
            {
                Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.ALREADY_IN_CATEGORY);
                notAssigned.add(failureReasonMap);
                continue;

            }

            if (this.category.getAllow_future_date().equalsIgnoreCase("N") && groupMember.getDate().after(new Date()))
            {
                Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.FUTURE_DATE_NOT_ALLOWED);
                notAssigned.add(failureReasonMap);
                continue;

            }
            if (this.category.getSex() != null && !this.category.getSex().equalsIgnoreCase(demographicsMap.get(groupMember.getParticipantid()).get("gender")))
            {
                Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.NOT_APPLICABLE_GENDER);
                notAssigned.add(failureReasonMap);
                continue;

            }
            if (this.category.getSpecies() != null)
            {
                //demographics uses arc_species
                //animal_group_categories uses the 2 characters species code
                TableInfo speciesTable = SNPRC_EHRSchema.getInstance().getTableInfoSpecies();
                SimpleFilter speciesFilter = new SimpleFilter();
                speciesFilter.addCondition(FieldKey.fromString("species_code"), demographicsMap.get(groupMember.getParticipantid()).get("species"), CompareType.EQUAL);
                AnimalSpecies speciesObject = new TableSelector(speciesTable, speciesFilter, null).getObject(AnimalSpecies.class);
                if (speciesObject == null)
                {
                    continue;
                }
                if (!speciesObject.getSpecies_code().equalsIgnoreCase(demographicsMap.get(groupMember.getParticipantid()).get("species")))
                {
                    Map<String, AssignmentFailureReason> failureReasonMap = new HashMap<>();
                    failureReasonMap.put(groupMember.getParticipantid(), AssignmentFailureReason.NOT_APPLICABLE_SPECIES);
                    notAssigned.add(failureReasonMap);
                    continue;
                }

            }

            Map groupMemberAsMap = oMapper.convertValue(groupMember, Map.class);
            groupMemberAsMap.remove("id");
            groupMemberAsMap.remove("Id");
            rows.add(groupMemberAsMap);


        }
        if (!rows.isEmpty())
        {
            UserSchema schema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");

            QueryUpdateService qus = table.getUpdateService();
            try
            {
                qus.insertRows(this.viewContext.getUser(), this.viewContext.getContainer(), rows, new BatchValidationException(), null, null);
            }
            catch (DuplicateKeyException e)
            {
                e.printStackTrace();

            }
            catch (BatchValidationException e)
            {
                e.getRowErrors();
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


        return notAssigned;
    }

}
