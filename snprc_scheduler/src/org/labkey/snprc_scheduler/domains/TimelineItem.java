package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.util.DateUtil;

import java.text.ParseException;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

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
    private Boolean _isDeleted; // NOTE WELL: The deleteFlag set to true signals deletion of the individual TimelineItem record.
    private Boolean _isDirty;    // NOTE WELL: is set to true if the record has been updated


    public static final String TIMELINEITEM_TIMELINE_ITEM_ID = "TimelineItemId";
    public static final String TIMELINEITEM_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINEITEM_PROJECT_ITEM_ID = "ProjectItemId";
    public static final String TIMELINEITEM_STUDY_DAY = "StudyDay";
    public static final String TIMELINEITEM_SCHEDULE_DATE = "ScheduleDate";
    public static final String TIMELINEITEM_OBJECT_ID = "ObjectId";
    public static final String TIMELINEITEM_IS_DELETED = "IsDeleted";
    public static final String TIMELINEITEM_IS_DIRTY = "IsDirty";


    public TimelineItem()
    {
        this.setDeleted(false);
        this.setDirty(false);
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
            this.setDeleted(json.has(TimelineItem.TIMELINEITEM_IS_DELETED) && json.getBoolean(TimelineItem.TIMELINEITEM_IS_DELETED));
            this.setDirty(json.has(TimelineItem.TIMELINEITEM_IS_DIRTY) && json.getBoolean(TimelineItem.TIMELINEITEM_IS_DIRTY));

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

    public Boolean getDeleted()
    {
        return _isDeleted;
    }

    public void setDeleted(Boolean deleted)
    {
        _isDeleted = deleted;
    }

    public Boolean getDirty()
    {
        return _isDirty;
    }

    public void setDirty(Boolean dirty)
    {
        _isDirty = dirty;
    }

    @NotNull
    public Map<String, Object> toMap(Container c)
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(TIMELINEITEM_TIMELINE_ITEM_ID, getTimelineItemId());
        values.put(TIMELINEITEM_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(TIMELINEITEM_PROJECT_ITEM_ID, getProjectItemId());
        values.put(TIMELINEITEM_STUDY_DAY, getStudyDay());
        values.put(TIMELINEITEM_SCHEDULE_DATE, getScheduleDate());
        values.put(TIMELINEITEM_OBJECT_ID, getObjectId());
        values.put(TIMELINEITEM_IS_DELETED, getDeleted());
        values.put(TIMELINEITEM_IS_DIRTY, getDirty());

        return values;
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
        json.put(TIMELINEITEM_IS_DELETED, getDeleted());
        json.put(TIMELINEITEM_IS_DIRTY, getDirty());
        return json;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TimelineItem that = (TimelineItem) o;
        return Objects.equals(_timelineItemId, that._timelineItemId) &&
                Objects.equals(_timelineObjectId, that._timelineObjectId) &&
                Objects.equals(_projectItemId, that._projectItemId) &&
                Objects.equals(_studyDay, that._studyDay) &&
                Objects.equals(_scheduleDate, that._scheduleDate) &&
                Objects.equals(_objectId, that._objectId) &&
                Objects.equals(_isDeleted, that._isDeleted) &&
                Objects.equals(_isDirty, that._isDirty);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_timelineItemId, _timelineObjectId, _projectItemId, _studyDay, _scheduleDate, _objectId, _isDeleted, _isDirty);
    }
}
