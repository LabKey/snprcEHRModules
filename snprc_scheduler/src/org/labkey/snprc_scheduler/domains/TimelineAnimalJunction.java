package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.util.DateUtil;

import java.text.ParseException;
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
    private Date _endDate;
    private String _assignmentStatus;
    private String _gender;
    private Double _weight;
    private String _age;
    private String _objectId;

    public static final String TIMELINE_ANIMAL_JUNCTION_ROW_ID = "RowId";
    public static final String TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID = "AnimalId";
    public static final String TIMELINE_ANIMAL_JUNCTION_END_DATE = "EndDate";
    public static final String TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS = "AssignmentStatus";
    public static final String TIMELINE_ANIMAL_JUNCTION_GENDER = "Gender";
    public static final String TIMELINE_ANIMAL_JUNCTION_WEIGHT = "Weight";
    public static final String TIMELINE_ANIMAL_JUNCTION_AGE = "Age";
    public static final String TIMELINE_ANIMAL_JUNCTION_OBJECT_ID = "ObjectId";

    public TimelineAnimalJunction()
    {
    }

    public TimelineAnimalJunction(String timelineObjectId, String animalId, String objectId)
    {
        _timelineObjectId = timelineObjectId;
        _animalId = animalId;
        _objectId = objectId;
    }

    public TimelineAnimalJunction(JSONObject json) throws RuntimeException
    {
        try
        {
            this.setRowId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID) ? json.getInt(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID) : null);
            this.setTimelineObjectId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID) : null);
            this.setAnimalId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID) : null);
            this.setAssignmentStatus(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS) : null);
            this.setGender(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_GENDER) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_GENDER) : null);
            this.setAge(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_AGE) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_AGE) : null);
            this.setWeight(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_WEIGHT) ? json.getDouble(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_WEIGHT) : null);
            this.setObjectId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID) : null);

            String endDateString = json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_END_DATE) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_END_DATE) : null;
            Date scheduleDate = null;

            try
            {
                this.setEndDate(endDateString == null ? null : DateUtil.parseDateTime(endDateString, Timeline.TIMELINE_DATE_FORMAT));

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

    public String getAssignmentStatus()
    {
        return _assignmentStatus;
    }

    public void setAssignmentStatus(String assignmentStatus)
    {
        _assignmentStatus = assignmentStatus;
    }

    public String getGender()
    {
        return _gender;
    }

    public void setGender(String gender)
    {
        _gender = gender;
    }

    public Double getWeight()
    {
        return _weight;
    }

    public void setWeight(Double weight)
    {
        _weight = weight;
    }

    public String getAge()
    {
        return _age;
    }

    public void setAge(String age)
    {
        _age = age;
    }

    @NotNull
    public Map<String, Object> toMap(Container c)
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(TIMELINE_ANIMAL_JUNCTION_ROW_ID, getRowId());
        values.put(TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID, getAnimalId());
        values.put(TIMELINE_ANIMAL_JUNCTION_END_DATE, getEndDate());
        values.put(TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS, getAssignmentStatus());
        values.put(TIMELINE_ANIMAL_JUNCTION_GENDER, getGender());
        values.put(TIMELINE_ANIMAL_JUNCTION_WEIGHT, getWeight());
        values.put(TIMELINE_ANIMAL_JUNCTION_AGE, getAge());
        values.put(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID, getObjectId());

        return values;
    }

    @NotNull
    public JSONObject toJSON(Container c)
    {
        JSONObject json = new JSONObject();
        json.put(TIMELINE_ANIMAL_JUNCTION_ROW_ID, getRowId());
        json.put(TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID, getTimelineObjectId());
        json.put(TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID, getAnimalId());
        json.put(TIMELINE_ANIMAL_JUNCTION_END_DATE, getEndDate());
        json.put(TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS, getAssignmentStatus());
        json.put(TIMELINE_ANIMAL_JUNCTION_GENDER, getGender());
        json.put(TIMELINE_ANIMAL_JUNCTION_WEIGHT, getWeight());
        json.put(TIMELINE_ANIMAL_JUNCTION_AGE, getAge());
        json.put(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID, getObjectId());

        return json;
    }
}
