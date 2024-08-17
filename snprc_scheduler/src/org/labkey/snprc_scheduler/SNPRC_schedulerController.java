package org.labkey.snprc_scheduler;

import org.json.JSONObject;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ApiUsageException;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleRedirectAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.snd.SNDService;
import org.labkey.api.snprc_scheduler.SNPRC_schedulerService;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.security.SNPRC_schedulerEditorsPermission;
import org.labkey.snprc_scheduler.security.SNPRC_schedulerReadersPermission;
import org.springframework.beans.PropertyValues;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

import java.text.ParseException;
import java.time.DateTimeException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.apache.commons.lang3.StringUtils.isNotBlank;


public class SNPRC_schedulerController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(SNPRC_schedulerController.class);
    public static final String NAME = "snprc_scheduler";

    public SNPRC_schedulerController()
    {
        setActionResolver(_actionResolver);
    }

    //http://localhost:8080/labkey/snprc_scheduler/snprc/Begin.view?
    @RequiresPermission(SNPRC_schedulerReadersPermission.class)
    //@RequiresPermission(ReadPermission.class)
    public class BeginAction extends SimpleRedirectAction
    {
        @Override
        public URLHelper getRedirectURL(Object o)
        {
            return new ActionURL(NAME, "app", getContainer());
        }
    }

    // http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveTimelines.view?ProjectObjectId=55130483-F7DD-4366-8FA3-55ED58115482
    @RequiresPermission(SNPRC_schedulerReadersPermission.class)
    public class getActiveTimelinesAction extends ReadOnlyApiAction<Timeline>
    {
        @Override
        public ApiResponse execute(Timeline timeline, BindException errors)
        {
            Map<String, Object> props = new HashMap<>();
            if (timeline.getProjectObjectId() != null)
            {
                try
                {
                    List<JSONObject> timelines = SNPRC_schedulerService.get().getActiveTimelines(getContainer(), getUser(),
                            timeline.getProjectObjectId(), new BatchValidationException());

                    props.put("success", true);
                    props.put("rows", timelines);
                }
                catch (ApiUsageException e)
                {
                    props.put("success", false);
                    props.put("message", e.getMessage());
                }
            }
            else
            {
                props.put("success", false);
                props.put("message", "ProjectObjectId is required");
            }
            return new ApiSimpleResponse(props);
        }
    }

    // Get Timelines, timelineItems, and animal data for a given species with procedures scheduled
    // on the specified date.

    @RequiresPermission(SNPRC_schedulerReadersPermission.class)
    public class getScheduledTimelinesForSpeciesAction extends ReadOnlyApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm form, BindException errors)
        {
            String species, dateString;
            Date date;

            ActionURL url = getViewContext().getActionURL();
            Map<String, Object> props = new HashMap<>();

            List<JSONObject> timelines;
            if (isNotBlank(url.getParameter("species")) && isNotBlank(url.getParameter("date")) )
            {
                try
                {
                    species = url.getParameter("species");
                    dateString = url.getParameter("date");

                     // assume current date if date is not passed in
                    date = (dateString == null ? new Date() : DateUtil.parseDateTime(dateString, Timeline.TIMELINE_DATE_FORMAT));
                    if (species != null && date != null)
                    {
                        timelines = SNPRC_schedulerService.get().getScheduledTimelinesForSpecies(getContainer(), getUser(),
                                species, date, new BatchValidationException());

                        props.put("success", true);
                        props.put("rows", timelines);
                    }
                    else
                    {
                        props.put("success", false);
                        props.put("message", "Species and Schedule Date are required.");
                    }
                }
                catch (ParseException e)
                {
                    props.put("success", false);
                    props.put("message", "Bad date format. Required format is " + Timeline.TIMELINE_DATE_FORMAT);
                }
                catch (Exception e)
                {
                    props.put("success", false);
                    props.put("message", e.getMessage());
                }
            }
            else
            {
                props.put("success", false);
                props.put("message", "Species and Schedule Date are required.");
            }

            return new ApiSimpleResponse(props);
        }

    }

    /**
     * getActiveProjectsAction
     * <p>
     * call without parameters returns the entire list of active research projects from the SND module
     * e.g. - http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveProjects.view?
     * <p>
     * call with the projectId & revisionNum to return a single project
     * e.g. - http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveProjects.view?ProjectId=18&RevisionNum=0
     * <p>
     * call with 2-character species code & one of the following project types: Clinical, Maintenance, Behavior, returns
     *  the corresponding project
     *  e.g. - http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveProjects.view?Species=PC&ProjectType=Clinical
     * <p>
     * call with ParentObjectId (object ID of project) to return a single project based on its objectId value
     *  e.g. - http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveProjects.view?ParentObjectId=D64C462A-33DA-485C-A72D-510EBE5CAC48
     */

    @RequiresPermission(SNPRC_schedulerReadersPermission.class)
    public class getActiveProjectsAction extends ReadOnlyApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<>();
            List<JSONObject> jsonProjects = new ArrayList<>();
            PropertyValues pv = getPropertyValues();
            String projectId;
            String revisionNum;
            String projectType;
            String species;  // two-character species code (referenceId.species.species.code)
            String parentObjectId;
            String eventDateString;

            Date eventDate = null;

            try
            {
                ArrayList<SimpleFilter> filters = new ArrayList<>();

                // see if a specific project is requested
                if (!pv.isEmpty())
                {
                    projectType = pv.contains("ProjectType") ? pv.getPropertyValue("ProjectType").getValue().toString(): null;
                    species = pv.contains("Species") ? pv.getPropertyValue("Species").getValue().toString() : null;
                    projectId = pv.contains("ProjectId") ? pv.getPropertyValue("ProjectId").getValue().toString() : null;
                    revisionNum = pv.contains("RevisionNum") ?pv.getPropertyValue("RevisionNum").getValue().toString() : null;
                    parentObjectId = pv.contains("ParentObjectId") ?pv.getPropertyValue("ParentObjectId").getValue().toString() : null;
                    eventDateString = pv.contains("EventDate") ?pv.getPropertyValue("EventDate").getValue().toString() : null;

                    if (projectType != null && "Maintenance Behavior Clinical".contains(projectType) && species != null)
                    {
                        // project is non-research
                        filters.add(new SimpleFilter(FieldKey.fromParts("ProjectType","Description"), projectType, CompareType.EQUAL));
                        filters.add(new SimpleFilter(FieldKey.fromParts("ReferenceId","species"), species, CompareType.EQUAL));
                    }
                    else if (projectId != null && revisionNum != null)
                    {
                        // specific project requested
                        try
                        {
                            // if a specific project is requested, add it to the filters ArrayList
                            filters.add(new SimpleFilter(FieldKey.fromParts("ProjectId"), Integer.parseInt(projectId), CompareType.EQUAL));
                            filters.add(new SimpleFilter(FieldKey.fromParts("RevisionNum"), Integer.parseInt(revisionNum), CompareType.EQUAL));

                        }
                        catch (NumberFormatException | NullPointerException e)
                        {
                            throw new ValidationException("ProjectId and RevisionNum must be numeric");
                        }
                    }
                    else if (parentObjectId != null )
                    {
                        // specific project requested by ParentObjectId
                        filters.add(new SimpleFilter(FieldKey.fromParts("ObjectId"), parentObjectId, CompareType.EQUAL));
                    }
                    else
                    {
                        // add filters to return all research projects
                        filters.add(new SimpleFilter(FieldKey.fromParts("ProjectType","Description"), "Research", CompareType.EQUAL));
                    }

                    if (eventDateString != null) {
                        try {
                            eventDate = DateUtil.parseDateTime(eventDateString, Timeline.TIMELINE_DATE_FORMAT);
                        } catch (ParseException pe) {
                            throw new ValidationException("EventDate must be a valid Date");
                        }
                    }
                }

                List<Map<String, Object>> projects = SNDService.get().getActiveProjects(getContainer(), getUser(), filters, true, eventDate);

                if (projects.size() > 0)
                {
                    //   SND returned the project table data, need to add Iacuc and CostAccount fields from ehr.project table
                    UserSchema schema = QueryService.get().getUserSchema(getUser(), getContainer(), "ehr");
                    TableInfo ti = schema.getTable("project");

                    for (Map<String, Object> project : projects)
                    {
                        JSONObject jsonProject = new JSONObject(project);
                        jsonProject.put("ProjectObjectId", jsonProject.getString("objectId"));

                        SimpleFilter filter = new SimpleFilter();
                        filter.addCondition(FieldKey.fromString("project"), project.get("referenceId"), CompareType.EQUAL);

                        //project (AKA chargeId) is the PK - should only get one row back
                        Map<String, Object> ehrProject = new TableSelector(ti, filter, null).getMap(); //getObject(Map.class);

                        if (ehrProject != null)
                        {
                            jsonProject.put("Iacuc", ehrProject.get("protocol"));
                            jsonProject.put("CostAccount", ehrProject.get("account"));
                            jsonProject.put("Species", ehrProject.get("species"));
                        }
                        jsonProjects.add(jsonProject);

                    }
                    props.put("success", true);
                    props.put("rows", jsonProjects);
                }
                else
                {
                    props.put("success", false);
                    props.put("message", "No Active Projects");
                }
            }
            catch (ValidationException e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }

            return new ApiSimpleResponse(props);
        }
    }

    // http://localhost:8080/labkey/snprc_scheduler/snprc/updateTimeline.view?
    @RequiresPermission(SNPRC_schedulerEditorsPermission.class)
    public class updateTimelineAction extends MutatingApiAction<SimpleApiJsonForm>
    {
        @Override
        public void validateForm(SimpleApiJsonForm form, Errors errors)
        {
            JSONObject json = form.getJsonObject();
            if (json == null)
            {
                errors.reject(ERROR_MSG, "Missing json parameter.");
                return;
            }

            // make sure timelineId is an integer or is null
            if (json.has("TimelineId") && !json.isNull(Timeline.TIMELINE_ID))
            {
                try
                {
                    json.getInt("TimelineId");
                }
                catch (Exception e)
                {
                    errors.reject(ERROR_MSG, "timelineId is present but not a valid integer.");
                }
            }
        }

        @Override
        public ApiResponse execute(SimpleApiJsonForm form, BindException errors)
        {
            ApiSimpleResponse response = new ApiSimpleResponse();
            JSONObject json = form.getJsonObject();
            JSONObject responseJson = null;

            BatchValidationException err = new BatchValidationException();
            try
            {
                responseJson = SNPRC_schedulerService.get().saveTimelineData(getContainer(), getUser(), json, err);
            }
            catch (RuntimeException e)
            {
                errors.reject(ERROR_MSG, e.getMessage());
            }

            if (err.hasErrors())
            {
                response.put("success", false);
                response.put("responseText", err.getMessage());
            }
            else
            {
                response.put("success", true);
                response.put("rows", responseJson);
            }

            return response;
        }
    }
}