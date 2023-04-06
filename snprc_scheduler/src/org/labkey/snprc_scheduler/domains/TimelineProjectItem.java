package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;

import java.util.Map;
import java.util.Objects;

/**
 * Created by thawkins on 9/19/2018.
 */

public class TimelineProjectItem
{
    private String _timelineObjectId;    // FK to snprc_scheduler.Timeline
    private Integer _projectItemId;  // FK to snd.ProjectItems
    private String _timelineFootNotes;
    private Integer _sortOrder;
    private String _objectId;
    private Boolean _isDeleted; // NOTE WELL: The deleteFlag set to true signals deletion of the individual TimelineProojectItem record.
    private Boolean _isDirty;    // NOTE WELL: is set to true if the record has been updated
    private Boolean _active;  // virtual field - populated from Active column in snd.ProjectItems

    public static final String TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID = "ProjectItemId";
    public static final String TIMELINE_PROJECT_ITEM_TIMELINE_FOOT_NOTES = "TimelineFootNotes";
    public static final String  TIMELINE_PROJECT_ITEM_SORT_ORDER = "SortOrder";
    public static final String TIMELINE_PROJECT_ITEM_OBJECTID = "ObjectId";
    public static final String TIMELINE_PROJECT_ITEM_IS_DELETED = "IsDeleted";
    public static final String TIMELINE_PROJECT_ITEM_IS_DIRTY = "IsDirty";
    public static final String TIMELINE_PROJECT_ITEM_IS_ACTIVE = "Active";


    public TimelineProjectItem()
    {
        this.setDeleted(false);
        this.setDirty(false);
        this.setActive(true);
    }

    public TimelineProjectItem(JSONObject json) throws RuntimeException
    {
        try
        {
            this.setProjectItemId(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID) ? json.getInt(TimelineProjectItem.TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID) : null);
            this.setTimelineObjectId(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID) ? json.getString(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID) : null);
            this.setSortOrder(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_SORT_ORDER) ? json.getInt(TimelineProjectItem.TIMELINE_PROJECT_ITEM_SORT_ORDER) : null);
            this.setObjectId(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_OBJECTID) ? json.getString(TimelineProjectItem.TIMELINE_PROJECT_ITEM_OBJECTID) : null);
            this.setTimelineFootNotes(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_FOOT_NOTES) ? json.getString(TimelineProjectItem.TIMELINE_PROJECT_ITEM_TIMELINE_FOOT_NOTES) : null);
            this.setDeleted(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_IS_DELETED) && json.getBoolean(TimelineProjectItem.TIMELINE_PROJECT_ITEM_IS_DELETED) );
            this.setDirty(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_IS_DIRTY) && json.getBoolean(TimelineProjectItem.TIMELINE_PROJECT_ITEM_IS_DIRTY) );
            this.setActive(json.has(TimelineProjectItem.TIMELINE_PROJECT_ITEM_IS_ACTIVE) && json.getBoolean(TimelineProjectItem.TIMELINE_PROJECT_ITEM_IS_ACTIVE) );

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

    public Integer getProjectItemId()
    {
        return _projectItemId;
    }

    public void setProjectItemId(Integer projectItemId)
    {
        _projectItemId = projectItemId;
    }

    public Integer getSortOrder()
    {
        return _sortOrder;
    }

    public void setSortOrder(Integer sortOrder)
    {
        _sortOrder = sortOrder;
    }

    public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
    }

    public String getTimelineFootNotes()
    {
        return _timelineFootNotes;
    }

    public void setTimelineFootNotes(String timelineFootNotes)
    {
        _timelineFootNotes = timelineFootNotes;
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

    public Boolean getActive()
    {
        return _active;
    }

    public void setActive(Boolean active)
    {
        _active = active;
    }

    @NotNull
    public Map<String, Object> toMap(Container c)
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID, getProjectItemId());
        values.put(TIMELINE_PROJECT_ITEM_TIMELINE_FOOT_NOTES, getTimelineFootNotes());
        values.put(TIMELINE_PROJECT_ITEM_SORT_ORDER, getSortOrder());
        values.put(TIMELINE_PROJECT_ITEM_OBJECTID, getObjectId());
        values.put(TIMELINE_PROJECT_ITEM_IS_DELETED, getDeleted());
        values.put(TIMELINE_PROJECT_ITEM_IS_DIRTY, getDirty());
        values.put(TIMELINE_PROJECT_ITEM_IS_ACTIVE, getActive());

        return values;
    }
    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();
        json.put(TIMELINE_PROJECT_ITEM_TIMELINE_OBJECT_ID, getTimelineObjectId());
        json.put(TIMELINE_PROJECT_ITEM_PROJECT_ITEM_ID, getProjectItemId());
        json.put(TIMELINE_PROJECT_ITEM_TIMELINE_FOOT_NOTES, getTimelineFootNotes());
        json.put(TIMELINE_PROJECT_ITEM_SORT_ORDER, getSortOrder());
        json.put(TIMELINE_PROJECT_ITEM_OBJECTID, getObjectId());
        json.put(TIMELINE_PROJECT_ITEM_IS_DELETED, getDeleted());
        json.put(TIMELINE_PROJECT_ITEM_IS_DIRTY, getDirty());
        json.put(TIMELINE_PROJECT_ITEM_IS_ACTIVE, getActive());

        return json;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TimelineProjectItem that = (TimelineProjectItem) o;
        return Objects.equals(_timelineObjectId, that._timelineObjectId) &&
                Objects.equals(_projectItemId, that._projectItemId) &&
                Objects.equals(_timelineFootNotes, that._timelineFootNotes) &&
                Objects.equals(_sortOrder, that._sortOrder) &&
                Objects.equals(_objectId, that._objectId) &&
                Objects.equals(_isDeleted, that._isDeleted) &&
                Objects.equals(_isDirty, that._isDirty) &&
                Objects.equals(_active, that._active);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_timelineObjectId, _projectItemId, _timelineFootNotes, _sortOrder, _objectId, _isDeleted, _isDirty, _active);
    }
}
