package org.labkey.snprc_ehr.domain;

import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;

import java.util.Map;
import java.util.Objects;

public class Counters
{
    private Integer _rowId;
    private String _name;
    private Integer _value;
    private String _container;
    private String _objectId;

    public static final String COUNTERS_ROW_ID = "RowId";
    public static final String COUNTERS_NAME = "Name";
    public static final String COUNTERS_VALUE = "Value";
    public static final String COUNTERS_CONTAINER = "Container";
    public static final String COUNTERS_OBJECT_ID = "ObjectId";

    public Counters()
    {

    }

    public Counters(String container, String name, Integer value)
    {
        this.setContainer(container);
        this.setName(name);
        this.setValue(value);
    }

    public Counters(Container c, JSONObject json) throws RuntimeException
    {
        try
        {
            this.setRowId(json.has(COUNTERS_ROW_ID) && !json.isNull(COUNTERS_ROW_ID) ? json.getInt(COUNTERS_ROW_ID) : null);
            this.setName(json.has(COUNTERS_NAME) && !json.isNull(COUNTERS_NAME) ? json.getString(COUNTERS_NAME) : null);
            this.setValue(json.has(COUNTERS_VALUE) && !json.isNull(COUNTERS_VALUE) ? json.getInt(COUNTERS_VALUE) : null);
            this.setContainer(json.has(COUNTERS_CONTAINER) && !json.isNull(COUNTERS_CONTAINER) ? json.getString(COUNTERS_CONTAINER) : null);
            this.setObjectId(json.has(COUNTERS_OBJECT_ID) && !json.isNull(COUNTERS_OBJECT_ID) ? json.getString(COUNTERS_OBJECT_ID) : null);
        }
        catch (Exception e)
        {
            throw new RuntimeException ( e.getMessage() ) ;
        }
    }
    @NotNull
    public JSONObject toJSON(Container c, User u)
    {
        JSONObject json = new JSONObject();

        if (getRowId() != null)
            json.put(COUNTERS_ROW_ID, getRowId());
        if (getObjectId() != null)
            json.put(COUNTERS_OBJECT_ID, getObjectId());
        json.put(COUNTERS_NAME, getName());
        json.put(COUNTERS_VALUE, getName());
        json.put(COUNTERS_CONTAINER, c.getId());

        return json;
    }

    @NotNull
    public Map<String, Object> toMap()
    {
        Map<String, Object> values = new ArrayListMap<>();
        values.put(COUNTERS_ROW_ID, getRowId());
        values.put(COUNTERS_NAME, getName());
        values.put(COUNTERS_VALUE, getValue());
        values.put(COUNTERS_OBJECT_ID, getObjectId());
        values.put(COUNTERS_CONTAINER, getContainer());

        return values;
    }

    public Integer getRowId()
    {
        return _rowId;
    }

    public void setRowId(Integer rowId)
    {
        _rowId = rowId;
    }

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        _name = name;
    }

    public Integer getValue()
    {
        return _value;
    }

    public void setValue(Integer value)
    {
        _value = value;
    }

    public String getContainer()
    {
        return _container;
    }

    public void setContainer(String container)
    {
        _container = container;
    }

    public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Counters counters = (Counters) o;
        return _rowId.equals(counters._rowId) &&
            _name.equals(counters._name) &&
            _value.equals(counters._value) &&
            _container.equals(counters._container) &&
            Objects.equals(_objectId, counters._objectId);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_rowId, _name, _value, _container, _objectId);
    }
}

