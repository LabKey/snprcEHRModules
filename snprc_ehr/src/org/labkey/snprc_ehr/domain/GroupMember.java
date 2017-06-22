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
 * Created by lkacimi on 3/23/2017.
 */
public class GroupMember extends Entity
{
    private int dsrowid;
    private String participantid;
    private Date date;
    private Date enddate;
    private int groupid;
    private String description;
    private String remark;
    private String id;


    private String objectid;

    private boolean activeOnly;


    public GroupMember()
    {

    }

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

    public int getGroupid()
    {
        return groupid;
    }

    public void setGroupid(int groupid)
    {
        this.groupid = groupid;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public String getRemark()
    {
        return remark;
    }

    public void setRemark(String remark)
    {
        this.remark = remark;
    }

    public int getDsrowid()
    {
        return dsrowid;
    }

    public void setDsrowid(int dsrowid)
    {
        this.dsrowid = dsrowid;
    }

    public JSONObject toJSON()
    {

        JSONObject json = new JSONObject();
        json.put("participantid", this.getParticipantid());
        json.put("id", this.getId());
        json.put("groupid", this.getGroupid());
        json.put("date", this.getDate());
        json.put("enddate", this.getEnddate());
        json.put("description", this.getDescription());
        return json;

    }

    public String getObjectid()
    {
        return objectid;
    }

    public void setObjectid(String objectid)
    {
        this.objectid = objectid;
    }

    public boolean isActiveOnly()
    {
        return activeOnly;
    }

    public void setActiveOnly(boolean activeOnly)
    {
        this.activeOnly = activeOnly;
    }

    @Override
    public int hashCode()
    {
        return this.getParticipantid() != null ? this.getParticipantid().hashCode() : this.getId().hashCode();
    }

    @Override
    public boolean equals(Object other)
    {

        if (this == other) return true;
        if (other == null || (this.getClass() != other.getClass()))
        {
            return false;
        }
        GroupMember groupMember = (GroupMember) other;

        return this.getParticipantid() != null ? this.getParticipantid().equals(groupMember.getId()) : this.getId().equals(groupMember.getId());

    }


}
