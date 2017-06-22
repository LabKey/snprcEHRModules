/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.labkey.snprc_ehr.domain;

import org.json.JSONObject;
import org.labkey.api.data.Entity;

import java.util.Date;

/**
 * Created by lkacimi on 3/20/2017.
 */
public class AnimalGroup extends Entity
{
    private int code;

    private int categoryCode;
    private String name;
    private Date date;
    private Date endDate;
    private String comment;
    private String sortOrder;

    public AnimalGroup()
    {

    }

    public int getCode()
    {
        return code;
    }

    public void setCode(int code)
    {
        this.code = code;
    }

    public int getCategoryCode()
    {
        return categoryCode;
    }

    public void setCategoryCode(int categoryCode)
    {
        this.categoryCode = categoryCode;
    }

    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    public Date getDate()
    {
        return date;
    }

    public void setDate(Date date)
    {
        this.date = date;
    }

    public Date getEndDate()
    {
        return endDate;
    }

    public void setEnddate(Date endDate)
    {
        this.endDate = endDate;
    }

    public String getComment()
    {
        return comment;
    }

    public void setComment(String comment)
    {
        this.comment = comment;
    }

    public String getSortOrder()
    {
        return sortOrder;
    }

    public void setSortOrder(String sortOrder)
    {
        this.sortOrder = sortOrder;
    }

    public JSONObject toJSON()
    {
        return new JSONObject(this);
    }
}
