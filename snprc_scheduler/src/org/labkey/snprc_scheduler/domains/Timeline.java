package org.labkey.snprc_scheduler.domains;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.snprc_scheduler.SNPRC_schedulerManager;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Created by thawkins on 9/13/2018.
 * <p>
 * Class for Timeline table data. Used when saving, updating, deleting and getting a Timeline table
 */

public class Timeline //extends Entity
{
    private Integer _timelineId;
    private Integer _revisionNum;
    private String _description;
    private Date _startDate;
    private Date _endDate;
    private String _leadTech;
    private String _notes;
    private String _schedulerNotes;
    private String _objectId;
    private Integer _projectId;
    private Integer _projectRevisionNum;
    private String _projectObjectId;
    private String _rc;
    private Date _created;
    private Date _modified;
    private Integer _createdBy;
    private Integer _modifiedBy;
    private String _createdByName;
    private String _modifiedByName;
    private Integer _qcState;
    private Boolean _isDeleted; // NOTE WELL: The deleteFlag set to true signals deletion of the timeline record and all associated TimelineItem, TimelineAnimalJunction, TimelineProject items.
    private Boolean _isDirty;    // NOTE WELL: is set to true if the record has been updated
    private Boolean _isInUse;    // NOTE WELL: is set to true if TBD
    private List<TimelineItem> _timelineItems = new ArrayList<>(); // list of TimelineItem objects associated with the timeline
    private List<TimelineProjectItem> _timelineProjectItems = new ArrayList<>(); // list of TimelineProjectItem objects associated with the timeline
    private List<TimelineAnimalJunction> _timelineAnimalItems = new ArrayList<>(); // list of animals assigned to timeline

    public static final String TIMELINE_ID = "TimelineId";
    public static final String TIMELINE_REVISION_NUM = "RevisionNum";
    public static final String TIMELINE_DESCRIPTION = "Description";
    public static final String TIMELINE_STARTDATE = "StartDate";
    public static final String TIMELINE_ENDDATE = "EndDate";
    public static final String TIMELINE_OBJECTID = "ObjectId";
    public static final String TIMELINE_CONTAINER = "Container";
    public static final String TIMELINE_LEAD_TECHS = "LeadTech";
    public static final String TIMELINE_NOTES = "Notes";
    public static final String TIMELINE_SCHEDULER_NOTES = "SchedulerNotes";
    public static final String TIMELINE_PROJECT_ID = "ProjectId";
    public static final String TIMELINE_PROJECT_REVISION_NUM = "ProjectRevisionNum";
    public static final String TIMELINE_DATE_CREATED = "Created";
    public static final String TIMELINE_DATE_MODIFIED = "Modified";
    public static final String TIMELINE_CREATED_BY = "CreatedBy";
    public static final String TIMELINE_MODIFIED_BY = "ModifiedBy";
    public static final String TIMELINE_CREATED_BY_NAME = "CreatedByName";
    public static final String TIMELINE_MODIFIED_BY_NAME = "ModifiedByName";
    public static final String TIMELINE_QCSTATE = "QcState";
    public static final String TIMELINE_TIMELINE_ITEMS = "TimelineItems";
    public static final String TIMELINE_TIMELINE_PROJECT_ITEMS = "TimelineProjectItems";
    public static final String TIMELINE_PROJECT_OBJECT_ID = "ProjectObjectId";
    public static final String TIMELINE_ANIMAL_ITEMS = "TimelineAnimalItems";
    public static final String TIMELINE_IS_DELETED = "IsDeleted";
    public static final String TIMELINE_IS_DIRTY = "IsDirty";
    public static final String TIMELINE_IS_IN_USE = "IsInUse";
    public static final String TIMELINE_RC = "RC";

    public static final String TIMELINE_DATE_FORMAT = "yyyy-MM-dd";  //
    public static final String TIMELINE_DATE_TIME_FORMAT = "yyyy-MM-dd'T'kk:mm:ss";  // ISO8601 w/24-hour time and 'T' character
    public static final String SQL_DATE_TIME_FORMAT = "yyyy-MM-dd HH:mm:ss:SSS";

    public Timeline()
    {
        this.setDeleted(false);
        this.setDirty(false);
        this.setInUse(false);
    }

    public Timeline(Container c, User u, JSONObject json) throws RuntimeException
    {
        try
        {
            this.setTimelineId(json.has(Timeline.TIMELINE_ID) ? json.getInt(Timeline.TIMELINE_ID) : null);
            this.setRevisionNum(json.has(Timeline.TIMELINE_REVISION_NUM) ? json.getInt(Timeline.TIMELINE_REVISION_NUM) : null);
            this.setLeadTech(json.has(Timeline.TIMELINE_LEAD_TECHS) ? json.getString(Timeline.TIMELINE_LEAD_TECHS) : null);
            this.setNotes(json.has(Timeline.TIMELINE_NOTES) ? json.getString(Timeline.TIMELINE_NOTES) : null);
            this.setSchedulerNotes(json.has(Timeline.TIMELINE_SCHEDULER_NOTES) ? json.getString(Timeline.TIMELINE_SCHEDULER_NOTES) : null);
            this.setObjectId(json.has(Timeline.TIMELINE_OBJECTID) ? json.getString(Timeline.TIMELINE_OBJECTID) : null);
            this.setCreatedBy(c, u, json.has(Timeline.TIMELINE_CREATED_BY) ? json.getInt(Timeline.TIMELINE_CREATED_BY): null);
            this.setModifiedBy(c, u, json.has(Timeline.TIMELINE_MODIFIED_BY) ? json.getInt(Timeline.TIMELINE_MODIFIED_BY): null);
            this.setCreatedByName(json.has(Timeline.TIMELINE_CREATED_BY_NAME) ?json.getString(Timeline.TIMELINE_CREATED_BY_NAME): null);
            this.setModifiedByName(json.has(Timeline.TIMELINE_MODIFIED_BY_NAME) ?json.getString(Timeline.TIMELINE_MODIFIED_BY_NAME): null);
            this.setDescription(json.has(Timeline.TIMELINE_DESCRIPTION) ? json.getString(Timeline.TIMELINE_DESCRIPTION) : null);
            this.setQcState(json.has(Timeline.TIMELINE_QCSTATE) ? json.getInt(Timeline.TIMELINE_QCSTATE) : null);
            this.setProjectObjectId(json.has(Timeline.TIMELINE_PROJECT_OBJECT_ID) ? json.getString(Timeline.TIMELINE_PROJECT_OBJECT_ID) : null);
            this.setProjectId(json.has(Timeline.TIMELINE_PROJECT_ID) ? json.getInt(Timeline.TIMELINE_PROJECT_ID) : null);
            this.setProjectRevisionNum(json.has(Timeline.TIMELINE_PROJECT_REVISION_NUM) ? json.getInt(Timeline.TIMELINE_PROJECT_REVISION_NUM) : null);
            this.setDeleted(json.has(Timeline.TIMELINE_IS_DELETED) && json.getBoolean(Timeline.TIMELINE_IS_DELETED));
            this.setDirty(json.has(Timeline.TIMELINE_IS_DIRTY) && json.getBoolean(Timeline.TIMELINE_IS_DIRTY));
            this.setInUse(json.has(Timeline.TIMELINE_IS_IN_USE) && json.getBoolean(Timeline.TIMELINE_IS_IN_USE));
            this.setRc(json.has(Timeline.TIMELINE_RC) ? json.getString(Timeline.TIMELINE_RC) : null);

            String startDateString = json.has(Timeline.TIMELINE_STARTDATE) ? json.getString(Timeline.TIMELINE_STARTDATE) : null;
            String endDateString = json.has(Timeline.TIMELINE_ENDDATE) ? json.getString(Timeline.TIMELINE_ENDDATE) : null;
            String createdDateString = json.has(Timeline.TIMELINE_DATE_CREATED) ? json.getString(Timeline.TIMELINE_DATE_CREATED) : null;
            String modifiedDateString = json.has(Timeline.TIMELINE_DATE_MODIFIED) ? json.getString(Timeline.TIMELINE_DATE_MODIFIED) : null;

            try
            {
                this.setStartDate(startDateString == null ? new Date() : DateUtil.parseDateTime(startDateString, Timeline.TIMELINE_DATE_FORMAT));
                this.setEndDate(endDateString == null ? null : DateUtil.parseDateTime(endDateString, Timeline.TIMELINE_DATE_FORMAT));
                this.setCreated(createdDateString == null ? new Date() : DateUtil.parseDateTime(createdDateString, Timeline.TIMELINE_DATE_FORMAT));
                this.setModified(modifiedDateString == null ? new Date() : DateUtil.parseDateTime(modifiedDateString, Timeline.TIMELINE_DATE_FORMAT));
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
    public Integer getTimelineId()
    {
        return _timelineId;
    }

    public void setTimelineId(Integer timelineId)
    {
        _timelineId = timelineId;
    }

    public String getDescription()
    {
        return _description;
    }

    public void setDescription(String description)
    {
        _description = description;
    }

    public Date getStartDate()
    {
        return _startDate;
    }

    @Nullable
    public String startDateToString()
    {

        return DateUtil.formatDateISO8601(getStartDate());
    }

    public void setStartDate(Date startDate)
    {
        _startDate = startDate;
    }

    public Date getEndDate()
    {
        return _endDate;
    }

    @Nullable
    public String endDateToString()
    {

        return DateUtil.formatDateISO8601(getEndDate());
    }

    public void setEndDate(Date endDate)
    {
        _endDate = endDate;
    }

    public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
    }

    public Integer getProjectId()
    {
        return _projectId;
    }

    public void setProjectId(Integer projectId)
    {
        _projectId = projectId;
    }

    public Integer getRevisionNum()
    {
        return _revisionNum;
    }

    public void setRevisionNum(Integer revisionNum)
    {
        _revisionNum = revisionNum;
    }

    public String getLeadTech()
    {
        return _leadTech;
    }

    public void setLeadTech(String leadTech)
    {
        _leadTech = leadTech;
    }

    public Date getCreated()
    {
        return _created;
    }

    public void setCreated(Date created)
    {
        _created = created;
    }

    @Nullable
    public String modifiedDateToString()
    {
        return DateUtil.formatDateISO8601(getModified());
    }

    @Nullable
    public String createdDateToString()
    {
        return DateUtil.formatDateISO8601(getCreated());
    }

    public Date getModified()
    {
        return _modified;
    }

    public void setModified(Date modified)
    {
        _modified = modified;
    }

    public void setCreatedBy(Integer createdBy)
    {
        _createdBy = createdBy;
    }

    public void setModifiedBy(Integer modifiedBy)
    {
        _modifiedBy = modifiedBy;
    }

    public void setCreatedBy(Container c, User u, Integer createdBy)
    {
        _createdBy = createdBy;
        if (_createdBy != null)
        {
            _createdByName = SNPRC_schedulerManager.getUserDisplayName(_createdBy);
        }
        else
        {
            _createdByName = null;
        }

    }


    public void setModifiedBy(Container c, User u, Integer modifiedBy)
    {
        _modifiedBy = modifiedBy;
        if (_modifiedBy != null)
        {
            _modifiedByName = SNPRC_schedulerManager.getUserDisplayName(_modifiedBy);
        }
        else
        {
            _modifiedByName = null;
        }
    }

    public String getSchedulerNotes()
    {
        return _schedulerNotes;
    }

    public void setSchedulerNotes(String schedulerNotes)
    {
        _schedulerNotes = schedulerNotes;
    }

    public Integer getProjectRevisionNum()
    {
        return _projectRevisionNum;
    }

    public void setProjectRevisionNum(Integer projectRevisionNum)
    {
        _projectRevisionNum = projectRevisionNum;
    }

    public Integer getQcState()
    {
        return _qcState;
    }

    public void setQcState(Integer qcState)
    {
        _qcState = qcState;
    }

    public String getNotes()
    {
        return _notes;
    }

    public void setNotes(String notes)
    {
        _notes = notes;
    }

    public List<TimelineItem> getTimelineItems()
    {
        return _timelineItems;
    }

    public void setTimelineItems(List<TimelineItem> timelineItems)
    {
        _timelineItems = timelineItems;
    }

    public List<TimelineProjectItem> getTimelineProjectItems()
    {
        return _timelineProjectItems;
    }

    public void setTimelineProjectItems(List<TimelineProjectItem> timelineProjectItems)
    {
        _timelineProjectItems = timelineProjectItems;
    }

    public String getProjectObjectId()
    {
        return _projectObjectId;
    }

    public void setProjectObjectId(String projectObjectId)
    {
        _projectObjectId = projectObjectId;
    }

    public Integer getCreatedBy() {
        return _createdBy;
    }

    public Integer getModifiedBy() {
        return _modifiedBy;
    }

    public List<TimelineAnimalJunction> getTimelineAnimalItems()
    {
        return _timelineAnimalItems;
    }

    public void setTimelineAnimalItems(List<TimelineAnimalJunction> timelineAnimalItems)
    {
        _timelineAnimalItems = timelineAnimalItems;
    }

    public String getCreatedByName()
    {
        return _createdByName;
    }

    public void setCreatedByName(String createdByName)
    {
        _createdByName = createdByName;
    }

    public String getModifiedByName()
    {
        return _modifiedByName;
    }

    public void setModifiedByName(String modifiedByName)
    {
        _modifiedByName = modifiedByName;
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

    public String getRc()
    {
        return _rc;
    }

    public void setRc(String rc)
    {
        _rc = rc;
    }

    public Boolean getInUse()
    {
//        return true;
        return _isInUse;
    }

    public void setInUse(Boolean inUse)
    {
        _isInUse = inUse;
    }

    @NotNull
    public Map<String, Object> toMap(Container c, User u)
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(TIMELINE_ID, getTimelineId());
        values.put(TIMELINE_REVISION_NUM, getRevisionNum());
        values.put(TIMELINE_DESCRIPTION, getDescription());
        values.put(TIMELINE_STARTDATE, getStartDate());
        values.put(TIMELINE_ENDDATE, getEndDate());
        values.put(TIMELINE_OBJECTID, getObjectId());
        values.put(TIMELINE_CONTAINER, c.getId());
        values.put(TIMELINE_LEAD_TECHS, getLeadTech());
        values.put(TIMELINE_NOTES, getNotes());
        values.put(TIMELINE_SCHEDULER_NOTES,getSchedulerNotes());
        values.put(TIMELINE_PROJECT_ID, getProjectId());
        values.put(TIMELINE_PROJECT_REVISION_NUM, getProjectRevisionNum());
        values.put(TIMELINE_DATE_CREATED, getCreated());
        values.put(TIMELINE_DATE_MODIFIED, getModified());
        values.put(TIMELINE_CREATED_BY, getCreatedBy());
        values.put(TIMELINE_MODIFIED_BY, getModifiedBy());
        values.put(TIMELINE_CREATED_BY_NAME, getCreatedByName());
        values.put(TIMELINE_MODIFIED_BY_NAME, getModifiedByName());
        values.put(TIMELINE_QCSTATE, getQcState());
        values.put(TIMELINE_PROJECT_OBJECT_ID, getProjectObjectId());
        values.put(TIMELINE_IS_DELETED, getDeleted());
        values.put(TIMELINE_IS_DIRTY, getDirty());
        values.put(TIMELINE_IS_IN_USE, getInUse());
        values.put(TIMELINE_RC, getRc());

        if (getTimelineItems().size() > 0)
        {
            List<Map<String, Object>> listTimelineItems = new ArrayList<>();
            for (TimelineItem timelineItem : getTimelineItems())
            {
                listTimelineItems.add(timelineItem.toMap(c));
            }
            values.put(TIMELINE_TIMELINE_ITEMS, listTimelineItems);
        }
        if (getTimelineProjectItems().size() > 0)
        {
            List<Map<String, Object>> listTimelineProjectItems = new ArrayList<>();
            for (TimelineProjectItem timelineProjectItem : getTimelineProjectItems())
            {
                listTimelineProjectItems.add(timelineProjectItem.toMap(c));
            }
            values.put(TIMELINE_TIMELINE_PROJECT_ITEMS, listTimelineProjectItems);
        }
        if (getTimelineAnimalItems().size() > 0)
        {
            List<Map<String, Object>> listTimelineAnimalItems = new ArrayList<>();
            for (TimelineAnimalJunction timelineAnimalItem : getTimelineAnimalItems())
            {
                listTimelineAnimalItems.add(timelineAnimalItem.toMap(c));
            }
            values.put(TIMELINE_ANIMAL_ITEMS, listTimelineAnimalItems);
        }

        return values;
    }

    @NotNull
    public JSONObject toJSON(Container c, User u)
    {
        JSONObject json = new JSONObject();


        if (getTimelineId() != null)
            json.put(TIMELINE_ID, getTimelineId());
        if (getRevisionNum() != null)
            json.put(TIMELINE_REVISION_NUM, getRevisionNum());
        json.put(TIMELINE_DESCRIPTION, getDescription());
        json.put(TIMELINE_STARTDATE, startDateToString());
        if (getEndDate() != null)
            json.put(TIMELINE_ENDDATE, endDateToString());
        if (getObjectId() != null)
          json.put(TIMELINE_OBJECTID, getObjectId());

        json.put(TIMELINE_CONTAINER, c.getId());
        json.put(TIMELINE_LEAD_TECHS, getLeadTech());
        json.put(TIMELINE_NOTES, getNotes());
        json.put(TIMELINE_SCHEDULER_NOTES,getSchedulerNotes());
        json.put(TIMELINE_PROJECT_ID, getProjectId());
        json.put(TIMELINE_PROJECT_REVISION_NUM, getProjectRevisionNum());
        json.put(TIMELINE_DATE_CREATED, createdDateToString());
        json.put(TIMELINE_DATE_MODIFIED, modifiedDateToString());
        json.put(TIMELINE_CREATED_BY, getCreatedBy());
        json.put(TIMELINE_MODIFIED_BY, getModifiedBy());
        json.put(TIMELINE_CREATED_BY_NAME, getCreatedByName());
        json.put(TIMELINE_MODIFIED_BY_NAME, getModifiedByName());
        json.put(TIMELINE_QCSTATE, getQcState());
        json.put(TIMELINE_PROJECT_OBJECT_ID, getProjectObjectId());
        json.put(TIMELINE_IS_DELETED, getDeleted());
        json.put(TIMELINE_IS_DIRTY, getDirty());
        json.put(TIMELINE_IS_IN_USE, getInUse());
        json.put(TIMELINE_RC, getRc());

        if (getTimelineItems().size() > 0)
        {
            JSONArray jsonTimelineItems = new JSONArray();
            for (TimelineItem timelineItem : getTimelineItems())
            {
                jsonTimelineItems.put(timelineItem.toJSON(c));
            }
            json.put(TIMELINE_TIMELINE_ITEMS, jsonTimelineItems);
        }
        if (getTimelineProjectItems().size() > 0)
        {
            JSONArray jsonTimelineProjectItems = new JSONArray();
            for (TimelineProjectItem timelineProjectItem : getTimelineProjectItems())
            {
                jsonTimelineProjectItems.put(timelineProjectItem.toJSON(c));
            }
            json.put(TIMELINE_TIMELINE_PROJECT_ITEMS, jsonTimelineProjectItems);
        }
        if (getTimelineAnimalItems().size() > 0)
        {
            JSONArray jsonTimelineAnimalItems = new JSONArray();
            for (TimelineAnimalJunction timelineAnimalItem : getTimelineAnimalItems())
            {
                jsonTimelineAnimalItems.put(timelineAnimalItem.toJSON(c));
            }
            json.put(TIMELINE_ANIMAL_ITEMS, jsonTimelineAnimalItems);
        }
        return json;
    }

    @NotNull
    public List<Map<String, Object>> getTimelineItemList(Container c)
    {
        List<Map<String, Object>> list = new ArrayList<>();

        for (TimelineItem timelineItem : getTimelineItems())
        {
            list.add(timelineItem.toMap(c));
        }

        return list;
    }

    @NotNull
    public List<Map<String, Object>> getTimelineAnimalList(Container c)
    {
        List<Map<String, Object>> list = new ArrayList<>();

        for (TimelineAnimalJunction timelineAnimal : getTimelineAnimalItems())
        {
            list.add(timelineAnimal.toMap(c));
        }

        return list;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (!(o instanceof Timeline)) return false;
        Timeline timeline = (Timeline) o;
        return Objects.equals(_timelineId, timeline._timelineId) &&
                Objects.equals(_revisionNum, timeline._revisionNum) &&
                Objects.equals(_description, timeline._description) &&
                Objects.equals(_startDate, timeline._startDate) &&
                Objects.equals(_endDate, timeline._endDate) &&
                Objects.equals(_leadTech, timeline._leadTech) &&
                Objects.equals(_notes, timeline._notes) &&
                Objects.equals(_schedulerNotes, timeline._schedulerNotes) &&
                Objects.equals(_objectId, timeline._objectId) &&
                Objects.equals(_projectId, timeline._projectId) &&
                Objects.equals(_projectRevisionNum, timeline._projectRevisionNum) &&
                Objects.equals(_projectObjectId, timeline._projectObjectId) &&
                Objects.equals(_rc, timeline._rc) &&
                Objects.equals(_created, timeline._created) &&
                Objects.equals(_modified, timeline._modified) &&
                Objects.equals(_createdBy, timeline._createdBy) &&
                Objects.equals(_modifiedBy, timeline._modifiedBy) &&
                Objects.equals(_createdByName, timeline._createdByName) &&
                Objects.equals(_modifiedByName, timeline._modifiedByName) &&
                Objects.equals(_qcState, timeline._qcState) &&
                Objects.equals(_isDeleted, timeline._isDeleted) &&
                Objects.equals(_isDirty, timeline._isDirty) &&
                Objects.equals(_isInUse, timeline._isInUse) &&
                Objects.equals(_timelineItems, timeline._timelineItems) &&
                Objects.equals(_timelineProjectItems, timeline._timelineProjectItems) &&
                Objects.equals(_timelineAnimalItems, timeline._timelineAnimalItems);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_timelineId, _revisionNum, _description, _startDate, _endDate, _leadTech, _notes, _schedulerNotes, _objectId, _projectId, _projectRevisionNum, _projectObjectId, _rc, _created, _modified, _createdBy, _modifiedBy, _createdByName, _modifiedByName, _qcState, _isDeleted, _isDirty, _isInUse, _timelineItems, _timelineProjectItems, _timelineAnimalItems);
    }
}