package org.labkey.snprc_scheduler.domains;


        import org.jetbrains.annotations.NotNull;
import org.json.old.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;

import java.util.Map;
        import java.util.Objects;

/**
 * Created by thawkins on 6/6/2019.
 */
public class StudyDayNotes
{
    private String _timelineObjectId;    // FK to snprc_scheduler.TimelineItem
    private Integer _studyDay;           // FK to snprc_scheduler.TimelineItem
    private String _studyDayNote;
    private String _objectId;
    private Boolean _isDeleted; // NOTE WELL: The deleteFlag set to true signals deletion of the individual StudyDayNote record.
    private Boolean _isDirty;    // NOTE WELL: is set to true if the record has been updated

    public static final String STUDYDAY_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String STUDYDAY_STUDY_DAY = "StudyDay";
    public static final String STUDYDAY_STUDY_DAY_NOTE = "StudyDayNote";
    public static final String STUDYDAY_OBJECT_ID = "ObjectId";
    public static final String STUDYDAY_IS_DELETED = "IsDeleted";
    public static final String STUDYDAY_IS_DIRTY = "IsDirty";

    public StudyDayNotes()
    {
        this.setDeleted(false);
        this.setDirty(false);
    }

    public StudyDayNotes(JSONObject json) throws RuntimeException
    {
        try
        {
            this.setTimelineObjectId(json.has(STUDYDAY_TIMELINE_OBJECT_ID) && !json.isNull(STUDYDAY_TIMELINE_OBJECT_ID) ? json.getString(STUDYDAY_TIMELINE_OBJECT_ID) : null);
            this.setStudyDay(json.has(STUDYDAY_STUDY_DAY) && !json.isNull(STUDYDAY_STUDY_DAY) ? json.getInt(STUDYDAY_STUDY_DAY) : null);
            this.setStudyDayNote(json.has(STUDYDAY_STUDY_DAY_NOTE) && !json.isNull(STUDYDAY_STUDY_DAY_NOTE) ? json.getString(STUDYDAY_STUDY_DAY_NOTE) : null);
            this.setObjectId(json.has(STUDYDAY_OBJECT_ID) && !json.isNull(STUDYDAY_OBJECT_ID) ? json.getString(STUDYDAY_OBJECT_ID) : null);
            this.setDeleted(json.has(STUDYDAY_IS_DELETED) && !json.isNull(STUDYDAY_IS_DELETED) && json.getBoolean(STUDYDAY_IS_DELETED));
            this.setDirty(json.has(STUDYDAY_IS_DIRTY) && !json.isNull(STUDYDAY_IS_DIRTY) && json.getBoolean(STUDYDAY_IS_DIRTY));
        }
        catch (Exception e)
        {
            throw new RuntimeException ( e.getMessage() ) ;
        }
    }



    public String getTimelineObjectId()
    {
        return _timelineObjectId;
    }

    public void setTimelineObjectId(String timelineObjectId)
    {
        _timelineObjectId = timelineObjectId;
    }

    public Integer getStudyDay()
    {
        return _studyDay;
    }

    public void setStudyDay(Integer studyDay)
    {
        _studyDay = studyDay;
    }

    public String getStudyDayNote()
    {
        return _studyDayNote;
    }

    public void setStudyDayNote(String studyDayNote)
    {
        _studyDayNote = studyDayNote;
    }

    public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
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
        values.put(STUDYDAY_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(STUDYDAY_OBJECT_ID, getObjectId());
        values.put(STUDYDAY_STUDY_DAY, getStudyDay());
        values.put(STUDYDAY_STUDY_DAY_NOTE, getStudyDayNote());
        values.put(STUDYDAY_IS_DELETED, getDeleted());
        values.put(STUDYDAY_IS_DIRTY, getDirty());

        return values;
    }

    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();

        if (getTimelineObjectId() != null)
            json.put(STUDYDAY_TIMELINE_OBJECT_ID, getTimelineObjectId());
        if (getObjectId() != null)
            json.put(STUDYDAY_OBJECT_ID, getObjectId());
        if (getStudyDay() != null)
            json.put(STUDYDAY_STUDY_DAY, getStudyDay());
        if (getStudyDayNote() != null)
            json.put(STUDYDAY_STUDY_DAY_NOTE, getStudyDayNote());
        if (getDeleted() != null)
            json.put(STUDYDAY_IS_DELETED, getDeleted());
        if (getDirty() != null)
            json.put(STUDYDAY_IS_DIRTY, getDirty());
        return json;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StudyDayNotes that = (StudyDayNotes) o;
        return _timelineObjectId.equals(that._timelineObjectId) &&
                _studyDay.equals(that._studyDay) &&
                Objects.equals(_studyDayNote, that._studyDayNote) &&
                Objects.equals(_objectId, that._objectId);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_timelineObjectId, _studyDay, _studyDayNote, _objectId);
    }
}
