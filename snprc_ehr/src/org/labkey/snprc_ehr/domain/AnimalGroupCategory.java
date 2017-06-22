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

/**
 * Created by lkacimi on 3/14/2017.
 */
public class AnimalGroupCategory
{
    private Integer categoryCode;
    private String description;
    private String comment;
    private String displayable;
    private String species;
    private String sex;
    private String enforceExclusivity;
    private String allowFutureDate;
    private Integer sortOrder;


    private String sort;

    private int start;
    private int limit;

    private String filter;

    public AnimalGroupCategory()
    {

    }


    public Integer getCategoryCode()
    {
        return categoryCode;
    }

    public void setCategoryCode(Integer categoryCode)
    {
        this.categoryCode = categoryCode;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public String getComment()
    {
        return comment;
    }

    public void setComment(String comment)
    {
        this.comment = comment;
    }

    public String getDisplayable()
    {
        return displayable;
    }

    public void setDisplayable(String displayable)
    {
        this.displayable = displayable;
    }

    public String getSpecies()
    {
        return species;
    }

    public void setSpecies(String species)
    {
        this.species = species;
    }

    public String getSex()
    {
        return sex;
    }

    public void setSex(String sex)
    {
        this.sex = sex;
    }

    public String getEnforceExclusivity()
    {
        return enforceExclusivity;
    }

    public void setEnforceExclusivity(String enforceExclusivity)
    {
        this.enforceExclusivity = enforceExclusivity;
    }

    public String getAllowFutureDate()
    {
        return allowFutureDate;
    }

    public void setAllowFutureDate(String allowFutureDate)
    {
        this.allowFutureDate = allowFutureDate;
    }

    public Integer getSortOrder()
    {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder)
    {
        this.sortOrder = sortOrder;
    }


    public JSONObject toJSON()
    {
        return new JSONObject(this);

    }

    public String getSort()
    {
        return sort;
    }

    public void setSort(String sort)
    {
        this.sort = sort;
    }

    public int getStart()
    {
        return start;
    }

    public void setStart(int start)
    {
        this.start = start;
    }

    public int getLimit()
    {
        return limit;
    }

    public void setLimit(int limit)
    {
        this.limit = limit;
    }

    public String getFilter()
    {
        return filter;
    }

    public void setFilter(String filter)
    {
        this.filter = filter;
    }
}
