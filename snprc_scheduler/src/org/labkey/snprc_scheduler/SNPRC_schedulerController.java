package org.labkey.snprc_scheduler;

import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.ApiUsageException;
import org.labkey.api.action.RedirectAction;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.snd.SNDService;
import org.labkey.api.snprc_scheduler.SNPRC_schedulerService;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class SNPRC_schedulerController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(SNPRC_schedulerController.class);
    public static final String NAME = "snprc_scheduler";

    public SNPRC_schedulerController()
    {
        setActionResolver(_actionResolver);
    }

    //http://localhost:8080/labkey/snprc_scheduler/snprc/Begin.view?
    @RequiresPermission(ReadPermission.class)
    public class BeginAction extends RedirectAction
    {

        @Override
        public URLHelper getSuccessURL(Object o)
        {
            return new ActionURL(NAME, "app", getContainer());
        }

        @Override
        public boolean doAction(Object o, BindException errors)
        {
            return true;
        }

    }

    // http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveTimelines.view?ProjectObjectId=55130483-F7DD-4366-8FA3-55ED58115482
    @RequiresPermission(ReadPermission.class)
    public class getActiveTimelinesAction extends ApiAction<Timeline>
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

    // http://localhost:8080/labkey/snprc_scheduler/snprc/getActiveProjects.view?
    @RequiresPermission(ReadPermission.class)
    public class getActiveProjectsAction extends ApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<>();
            List<JSONObject> jsonProjects = new ArrayList<>();

            // add filters to remove colony maintenance, behavior, clinical, and legacy projects
            SimpleFilter[] filters = new SimpleFilter[2];
            filters[0] = new SimpleFilter(FieldKey.fromParts("ReferenceId"), 4000, CompareType.LT);
            filters[1] = new SimpleFilter(FieldKey.fromParts("ReferenceId"), 0, CompareType.GT);

            List<Map<String, Object>> projects = SNDService.get().getActiveProjects(getContainer(), getUser(), filters);

            if (projects.size() > 0)
            {
                props.put("success", true);

                //   SND returned the project table data, need to add Iacuc and CostAccount fields from ehr.project table
                UserSchema schema = QueryService.get().getUserSchema(getUser(), getContainer(), "ehr");
                TableInfo ti = schema.getTable("project");

                // one project at a time
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
                    }
                    jsonProjects.add(jsonProject);
                }
                props.put("rows", jsonProjects);
            }
            else
            {
                props.put("success", false);
                props.put("message", "No Active Projects");
            }


            return new ApiSimpleResponse(props);
        }
    }

    // http://localhost:8080/labkey/snprc_scheduler/snprc/updateTimeline.view?
    @RequiresPermission(ReadPermission.class)
    public class updateTimelineAction extends ApiAction<SimpleApiJsonForm>
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

            if (json.has("TimelineId"))
            {
                try
                {
                    json.getInt("TimelineId"); // make sure timelineId is an integer
                }
                catch (Exception e)
                {
                    errors.reject(ERROR_MSG, "timelineId is present but not a valid integer.");
                }

                // if timelineId is present, then
            }

            return;

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
                errors.reject(err.getMessage());
            }

            if (err.hasErrors()) {
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