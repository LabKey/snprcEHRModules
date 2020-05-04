/*
 * Copyright (c) 2014 LabKey Corporation
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

package org.labkey.snprc_ehr;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;

import java.util.Map;

public class SNPRC_EHRManager
{
    private static final SNPRC_EHRManager _instance = new SNPRC_EHRManager();

    private SNPRC_EHRManager()
    {
        // prevent external construction with a private default constructor
    }

    public static SNPRC_EHRManager get()
    {
        return _instance;
    }

    /**
     * Get the user's name from the user's id
     *
     * @param userId = user id to be looked up
     * @return Users display name
     */
    public static String getUserDisplayName(Integer userId)
    {
        String userName = "";
        DbSchema schema = DbSchema.get("core", DbSchemaType.Module);
        TableInfo ti = schema.getTable("Users");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("UserId"), userId, CompareType.EQUAL);
        // should only get one row back
        Map<String, Object> user = new TableSelector(ti, filter, null).getMap();
        if (user != null)
        {
            userName = (String) user.get("DisplayName");
        }
        return userName;
    }
}