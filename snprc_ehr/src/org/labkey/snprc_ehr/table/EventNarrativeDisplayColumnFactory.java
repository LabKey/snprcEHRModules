/*
 * Copyright (c) 2024-2026 LabKey Corporation
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
package org.labkey.snprc_ehr.table;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.RenderContext;
import org.labkey.api.snd.PlainTextNarrativeDisplayColumn;

public class EventNarrativeDisplayColumnFactory implements DisplayColumnFactory
{
    @Override
    public DisplayColumn createRenderer(ColumnInfo colInfo)
    {
        return new EventNarrativeDisplayColumn(colInfo);
    }

    public static class EventNarrativeDisplayColumn extends DataColumn
    {
        public EventNarrativeDisplayColumn(ColumnInfo col)
        {
            super(col, false);
        }

        @Override
        public Object getExportCompatibleValue(RenderContext ctx)
        {
            return PlainTextNarrativeDisplayColumn.removeHtmlTagsFromNarrative((String)ctx.get(getBoundColumn().getName()));
        }
    }
}