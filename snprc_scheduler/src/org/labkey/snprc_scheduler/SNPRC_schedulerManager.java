package org.labkey.snprc_scheduler;

import org.labkey.api.action.ApiUsageException;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.util.GUID;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.domains.TimelineAnimalJunction;
import org.labkey.snprc_scheduler.domains.TimelineItem;
import org.labkey.snprc_scheduler.domains.TimelineProjectItem;
import org.labkey.snprc_scheduler.query.TimelineTable;
import org.labkey.snprc_scheduler.security.QCStateEnum;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SNPRC_schedulerManager
{
    private static final SNPRC_schedulerManager _instance = new SNPRC_schedulerManager();

    private SNPRC_schedulerManager()
    {
        // prevent external construction with a private default constructor
    }

    public static UserSchema getSNPRC_schedulerUserSchema(Container c, User u)
    {
        return new SNPRC_schedulerUserSchema(u, c);
    }

    public static SNPRC_schedulerManager get()
    {
        return _instance;
    }


    /**
     * Get the next revision number in sequence
     *
     * @param timelineId
     * @return next revision number
     */
    private Integer getNextRevisionNum(int timelineId)
    {

        SQLFragment sql = new SQLFragment("SELECT MAX(t.RevisionNum) AS RevisionNum FROM ");
        sql.append(SNPRC_schedulerSchema.getInstance().getTableInfoTimeline(), "t");
        sql.append(" WHERE t.TimelineId = ?").add(timelineId);
        SqlSelector sqlSelector = new SqlSelector(SNPRC_schedulerSchema.getInstance().getSchema(), sql);

        Integer revNum = sqlSelector.getObject(Integer.class);

        return (revNum == null) ? 0 : revNum + 1;

    }

    /**
     * Get the user's name from the user's id
     *
     * @param c      = Container object
     * @param u      = User object
     * @param userId = user id to be looked up
     * @return Users display name
     */
    public static String getUserDisplayName(Container c, User u, Integer userId)
    {
        String userName = "";
        DbSchema schema = DbSchema.get("core", DbSchemaType.Module);
        TableInfo ti = schema.getTable("Users");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("UserId"), userId, CompareType.EQUAL);
        // should only get one row back
        Map<String, Object> user = new TableSelector(ti, filter, null).getMap();
        if (user != null)
        {
            userName = (String) user.get("DisplayName");
        }
        return userName;
    }

    public List<TimelineItem> getTimelineItems(Container c, User u, String timelineObjectId) throws ApiUsageException
    {

        List<TimelineItem> timelineItems = null;
        try
        {
            UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
            TableInfo timelineItemTable = SNPRC_schedulerSchema.getInstance().getTableInfoTimelineItem();

            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts(TimelineItem.TIMELINEITEM_TIMELINE_OBJECT_ID), timelineObjectId, CompareType.EQUAL);

            timelineItems = new TableSelector(timelineItemTable, filter, null).getArrayList(TimelineItem.class);

        }
        catch (Exception e)
        {
            throw new ApiUsageException(e);
        }

        return timelineItems;
    }

    public List<TimelineAnimalJunction> getTimelineAnimalItems(Container c, User u, String timelineObjectId) throws ApiUsageException
    {

        List<TimelineAnimalJunction> timelineAnimalItems = null;
        try
        {
            UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
            TableInfo timelineAnimalJunctionTable = SNPRC_schedulerSchema.getInstance().getTableInfoTimelineAnimalJunction();

            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID), timelineObjectId, CompareType.EQUAL);

            timelineAnimalItems = new TableSelector(timelineAnimalJunctionTable, filter, null).getArrayList(TimelineAnimalJunction.class);

            //UserSchema studySchema = QueryService.get().getUserSchema(u, EHRService.get().getEHRStudyContainer(c), "study");
            UserSchema sndSchema = QueryService.get().getUserSchema(u, c, "snd");
            TableInfo ti = sndSchema.getTable("AnimalsByProject");

            SimpleFilter demFliter = null;
            // add demographics data
            for (TimelineAnimalJunction timelineAnimalItem : timelineAnimalItems)
            {

                demFliter = new SimpleFilter(FieldKey.fromParts("Id"), timelineAnimalItem.getAnimalId(), CompareType.EQUAL);

                Map result = new TableSelector(ti, demFliter, null).getMap();

                if (result != null)
                {
                    timelineAnimalItem.setGender((String) result.get("Gender"));
                    timelineAnimalItem.setAge((String) result.get("Age"));
                    timelineAnimalItem.setWeight((Double) result.get("Weight"));
                    timelineAnimalItem.setAssignmentStatus((String) result.get("AssignmentStatus"));
                }
            }

        }
        catch (Exception e)
        {
            throw new ApiUsageException(e);
        }

        return timelineAnimalItems;
    }

    public List<TimelineProjectItem> getTimelineProjectItems(Container c, User u, String timelineObjectId) throws ApiUsageException
    {

        List<TimelineProjectItem> timelineProjectItems = null;
        try
        {
            UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
            TableInfo timelineProjectItemTable = SNPRC_schedulerSchema.getInstance().getTableInfoTimelineProjectItem();

            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID), timelineObjectId, CompareType.EQUAL);

            timelineProjectItems = new TableSelector(timelineProjectItemTable, filter, null).getArrayList(TimelineProjectItem.class);
        }
        catch (Exception e)
        {
            throw new ApiUsageException(e);
        }

        return timelineProjectItems;
    }

    /**
     * Validate before deleting
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timeline = Timeline object to be deleted
     * @param errors = exception object
     */
    public void validateBeforeDelete(Container c, User u, Timeline timeline, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);
        TimelineTable timelineTable = (TimelineTable) schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE);

        Integer timelineId = timeline.getTimelineId();
        Integer revisionNum = timeline.getRevisionNum();
        String timelineObjectId = timeline.getObjectId();


        // did we get the json needed to delete a timeline?
        if (timelineId == null || revisionNum == null || timelineObjectId == null)
            errors.addRowError(new ValidationException("TimelineObjectId, TimelineId and RevisionNum are required - cannot deleted record."));

        // Does timeline exist?
        if (!errors.hasErrors())
        {
            Set<String> cols = new HashSet<>();
            cols.add(Timeline.TIMELINE_ID);

            SimpleFilter filter = new SimpleFilter(FieldKey.fromString(Timeline.TIMELINE_ID), timelineId, CompareType.EQUAL).
                    addCondition(FieldKey.fromString(Timeline.TIMELINE_REVISION_NUM), revisionNum, CompareType.EQUAL);

            TableSelector ts = new TableSelector(timelineTable, cols, filter, null);
            Map<String, Object> result = ts.getMap();

            if (result == null)
                errors.addRowError(new ValidationException("Timeline does not exist."));
        }

        // is timeline in use?
        if (!errors.hasErrors())
        {
            if (timelineTable.isTimelineInUse(timelineId, revisionNum))
                errors.addRowError(new ValidationException("Timeline is in use - cannot be deleted."));
        }

    }

    /**
     * Delete the Timeline and corresponding records (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timeline = Timeline object to be deleted
     * @param errors = exception object
     */
    public void deleteTimeline(Container c, User u, Timeline timeline, BatchValidationException errors)
    {
        validateBeforeDelete(c, u, timeline, errors);
        if (!errors.hasErrors())
        {
            UserSchema schema = getSNPRC_schedulerUserSchema(c, u);
            TimelineTable timelineTable = (TimelineTable) schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE);
            DbScope scope = schema.getDbSchema().getScope();
            QueryUpdateService qus;

            Integer timelineId = timeline.getTimelineId();
            Integer revisionNum = timeline.getRevisionNum();
            String timelineObjectId = timeline.getObjectId();


            // delete the timeline
            try (DbScope.Transaction transaction = scope.ensureTransaction())
            {
                //==================================
                // delete from timelineItems
                //==================================
                TableInfo timelineItemTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_ITEM);
                qus = timelineItemTable.getUpdateService();

                Set<String> cols = new HashSet<>();
                cols.add(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID);

                SimpleFilter filter = new SimpleFilter(FieldKey.fromString(TimelineItem.TIMELINEITEM_TIMELINE_OBJECT_ID), timelineObjectId, CompareType.EQUAL);

                List<Integer> timelineItemIds = new TableSelector(timelineItemTable, cols, filter, null).getArrayList(Integer.class);

                Map<String, Object> row; // = new HashMap<>();
                List<Map<String, Object>> rows = new ArrayList<>();

                for (Integer timelineItemId : timelineItemIds)
                {
                    row = new HashMap<>();
                    row.put(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID, timelineItemId);
                    rows.add(row);
                }
                qus.deleteRows(u, c, rows, null, null);

                //==================================
                // delete from timelineProjectItems
                //==================================
                TableInfo timelineProjectItemTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_PROJECT_ITEM);
                qus = timelineProjectItemTable.getUpdateService();

                cols = new HashSet<>();
                cols.add(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID);
                cols.add(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID);
                filter = new SimpleFilter(FieldKey.fromString(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID), timelineObjectId, CompareType.EQUAL);

                List<Map> projectItemRows = new TableSelector(timelineProjectItemTable, cols, filter, null).getArrayList(Map.class);

                rows.clear();
                for (Map projectItemRow : projectItemRows)
                {
                    row = new HashMap<>();
                    row.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID, projectItemRow.get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID));
                    row.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID, projectItemRow.get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID));
                    rows.add(row);
                }

                qus.deleteRows(u, c, rows, null, null);

                //==================================
                // delete from timelineAnimalJunction
                //==================================
                TableInfo timelineAnimalJunctionTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_ANIMAL_JUNCTION);
                qus = timelineAnimalJunctionTable.getUpdateService();

                cols = new HashSet<>();
                cols.add(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID);
                filter = new SimpleFilter(FieldKey.fromString(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID), timelineObjectId, CompareType.EQUAL);

                List<Integer> animalRows = new TableSelector(timelineAnimalJunctionTable, cols, filter, null).getArrayList(Integer.class);
                rows.clear();
                for (Integer animalRow : animalRows)
                {
                    row = new HashMap<>();
                    row.put(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID, animalRow);
                    rows.add(row);
                }

                qus.deleteRows(u, c, rows, null, null);

                //==================================
                // delete from timeline table
                //==================================
                qus = timelineTable.getUpdateService();

                rows.clear();

                row = new HashMap<>();
                row.put(Timeline.TIMELINE_ID, timelineId);
                row.put(Timeline.TIMELINE_REVISION_NUM, revisionNum);
                rows.add(row);

                qus.deleteRows(u, c, rows, null, null);


                // All is well
                transaction.commit();

            }
            catch (BatchValidationException | InvalidKeyException | QueryUpdateServiceException | SQLException e)
            {
                errors.addRowError(new ValidationException(e.getMessage()));
            }
        }
    }


    /**
     * Update the Timeline table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timeline = Timeline object
     * @param errors = exception object
     */
    public void updateTimeline(Container c, User u, Timeline timeline, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE);
        QueryUpdateService qus = timelineTable.getUpdateService();

        List<Map<String, Object>> timelineRows = new ArrayList<>();

        try
        {
            // insert new row
            if (timeline.getObjectId() == null)
            {

                timeline.setTimelineId(SNPRC_schedulerSequencer.TIMELINEID.ensureId(c, timeline.getTimelineId()));

                timeline.setRevisionNum(getNextRevisionNum(timeline.getTimelineId()));
                timeline.setObjectId(new GUID().toString());
                // add default QcState
                if (timeline.getQcState() == null) timeline.setQcState(QCStateEnum.IN_PROGRESS.getValue());

                timelineRows.add(timeline.toMap(c, u));

                List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineRows, errors, null, null);

                // add updated values returned from db call
                if (insertedRow != null)
                {
                    timeline.setCreated((Date) insertedRow.get(0).get("Created"));
                    timeline.setCreatedBy(c, u, (Integer) insertedRow.get(0).get("CreatedBy"));
                    timeline.setModified((Date) insertedRow.get(0).get("Modified"));
                    timeline.setModifiedBy(c, u, (Integer) insertedRow.get(0).get("ModifiedBy"));
                }

                if (errors.hasErrors())
                {
                    throw errors;
                }
            }
            // update existing row
            else if (timeline.getDirty())
            {
                timelineRows.add(timeline.toMap(c, u));
                Map<String, Object> pkMap = new HashMap<>();
                List<Map<String, Object>> pkList = new ArrayList<>();

                pkMap.put(Timeline.TIMELINE_ID, timeline.getTimelineId());
                pkMap.put(Timeline.TIMELINE_REVISION_NUM, timeline.getRevisionNum());
                pkList.add(pkMap);
                List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineRows, pkList, null, null);
                // add updated values returned from db call
                timeline.setModified((Date) updatedRow.get(0).get("Modified"));
                timeline.setModifiedBy(c, u, (Integer) updatedRow.get(0).get("ModifiedBy"));

            }
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }

    }


    /**
     * Update the TimelineItem table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c             = Container object
     * @param u             = User object
     * @param timelineItems = List of TimelineItem objects
     * @return errors = exception object
     */
    public void updateTimelineItems(Container c, User u, List<TimelineItem> timelineItems, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineItemTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_ITEM);
        QueryUpdateService qus = timelineItemTable.getUpdateService();

        try
        {
            List<TimelineItem> toRemove = new ArrayList<>(); // list of timelineItems that were deleted

            for (TimelineItem timelineItem : timelineItems)
            {
                List<Map<String, Object>> timelineItemRows = new ArrayList<>();

                // insert new row
                if (timelineItem.getObjectId() == null)
                {
                    timelineItem.setObjectId(new GUID().toString());

                    timelineItemRows.add(timelineItem.toMap(c));
                    List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineItemRows, errors, null, null);

                    // add updated values returned from db call
                    if (insertedRow != null)
                    {
                        timelineItem.setObjectId((String) insertedRow.get(0).get(TimelineItem.TIMELINEITEM_OBJECT_ID));
                        timelineItem.setTimelineItemId((Integer) insertedRow.get(0).get(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID));
                    }
                }
                // delete existing row
                else if (timelineItem.getDeleted())
                {
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID, timelineItem.getTimelineItemId());
                    pkList.add(pkMap);
                    qus.deleteRows(u, c, pkList, null, null);

                    toRemove.add(timelineItem); // save the timelineItem for removal
                }
                // update existing row
                else if (timelineItem.getDirty())
                {
                    timelineItemRows.add(timelineItem.toMap(c));
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID, timelineItem.getTimelineItemId());
                    pkList.add(pkMap);

                    List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineItemRows, pkList, null, null);
                }
            }
            // remove timelineItems that were deleted
            timelineItems.removeAll(toRemove);
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }
    }

    /**
     * Update the TimelineProjectItem table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c                    = Container object
     * @param u                    = User object
     * @param timelineProjectItems = List of TimelineItem objects
     * @return errors = exception object
     */
    public void updateTimelineProjectItems(Container c, User u, List<TimelineProjectItem> timelineProjectItems, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineProjectItemTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_PROJECT_ITEM);
        QueryUpdateService qus = timelineProjectItemTable.getUpdateService();


        try
        {
            List<TimelineProjectItem> toRemove = new ArrayList<>(); // list of timelineProjectItems that were deleted

            for (TimelineProjectItem timelineProjectItem : timelineProjectItems)
            {
                List<Map<String, Object>> timelineProjectItemRows = new ArrayList<>();

                // insert new row
                if (timelineProjectItem.getObjectId() == null)
                {
                    timelineProjectItem.setObjectId(new GUID().toString());

                    timelineProjectItemRows.add(timelineProjectItem.toMap(c));
                    List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineProjectItemRows, errors, null, null);

                    // add updated values returned from db call
                    if (insertedRow != null)
                    {
                        timelineProjectItem.setObjectId((String) insertedRow.get(0).get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID));
                        timelineProjectItem.setProjectItemId((Integer) insertedRow.get(0).get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID));
                    }
                }
                // delete existing row
                else if (timelineProjectItem.getDeleted())
                {
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID, timelineProjectItem.getProjectItemId());
                    pkMap.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID, timelineProjectItem.getTimelineObjectId());
                    pkList.add(pkMap);

                    qus.deleteRows(u, c, pkList, null, null);

                    toRemove.add(timelineProjectItem); // save the timelineItem for removal
                }
                // update existing row
                else if (timelineProjectItem.getDirty())
                {
                    timelineProjectItemRows.add(timelineProjectItem.toMap(c));
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID, timelineProjectItem.getProjectItemId());
                    pkMap.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID, timelineProjectItem.getTimelineObjectId());
                    pkList.add(pkMap);

                    List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineProjectItemRows, pkList, null, null);

                    if (updatedRow != null)
                    {
                        timelineProjectItem.setObjectId((String) updatedRow.get(0).get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID));
                    }
                }
            }
            // remove timelineItems that were deleted
            timelineProjectItems.removeAll(toRemove);
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }
    }

    /**
     * Update the TimelineAnimalJunction table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c                   = Container object
     * @param u                   = User object
     * @param timelineAnimalItems = List of TimelineItem objects
     * @return errors = exception object
     */
    public void updateTimelineAnimalItems(Container c, User u, List<TimelineAnimalJunction> timelineAnimalItems, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineAnimalJunctionTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_ANIMAL_JUNCTION);
        QueryUpdateService qus = timelineAnimalJunctionTable.getUpdateService();

        try
        {
            List<TimelineAnimalJunction> toRemove = new ArrayList<>(); // list of timelineAnimalItems that were deleted

            for (TimelineAnimalJunction timelineAnimalItem : timelineAnimalItems)
            {
                List<Map<String, Object>> timelineAnimalItemRows = new ArrayList<>();

                // insert new row
                if (timelineAnimalItem.getObjectId() == null)
                {
                    timelineAnimalItem.setObjectId(new GUID().toString());

                    timelineAnimalItemRows.add(timelineAnimalItem.toMap(c));
                    List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineAnimalItemRows, errors, null, null);

                    // add updated values returned from db call
                    if (insertedRow != null)
                    {
                        timelineAnimalItem.setObjectId((String) insertedRow.get(0).get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID));
                        timelineAnimalItem.setRowId((Integer) insertedRow.get(0).get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID));
                    }
                }
                // delete existing row
                else if (timelineAnimalItem.getDeleted())
                {
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID, timelineAnimalItem.getRowId());
                    pkList.add(pkMap);

                    qus.deleteRows(u, c, pkList, null, null);

                    toRemove.add(timelineAnimalItem); // save the timelineAnimalItem for removal from list
                }
                // update existing row
                else if (timelineAnimalItem.getDirty())
                {
                    timelineAnimalItemRows.add(timelineAnimalItem.toMap(c));
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID, timelineAnimalItem.getRowId());
                    pkList.add(pkMap);

                    List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineAnimalItemRows, pkList, null, null);
                    if (updatedRow != null)
                    {
                        timelineAnimalItem.setObjectId((String) updatedRow.get(0).get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID));
                    }
                }
            }
            // remove timelineAnimalItems that were deleted
            timelineAnimalItems.removeAll(toRemove);
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }
    }
}