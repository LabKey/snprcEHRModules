package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.api.util.GUID;

import java.util.Map;

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

    public static final String TIMELINE_PROJECT_ITEMS_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINE_PROJECT_ITEMS_PROJECT_ITEM_ID = "PorjectItemId";
    public static final String TIMELINE_PROJECT_ITEMS_TIMELINE_FOOT_NOTES = "TimelineFootNotes";
    public static final String  TIMELINE_PROJECT_ITEMS_SORT_ORDER = "SortOrder";
    public static final String TIMELINE_PROJECT_ITEMS_OBJECT_ID = "ObjectId";


    public TimelineProjectItem()
    {
    }

    public TimelineProjectItem(String timelineObjectId, Integer projectItemId, String timelineFootNotes, Integer sortOrder, User u)
    {
        _timelineObjectId = timelineObjectId;
        _projectItemId = projectItemId;
        _timelineFootNotes = timelineFootNotes;
        _sortOrder = sortOrder;
        _objectId = GUID.makeGUID();
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


    @NotNull
    public Map<String, Object> toMap(Container c)
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(TIMELINE_PROJECT_ITEMS_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(TIMELINE_PROJECT_ITEMS_PROJECT_ITEM_ID, getProjectItemId());
        values.put(TIMELINE_PROJECT_ITEMS_TIMELINE_FOOT_NOTES, getTimelineFootNotes());
        values.put(TIMELINE_PROJECT_ITEMS_SORT_ORDER, getSortOrder());
        values.put(TIMELINE_PROJECT_ITEMS_OBJECT_ID, getObjectId());

        return values;
    }
    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();
        json.put(TIMELINE_PROJECT_ITEMS_TIMELINE_OBJECT_ID, getTimelineObjectId());
        json.put(TIMELINE_PROJECT_ITEMS_PROJECT_ITEM_ID, getProjectItemId());
        json.put(TIMELINE_PROJECT_ITEMS_TIMELINE_FOOT_NOTES, getTimelineFootNotes());
        json.put(TIMELINE_PROJECT_ITEMS_SORT_ORDER, getSortOrder());
        json.put(TIMELINE_PROJECT_ITEMS_OBJECT_ID, getObjectId());

        return json;
    }

}
