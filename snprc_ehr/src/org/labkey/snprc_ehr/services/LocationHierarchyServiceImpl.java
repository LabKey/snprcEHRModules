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
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 4/11/2017.
 */

/**
 * EHR schema doesn't offer a hierarchical view of SNPRC locations (@see CAMP)
 * <p>
 * This service is an attempt to recover the original hierarchy, though not backed by the underlying schema
 * <p>
 * Will be making a lot of assumptions, will fix any issues that might arise
 */
public class LocationHierarchyServiceImpl implements HierarchyService
{
    private ViewContext viewContext;

    public LocationHierarchyServiceImpl(ViewContext viewContext)
    {
        this.viewContext = viewContext;
    }

    /**
     * get root locations
     *
     * @return root locations as a list
     */
    @Override
    public List<Node> getRootNodes()
    {
        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        Sort sort = new Sort();

        sort.insertSortColumn(FieldKey.fromString("room"), Sort.SortDirection.ASC);

        List<Map> maps = new TableSelector(housingTable, currentHousingRecordsFilter, sort).getArrayList(Map.class);

        List<Node> rootNodes = new ArrayList<>();
        List<Node> alreadySeenNodes = new ArrayList<Node>();

        for (Map map : maps)
        {
            Node node = new Node();
            node.setNode((String) map.get("room"));
            node.setText((String) map.get("room"));
            node.setNodeClass("location");
            if (this.isRootNode(node))
            {
                if (!alreadySeenNodes.contains(node))
                {
                    rootNodes.add(node);
                    alreadySeenNodes.add(node);
                }
            }
            else
            {
                Node rootNode = this.getRootNode(node);
                if (!alreadySeenNodes.contains(rootNode))
                {
                    rootNodes.add(rootNode);
                    alreadySeenNodes.add(rootNode);
                }
            }
        }

        rootNodes.sort((o1, o2) ->
        {
            try
            {
                double location1RoomAsDouble = Double.parseDouble(o1.getNode());
                double location2RoomAsDouble = Double.parseDouble(o2.getNode());
                if (location1RoomAsDouble == location2RoomAsDouble)
                {
                    return 0;
                }
                if (location1RoomAsDouble > location2RoomAsDouble)
                {
                    return 1;
                }
                return -1;


            }
            catch (Exception ex)
            {
                return 0;
            }


        });

        return rootNodes;
    }

    @Override
    public List<Node> getSubNodes(Node node)
    {
        if (!this.isRootNode(node))
        {
            return Collections.emptyList();
        }

        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("room"), node.getNode(), CompareType.NEQ);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("room"), node.getNode().substring(0, node.getNode().length() - 2), CompareType.STARTS_WITH);
        Sort sort = new Sort();
        sort.insertSortColumn(FieldKey.fromString("room"), Sort.SortDirection.ASC);
        List<Map> maps = new TableSelector(housingTable, currentHousingRecordsFilter, sort).getArrayList(Map.class);

        List<Node> subNodes = new ArrayList<>();
        List<Node> alreadySeenNode = new ArrayList<>();

        for (Map m : maps)
        {
            Node l = new Node();
            l.setNode((String) m.get("room"));
            l.setText((String) m.get("room"));
            l.setNodeClass("location");

            if (!alreadySeenNode.contains(l))
            {
                subNodes.add(l);
                alreadySeenNode.add(l);
            }
        }
        return subNodes;

    }

    @Override
    public List<Animal> getAnimals(Node node)
    {

        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("room"), node.getNode(), CompareType.EQUAL);
        Sort sort = new Sort();
        sort.insertSortColumn(FieldKey.fromString("participantid"), Sort.SortDirection.ASC);

        List<Animal> animals = new TableSelector(housingTable, currentHousingRecordsFilter, sort).getArrayList(Animal.class);

        TableInfo demographicsTable = userSchema.getTable("demographics");
        SimpleFilter filter = new SimpleFilter();

        List<String> animalIds = new ArrayList<String>();
        for (Animal animal : animals)
        {
            animalIds.add(animal.getId());
        }


        filter.addCondition(FieldKey.fromString("id"), animalIds, CompareType.IN);
        Map<String, Map<String, String>> demographicsMap = new HashMap<>();
        for (Map a : new TableSelector(demographicsTable, filter, null).getMapCollection())
        {
            Map oneAnimalDemographicsMap = new HashMap();
            oneAnimalDemographicsMap.put("gender", a.get("gender"));
            demographicsMap.put((String) a.get("id"), oneAnimalDemographicsMap);
        }
        for (Animal animal : animals)
        {
            if (demographicsMap.containsKey(animal.getId()))
            {
                animal.setSex(demographicsMap.get(animal.getId()).get("gender"));
            }
        }

        return animals;
    }


    /**
     * @param node
     * @return true if node is a root node, false otherwise
     */
    @Override
    public boolean isRootNode(Node node)
    {
        return this.getRootNode(node) == null;
    }


    @Override
    public boolean hasAnimals(Node node)
    {
        return !this.getAnimals(node).isEmpty();
    }

    @Override
    public Node getRootNode(Node node)
    {
        if (node.getNode() == null || node.getNode().substring(node.getNode().length() - 3).equals(".00"))
        {
            return null;
        }

        Node rootNode = new Node();

        rootNode.setNode(node.getNode().replaceAll("\\.[0-9]+", ".00"));
        rootNode.setText(node.getNode().replaceAll("\\.[0-9]+", ".00"));


        return rootNode;
    }

    @Override
    public boolean hasSubNodes(Node node)
    {
        return !this.getSubNodes(node).isEmpty();
    }

    @Override
    public AnimalNodePath getNodePath(Animal animal)
    {
        UserSchema userSchema = QueryService.get().getUserSchema(this.viewContext.getUser(), this.viewContext.getContainer(), "study");
        TableInfo housingTable = userSchema.getTable("housing");
        SimpleFilter currentHousingRecordsFilter = new SimpleFilter();
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
        currentHousingRecordsFilter.addCondition(FieldKey.fromString("participantid"), animal.getParticipantid(), CompareType.EQUAL);

        Map map = new TableSelector(housingTable, currentHousingRecordsFilter, null).getObject(Map.class);

        AnimalNodePath animalNodePath = new AnimalNodePath();
        animalNodePath.setAnimalId(animal.getParticipantid());

        List<Node> locationsPath = new ArrayList<Node>();
        animalNodePath.setLocations(locationsPath);

        if (map == null)
        {
            //the id specified might be a secondary id, let's check it before returning an empty list
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
                currentHousingRecordsFilter = new SimpleFilter();
                currentHousingRecordsFilter.addCondition(FieldKey.fromString("enddate"), null, CompareType.ISBLANK);
                currentHousingRecordsFilter.addCondition(FieldKey.fromString("participantid"), secondaryId.get("id"), CompareType.EQUAL);
                map = new TableSelector(housingTable, currentHousingRecordsFilter, null).getObject(Map.class);
                if (map == null)
                {
                    return animalNodePath;
                }
                animalNodePath.setAnimalId((String) secondaryId.get("id"));
            }
            catch (Exception ex)
            {
                return animalNodePath; //if for some reason, the query above returns multiple rows
            }
        }

        Node node = new Node();
        node.setNode((String) map.get("room"));
        node.setText((String) map.get("room"));
        node.setNodeClass("location");
        if (this.isRootNode(node))
        {
            locationsPath.add(node);
            return animalNodePath;
        }
        else
        {
            locationsPath.add(this.getRootNode(node));
            locationsPath.add(node);
        }
        return animalNodePath;
    }
}
