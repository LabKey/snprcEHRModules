package org.labkey.snprc_ehr.services;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.view.ViewContext;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.domain.Animal;
import org.labkey.snprc_ehr.domain.AnimalGroup;
import org.labkey.snprc_ehr.domain.AnimalGroupCategory;
import org.labkey.snprc_ehr.domain.AnimalNodePath;
import org.labkey.snprc_ehr.domain.GroupMember;
import org.labkey.snprc_ehr.domain.Node;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 7/21/2017.
 */
public class GroupsHierarchyServiceImpl implements HierarchyService
{
    private ViewContext viewContext;


    public GroupsHierarchyServiceImpl(ViewContext viewContext)
    {
        this.viewContext = viewContext;
    }


    @Override
    public List<Node> getRootNodes()
    {
        List<Node> categoryNodes = new ArrayList<Node>();
        ArrayList<AnimalGroupCategory> categories = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroupCategories(), null, null).getArrayList(AnimalGroupCategory.class);
        for (AnimalGroupCategory category : categories)
        {
            Node categoryNode = new Node();
            categoryNode.setNode("CATEGORY-" + category.getCategoryCode().toString());
            categoryNode.setText(category.getDescription());
            categoryNode.setNodeClass("category");
            categoryNodes.add(categoryNode);

        }
        return categoryNodes;
    }

    @Override
    public List<Node> getSubNodes(Node node)
    {
        List<Node> categoryGroupNodes = new ArrayList<Node>();
        try
        {
            Integer categoryCode = Integer.parseInt(node.getNode().replace("CATEGORY-", ""));
            ArrayList<AnimalGroup> categoryGroups = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups(), new SimpleFilter().addCondition("category_code", categoryCode, CompareType.EQUAL), null).getArrayList(AnimalGroup.class);
            for (AnimalGroup group : categoryGroups)
            {
                Node groupNode = new Node();
                groupNode.setNode("GROUP-" + group.getCode());
                groupNode.setText(group.getName());
                groupNode.setNodeClass("group");

                categoryGroupNodes.add(groupNode);
            }

            return categoryGroupNodes;


        }
        catch (Exception ex)
        {
            return categoryGroupNodes;
        }

    }

    @Override
    public boolean hasSubNodes(Node node)
    {
        return node.getNode().contains("CATEGORY");
    }

    @Override
    public List<Animal> getAnimals(Node node)
    {
        if (!node.getNode().contains("GROUP"))
        {
            return new ArrayList<Animal>();
        }
        String[] stringParts = node.getNode().split("-");
        try
        {

            Integer groupCode = Integer.parseInt(stringParts[1]);
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("groupid"), groupCode, CompareType.EQUAL);
            //TO DO, should we also display non-active assignments?

            {
                Date today = new Date();
                filter.addClause(new SimpleFilter.OrClause(
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null),
                        new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GT, today)
                ));
            }

            UserSchema schema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
            TableInfo table = schema.getTable("animal_group_members");

            List<Animal> animals = new ArrayList<>();
            List<GroupMember> groupMembers = new TableSelector(table, filter, null).getArrayList(GroupMember.class);
            for (GroupMember member : groupMembers)
            {

                Animal animal = new Animal();
                animal.setParticipantid(member.getParticipantid());
                animal.setId(node.getNode() + '-' + member.getId());
                animal.setText(member.getId());
                animal.setLeaf(true);


                if (!animals.contains(animal))
                {
                    animals.add(animal);
                }


            }

            TableInfo demographicsTable = schema.getTable("demographics");
            SimpleFilter animalFilter = new SimpleFilter();

            List<String> animalIds = new ArrayList<String>();
            for (Animal animal : animals)
            {
                animalIds.add(animal.getText());
            }


            animalFilter.addCondition(FieldKey.fromString("id"), animalIds, CompareType.IN);
            Map<String, Map<String, String>> demographicsMap = new HashMap<>();
            for (Map a : new TableSelector(demographicsTable, animalFilter, null).getMapCollection())
            {
                Map oneAnimalDemographicsMap = new HashMap();
                oneAnimalDemographicsMap.put("gender", a.get("gender"));
                demographicsMap.put((String) a.get("id"), oneAnimalDemographicsMap);
            }
            for (Animal animal : animals)
            {
                if (demographicsMap.containsKey(animal.getText()))
                {
                    animal.setSex(demographicsMap.get(animal.getText()).get("gender"));
                }
            }

            return animals;


        }
        catch (Exception ex)
        {
            return new ArrayList<Animal>();
        }

    }

    @Override
    public boolean isRootNode(Node node)
    {
        return this.hasSubNodes(node);

    }

    @Override
    public boolean hasAnimals(Node node)
    {
        return this.getAnimals(node).isEmpty();
    }

    @Override
    public Node getRootNode(Node node)
    {
        if (this.isRootNode(node))
        {
            return null;
        }
        Node rootNode = new Node();
        Map<String, Object> props = new HashMap<String, Object>();
        AnimalGroup group = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoAnimalGroups(), new SimpleFilter().addCondition("code", node.getNode().replace("GROUP-", ""), CompareType.EQUAL), null).getObject(AnimalGroup.class);

        rootNode.setNode("CATEGORY-" + group.getCategoryCode());
        rootNode.setNodeClass("category");

        return rootNode;
    }

    @Override
    public AnimalNodePath getNodePath(Animal animal)
    {
        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo demographicsTable = userSchema.getTable("demographics");
        SimpleFilter demographicsFilter = new SimpleFilter();

        demographicsFilter.addCondition(FieldKey.fromString("id"), animal.getParticipantid(), CompareType.EQUAL);

        Animal animalRecord = new TableSelector(demographicsTable, demographicsFilter, null).getObject(Animal.class);


        List<Node> locationsPath = new ArrayList<Node>();

        AnimalNodePath animalNodePath = new AnimalNodePath();
        animalNodePath.setAnimalId(animal.getParticipantid());
        animalNodePath.setLocations(locationsPath);


        String animalId = animal.getParticipantid();

        if (animalRecord == null)
        {
            TableInfo idHistoryTable = userSchema.getTable("idHistory");
            SimpleFilter idHistoryRecordsFilter = new SimpleFilter();
            idHistoryRecordsFilter.addCondition(FieldKey.fromString("value"), animal.getParticipantid(), CompareType.EQUAL);
            try
            {
                Map secondaryId = new TableSelector(idHistoryTable, idHistoryRecordsFilter, null).getObject(Map.class);
                if (secondaryId == null)
                {
                    return animalNodePath;
                }
                animalId = (String) secondaryId.get("id");


            }
            catch (Exception ex)
            {
                return animalNodePath;
            }

        }
        SimpleFilter currentAssignmentFilter = new SimpleFilter();
        Date today = new Date();
        currentAssignmentFilter.addClause(new SimpleFilter.OrClause(
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GT, today)
        ));
        currentAssignmentFilter.addCondition(FieldKey.fromString("participantid"), animalId, CompareType.EQUAL);
        TableInfo groupMembersTable = userSchema.getTable("animal_group_members");
        ArrayList<GroupMember> activeAssignments = new TableSelector(groupMembersTable, currentAssignmentFilter, null).getArrayList(GroupMember.class);
        if (activeAssignments == null || activeAssignments.isEmpty())
        {
            return animalNodePath;
        }
        Node node = new Node();
        GroupMember firstActiveAssignment = activeAssignments.get(0);
        node.setNode("GROUP-" + firstActiveAssignment.getGroupid());

        locationsPath.add(this.getRootNode(node));
        locationsPath.add(node);
        animalNodePath.setAnimalId("GROUP-" + firstActiveAssignment.getGroupid() + "-" + animalId);


        return animalNodePath;
    }
}
