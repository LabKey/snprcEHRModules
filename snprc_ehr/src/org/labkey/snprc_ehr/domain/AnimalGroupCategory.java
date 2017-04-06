package org.labkey.snprc_ehr.domain;

import org.json.JSONObject;
import org.labkey.api.data.Entity;

/**
 * Created by lkacimi on 3/14/2017.
 */
public class AnimalGroupCategory extends Entity
{
    private Integer category_code;
    private String description;
    private String comment;
    private String displayable;
    private String species;
    private String sex;
    private String enforce_exclusivity;
    private String allow_future_date;
    private Integer sort_order;
    private String objectId;

    private String sort;

    private int start;
    private int limit;

    private String filter;

    public AnimalGroupCategory()
    {

    }


    public Integer getCategory_code()
    {
        return category_code;
    }

    public void setCategory_code(Integer category_code)
    {
        this.category_code = category_code;
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

    public String getEnforce_exclusivity()
    {
        return enforce_exclusivity;
    }

    public void setEnforce_exclusivity(String enforce_exclusivity)
    {
        this.enforce_exclusivity = enforce_exclusivity;
    }

    public String getAllow_future_date()
    {
        return allow_future_date;
    }

    public void setAllow_future_date(String allow_future_date)
    {
        this.allow_future_date = allow_future_date;
    }

    public Integer getSort_order()
    {
        return sort_order;
    }

    public void setSort_order(Integer sort_order)
    {
        this.sort_order = sort_order;
    }

    public String getObjectId()
    {
        return objectId;
    }

    public void setObjectId(String objectId)
    {
        this.objectId = objectId;
    }

    public JSONObject toJSON()
    {
        JSONObject json = new JSONObject();
        json.put("category_code", this.getCategory_code());
        json.put("description", this.getDescription());
        json.put("comment", this.getComment());
        json.put("displayable", this.getDisplayable());
        json.put("species", this.getSpecies());
        json.put("sex", this.getSex());
        json.put("enforce_exclusivity", this.getEnforce_exclusivity());
        json.put("allow_future_date", this.getAllow_future_date());
        json.put("sort_order", this.getSort_order());
        return json;
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
