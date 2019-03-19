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

import org.json.JSONObject;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.WebPartView;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.domain.Animal;
import org.labkey.snprc_ehr.domain.AnimalNodePath;
import org.labkey.snprc_ehr.domain.Node;
import org.labkey.snprc_ehr.services.GroupsHierarchyServiceImpl;
import org.labkey.snprc_ehr.services.HierarchyService;
import org.labkey.snprc_ehr.services.LocationHierarchyServiceImpl;
import org.labkey.snprc_ehr.services.ProtocolHierarchyServiceImpl;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 4/10/2017.
 */
public class AnimalsHierarchyController extends SpringActionController
{

    public static final String NAME = "AnimalsHierarchy";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(AnimalsHierarchyController.class);


    public AnimalsHierarchyController()
    {
        setActionResolver(_actionResolver);
    }

    public static class ViewByForm
    {
        String viewBy;

        public String getViewBy()
        {
            return viewBy;
        }

        public void setViewBy(String viewBy)
        {
            this.viewBy = viewBy;
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class GetViewAction extends SimpleViewAction<ViewByForm>
    {

        @Override
        public ModelAndView getView(ViewByForm form, BindException errors)
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/AnimalsHierarchy.jsp", this);
            String viewBy = form.getViewBy();
            if (viewBy == null) viewBy = "locations";
            view.setTitle("Animal Tree View Navigation");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);

            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("View Animals");
        }
    }


    @RequiresPermission(ReadPermission.class)
    public class GetHierarchy extends ReadOnlyApiAction<Node>
    {
        @Override
        public Object execute(Node nodeForm, BindException errors)
        {
            HierarchyService hierarchyService = getHierarchyService(nodeForm.getViewBy());

            if (nodeForm.getNode() == null)
            {
                List<Node> rootNodes = hierarchyService.getRootNodes();

                List<JSONObject> jsonRootLocations = new ArrayList<>();
                for (Node node : rootNodes)
                {
                    jsonRootLocations.add(node.toJSON());
                }

                Map props = new HashMap();


                props.put("nodes", jsonRootLocations);


                return new ApiSimpleResponse(props);

            }

            //Root node is given,
            //1. load subNodes
            //2. load assigned animals if any
            nodeForm.setNode(nodeForm.getNode());
            List<Node> subNodes = hierarchyService.getSubNodes(nodeForm);
            List<Animal> animals = hierarchyService.getAnimals(nodeForm);

            List<JSONObject> jsonRootLocations = new ArrayList<>();
            for (Node node : subNodes)
            {
                jsonRootLocations.add(node.toJSON());
            }

            for (Animal animal : animals)
            {
                jsonRootLocations.add(animal.toJSON());
            }

            Map props = new HashMap();


            props.put("nodes", jsonRootLocations);


            return new ApiSimpleResponse(props);


        }


    }

    public static class AnimalsBy
    {
        private String value;
        private String by;
        private boolean includeAllAnimals;

        public String getValue()
        {
            return value;
        }

        public void setValue(String value)
        {
            this.value = value;
        }

        public String getBy()
        {
            return by;
        }

        public void setBy(String by)
        {
            this.by = by;
        }

        public boolean isIncludeAllAnimals()
        {
            return includeAllAnimals;
        }

        public void setIncludeAllAnimals(boolean includeAllAnimals)
        {
            this.includeAllAnimals = includeAllAnimals;
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class GetAnimals extends ReadOnlyApiAction<AnimalsBy>
    {
        @Override
        public Object execute(AnimalsBy animalsBy, BindException errors)
        {
            List<Animal> animals = new ArrayList<Animal>();
            Node node = new Node();
            switch (animalsBy.getBy().toLowerCase())
            {
                case "location":
                    LocationHierarchyServiceImpl locationHierarchyService = new LocationHierarchyServiceImpl(this.getViewContext());

                    node.setNode(animalsBy.getValue());
                    node.setIncludeAllAnimals(animalsBy.isIncludeAllAnimals());
                    if (locationHierarchyService.isRootNode(node))
                    {
                        for (Node n : locationHierarchyService.getSubNodes(node))
                        {
                            n.setIncludeAllAnimals(animalsBy.isIncludeAllAnimals());
                            animals.addAll(locationHierarchyService.getAnimals(n));
                        }

                    }
                    else
                    {
                        animals = locationHierarchyService.getAnimals(node);
                    }

                    break;
                case "protocol":
                    ProtocolHierarchyServiceImpl protocolHierarchyService = new ProtocolHierarchyServiceImpl(this.getViewContext());
                    node.setNode(animalsBy.getValue());
                    node.setIncludeAllAnimals(animalsBy.isIncludeAllAnimals());
                    animals = protocolHierarchyService.getAnimals(node);
                    break;
                case "category":
                case "group":
                    GroupsHierarchyServiceImpl groupsHierarchyService = new GroupsHierarchyServiceImpl(this.getViewContext());
                    node.setNode(animalsBy.getValue());
                    node.setIncludeAllAnimals(animalsBy.isIncludeAllAnimals());
                    if (groupsHierarchyService.isRootNode(node))
                    {
                        for (Node n : groupsHierarchyService.getSubNodes(node))
                        {
                            n.setIncludeAllAnimals(animalsBy.isIncludeAllAnimals());
                            animals.addAll(groupsHierarchyService.getAnimals(n));
                        }
                    }
                    else
                    {
                        animals = groupsHierarchyService.getAnimals(node);
                    }

                    break;


            }
            List<JSONObject> jsonRootLocations = new ArrayList<>();
            for (Animal animal : animals)
            {
                jsonRootLocations.add(animal.toJSON());
            }

            Map props = new HashMap();


            props.put("animals", jsonRootLocations);


            return new ApiSimpleResponse(props);

        }
    }

    @RequiresPermission(ReadPermission.class)
    public class GetLocationsPath extends ReadOnlyApiAction<Animal>
    {
        @Override
        public ApiResponse execute(Animal animal, BindException errors)
        {
            HierarchyService hierarchyService = getHierarchyService(animal.getViewBy());

            AnimalNodePath animalNodePath = hierarchyService.getNodePath(animal);

            List<JSONObject> jsonLocationsPath = new ArrayList<>();


            for (Node node : animalNodePath.getLocations())
            {
                jsonLocationsPath.add(node.toJSON());
            }

            Map props = new HashMap();


            props.put("path", jsonLocationsPath);
            props.put("animal", animalNodePath.getAnimalId());


            return new ApiSimpleResponse(props);

        }
    }

    private HierarchyService getHierarchyService(String viewBy)
    {
        HierarchyService hierarchyService;
        if (viewBy == null)
        {
            return new LocationHierarchyServiceImpl(this.getViewContext());
        }
        switch (viewBy)
        {
            case "locations":
                return new LocationHierarchyServiceImpl(this.getViewContext());
            case "groups":
                return new GroupsHierarchyServiceImpl(this.getViewContext());
            case "protocols":
                return new ProtocolHierarchyServiceImpl(this.getViewContext());
            default:
                return new GroupsHierarchyServiceImpl(this.getViewContext());
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class GetReportsAction extends ReadOnlyApiAction<Object>
    {
        public Object execute(Object o, BindException errors)
        {


            TableInfo reportsTable = SNPRC_EHRSchema.getInstance().getTableInfoReports();
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("visible"), 1, CompareType.EQUAL);
            Sort sort = new Sort();
            sort.appendSortColumn(FieldKey.fromString("category"), Sort.SortDirection.ASC, false);
            sort.appendSortColumn(FieldKey.fromString("reporttitle"), Sort.SortDirection.ASC, false);
            sort.appendSortColumn(FieldKey.fromString("sort_order"), Sort.SortDirection.ASC, false);


            List<Map> reports = new TableSelector(reportsTable, filter, sort).getArrayList(Map.class);

            JSONObject reportsJson = new JSONObject();

            for (Map m : reports)
            {
                JSONObject reportObject = new JSONObject();

                reportObject.put("title", m.get("reporttitle"));
                reportObject.put("type", m.get("reporttype"));
                reportObject.put("schemaName", m.get("schemaname"));
                reportObject.put("queryName", m.get("queryname"));
                reportObject.put("viewName", m.get("viewname"));
                reportsJson.append((String) m.get("category"), reportObject);

            }

            Map props = new HashMap();
            props.put("reports", reportsJson);
            return new ApiSimpleResponse(props);
        }
    }
}