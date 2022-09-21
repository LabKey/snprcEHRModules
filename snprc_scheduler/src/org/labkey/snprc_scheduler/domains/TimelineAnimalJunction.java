package org.labkey.snprc_scheduler.domains;


import org.jetbrains.annotations.NotNull;
import org.json.old.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.util.DateUtil;

import java.text.ParseException;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

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
    private String _location;
    private String _cage;
    private String _objectId;
    private Boolean _isDeleted; // NOTE WELL: The deleteFlag set to true signals deletion of the individual TimelineAnimalJunction record.
    private Boolean _isDirty;    // NOTE WELL: is set to true if the record has been updated

    public static final String TIMELINE_ANIMAL_JUNCTION_ROW_ID = "RowId";
    public static final String TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID = "TimelineObjectId";
    public static final String TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID = "AnimalId";
    public static final String TIMELINE_ANIMAL_JUNCTION_END_DATE = "EndDate";
    public static final String TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS = "AssignmentStatus";
    public static final String TIMELINE_ANIMAL_JUNCTION_GENDER = "Gender";
    public static final String TIMELINE_ANIMAL_JUNCTION_WEIGHT = "Weight";
    public static final String TIMELINE_ANIMAL_JUNCTION_AGE = "Age";
    public static final String TIMELINE_ANIMAL_JUNCTION_LOCATION = "Location";
    public static final String TIMELINE_ANIMAL_JUNCTION_CAGE = "Cage";
    public static final String TIMELINE_ANIMAL_JUNCTION_OBJECT_ID = "ObjectId";
    public static final String TIMELINE_ANIMAL_JUNCTION_IS_DELETED = "IsDeleted";
    public static final String TIMELINE_ANIMAL_JUNCTION_IS_DIRTY = "IsDirty";

    public TimelineAnimalJunction()
    {
        this.setDeleted(false);
        this.setDirty(false);
    }

    public TimelineAnimalJunction(JSONObject json) throws RuntimeException
    {
        try
        {
            // TODO: Update or remove commented out lines once we get to animal assignment
            this.setRowId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_ROW_ID)  ? json.getInt(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ROW_ID) : null);
            this.setTimelineObjectId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID) : null);
            this.setAnimalId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID) : null);
            this.setAssignmentStatus(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS) : null);
            this.setGender(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_GENDER) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_GENDER)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_GENDER) : null);
            this.setAge(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_AGE) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_AGE)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_AGE) : null);
            this.setLocation(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_LOCATION) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_LOCATION)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_LOCATION) : null);
            this.setCage(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_CAGE) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_CAGE)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_CAGE) : null);
            this.setWeight(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_WEIGHT) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_WEIGHT)  ? json.getDouble(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_WEIGHT) : null);
            this.setObjectId(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID)  ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_OBJECT_ID) : null);
            this.setDeleted(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_IS_DELETED) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_IS_DELETED)  && json.getBoolean(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_IS_DELETED));
            this.setDirty(json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_IS_DIRTY) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_IS_DIRTY)  && json.getBoolean(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_IS_DIRTY));

            String endDateString = json.has(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_END_DATE) && !json.isNull(TIMELINE_ANIMAL_JUNCTION_END_DATE) ? json.getString(TimelineAnimalJunction.TIMELINE_ANIMAL_JUNCTION_END_DATE) : null;
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

    public String getLocation()
    {
        return _location;
    }

    public void setLocation(String location)
    {
        _location = location;
    }

    public String getCage()
    {
        return _cage;
    }

    public void setCage(String cage)
    {
        _cage = cage;
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
        values.put(TIMELINE_ANIMAL_JUNCTION_ROW_ID, getRowId());
        values.put(TIMELINE_ANIMAL_JUNCTION_TIMELINE_OBJECT_ID, getTimelineObjectId());
        values.put(TIMELINE_ANIMAL_JUNCTION_ANIMAL_ID, getAnimalId());
        values.put(TIMELINE_ANIMAL_JUNCTION_END_DATE, getEndDate());
        values.put(TIMELINE_ANIMAL_JUNCTION_ASSIGNMENT_STATUS, getAssignmentStatus());
        values.put(TIMELINE_ANIMAL_JUNCTION_GENDER, getGender());
        values.put(TIMELINE_ANIMAL_JUNCTION_WEIGHT, getWeight());
        values.put(TIMELINE_ANIMAL_JUNCTION_AGE, getAge());
        values.put(TIMELINE_ANIMAL_JUNCTION_LOCATION, getLocation());
        values.put(TIMELINE_ANIMAL_JUNCTION_CAGE, getCage());
        values.put(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID, getObjectId());
        values.put(TIMELINE_ANIMAL_JUNCTION_IS_DELETED, getDeleted());
        values.put(TIMELINE_ANIMAL_JUNCTION_IS_DIRTY, getDirty());

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
        json.put(TIMELINE_ANIMAL_JUNCTION_LOCATION, getLocation());
        json.put(TIMELINE_ANIMAL_JUNCTION_CAGE, getCage());
        json.put(TIMELINE_ANIMAL_JUNCTION_OBJECT_ID, getObjectId());
        json.put(TIMELINE_ANIMAL_JUNCTION_IS_DELETED, getDeleted());
        json.put(TIMELINE_ANIMAL_JUNCTION_IS_DIRTY, getDirty());

        return json;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TimelineAnimalJunction that = (TimelineAnimalJunction) o;
        return Objects.equals(_rowId, that._rowId) &&
                Objects.equals(_timelineObjectId, that._timelineObjectId) &&
                Objects.equals(_animalId, that._animalId) &&
                Objects.equals(_endDate, that._endDate) &&
                Objects.equals(_assignmentStatus, that._assignmentStatus) &&
                Objects.equals(_gender, that._gender) &&
                Objects.equals(_weight, that._weight) &&
                Objects.equals(_age, that._age) &&
                Objects.equals(_location, that._location) &&
                Objects.equals(_cage, that._cage) &&
                Objects.equals(_objectId, that._objectId) &&
                Objects.equals(_isDeleted, that._isDeleted) &&
                Objects.equals(_isDirty, that._isDirty);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_rowId, _timelineObjectId, _animalId, _endDate, _assignmentStatus, _gender, _weight, _age, _location, _cage, _objectId, _isDeleted, _isDirty);
    }
}
