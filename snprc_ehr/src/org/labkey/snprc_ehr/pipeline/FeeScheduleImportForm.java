/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
        _name = name;
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

