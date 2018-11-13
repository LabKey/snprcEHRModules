/*
 * Copyright (c) 2016 LabKey Corporation
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
package org.labkey.snprc_ehr.notification;

/**
 * Created by: jeckels
 * Date: 6/29/16
 */
public class SampleSSRSNotification extends AbstractSSRSNotification
{
    public SampleSSRSNotification()
    {
        super("%2fbeta%2fLabkey_xml%2flabkey_xml", "Daily Report", "Please see attached report.", Format.PDF);
    }

    @Override
    public String getName()
    {
        return "SampleSSRS";
    }

    @Override
    public String getCategory()
    {
        return "SSRS";
    }

    @Override
    public String getCronString()
    {
        return "0 6 * * * ?";
    }

    @Override
    public String getScheduleDescription()
    {
        return "every day at 6AM";
    }

    @Override
    public String getDescription()
    {
        return "SSRS-based notification 1";
    }

}
