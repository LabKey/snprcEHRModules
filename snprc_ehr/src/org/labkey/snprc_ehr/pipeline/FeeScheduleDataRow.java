package org.labkey.snprc_ehr.pipeline;

import org.labkey.api.data.Container;

import java.util.Date;
import java.util.Map;

public class FeeScheduleDataRow
{

/**
 * User: thawkins
 * Date: December 27, 2017
 */
    private String _species;
    private String _description;
    private int _activityId;
    private Map<String, Double> _cost;
    private int _rowId;

    private String _fileName;
    private Date _parseDate;
    private Container _container;
    private String _lsid;


    public FeeScheduleDataRow()
    {
    }

    public String getSpecies()
    {
        return _species;
    }

    public void setSpecies(String species)
    {
        _species = species;
    }

    public String getDescription()
    {
        return _description;
    }

    public void setDescription(String description)
    {
        _description = description;
    }

    public int getActivityId()
    {
        return _activityId;
    }

    public void setActivityId(int activityId)
    {
        _activityId = activityId;
    }

    public Map<String, Double> getCost()
    {
        return _cost;
    }

    public void setCost(Map<String, Double> cost)
    {
        _cost = cost;
    }

    public int getRowId()
    {
        return _rowId;
    }

    public void setRowId(int rowId)
    {
        _rowId = rowId;
    }

    public String getFileName()
    {
        return _fileName;
    }

    public void setFileName(String fileName)
    {
        _fileName = fileName;
    }

    public Date getParseDate()
    {
        return _parseDate;
    }

    public void setParseDate(Date parseDate)
    {
        _parseDate = parseDate;
    }

    public Container getContainer()
    {
        return _container;
    }

    public void setContainer(Container container)
    {
        _container = container;
    }

    public String getLsid()
    {
        return _lsid;
    }

    public void setLsid(String lsid)
    {
        _lsid = lsid;
    }
}
