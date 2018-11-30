package org.labkey.snprc_scheduler.services;

import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.ApiUsageException;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableResultSet;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.snd.ProjectItem;
import org.labkey.api.snd.SNDService;
import org.labkey.api.snprc_scheduler.SNPRC_schedulerService;
import org.labkey.api.util.GUID;
import org.labkey.snprc_scheduler.SNPRC_schedulerManager;
import org.labkey.snprc_scheduler.SNPRC_schedulerSchema;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.domains.TimelineAnimalJunction;
import org.labkey.snprc_scheduler.domains.TimelineItem;
import org.labkey.snprc_scheduler.domains.TimelineProjectItem;
import org.springframework.validation.BindException;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

//import org.labkey.api.snd.QCStateEnum;

/**
 * Created by thawkins on 10/21/2018
 */
public class SNPRC_schedulerServiceImpl implements SNPRC_schedulerService
{
    public static final SNPRC_schedulerServiceImpl INSTANCE = new SNPRC_schedulerServiceImpl();

    private SNPRC_schedulerServiceImpl()
    {
    }

    public List<Map<String, Object>> getActiveProjects(Container c, User u, SimpleFilter[] filters)
    {

        return SNDService.get().getActiveProjects(c, u, filters);

    }

    /**
     * returns a list of active timelines for a projectId/RevisionNum
     */
    //TODO: Client needs to be refactored to use ProjectObjectId instead of ProjectId/RevisionNum
    public List<JSONObject> getActiveTimelines(Container c, User u, String projectObjectId, BatchValidationException errors) throws ApiUsageException
    {
        List<JSONObject> timelinesJson = new ArrayList<>();
        try
        {
            UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
            TableInfo timelineTable = SNPRC_schedulerSchema.getInstance().getTableInfoTimeline();

            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("ProjectObjectId"), projectObjectId, CompareType.EQUAL);

            List<Timeline> timelines = new TableSelector(timelineTable, filter, null).getArrayList(Timeline.class);

            //UserSchema studySchema = QueryService.get().getUserSchema(u, EHRService.get().getEHRStudyContainer(c), "study");
            UserSchema sndSchema = QueryService.get().getUserSchema(u,c, "snd");
            TableInfo ti = sndSchema.getTable("Projects");
            SimpleFilter sndFliter = null;

            for (Timeline timeline : timelines)
            {
                timeline.setTimelineItems(SNPRC_schedulerManager.get().getTimelineItems(c, u, timeline.getObjectId()));
                timeline.setTimelineAnimalItems(SNPRC_schedulerManager.get().getTimelineAnimalItems(c, u, timeline.getObjectId()));
                timeline.setCreatedByName(SNPRC_schedulerManager.getUserName(c, u, timeline.getCreatedBy()));
                timeline.setModifiedByName(SNPRC_schedulerManager.getUserName(c, u, timeline.getModifiedBy()));

                // add projectId and RevisionNum
                sndFliter =  new SimpleFilter(FieldKey.fromParts("ObjectId"), timeline.getProjectObjectId(), CompareType.EQUAL);
                Map result = new TableSelector(ti, sndFliter, null).getMap();

                if (result != null) {
                    timeline.setProjectId((Integer) result.get("ProjectId"));
                    timeline.setRevisionNum((Integer) result.get("RevisionNum"));
                }

                timelinesJson.add(timeline.toJSON(c, u));
            }
        }
        catch (Exception e)
        {
            throw new ApiUsageException(e);
        }

        return timelinesJson;
    }



    public List<TimelineProjectItem> getTimelineProjectItemTestData(Container c, User u, String timelineObjectId, Integer ProjectId, Integer RevisionNum)
    {
        List<TimelineProjectItem> tpItems = new ArrayList<>();

        // get project Items test data
        UserSchema schema = QueryService.get().getUserSchema(u, c, "snd");
        SQLFragment sql = new SQLFragment("SELECT * FROM snd.ProjectItems as pi");
        sql.append(" JOIN snd.Projects as p on pi.ParentObjectId = p.ObjectId ");
        sql.append(" JOIN snd.superPkgs as sp on pi.SuperPkgId = sp.SuperPkgId and sp.ParentSuperPkgId is NULL");
        sql.append(" WHERE  p.ProjectId = " + ProjectId.toString());
        sql.append(" AND p.RevisionNum = " + RevisionNum.toString());
        SqlSelector selector = new SqlSelector(schema.getDbSchema(), sql);

        int sortOrder = 0;
        String footNote = "";
        for (ProjectItem projectItem : selector.getArrayList(ProjectItem.class))
        {
            TimelineProjectItem timelineProjectItem = new TimelineProjectItem(timelineObjectId, projectItem.getProjectItemId(), footNote, sortOrder, u);
            sortOrder++;

            tpItems.add(timelineProjectItem);
        }

        return tpItems;

    }

    public List<TimelineAnimalJunction> getTimelineAnimalJunctionTestData(Container c, User u, String timelineObjectId, Integer projectId, Integer revisionNum)
    {

        UserSchema schema = QueryService.get().getUserSchema(u, c, "snd");
        TableInfo ti = schema.getTable("AnimalsByProject");
        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("ProjectId"), projectId, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("RevisionNum"), revisionNum, CompareType.EQUAL);
        filter.addClause(new SimpleFilter.OrClause(
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null),
                new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.DATE_GT, new Date())
        ));

        TableSelector selector = new TableSelector(ti, filter, null);

        List<TimelineAnimalJunction> animalItems = new ArrayList<>();
        try (TableResultSet rs = selector.getResultSet())
        {
            for (Map<String, Object> row : rs)
            {
                TimelineAnimalJunction animalItem = new TimelineAnimalJunction();

                animalItem.setAnimalId(row.get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID).toString());
                animalItem.setAssignmentStatus(row.get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS).toString());
                animalItem.setWeight((Double) row.get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_WEIGHT));
                animalItem.setGender(row.get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_GENDER).toString());
                animalItem.setAge(row.get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_AGE).toString());
                animalItem.setTimelineObjectId(timelineObjectId);
                animalItem.setObjectId(GUID.makeGUID());
                animalItems.add(animalItem);
            }
        }
        catch (SQLException e)
        {
            // ignore
        }

        return animalItems;

    }

    /**
     * Save Timeline and associated datasets (called by SNPRC_schedulerServiceImpl.SNPRC_schedulerController.updateTimelineAction())
     *
     * @param c    = Container object
     * @param u    = User object
     * @param json = JSONObject from submitted form
     * @return errors = exception object
     */
    // TODO: Create automated test cases
    public JSONObject saveTimelineData(Container c, User u, JSONObject json, BindException errors)
    {

        JSONObject responseJson = new JSONObject();

        Timeline timeline = null;
        List<TimelineItem> timelineItems = new ArrayList<>();
        List<TimelineProjectItem> timelineProjectItems = new ArrayList<>();
        List<TimelineAnimalJunction> timelineAnimalItems = new ArrayList<>();

        UserSchema schema = QueryService.get().getUserSchema(u, c, "snprc_ehr");
        DbScope scope = schema.getDbSchema().getScope();
        try (DbScope.Transaction transaction = scope.ensureTransaction())
        {

            // get timeline data from json
            timeline = new Timeline(c, u, json);
            BatchValidationException err = new BatchValidationException();

            SNPRC_schedulerManager.get().updateTimeline(c, u, timeline, err);

            // update the Timelineitem table
            if (!err.hasErrors())
            {
                // Get timeline items from json
                JSONArray timelineItemsJsonArray = json.has(Timeline.TIMELINE_TIMELINE_ITEMS) ? json.getJSONArray(Timeline.TIMELINE_TIMELINE_ITEMS) : null;
                if (timelineItemsJsonArray != null)
                {
                    for (int i = 0, size = timelineItemsJsonArray.length(); i < size; i++)
                    {
                        TimelineItem newItem = new TimelineItem(timelineItemsJsonArray.getJSONObject(i));
                        // add the timelineObjectId before using the object (it may have been created within this transaction)
                        newItem.setTimelineObjectId(timeline.getObjectId());
                        timelineItems.add(newItem);
                    }
                }

                SNPRC_schedulerManager.get().updateTimelineItems(c, u, timelineItems, new BatchValidationException());
            }

            // update TimelineProjectItem table
            if (!err.hasErrors())
            {

                // Get timeline project items from json
                JSONArray timelineProjectItemsJsonArray = json.has(Timeline.TIMELINE_TIMELINE_PROJECT_ITEMS) ? json.getJSONArray(Timeline.TIMELINE_TIMELINE_PROJECT_ITEMS) : null;
                if (timelineProjectItemsJsonArray != null)
                {
                    for (int i = 0, size = timelineProjectItemsJsonArray.length(); i < size; i++)
                    {
                        TimelineProjectItem newItem = new TimelineProjectItem(timelineProjectItemsJsonArray.getJSONObject(i));
                        // add the timelineObjectId before using the object (it may have been created within this transaction)
                        newItem.setTimelineObjectId(timeline.getObjectId());
                        timelineProjectItems.add(newItem);

                    }
                }
                SNPRC_schedulerManager.get().updateTimelineProjectItems(c, u, timelineProjectItems, new BatchValidationException());
            }

            // update the TimelineAnimalJunction table
            if (!err.hasErrors())
            {
                // Get animal ids from json
                JSONArray timelineAnimalItemsJsonArray = json.has(Timeline.TIMELINE_ANIMAL_ITEMS) ? json.getJSONArray(Timeline.TIMELINE_ANIMAL_ITEMS) : null;
                if (timelineAnimalItemsJsonArray != null)
                {
                    for (int i = 0, size = timelineAnimalItemsJsonArray.length(); i < size; i++)
                    {
                        TimelineAnimalJunction newItem = new TimelineAnimalJunction(timelineAnimalItemsJsonArray.getJSONObject(i));
                        // add the timelineObjectId before using the object (it may have been created within this transaction)
                        newItem.setTimelineObjectId(timeline.getObjectId());
                        timelineAnimalItems.add(newItem);
                    }
                }

                SNPRC_schedulerManager.get().updateTimelineAnimalItems(c, u, timelineAnimalItems, new BatchValidationException());
            }

            transaction.commit();

            if (!err.hasErrors())
            {
                timeline.setTimelineItems(timelineItems);
                timeline.setTimelineProjectItems(timelineProjectItems);
                timeline.setTimelineAnimalItems(timelineAnimalItems);

                responseJson = timeline.toJSON(c, u);

            }
        }
        catch (RuntimeException e)
        {
            errors.reject(null, e.getMessage());
        }


//       JSON form has been parsed into these objects:
//       Timeline timeline
//       List<TimelineItem> timelineItems
//       List<TimelineProjectItem> timelineProjectItems
//       List<TimelineItem> timelineAnimalJunction

        return responseJson;
    }
}
