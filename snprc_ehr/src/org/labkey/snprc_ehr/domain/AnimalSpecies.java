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
