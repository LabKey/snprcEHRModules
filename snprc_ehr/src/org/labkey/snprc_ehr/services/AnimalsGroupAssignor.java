/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.labkey.snprc_ehr.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
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
        this.category = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories(), new SimpleFilter(FieldKey.fromString("category_code"), this.group.getCategoryCode(), CompareType.EQUAL), null).getObject(AnimalGroupCategory.class);

        this.groupMembers = this.getGroupAssignees();
        if (this.category.getEnforceExclusivity().equalsIgnoreCase("Y"))
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
        filter.addCondition(FieldKey.fromString("category_code"), this.category.getCategoryCode(), CompareType.EQUAL);

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
     * @return - Nothing - Animals are either assigned or an exception is thrown
     */
    public void assign(List<GroupMember> groupMembers) throws InvalidKeyException, BatchValidationException, QueryUpdateServiceException,
        DuplicateKeyException, NullPointerException, SQLException, ValidationException

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
        Map<String, Map<String, Object>> demographicsMap = new HashMap<>();
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
            // check for valid animal id
            if (!demographicsMap.containsKey(groupMember.getParticipantid()))
            {
                throw new ValidationException(AssignmentFailureReason.INVALID_ANIMAL_ID.toString());
            }

            // Make sure animal is alive on start date
            String animalId = groupMember.getParticipantid();
            Map<String, Object> rowMap = demographicsMap.get(animalId);

            Date dod = (Date) rowMap.get("death");
            Date startDate = groupMember.getDate();
            Date endDate = groupMember.getEnddate();


            if ( (dod != null) && (dod.compareTo(startDate) < 0))
            {
                throw new ValidationException(AssignmentFailureReason.START_DATE_AFTER_DEATH.toString());
            }

            // make sure animal is alive on end date
            if ( (dod != null) && (endDate != null) && (dod.compareTo(endDate) < 0))
            {
                throw new ValidationException(AssignmentFailureReason.END_DATE_AFTER_DEATH.toString());
            }

            // make sure animal is not already assigned to group
            // if objectid is null, then it is a new assignment
            if (this.groupMembers.contains(groupMember) && groupMember.getObjectid() == null)
            {
                throw new ValidationException(AssignmentFailureReason.ALREADY_IN_GROUP.toString());
            }

            // if category groups are mutually exclusive, then we need to make sure animal
            // hasn't already been assigned to another category
            if (this.category.getEnforceExclusivity().equalsIgnoreCase("Y") &&
                    this.categoryMembers.contains(groupMember) &&
                    groupMember.getObjectid() == null)
            {
                throw new ValidationException(AssignmentFailureReason.ALREADY_IN_CATEGORY.toString());

            }

            // if future dates are not allowed, then we need to make sure a future date is not being entered
            if (this.category.getAllowFutureDate().equalsIgnoreCase("N") && groupMember.getDate().after(new Date()))
            {
                throw new ValidationException(AssignmentFailureReason.FUTURE_DATE_NOT_ALLOWED.toString());
            }

            // if category has a gender restriction, then we need to validate gender
            if (this.category.getSex() != null && !this.category.getSex().equalsIgnoreCase((String) demographicsMap.get(groupMember.getParticipantid()).get("gender")))
            {
                throw new ValidationException(AssignmentFailureReason.NOT_APPLICABLE_GENDER.toString());
            }

            // if category has a species restriction, then we need to validate species
            if (this.category.getSpecies() != null)
            {
                //demographics uses 3 char species
                //animal_group_categories uses the 2 characters species code
                TableInfo speciesTable = SNPRC_EHRSchema.getInstance().getTableInfoSpecies();
                SimpleFilter speciesFilter = new SimpleFilter();
                String animal_genus = demographicsMap.get(groupMember.getParticipantid()).get("species").toString();
                String animal_species = null;

                FieldKey key = FieldKey.fromString("species_code");

                speciesFilter.addCondition(key, animal_genus, CompareType.EQUAL);



                AnimalSpecies speciesObject = new TableSelector(speciesTable, speciesFilter, null).getObject(AnimalSpecies.class);
                if (speciesObject != null)
                {
                    animal_species = speciesObject.getArcSpeciesCode();
                }

                String category_speciesCode = this.category.getSpecies();

                if (!animal_species.equalsIgnoreCase(category_speciesCode))
                {
                    throw new ValidationException(AssignmentFailureReason.NOT_APPLICABLE_SPECIES.toString() + " Id: " + groupMember.getParticipantid() + "  Species: " + animal_species);
                }

            }

            // date (startdate) and enddate must be bracketed by animal_groups start and enddate
            {
                Date today = new Date();
                TableInfo animalGroupsTable = SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups();
                SimpleFilter groupsFilter = new SimpleFilter();
                groupsFilter.addCondition(FieldKey.fromString("code"), groupMember.getGroupid(), CompareType.EQUAL);
                AnimalGroup animalGroupsObject = new TableSelector(animalGroupsTable, groupsFilter, null).getObject(AnimalGroup.class);
                // validate group
                if (animalGroupsObject == null)
                {
                    //animal group does not exist
                    throw new ValidationException(AssignmentFailureReason.GROUP_DOES_NOT_EXIST.toString());
                }
                // validate start date
                if (groupMember.getDate().before(animalGroupsObject.getDate()) )
                {
                    throw new ValidationException(AssignmentFailureReason.INVALID_DATE.toString());
                }
                // start date must be before end date
                if ( animalGroupsObject.getEndDate() != null && groupMember.getDate().after( animalGroupsObject.getEndDate()) )
                {
                    throw new ValidationException(AssignmentFailureReason.INVALID_DATE.toString());
                }
                // validate end date
                if (groupMember.getEnddate() != null && animalGroupsObject.getEndDate() != null)
                {
                    if (groupMember.getEnddate().before(animalGroupsObject.getDate()) ||  groupMember.getEnddate().after( animalGroupsObject.getEndDate()))
                    {
                        throw new ValidationException(AssignmentFailureReason.INVALID_DATE.toString());
                    }
                }

            }

            Map groupMemberAsMap = oMapper.convertValue(groupMember, CaseInsensitiveHashMap.class);
            groupMemberAsMap.remove("Id");
            groupMemberAsMap.remove("Id");
            rows.add(groupMemberAsMap);


        }
        if (!rows.isEmpty())
        {
            UserSchema schema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");

            QueryUpdateService qus = table.getUpdateService();
            for (Map<String, Object> row : rows)
            {

                List<Map<String, Object>> newrows = new ArrayList<>();
                newrows.add(row);
                try
                {
                    if (row.get("objectid") == null)
                    {
                        // insert a new row
                        qus.insertRows(this.viewContext.getUser(), this.viewContext.getContainer(), newrows, new BatchValidationException(), null, null);
                    }
                    else
                    {
                        // update existing row
                        qus.updateRows(this.viewContext.getUser(), this.viewContext.getContainer(), newrows, null, null, null);
                    }
                }
                // catch trigger script errors (BatchValidationException) and other SQL related errors
                catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException |
                        DuplicateKeyException | NullPointerException | SQLException e) {

                    throw e;
                }
            }
        }
        //return;
    }

}
