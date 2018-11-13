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

/**
 * Created by lkacimi on 4/18/2017.
 */
public class Veterinarian
{
    private Integer vetId;
    private Integer displayName;
    private String emailAddress;
    private String status;

    public Veterinarian()
    {

    }

    public Integer getVetId()
    {
        return vetId;
    }

    public void setVetId(Integer vetId)
    {
        this.vetId = vetId;
    }

    public Integer getDisplayName()
    {
        return displayName;
    }

    public void setDisplayName(Integer displayName)
    {
        this.displayName = displayName;
    }

    public String getEmailAddress()
    {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress)
    {
        this.emailAddress = emailAddress;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }
}
