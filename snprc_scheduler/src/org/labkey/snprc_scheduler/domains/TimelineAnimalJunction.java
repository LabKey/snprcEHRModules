package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;

import java.util.Date;
import java.util.Map;

/**
 * Created by thawkins on 9/19/2018.
 */
public class TimelineAnimalJunction
{

    private Integer _rowId;         //PK
    private String _timelineObjectId;    // FK to snprc_scheduler.Timeline
    private String _animalId;       // FK to study.assignment
    //private Date _startDate;
    private Date _endDate;
    private String _objectId;

    public static final String TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINE_ANIMAL_JUNCTION_TIMELINE_REVISION_NUM = "TimelineRevisionNum";
    public static final String TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID = "AnimalId";
    //public static final String TIMELINE_ANIMAL_JUNCTION_START_DATE = "StartDate";
    public static final String TIMELINE_ANIMAL_JUNCTION_END_DATE = "EndDate";
    public static final String TIMELINE_ANIMAL_JUNCTION_OBJECT_ID = "ObjectId";

    public TimelineAnimalJunction()
    {
    }


    public String getTimelineObjectId()
    {
        return _timelineObjectId;
    }

    public void setTimelineObjectId(String timelineObjectId)
    {
        _timelineObjectId = timelineObjectId;
    }

    public String getAnimalId()
    {
        return _animalId;
    }

    public void setAnimalId(String animalId)
    {
        _animalId = animalId;
    }

    public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
    }

    public Integer getRowId()
    {
        return _rowId;
    }

    public void setRowId(Integer rowId)
    {
        _rowId = rowId;
    }

    public Date getEndDate()
    {
        return _endDate;
    }

    public void setEndDate(Date endDate)
    {
        _endDate = endDate;
    }



    @NotNull
    public Map<String, Object> getTimelineAnimalJunctionRow(Container c)
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID, getAnimalId());
        values.put(TIMELINE_ANIMAL_JUNCTION_END_DATE, getEndDate());
        values.put(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID, getObjectId());

        return values;
    }

    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();
        json.put(TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID, getTimelineObjectId());
        json.put(TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID, getAnimalId());
        json.put(TIMELINE_ANIMAL_JUNCTION_END_DATE, getEndDate());
        json.put(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID, getObjectId());

        return json;
    }
}
