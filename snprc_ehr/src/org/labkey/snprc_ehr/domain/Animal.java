package org.labkey.snprc_ehr.domain;

import org.json.JSONObject;

/**
 * Created by lkacimi on 4/11/2017.
 */
public class Animal
{
    private String id;
    private String participantid;
    private String sex;

    private boolean leaf = true;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public String getParticipantid()
    {
        return participantid;
    }

    public void setParticipantid(String participantid)
    {
        this.participantid = participantid;
    }

    public boolean isLeaf()
    {
        return leaf;
    }

    public void setLeaf(boolean leaf)
    {
        this.leaf = leaf;
    }

    public String getSex()
    {
        return sex;
    }

    public void setSex(String sex)
    {
        this.sex = sex;
    }

    public JSONObject toJSON()
    {
        JSONObject json = new JSONObject();
        json.put("id", this.getId());
        json.put("text", this.getId());
        json.put("sex", this.getSex());
        json.put("leaf", this.isLeaf());
        json.put("cls", "animal");
        json.put("iconCls", "animal " + (this.getSex() != null ? (this.getSex().equalsIgnoreCase("F") ? "female" : "male") : ""));
        return json;
    }
}
