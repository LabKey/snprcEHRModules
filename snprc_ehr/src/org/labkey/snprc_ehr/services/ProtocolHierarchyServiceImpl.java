package org.labkey.snprc_ehr.services;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.view.ViewContext;
import org.labkey.snprc_ehr.domain.Animal;
import org.labkey.snprc_ehr.domain.AnimalNodePath;
import org.labkey.snprc_ehr.domain.Node;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 7/24/2017.
 */
public class ProtocolHierarchyServiceImpl implements HierarchyService
{
    private ViewContext viewContext;

    public ProtocolHierarchyServiceImpl(ViewContext viewContext)
    {
        this.viewContext = viewContext;
    }

    @Override
    public List<Node> getRootNodes()
    {
        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo assignmentTable = userSchema.getTable("assignment");
        SimpleFilter currentAssignmentsRecordsFilter = new SimpleFilter();
        currentAssignmentsRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentAssignmentsRecordsFilter.addCondition(FieldKey.fromString("assignmentStatus"), "A", CompareType.EQUAL);
        Sort sort = new Sort();

        sort.insertSortColumn(FieldKey.fromString("protocol"), Sort.SortDirection.ASC);

        List<Map> maps = new TableSelector(assignmentTable, currentAssignmentsRecordsFilter, sort).getArrayList(Map.class);

        List<Node> rootNodes = new ArrayList<>();
        List<Node> alreadySeenNodes = new ArrayList<Node>();

        for (Map map : maps)
        {
            Node node = new Node();
            node.setNode((String) map.get("protocol"));
            node.setText((String) map.get("protocol"));
            node.setNodeClass("protocol");
            if (!alreadySeenNodes.contains(node))
            {
                rootNodes.add(node);
                alreadySeenNodes.add(node);
            }
        }
        return rootNodes;
    }

    @Override
    public List<Node> getSubNodes(Node node)
    {
        return new ArrayList<Node>();
    }

    @Override
    public boolean hasSubNodes(Node node)
    {
        return false;
    }

    @Override
    public List<Animal> getAnimals(Node node)
    {
        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo assignmentTable = userSchema.getTable("assignment");
        SimpleFilter currentAssignmentRecordsFilter = new SimpleFilter();
        currentAssignmentRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentAssignmentRecordsFilter.addCondition(FieldKey.fromString("protocol"), node.getNode(), CompareType.EQUAL);

        Sort sort = new Sort();
        sort.insertSortColumn(FieldKey.fromString("participantid"), Sort.SortDirection.ASC);

        List<Animal> animals = new TableSelector(assignmentTable, currentAssignmentRecordsFilter, sort).getArrayList(Animal.class);
        List<Animal> distinctAnimals = new ArrayList<Animal>();
        List<String> animalIds = new ArrayList<String>();

        for (Animal animal : animals)
        {
            animal.setText(animal.getId());
            animal.setId(node.getNode() + '-' + animal.getId());
            animal.setLeaf(true);
            if (!distinctAnimals.contains(animal))
            {
                distinctAnimals.add(animal);
            }
            animalIds.add(animal.getText());
        }

        TableInfo demographicsTable = userSchema.getTable("demographics");
        SimpleFilter filter = new SimpleFilter();

        filter.addCondition(FieldKey.fromString("id"), animalIds, CompareType.IN);
        Map<String, Map<String, String>> demographicsMap = new HashMap<>();
        for (Map a : new TableSelector(demographicsTable, filter, null).getMapCollection())
        {
            Map oneAnimalDemographicsMap = new HashMap();
            oneAnimalDemographicsMap.put("gender", a.get("gender"));
            demographicsMap.put((String) a.get("id"), oneAnimalDemographicsMap);
        }
        for (Animal animal : distinctAnimals)
        {
            if (demographicsMap.containsKey(animal.getText()))
            {
                animal.setSex(demographicsMap.get(animal.getText()).get("gender"));
            }
        }

        return distinctAnimals;
    }

    @Override
    public boolean isRootNode(Node node)
    {
        return true;
    }

    @Override
    public boolean hasAnimals(Node node)
    {
        return true;
    }

    @Override
    public Node getRootNode(Node node)
    {
        return null;
    }

    @Override
    public AnimalNodePath getNodePath(Animal animal)
    {


        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo demographicsTable = userSchema.getTable("demographics");
        SimpleFilter demographicsFilter = new SimpleFilter();

        demographicsFilter.addCondition(FieldKey.fromString("id"), animal.getParticipantid(), CompareType.EQUAL);

        Animal animalDemographicsRecord = new TableSelector(demographicsTable, demographicsFilter, null).getObject(Animal.class);


        List<Node> locationsPath = new ArrayList<Node>();

        AnimalNodePath animalNodePath = new AnimalNodePath();
        animalNodePath.setAnimalId(animal.getParticipantid());
        animalNodePath.setLocations(locationsPath);


        String animalId = animal.getParticipantid();

        if (animalDemographicsRecord == null)
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
                return animalNodePath; //if for some reason, the query above returns multiple rows
            }

        }

        TableInfo assignmentTable = userSchema.getTable("assignment");
        SimpleFilter currentAssignmentRecordsFilter = new SimpleFilter();
        currentAssignmentRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentAssignmentRecordsFilter.addCondition(FieldKey.fromString("participantid"), animalId, CompareType.EQUAL);
        List<Map> currentAnimalAssignments = new TableSelector(assignmentTable, currentAssignmentRecordsFilter, null).getArrayList(Map.class);

        if (currentAnimalAssignments == null || currentAnimalAssignments.isEmpty())
        {
            return animalNodePath;
        }
        Map firstCurrentAnimalAssignment = currentAnimalAssignments.get(0);

        Node node = new Node();
        node.setNode((String) firstCurrentAnimalAssignment.get("protocol"));

        locationsPath.add(node);
        animalNodePath.setAnimalId(firstCurrentAnimalAssignment.get("protocol") + "-" + animalId);


        return animalNodePath;
    }
}
