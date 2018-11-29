package org.labkey.snprc_scheduler;

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
import org.labkey.snprc_scheduler.security.QCStateEnum;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
     * @return Users name
     */
    public static String getUserName(Container c, User u, Integer userId)
    {
        String userName = "";
        DbSchema schema = DbSchema.get("core", DbSchemaType.Module);
        TableInfo ti = schema.getTable("Principals");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("UserId"), userId, CompareType.EQUAL);
        // should only get one row back
        Map<String, Object> user = new TableSelector(ti, filter, null).getMap();
        if (user != null)
        {
            userName = (String) user.get("name");
        }
        return userName;
    }

    /**
     * Update the Timeline table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timeline = Timeline object
     * @return errors = exception object
     */
    public void updateTimeline(Container c, User u, Timeline timeline, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE);
        QueryUpdateService qus = timelineTable.getUpdateService();

        List<Map<String, Object>> timelineRows = new ArrayList<>();

        try (DbScope.Transaction tx = timelineTable.getSchema().getScope().ensureTransaction())
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
                timeline.setCreated((Date) insertedRow.get(0).get("Created"));
                timeline.setCreatedBy(c, u, (Integer) insertedRow.get(0).get("CreatedBy"));
                timeline.setModified((Date) insertedRow.get(0).get("Modified"));
                timeline.setModifiedBy(c, u, (Integer) insertedRow.get(0).get("ModifiedBy"));

                if (errors.hasErrors())
                {
                    throw errors;
                }
            }
            // update existing row
            else
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
            tx.commit();
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }

    }


    /**
     * Update the TimelineItem table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timelineItems = List of TimelineItem objects
     * @return errors = exception object
     */
    public void updateTimelineItems(Container c, User u, List<TimelineItem> timelineItems, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineItemTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_ITEM);
        QueryUpdateService qus = timelineItemTable.getUpdateService();


        try (DbScope.Transaction tx = timelineItemTable.getSchema().getScope().ensureTransaction())
        {
            for (TimelineItem timelineItem: timelineItems)
            {
                List<Map<String, Object>> timelineItemRows = new ArrayList<>();

                // insert new row
                if (timelineItem.getObjectId() == null)
                {
                    timelineItem.setObjectId(new GUID().toString());

                    timelineItemRows.add(timelineItem.toMap(c));
                    List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineItemRows, errors, null, null);

                    // add updated values returned from db call
                    timelineItem.setObjectId((String) insertedRow.get(0).get(TimelineItem.TIMELINEITEM_OBJECT_ID));
                    timelineItem.setTimelineItemId((Integer) insertedRow.get(0).get(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID));
                }
                // update existing row
                else
                {
                    timelineItemRows.add(timelineItem.toMap(c));
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID, timelineItem.getTimelineItemId());
                    pkList.add(pkMap);

                    List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineItemRows, pkList, null, null);
                }
            }
            tx.commit();
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }
    }

    /**
     * Update the TimelineProjectItem table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timelineProjectItems = List of TimelineItem objects
     * @return errors = exception object
     */
    public void updateTimelineProjectItems(Container c, User u, List<TimelineProjectItem> timelineProjectItems, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineProjectItemTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_PROJECT_ITEM);
        QueryUpdateService qus = timelineProjectItemTable.getUpdateService();


        try (DbScope.Transaction tx = timelineProjectItemTable.getSchema().getScope().ensureTransaction())
        {
            for (TimelineProjectItem timelineProjectItem: timelineProjectItems)
            {
                List<Map<String, Object>> timelineProjectItemRows = new ArrayList<>();

                // insert new row
                if (timelineProjectItem.getObjectId() == null)
                {
                    timelineProjectItem.setObjectId(new GUID().toString());

                    timelineProjectItemRows.add(timelineProjectItem.toMap(c));
                    List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineProjectItemRows, errors, null, null);

                    // add updated values returned from db call
                    timelineProjectItem.setObjectId((String) insertedRow.get(0).get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID));
                    timelineProjectItem.setProjectItemId((Integer) insertedRow.get(0).get(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID));
                }
                // update existing row
                else
                {
                    timelineProjectItemRows.add(timelineProjectItem.toMap(c));
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID, timelineProjectItem.getProjectItemId());
                    pkMap.put(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID, timelineProjectItem.getTimelineObjectId());
                    pkList.add(pkMap);

                    List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineProjectItemRows, pkList, null, null);
                }
            }
            tx.commit();
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }
    }

    /**
     * Update the TimelineAnimalJunction table (called by SNPRC_schedulerServiceImpl.saveTimelineData()
     *
     * @param c        = Container object
     * @param u        = User object
     * @param timelineAnimalItems = List of TimelineItem objects
     * @return errors = exception object
     */
    public void updateTimelineAnimalItems(Container c, User u, List<TimelineAnimalJunction> timelineAnimalItems, BatchValidationException errors)
    {
        UserSchema schema = getSNPRC_schedulerUserSchema(c, u);

        TableInfo timelineAnimalJunctionTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE_ANIMAL_JUNCTION);
        QueryUpdateService qus = timelineAnimalJunctionTable.getUpdateService();

        try (DbScope.Transaction tx = timelineAnimalJunctionTable.getSchema().getScope().ensureTransaction())
        {
            for (TimelineAnimalJunction timelineAnimalItem: timelineAnimalItems)
            {
                List<Map<String, Object>> timelineAnimalItemRows = new ArrayList<>();

                // insert new row
                if (timelineAnimalItem.getObjectId() == null)
                {
                    timelineAnimalItem.setObjectId(new GUID().toString());

                    timelineAnimalItemRows.add(timelineAnimalItem.toMap(c));
                    List<Map<String, Object>> insertedRow = qus.insertRows(u, c, timelineAnimalItemRows, errors, null, null);

                    // add updated values returned from db call
                    timelineAnimalItem.setObjectId((String) insertedRow.get(0).get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID));
                    timelineAnimalItem.setRowId((Integer) insertedRow.get(0).get(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID));
                }
                // update existing row
                else
                {
                    timelineAnimalItemRows.add(timelineAnimalItem.toMap(c));
                    Map<String, Object> pkMap = new HashMap<>();
                    List<Map<String, Object>> pkList = new ArrayList<>();

                    pkMap.put(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID, timelineAnimalItem.getRowId());
                    pkList.add(pkMap);

                    List<Map<String, Object>> updatedRow = qus.updateRows(u, c, timelineAnimalItemRows, pkList, null, null);
                }
            }
            tx.commit();
        }
        catch (QueryUpdateServiceException | BatchValidationException | SQLException | DuplicateKeyException | InvalidKeyException e)
        {
            errors.addRowError(new ValidationException(e.getMessage()));
        }
    }
}