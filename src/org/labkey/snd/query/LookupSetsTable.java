/*
 * Copyright (c) 2018 LabKey Corporation
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
package org.labkey.snd.query;

import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.dataiterator.DataIteratorBuilder;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.SimpleQueryUpdateService;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.snd.SNDManager;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Created by marty on 9/17/2017.
 */
public class LookupSetsTable extends SimpleUserSchema.SimpleTable
{
    private static final String CACHE_KEY = LookupSetsTable.class.getName() + "||values";
    private static final String SETNAME_COL = "SetName";
    private static final String LABEL_COL = "Label";
    private static final String DESCRIPTION_COL = "Description";
    private static final String LOOKUPSETID_COL = "LookupSetId";
    private Integer _lookupSetId;


    public LookupSetsTable(UserSchema schema, TableInfo table, String setName, Map<String, Object> map)
    {
        super(schema, table);

        _lookupSetId = (Integer) map.get(LOOKUPSETID_COL);

        if (map.containsKey(LABEL_COL))
            setTitle((String)map.get(LABEL_COL));

        if (map.containsKey(DESCRIPTION_COL))
            setDescription((String) map.get(DESCRIPTION_COL));

    }

    public static String getCacheKey(Container c)
    {
        return CACHE_KEY + "||" + c.getId();
    }

    public LookupSetsTable init()
    {
        super.init();

        ColumnInfo col = getRealTable().getColumn(LOOKUPSETID_COL);
        addCondition(col, _lookupSetId);

        return this;
    }

}
