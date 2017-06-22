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
 * Created by lkacimi on 4/13/2017.
 */
public class Institution
{

    private String institutionName;
    private String shortName;

    private Integer institutionId;

    private String city;

    private String state;
    private String affiliate;
    private String webSite;

    private String sort;
    private String filter;

    public Integer getInstitutionId()
    {
        return institutionId;
    }

    public void setInstitutionId(Integer institutionId)
    {
        this.institutionId = institutionId;
    }


    public String getInstitutionName()
    {
        return institutionName;
    }

    public void setInstitutionName(String institutionName)
    {
        this.institutionName = institutionName;
    }

    public String getShortName()
    {
        return shortName;
    }

    public void setShortName(String shortName)
    {
        this.shortName = shortName;
    }

    public String getCity()
    {
        return city;
    }

    public void setCity(String city)
    {
        this.city = city;
    }

    public String getState()
    {
        return state;
    }

    public void setState(String state)
    {
        this.state = state;
    }

    public String getAffiliate()
    {
        return affiliate;
    }

    public void setAffiliate(String affiliate)
    {
        this.affiliate = affiliate;
    }

    public String getWebSite()
    {
        return webSite;
    }

    public void setWebSite(String webSite)
    {
        this.webSite = webSite;
    }

    public String getSort()
    {
        return sort;
    }

    public void setSort(String sort)
    {
        this.sort = sort;
    }

    public String getFilter()
    {
        return filter;
    }

    public void setFilter(String filter)
    {
        this.filter = filter;
    }

    public JSONObject toJSON()
    {
        return new JSONObject(this);

    }
}
