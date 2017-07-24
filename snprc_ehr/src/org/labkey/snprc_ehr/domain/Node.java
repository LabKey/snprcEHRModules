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
 * Created by lkacimi on 4/10/2017.
 */
public class Node
{

    private String node;

    private String text;

    public String getText()
    {
        return text;
    }

    public void setText(String text)
    {
        this.text = text;
    }

    private String nodeClass;

    public String getNodeClass()
    {
        return nodeClass;
    }

    public void setNodeClass(String nodeClass)
    {
        this.nodeClass = nodeClass;
    }

    public Node()
    {

    }

    private String viewBy;

    public String getViewBy()
    {
        return viewBy;
    }

    public void setViewBy(String viewBy)
    {
        this.viewBy = viewBy;
    }

    public Node(String nodeIdentifier)
    {
        this.node = nodeIdentifier;
    }



    public String getNode()
    {
        return node;
    }

    public void setNode(String node)
    {
        this.node = node;
    }

    public JSONObject toJSON()
    {
        JSONObject json = new JSONObject();
        json.put("id", this.getNode());
        json.put("text", this.getText());
        json.put("leaf", false);
        json.put("cls", this.getNodeClass() != null ? this.getNodeClass() : "location");
        return json;
    }

    @Override
    public int hashCode()
    {
        return this.node.hashCode();
    }

    @Override
    public boolean equals(Object obj)
    {
        if (this == obj) return true;
        if (obj == null || (this.getClass() != obj.getClass()))
        {
            return false;
        }

        if (this.getNode() == null)
        {
            return false;
        }
        return ((Node) obj).getNode().equals(this.getNode());
    }
}
