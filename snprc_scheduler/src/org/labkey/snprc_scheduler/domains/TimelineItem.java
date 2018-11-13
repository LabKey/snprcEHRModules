package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.api.util.GUID;

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
    public static final String TIMELINEITEM_SCHEDULED_DAY = "ScheduleDate";
    public static final String TIMELINEITEM_OBJECTID = "ObjectId";
    public static final String TIMELINEITEM_PROJECT_ITEM = "ProjectItem";


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
        timelineItemValues.put(TIMELINEITEM_SCHEDULED_DAY, getScheduleDate());
        timelineItemValues.put(TIMELINEITEM_OBJECTID, getObjectId());

        return timelineItemValues;
    }
    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();

        if (getTimelineItemId() != null)
            json.put(TIMELINEITEM_TIMELINE_ITEM_ID, getTimelineItemId());
        if (getObjectId() != null)
            json.put(TIMELINEITEM_OBJECTID, getObjectId());

        json.put(TIMELINEITEM_TIMELINE_OBJECT_ID, getTimelineObjectId());
        json.put(TIMELINEITEM_PROJECT_ITEM_ID, getProjectItemId());
        json.put(TIMELINEITEM_STUDY_DAY, getStudyDay());
        json.put(TIMELINEITEM_SCHEDULED_DAY, getScheduleDate());
        json.put(TIMELINEITEM_OBJECTID, getObjectId());
        return json;
    }
}
