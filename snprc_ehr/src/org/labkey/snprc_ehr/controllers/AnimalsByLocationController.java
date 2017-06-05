package org.labkey.snprc_ehr.controllers;

import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
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
import org.labkey.snprc_ehr.domain.AnimalLocationPath;
import org.labkey.snprc_ehr.domain.Location;
import org.labkey.snprc_ehr.services.LocationsService;
import org.labkey.snprc_ehr.services.LocationsServiceImpl;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 4/10/2017.
 */
public class AnimalsByLocationController extends SpringActionController
{

    public static final String NAME = "AnimalsByLocation";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(AnimalsByLocationController.class);

    public AnimalsByLocationController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public class GetViewAction extends SimpleViewAction<Object>
    {

        @Override
        public ModelAndView getView(Object form, BindException errors) throws Exception
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/AnimalsByLocation.jsp", this);
            view.setTitle("View Animals By Location");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("View Animals By Location");
        }
    }


    @RequiresPermission(ReadPermission.class)
    public class GetHierarchy extends ApiAction<Location>
    {
        @Override
        public Object execute(Location locationForm, BindException errors) throws Exception
        {

            LocationsServiceImpl locationsService = new LocationsServiceImpl(this.getViewContext());

            if (locationForm.getNode() == null)
            {
                List<Location> rootLocations = locationsService.getRootLocations();

                List<JSONObject> jsonRootLocations = new ArrayList<>();
                for (Location location : rootLocations)
                {
                    jsonRootLocations.add(location.toJSON());
                }

                Map props = new HashMap();


                props.put("nodes", jsonRootLocations);


                return new ApiSimpleResponse(props);

            }

            //Root location is given,
            //1. load subLocations
            //2. load assigned animals if any
            locationForm.setRoom(locationForm.getNode());
            List<Location> subLocations = locationsService.getSubLocations(locationForm);
            List<Animal> animals = locationsService.getAnimals(locationForm);

            List<JSONObject> jsonRootLocations = new ArrayList<>();
            for (Location location : subLocations)
            {
                jsonRootLocations.add(location.toJSON());
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

    @RequiresPermission(ReadPermission.class)
    public class GetLocationsPath extends ApiAction<Animal>
    {
        @Override
        public ApiResponse execute(Animal animal, BindException errors) throws Exception
        {
            LocationsService locationsService = new LocationsServiceImpl(this.getViewContext());
            AnimalLocationPath animalLocationPath = locationsService.getLocationsPath(animal);

            List<JSONObject> jsonLocationsPath = new ArrayList<>();


            for (Location location : animalLocationPath.getLocations())
            {
                jsonLocationsPath.add(location.toJSON());
            }

            Map props = new HashMap();


            props.put("path", jsonLocationsPath);
            props.put("animal", animalLocationPath.getAnimalId());


            return new ApiSimpleResponse(props);

        }
    }

    @RequiresPermission(ReadPermission.class)
    public class GetReportsAction extends ApiAction<Object>
    {
        public Object execute(Object o, BindException errors)
        {


            TableInfo reportsTable = SNPRC_EHRSchema.getInstance().getTableInfoReports();
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("visible"), 1, CompareType.EQUAL);
            Sort sort = new Sort();
            sort.appendSortColumn(FieldKey.fromString("category"), Sort.SortDirection.ASC, false);
            sort.appendSortColumn(FieldKey.fromString("sort_order"), Sort.SortDirection.ASC, false);
            sort.appendSortColumn(FieldKey.fromString("reportname"), Sort.SortDirection.ASC, false);


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