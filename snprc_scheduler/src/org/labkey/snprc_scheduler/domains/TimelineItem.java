package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.api.util.GUID;

import java.text.ParseException;
import java.util.Date;
import java.util.Map;

/**
 * Created by thawkins on 9/13/2018.
 * <p>
 * Class for TimelineTable item data. Used in TimelineTable class.
 */
public class TimelineItem
{
    private Integer _timelineItemId;    //PK
    private String _timelineObjectId;        // FK - timeline
    private Integer _projectItemId;     // FK - timelineProjectItem
    private Integer _studyDay;
    private Date _scheduleDate;
    private String _objectId;


    public static final String TIMELINEITEM_TIMELINE_ITEM_ID = "TimelineItemId";
    public static final String TIMELINEITEM_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINEITEM_PROJECT_ITEM_ID = "ProjectItemId";
    public static final String TIMELINEITEM_STUDY_DAY = "StudyDay";
    public static final String TIMELINEITEM_SCHEDULE_DATE = "ScheduleDate";
    public static final String TIMELINEITEM_OBJECT_ID = "ObjectId";


    public TimelineItem()
    {
    }

    public TimelineItem(Integer timelineItemId, String timelineObjectId, Integer projectItemId, Integer studyDay, User u)
    {
        _timelineItemId = timelineItemId;
        _timelineObjectId = timelineObjectId;
        _projectItemId = projectItemId;
        _studyDay = studyDay;
        _objectId = GUID.makeGUID();
    }

    public TimelineItem(JSONObject json) throws RuntimeException
    {
        try
        {

            this.setTimelineItemId(json.has(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID) ? json.getInt(TimelineItem.TIMELINEITEM_TIMELINE_ITEM_ID) : null);
            this.setTimelineObjectId(json.has(TimelineItem.TIMELINEITEM_TIMELINE_OBJECT_ID) ? json.getString(TimelineItem.TIMELINEITEM_TIMELINE_OBJECT_ID) : null);
            this.setStudyDay(json.has(TimelineItem.TIMELINEITEM_STUDY_DAY) ? json.getInt(TimelineItem.TIMELINEITEM_STUDY_DAY) : null);
            this.setProjectItemId(json.has(TimelineItem.TIMELINEITEM_PROJECT_ITEM_ID) ? json.getInt(TimelineItem.TIMELINEITEM_PROJECT_ITEM_ID) : null);
            this.setObjectId(json.has(TimelineItem.TIMELINEITEM_OBJECT_ID) ? json.getString(TimelineItem.TIMELINEITEM_OBJECT_ID) : null);

            String scheduleDateString = json.has(TimelineItem.TIMELINEITEM_SCHEDULE_DATE) ? json.getString(TimelineItem.TIMELINEITEM_SCHEDULE_DATE) : null;
            Date scheduleDate = null;

            try
            {
                this.setScheduleDate(scheduleDateString == null ? null : DateUtil.parseDateTime(scheduleDateString, Timeline.TIMELINE_DATE_FORMAT));

            }
            catch (ParseException e)
            {
                throw new RuntimeException(e.getMessage());
            }

        }
        catch (Exception e)
        {
            throw new RuntimeException ( e.getMessage() ) ;
        }

    }
    public Integer getTimelineItemId()
    {
        return _timelineItemId;
    }

    public void setTimelineItemId(Integer timelineItemId)
    {
        _timelineItemId = timelineItemId;
    }

    public String getTimelineObjectId()
    {
        return _timelineObjectId;
    }

    public void setTimelineObjectId(String timelineObjectId)
    {
        _timelineObjectId = timelineObjectId;
    }

    public Integer getProjectItemId()
    {
        return _projectItemId;
    }

    public void setProjectItemId(Integer projectItemId)
    {
        _projectItemId = projectItemId;
    }

   public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
    }

    public Integer getStudyDay()
    {
        return _studyDay;
    }

    public void setStudyDay(Integer studyDay)
    {
        _studyDay = studyDay;
    }

    public Date getScheduleDate()
    {
        return _scheduleDate;
    }

    public void setScheduleDate(Date scheduleDate)
    {
        _scheduleDate = scheduleDate;
    }

    @NotNull
    public Map<String, Object> toMap(Container c)
    {
        Map<String, Object> timelineItemValues = new ArrayListMap<>();
        timelineItemValues.put(TIMELINEITEM_TIMELINE_ITEM_ID, getTimelineItemId());
        timelineItemValues.put(TIMELINEITEM_TIMELINE_OBJECT_ID, getTimelineObjectId());
        timelineItemValues.put(TIMELINEITEM_PROJECT_ITEM_ID, getProjectItemId());
        timelineItemValues.put(TIMELINEITEM_STUDY_DAY, getStudyDay());
        timelineItemValues.put(TIMELINEITEM_SCHEDULE_DATE, getScheduleDate());
        timelineItemValues.put(TIMELINEITEM_OBJECT_ID, getObjectId());

        return timelineItemValues;
    }
    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();

        if (getTimelineItemId() != null)
            json.put(TIMELINEITEM_TIMELINE_ITEM_ID, getTimelineItemId());
        if (getObjectId() != null)
            json.put(TIMELINEITEM_OBJECT_ID, getObjectId());

        json.put(TIMELINEITEM_TIMELINE_OBJECT_ID, getTimelineObjectId());
        json.put(TIMELINEITEM_PROJECT_ITEM_ID, getProjectItemId());
        json.put(TIMELINEITEM_STUDY_DAY, getStudyDay());
        json.put(TIMELINEITEM_SCHEDULE_DATE, getScheduleDate());
        json.put(TIMELINEITEM_OBJECT_ID, getObjectId());
        return json;
    }
}
