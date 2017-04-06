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

    private int category_code;
    private String name;
    private Date date;
    private Date enddate;
    private String comment;
    private String sort_order;

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

    public int getCategory_code()
    {
        return category_code;
    }

    public void setCategory_code(int category_code)
    {
        this.category_code = category_code;
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

    public Date getEnddate()
    {
        return enddate;
    }

    public void setEnddate(Date enddate)
    {
        this.enddate = enddate;
    }

    public String getComment()
    {
        return comment;
    }

    public void setComment(String comment)
    {
        this.comment = comment;
    }

    public String getSort_order()
    {
        return sort_order;
    }

    public void setSort_order(String sort_order)
    {
        this.sort_order = sort_order;
    }

    public JSONObject toJSON()
    {
        JSONObject json = new JSONObject();
        json.put("code", this.getCode());
        json.put("category_code", this.getCategory_code());
        json.put("name", this.getName());
        json.put("date", this.getDate());
        json.put("enddate", this.getEnddate());
        json.put("comment", this.getComment());
        json.put("sort_order", this.getSort_order());
        return json;
    }
}
