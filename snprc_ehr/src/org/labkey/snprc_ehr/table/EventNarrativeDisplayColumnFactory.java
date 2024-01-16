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
        return new EventNarrativeDisplayColumnFactory.EventNarrativeDisplayColumn(colInfo);
    }

    public class EventNarrativeDisplayColumn extends DataColumn
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