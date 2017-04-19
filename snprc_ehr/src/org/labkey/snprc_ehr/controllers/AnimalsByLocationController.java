package org.labkey.snprc_ehr.controllers;

import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.WebPartView;
import org.labkey.snprc_ehr.domain.Animal;
import org.labkey.snprc_ehr.domain.Location;
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
}
