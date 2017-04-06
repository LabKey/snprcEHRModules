package org.labkey.snprc_ehr.domain;

import org.json.JSONObject;
import org.labkey.api.data.Entity;

/**
 * Created by lkacimi on 3/14/2017.
 */
public class AnimalSpecies extends Entity
{
    private String species_code;
    private String arc_species_code;
    private String common;
    private String scientific_name;

    public AnimalSpecies()
    {

    }

    public String getArc_species_code()
    {
        return arc_species_code;
    }

    public void setArc_species_code(String arc_species_code)
    {
        this.arc_species_code = arc_species_code;
    }

    public String getCommon()
    {
        return common;
    }

    public void setCommon(String common)
    {
        this.common = common;
    }

    public String getScientific_name()
    {
        return scientific_name;
    }

    public void setScientific_name(String scientific_name)
    {
        this.scientific_name = scientific_name;
    }

    public String getSpecies_code()
    {
        return species_code;
    }

    public void setSpecies_code(String species_code)
    {
        this.species_code = species_code;
    }

    public JSONObject toJSON()
    {
        JSONObject json = new JSONObject();
        json.put("arc_species_code", this.arc_species_code);
        json.put("species_name", this.arc_species_code + " (" + this.common.trim() + ")");
        return json;
    }


}
