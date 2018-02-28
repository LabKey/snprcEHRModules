package org.labkey.snprc_ehr.pipeline;

import java.util.List;

public class FeeScheduleImportForm //extends PipelinePathForm
{
    private String _filePath = "";
    private String _name = "";
    private String _size = "";
    private String _date = "";
    private String _navTrail = "";
    private String _tabPage = "";
    private String _path = "";

    private List<String> _availableTabPages;


    public FeeScheduleImportForm()
    {
    }

    public FeeScheduleImportForm(String filePath, String name, String size, String date, String navTrail, String tabPage)
    {
        _filePath = filePath;
        _name = name;
        _size = size;
        _date = date;
        _navTrail = navTrail;
        _tabPage = tabPage;
    }

    public List<String> getAvailableTabPages()
    {
        return _availableTabPages;
    }

    public void setAvailableTabPages(List<String> availableTabPages)
    {
        _availableTabPages = availableTabPages;
    }

    public String getSize()
    {
        return _size;
    }

    public void setSize(String size)
    {
        _size = size;
    }

    public String getDate()
    {
        return _date;
    }

    public void setDate(String date)
    {
        _date = date;
    }

    public String getNavtrail()
    {
        return " - " + _name;
    }

    public void setNavTrail(String navTrail)
    {
        _navTrail = navTrail;
    }

    public String getFilePath()
    {
        return _filePath;
    }

    public void setFilePath(String filePath)
    {
        _filePath = filePath;
    }

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        this._name = name;
    }

    public String getTabPage()
    {
        return _tabPage;
    }

    public void setTabPage(String tabPage)
    {
        _tabPage = tabPage;
    }

    public String getPath()
    {
        return _path;
    }

    public void setPath(String path)
    {
        _path = path;
    }
}

