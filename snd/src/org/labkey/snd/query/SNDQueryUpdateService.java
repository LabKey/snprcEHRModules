/*
 * Copyright (c) 2021-2026 LabKey Corporation
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
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.dataiterator.DataIteratorBuilder;
import org.labkey.api.dataiterator.DataIteratorContext;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.SimpleQueryUpdateService;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;

import java.util.Map;

public class SNDQueryUpdateService extends SimpleQueryUpdateService
{
    public SNDQueryUpdateService(SimpleUserSchema.SimpleTable queryTable, TableInfo dbTable)
    {
        super(queryTable, dbTable);
    }

    // Most of the SND tables have custom operations associated with mergeRows or importRows. loadRows also needs
    // to execute that custom logic.  For example when rows are loaded via ETL merge, loadRows is called
    // and the custom table logic for merging should be executed.
    @Override
    public int loadRows(User user, Container container, DataIteratorBuilder rows, DataIteratorContext context, @Nullable Map<String, Object> extraScriptContext)
    {
        if (context.getInsertOption() == QueryUpdateService.InsertOption.MERGE || context.getInsertOption() == QueryUpdateService.InsertOption.REPLACE)
        {
            return mergeRows(user, container, rows, context.getErrors(), context.getConfigParameters(), extraScriptContext);
        }
        else
        {
            return importRows(user, container, rows, context.getErrors(), context.getConfigParameters(), extraScriptContext);
        }
    }
}
