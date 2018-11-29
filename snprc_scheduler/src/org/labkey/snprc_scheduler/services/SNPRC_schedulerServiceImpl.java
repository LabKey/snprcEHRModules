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
import org.labkey.api.snd.Project;
import org.labkey.api.snd.ProjectItem;
import org.labkey.api.snd.SNDService;
import org.labkey.api.snprc_scheduler.SNPRC_schedulerService;
import org.labkey.api.util.GUID;
import org.labkey.snprc_scheduler.SNPRC_schedulerManager;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.domains.TimelineAnimalJunction;
import org.labkey.snprc_scheduler.domains.TimelineItem;
import org.labkey.snprc_scheduler.domains.TimelineProjectItem;
import org.labkey.snprc_scheduler.security.QCStateEnum;
import org.springframework.validation.BindException;

import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
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
    public List<JSONObject> getActiveTimelines(Container c, User u, int projectId, int revisionNum, BatchValidationException errors) throws ApiUsageException
    {


        //TODO: uncomment after datasets are created
//        List<Map<String, Timeline>> timelines = new ArrayList<>();
//        UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
//        TableInfo timelineTable =  SNPRC_schedulerSchema.getInstance().getTableInfoTimeline();
//        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("ProjectId"), projectId, CompareType.EQUAL);
//        filter.addCondition(FieldKey.fromParts("RevisionNum"), revNum, CompareType.EQUAL);
//        TableSelector ts = new TableSelector(timelineTable, filter, null);
//
//        List<Timeline> timelines = new TableSelector(table, filter, null).getArrayList(Timeline.class);

//        try (TableResultSet rs = ts.getResultSet())
//        {
//            Timeline timeline = new Timeline();
//
//            for (Map<String, Object> row : rs)
//            {
//
//                //timelines.add();
//            }
//        }
//        catch (SQLException e)
//        {
//        }

        DateFormat formatString = new SimpleDateFormat("MM/dd/yyyy");
        List<JSONObject> timelines = new ArrayList<>();

        Project project1 = SNDService.get().getProject(c, u, 20, 0);

        try
        {
            Timeline timeline1 = new Timeline();
            timeline1.setTimelineId(1);
            timeline1.setRevisionNum(0);
            timeline1.setDescription("Timeline #1 Revision 0");
            timeline1.setStartDate(formatString.parse("01/01/2018"));
            timeline1.setEndDate(formatString.parse("05/31/2018"));
            timeline1.setLeadTechs("John Wayne, Clint Eastwood");
            timeline1.setSchedulerNotes("Don't schedule on weekends.");
            timeline1.setNotes("Go ahead, make my day!");
            timeline1.setObjectId(GUID.makeGUID());
            timeline1.setProjectId(project1.getProjectId());
            timeline1.setProjectRevisionNum(project1.getRevisionNum());
            timeline1.setProjectObjectId(project1.getObjectId());
            timeline1.setCreated(formatString.parse("10/1/2018"));
            timeline1.setModified(formatString.parse("10/4/2018"));
            timeline1.setCreatedBy(c, u, u.getUserId());
            timeline1.setModifiedBy(c, u, u.getUserId());

            timeline1.setQcState(QCStateEnum.getValueByName("Completed"));


            timeline1.setTimelineItems(getTimelineItemTestData(c, u, timeline1.getObjectId(), timeline1.getProjectId(), timeline1.getProjectRevisionNum()));
            timeline1.setTimelineProjectItems(getTimelineProjectItemTestData(c, u, timeline1.getObjectId(), timeline1.getProjectId(), timeline1.getProjectRevisionNum()));
            timeline1.setTimelineAnimalItems(getTimelineAnimalJunctionTestData(c, u, timeline1.getObjectId(), timeline1.getProjectId(), timeline1.getProjectRevisionNum()));

            timelines.add(timeline1.toJSON(c, u));

            Timeline timeline2 = new Timeline();
            timeline2.setTimelineId(1);
            timeline2.setRevisionNum(1);
            timeline2.setDescription("Timeline #1 Revision 1");
            timeline2.setStartDate(formatString.parse("06/01/2018"));
            timeline2.setEndDate(formatString.parse("12/31/2018"));
            timeline2.setLeadTechs("Zaphod Beeblebrox, Trisha McMillian");
            timeline2.setNotes("Not again.");
            timeline2.setObjectId(GUID.makeGUID());
            timeline2.setProjectId(project1.getProjectId());
            timeline2.setProjectRevisionNum(project1.getRevisionNum());
            timeline2.setProjectObjectId(project1.getObjectId());
            timeline2.setCreated(formatString.parse("09/20/2018"));
            timeline2.setModified(formatString.parse("10/1/2018"));
            timeline2.setCreatedBy(c, u, u.getUserId());
            timeline2.setModifiedBy(c, u, u.getUserId());
            timeline2.setSchedulerNotes("The ships hung in the sky in much the same way that bricks don’t.");
            timeline2.setQcState(QCStateEnum.getValueByName("In Progress"));

            timeline2.setTimelineItems(getTimelineItemTestData(c, u, timeline2.getObjectId(), timeline2.getProjectId(), timeline2.getProjectRevisionNum()));
            timeline2.setTimelineProjectItems(getTimelineProjectItemTestData(c, u, timeline2.getObjectId(), timeline2.getProjectId(), timeline2.getProjectRevisionNum()));
            timeline2.setTimelineAnimalItems(getTimelineAnimalJunctionTestData(c, u, timeline2.getObjectId(), timeline2.getProjectId(), timeline2.getProjectRevisionNum()));
            timelines.add(timeline2.toJSON(c, u));

            Project project2 = SNDService.get().getProject(c, u, 18, 0);
            Timeline timeline3 = new Timeline();
            timeline3.setTimelineId(3);
            timeline3.setRevisionNum(0);
            timeline3.setDescription("Timeline #3");
            timeline3.setStartDate(formatString.parse("02/1/2018"));
            timeline3.setEndDate(formatString.parse("12/30/2018"));
            timeline3.setLeadTechs("Henry Ford, Nicoli Tesla");
            timeline3.setObjectId(GUID.makeGUID());
            timeline3.setProjectId(project2.getProjectId());
            timeline3.setProjectRevisionNum(project2.getRevisionNum());
            timeline3.setProjectObjectId(project2.getObjectId());
            timeline3.setCreated(formatString.parse("09/20/2018"));
            timeline3.setModified(formatString.parse("10/1/2018"));
            timeline3.setCreatedBy(c, u, u.getUserId());
            timeline3.setModifiedBy(c, u, u.getUserId());
            timeline3.setSchedulerNotes("Of all the things i've lost in life, i miss my mind the most");
            timeline3.setQcState(QCStateEnum.getValueByName("Completed"));


            timeline3.setTimelineItems(getTimelineItemTestData(c, u, timeline3.getObjectId(), timeline3.getProjectId(), timeline3.getProjectRevisionNum()));
            timeline3.setTimelineProjectItems(getTimelineProjectItemTestData(c, u, timeline3.getObjectId(), timeline3.getProjectId(), timeline3.getProjectRevisionNum()));
            timeline3.setTimelineAnimalItems(getTimelineAnimalJunctionTestData(c, u, timeline3.getObjectId(), timeline3.getProjectId(), timeline3.getProjectRevisionNum()));
            timelines.add(timeline3.toJSON(c, u));
        }

        catch (Exception e)

        {
            throw new ApiUsageException(e);
        }
        return timelines;
    }

    public List<TimelineItem> getTimelineItemTestData(Container c, User u, String timelineObjectId, Integer ProjectId, Integer RevisionNum)
    {
        // get project Items test data
        UserSchema schema = QueryService.get().getUserSchema(u, c, "snd");
        SQLFragment sql = new SQLFragment("SELECT * FROM snd.ProjectItems as pi");
        sql.append(" JOIN snd.Projects as p on pi.ParentObjectId = p.ObjectId ");
        sql.append(" JOIN snd.superPkgs as sp on pi.SuperPkgId = sp.SuperPkgId and sp.ParentSuperPkgId is NULL");
        sql.append(" WHERE  p.ProjectId = " + ProjectId.toString());
        sql.append(" AND p.RevisionNum = " + RevisionNum.toString());
        SqlSelector selector = new SqlSelector(schema.getDbSchema(), sql);

        List<TimelineItem> tItems = new ArrayList<>();

        int studyDay = 0;
        int timelineItemId = 0;

        for (ProjectItem projectItem : selector.getArrayList(ProjectItem.class))
        {
            TimelineItem timelineItem = new TimelineItem(timelineItemId, timelineObjectId, projectItem.getProjectItemId(), studyDay, u);
            timelineItemId++;
            if (timelineItemId % 2 == 0) studyDay++;
            tItems.add(timelineItem);
        }

        return tItems;
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
     * @param c        = Container object
     * @param u        = User object
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
                        TimelineItem newItem = new TimelineItem (timelineItemsJsonArray.getJSONObject(i));
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
                        TimelineProjectItem newItem = new TimelineProjectItem (timelineProjectItemsJsonArray.getJSONObject(i));
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
                        TimelineAnimalJunction newItem = new TimelineAnimalJunction (timelineAnimalItemsJsonArray.getJSONObject(i));
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
