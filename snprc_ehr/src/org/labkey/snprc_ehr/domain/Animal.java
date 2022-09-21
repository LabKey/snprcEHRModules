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

import org.json.old.JSONObject;

/**
 * Created by lkacimi on 4/11/2017.
 */
public class Animal
{
    private String id;
    private String text;
    private String participantid;
    private String sex;

    private String viewBy;

    public String getViewBy()
    {
        return viewBy;
    }

    public void setViewBy(String viewBy)
    {
        this.viewBy = viewBy;
    }

    private boolean leaf = true;

    public String getText()
    {
        return text;
    }

    public void setText(String text)
    {
        this.text = text;
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
        json.put("text", this.getText() != null ? this.getText() : this.getId());
        json.put("sex", this.getSex());
        json.put("leaf", this.isLeaf());
        json.put("cls", "animal");

        json.put("iconCls", "animal " + (this.getSex() != null ? (this.getSex().equalsIgnoreCase("F") ? "female" : ((this.getSex().equalsIgnoreCase("M") ? "male" : "unknown-sex"))) : "unknown-sex"));
        return json;
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
        Animal animal = (Animal) other;

        return this.getParticipantid() != null ? this.getParticipantid().equals(animal.getId()) : this.getId().equals(animal.getId());

    }

}
