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

/**
 * Created by lkacimi on 3/14/2017.
 */
public class AnimalSpecies extends Entity
{
    private String speciesCode;
    private String arcSpeciesCode;
    private String common;
    private String scientificName;

    public AnimalSpecies()
    {

    }

    public String getSpeciesCode()
    {
        return speciesCode;
    }

    public void setSpeciesCode(String speciesCode)
    {
        this.speciesCode = speciesCode;
    }

    public String getArcSpeciesCode()
    {
        return arcSpeciesCode;
    }

    public void setArcSpeciesCode(String arcSpeciesCode)
    {
        this.arcSpeciesCode = arcSpeciesCode;
    }

    public String getCommon()
    {
        return common;
    }

    public void setCommon(String common)
    {
        this.common = common;
    }

    public String getScientificName()
    {
        return scientificName;
    }

    public void setScientificName(String scientificName)
    {
        this.scientificName = scientificName;
    }

    public JSONObject toJSON()
    {
        JSONObject json = new JSONObject();
        json.put("arcSpeciesCode", this.arcSpeciesCode);
        json.put("speciesName", this.arcSpeciesCode + " (" + this.getCommon().trim() + ")");
        return json;
    }
}
